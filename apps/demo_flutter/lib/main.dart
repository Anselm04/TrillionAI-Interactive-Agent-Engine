import 'package:material_ui/material_ui.dart';
import 'package:trillionai_interactive_sdk/trillionai_interactive_sdk.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'avatar.dart';

void main() => runApp(const MaterialApp(home: Demo(), debugShowCheckedModeBanner: false));
class Demo extends StatefulWidget {
  const Demo({super.key});
  @override State<Demo> createState()=>_DemoState();
}
class _DemoState extends State<Demo> {
  final input=TextEditingController();
  final token=TextEditingController();
  final voice=FlutterTts();
  final speech=SpeechToText();
  late final client=InteractiveEngineClient(endpoint:Uri.parse(base),token:() async=>token.text);
  String? session;
  String state='idle', reply='Connect using your local engine token.';
  bool busy=false, listening=false;
  int generation=0;
  String mode='Engine not connected';
  Future<void> stopPlayback() async {
    if(state!='speaking')return;
    generation++;
    try { await voice.stop(); } finally { if(mounted)setState((){busy=false;state='idle';}); }
  }
  static const base=String.fromEnvironment('ENGINE_URL', defaultValue:'http://127.0.0.1:3000');
  Future<void> send() async {
    if(busy || listening || input.text.trim().isEmpty) return;
    final turn=++generation;
    setState((){busy=true;state='thinking';});
    try{
      session ??= await client.createSession();
      final response=await client.sendMessage(session!,input.text);
      if(!mounted||turn!=generation)return;
      setState((){reply=response.text;mode=response.mode;state='speaking';});
      await voice.awaitSpeakCompletion(true);
      if(!mounted||turn!=generation)return;
      await voice.speak(reply);
    }catch(e){if(e is EngineException && e.status==404)session=null;if(mounted&&turn==generation)setState(()=>reply='Engine or voice unavailable. Check local configuration.');}
    finally{if(mounted&&turn==generation)setState((){busy=false;state='idle';});}
  }
  Future<void> listen() async {
    if(busy)return;
    try{
      if(listening){await speech.stop();if(mounted)setState((){listening=false;state='idle';});return;}
      final available=await speech.initialize(onStatus:(s){if(mounted&&(s=='done'||s=='notListening'))setState((){listening=false;state='idle';});},onError:(e){if(mounted)setState((){listening=false;state='idle';reply='Microphone recognition unavailable.';});});
      if(!mounted)return;
      if(!available){setState(()=>reply='Speech recognition unavailable on this device.');return;}
      setState((){listening=true;state='listening';});
      await speech.listen(onResult:(r){if(mounted)input.text=r.recognizedWords;});
    }catch(e){if(mounted)setState((){listening=false;state='idle';reply='Microphone unavailable.';});}
  }
  @override void dispose(){speech.cancel();voice.stop();client.close();input.dispose();token.dispose();super.dispose();}
  @override Widget build(BuildContext context)=>Scaffold(
    backgroundColor:const Color(0xfff4f8fc),appBar:AppBar(title:const Text('TrillionAI Interactive Engine')),
    body:Center(child:ConstrainedBox(constraints:const BoxConstraints(maxWidth:560),child:ListView(padding:const EdgeInsets.all(24),children:[
      AgentAvatar(state:state),Center(child:Text(state.toUpperCase())),
      Text(mode=='local-demo'?'Local demonstration · no model connected':mode),
      const SizedBox(height:16),TextField(controller:token,obscureText:true,enabled:!busy&&!listening,decoration:const InputDecoration(labelText:'Local engine token'),onChanged:(_)=>session=null),
      const SizedBox(height:16),SelectableText(reply),
      TextField(controller:input,maxLength:2000,decoration:const InputDecoration(labelText:'Message')),
      const Text('Microphone uses device speech services; audio may be processed by your platform provider. Tap only to consent.'),
      Wrap(spacing:12,children:[FilledButton(onPressed:busy||listening?null:send,child:const Text('Send')),OutlinedButton(onPressed:busy?null:listen,child:Text(listening?'Stop microphone':'Use microphone')),OutlinedButton(onPressed:state=='speaking'?stopPlayback:null,child:const Text('Stop speech'))])
    ]))));
}
