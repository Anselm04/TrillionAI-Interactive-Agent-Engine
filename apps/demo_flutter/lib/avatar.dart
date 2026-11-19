import 'dart:math' as math;
import 'package:material_ui/material_ui.dart';
import 'avatar/characters.dart';
import 'avatar/renderer.dart';

class AgentAvatar extends StatefulWidget {
  final String state;
  const AgentAvatar({super.key, required this.state});
  @override
  State<AgentAvatar> createState()=>_AvatarState();
}
class _AvatarState extends State<AgentAvatar> with SingleTickerProviderStateMixin {
  late final AnimationController animation=AnimationController(vsync:this,duration:const Duration(seconds:4))..repeat();
  Character character=CharacterCatalog.create('aura');
  double rotation=0;
  @override
  void dispose(){animation.dispose();super.dispose();}
  @override
  Widget build(BuildContext context)=>Column(children:[
    Semantics(label:'Agent ${widget.state}',child:GestureDetector(
      onHorizontalDragUpdate:(event)=>setState(()=>rotation=(rotation+event.delta.dx*.012)%(2*math.pi)),
      child:SizedBox(width:double.infinity,height:240,child:AnimatedBuilder(animation:animation,builder:(context,child){
        final t=animation.value*2*math.pi;
        return CustomPaint(painter:MeshRenderer(character:character,yaw:rotation+math.sin(t)*.14,pitch:math.sin(t)*.04,mouthOpen:widget.state=='speaking'?math.sin(t*7).abs():0,blink:animation.value>.94?1:0));
      })),
    )),
    Wrap(spacing:8,children:[
      for(final id in ['aura','nova'])
        ChoiceChip(label:Text(id=='aura'?'Aura':'Nova'),selected:character.id==id,onSelected:(selected){if(selected)setState(()=>character=CharacterCatalog.create(id));})
    ])
  ]);
}
