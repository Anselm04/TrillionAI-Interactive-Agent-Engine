import 'dart:math' as math;
import 'package:flutter/widgets.dart';
import 'mesh.dart';
import 'characters.dart';

class _Face {
  final Path path;
  final double depth;
  final Color color;
  _Face(this.path,this.depth,this.color);
}
class MeshRenderer extends CustomPainter {
  final Character character;
  final double yaw, pitch, mouthOpen, blink;
  MeshRenderer({required this.character,required this.yaw,this.pitch=0,this.mouthOpen=0,this.blink=0});
  @override
  void paint(Canvas canvas,Size size){
    final scale=math.min(size.width,size.height)*.95;
    const distance=4.5;
    Offset project(Vec3 v)=>Offset(size.width/2+scale*v.x/(distance-v.z),size.height/2-scale*v.y/(distance-v.z));
    final faces=<_Face>[];
    for(final part in character.parts){
      final points=part.mesh.vertices.map((v){
        var p=v;
        if(part.id=='mouth') p=Vec3(p.x,-.29+(p.y+.29)*(1+2*mouthOpen.clamp(0,1)),p.z);
        if(part.id.endsWith('eye')) p=Vec3(p.x,.16+(p.y-.16)*(1-.92*blink.clamp(0,1)),p.z);
        return p.rotateY(yaw).rotateX(pitch);
      }).toList(growable:false);
      for(final t in part.mesh.triangles){
        final a=points[t.a],b=points[t.b],c=points[t.c];
        final ux=b.x-a.x,uy=b.y-a.y,uz=b.z-a.z;
        final vx=c.x-a.x,vy=c.y-a.y,vz=c.z-a.z;
        final nx=uy*vz-uz*vy,ny=uz*vx-ux*vz,nz=ux*vy-uy*vx;
        final length=math.sqrt(nx*nx+ny*ny+nz*nz);
        if(length<1e-9)continue;
        final cx=(a.x+b.x+c.x)/3,cy=(a.y+b.y+c.y)/3,cz=(a.z+b.z+c.z)/3;
        if(nx*(-cx)+ny*(-cy)+nz*(distance-cz)<=0)continue;
        final light=(.48+.52*((nx*-.3+ny*.6+nz*.74)/length).clamp(0.0,1.0)).toDouble();
        final color=Color(part.color);
        final shaded=Color.fromARGB(255,((color.r*255)*light).round(),((color.g*255)*light).round(),((color.b*255)*light).round());
        final pa=project(a),pb=project(b),pc=project(c);
        faces.add(_Face(Path()..moveTo(pa.dx,pa.dy)..lineTo(pb.dx,pb.dy)..lineTo(pc.dx,pc.dy)..close(),cz,shaded));
      }
    }
    faces.sort((a,b)=>a.depth.compareTo(b.depth));
    for(final face in faces){
      canvas.drawPath(face.path,Paint()..color=face.color..isAntiAlias=true);
    }
  }
  @override
  bool shouldRepaint(covariant MeshRenderer old)=>old.character!=character||old.yaw!=yaw||old.pitch!=pitch||old.mouthOpen!=mouthOpen||old.blink!=blink;
}
