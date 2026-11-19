import 'dart:math' as math;
import 'package:flutter/material.dart';
class AgentAvatar extends StatefulWidget {
 final String state;
 const AgentAvatar({super.key,required this.state});
 @override State<AgentAvatar> createState()=>_AvatarState();
}
class _AvatarState extends State<AgentAvatar> with SingleTickerProviderStateMixin {
 late final AnimationController animation=AnimationController(vsync:this,duration:const Duration(seconds:3))..repeat();
 @override void dispose(){animation.dispose();super.dispose();}
 @override Widget build(BuildContext context)=>Semantics(label:'Agent ${widget.state}',child:SizedBox(height:240,child:AnimatedBuilder(animation:animation,builder:(context,child)=>CustomPaint(painter:_Orb(widget.state,animation.value)))));
}
class _Orb extends CustomPainter {
 final String state;final double phase;
 _Orb(this.state,this.phase);
 @override void paint(Canvas c,Size s){
  final p=Offset(s.width/2,s.height/2+math.sin(phase*math.pi*2)*7);
  final r=math.min(s.width,s.height)*.32;
  c.drawOval(Rect.fromCenter(center:Offset(s.width/2,s.height*.9),width:r*1.4,height:12),Paint()..color=const Color(0x2200518a));
  c.drawCircle(p,r,Paint()..shader=RadialGradient(center:const Alignment(-.4,-.5),colors:const [Color(0xffe9faff),Color(0xff76b9ec),Color(0xff245fba)]).createShader(Rect.fromCircle(center:p,radius:r)));
  final ink=Paint()..color=const Color(0xff15365e);
  final blink=phase>.94?2.0:12.0;
  for(final x in [-.31,.31]){c.drawOval(Rect.fromCenter(center:p+Offset(r*x,-r*.12),width:10,height:blink),ink);}
  final h=state=='speaking'?8+math.sin(phase*math.pi*16).abs()*22:state=='listening'?9.0:5.0;
  c.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center:p+Offset(0,r*.28),width:r*.38,height:h),const Radius.circular(12)),ink);
  if(state=='thinking'||state=='listening')c.drawArc(Rect.fromCircle(center:p,radius:r+12),phase*math.pi*2,math.pi*.75,false,Paint()..color=const Color(0xff367bd0)..style=PaintingStyle.stroke..strokeWidth=3);
 }
 @override bool shouldRepaint(covariant _Orb old)=>old.phase!=phase||old.state!=state;
}
