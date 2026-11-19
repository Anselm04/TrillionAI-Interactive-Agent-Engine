import 'dart:convert';
import 'package:http/http.dart' as http;

class EngineException implements Exception {
  final int status;
  final String message;
  const EngineException(this.status, this.message);
  @override
  String toString() => 'EngineException($status): $message';
}

class AgentMessage {
  final String sessionId, text, mode;
  final int sequence;
  const AgentMessage({required this.sessionId, required this.text, required this.mode, required this.sequence});
  factory AgentMessage.fromJson(Map<String,dynamic> json, String expectedSession) {
    if (json['version'] != 1 || json['type'] != 'assistant.message' ||
        json['sessionId'] != expectedSession || json['sequence'] is! int ||
        (json['sequence'] as int) < 1 || json['text'] is! String || json['mode'] is! String) {
      throw const FormatException('Invalid engine message');
    }
    return AgentMessage(sessionId: expectedSession, text: json['text'] as String,
      mode: json['mode'] as String, sequence: json['sequence'] as int);
  }
}

class InteractiveEngineClient {
  final Uri endpoint;
  final Future<String> Function() token;
  final http.Client _client;
  final bool _ownsClient;
  final Duration timeout;
  bool _closed = false;

  InteractiveEngineClient({required this.endpoint, required this.token,
    http.Client? client, this.timeout = const Duration(seconds: 15)})
    : _client = client ?? http.Client(), _ownsClient = client == null {
    final loopback = ['localhost','127.0.0.1','::1'].contains(endpoint.host);
    if (endpoint.host.isEmpty || (endpoint.scheme != 'https' && !(endpoint.scheme == 'http' && loopback)) ||
        endpoint.userInfo.isNotEmpty || endpoint.hasQuery || endpoint.hasFragment ||
        (endpoint.path.isNotEmpty && endpoint.path != '/') || timeout.inMilliseconds <= 0) {
      throw ArgumentError('Use an HTTPS origin or a local loopback HTTP origin');
    }
  }

  String _sessionPath(String id) {
    if (!RegExp(r'^[0-9a-f-]{1,64}$').hasMatch(id)) throw ArgumentError('Invalid session ID');
    return '/v1/sessions/$id';
  }

  Future<Map<String,dynamic>> _request(String method, String path, int expected, [Map<String,dynamic>? payload]) async {
    if (_closed) throw StateError('Client closed');
    final credential = await token().timeout(timeout);
    if (credential.isEmpty || credential.contains(RegExp(r'[\r\n]'))) throw StateError('Invalid credential');
    final request = http.Request(method, endpoint.replace(path:path));
    request.followRedirects = false;
    request.headers['Authorization'] = 'Bearer $credential';
    request.headers['Accept'] = 'application/json';
    if (payload != null) {
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(payload);
    }
    final response = await _client.send(request).timeout(timeout);
    if (response.statusCode != expected) {
      await response.stream.listen((_){}).cancel();
      throw EngineException(response.statusCode, 'Request rejected');
    }
    final bytes = <int>[];
    await for (final chunk in response.stream.timeout(timeout)) {
      if (bytes.length + chunk.length > 65536) throw const FormatException('Response too large');
      bytes.addAll(chunk);
    }
    final decoded = jsonDecode(utf8.decode(bytes));
    if (decoded is! Map<String,dynamic>) throw const FormatException('Expected JSON object');
    return decoded;
  }

  Future<String> createSession() async {
    final result = await _request('POST','/v1/sessions',201);
    final id = result['id'];
    if (id is! String) throw const FormatException('Invalid session');
    _sessionPath(id);
    return id;
  }

  Future<AgentMessage> sendMessage(String sessionId, String text) async {
    if (text.trim().isEmpty || text.length > 2000) throw ArgumentError('Invalid message');
    return AgentMessage.fromJson(await _request('POST','${_sessionPath(sessionId)}/messages',200,{'text':text}),sessionId);
  }

  Future<void> deleteSession(String id) async {
    final result = await _request('DELETE',_sessionPath(id),200);
    if (result['deleted'] != true) throw const FormatException('Deletion not confirmed');
  }

  void close() {
    _closed = true;
    if (_ownsClient) _client.close();
  }
}
