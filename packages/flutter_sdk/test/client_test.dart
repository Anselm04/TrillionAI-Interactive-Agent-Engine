import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';
import 'package:trillionai_interactive_sdk/trillionai_interactive_sdk.dart';

void main() {
  test('authenticated session lifecycle and typed response', () async {
    final paths = <String>[];
    final client = InteractiveEngineClient(endpoint:Uri.parse('http://127.0.0.1:3000'),
      token:() async => 'local-token', client:MockClient((request) async {
        expect(request.headers['Authorization'],'Bearer local-token');
        expect(request.followRedirects,false);
        paths.add('${request.method} ${request.url.path}');
        if (request.url.path == '/v1/sessions') return http.Response('{"id":"abc"}',201);
        if (request.method == 'DELETE') return http.Response('{"deleted":true}',200);
        expect(jsonDecode(request.body)['text'],'hello');
        return http.Response('{"version":1,"type":"assistant.message","sessionId":"abc","sequence":1,"text":"reply","mode":"local-demo"}',200);
      }));
    final id = await client.createSession();
    final reply = await client.sendMessage(id,'hello');
    expect(reply.text,'reply');
    expect(reply.mode,'local-demo');
    await client.deleteSession(id);
    expect(paths,['POST /v1/sessions','POST /v1/sessions/abc/messages','DELETE /v1/sessions/abc']);
    client.close();
    await expectLater(client.createSession(),throwsStateError);
  });
  test('rejects insecure remote origins and invalid message metadata',(){
    expect(()=>InteractiveEngineClient(endpoint:Uri.parse('http://example.com'),token:()async=>'x'),throwsArgumentError);
    expect(()=>AgentMessage.fromJson({'version':2},'abc'),throwsFormatException);
  });
  test('rejects unauthorized and malformed responses',()async{
    final client=InteractiveEngineClient(endpoint:Uri.parse('https://example.com'),token:()async=>'x',
      client:MockClient((_)async=>http.Response('denied',401)));
    await expectLater(client.createSession(),throwsA(isA<EngineException>().having((e)=>e.status,'status',401)));
    client.close();
  });
}
