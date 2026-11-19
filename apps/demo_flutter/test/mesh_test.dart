import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:trillionai_interactive_demo/avatar/mesh.dart';
import 'package:trillionai_interactive_demo/avatar/characters.dart';
void main(){
 test('ellipsoid produces bounded mesh indices',(){
  final mesh=Mesh.ellipsoid(segments:12,rings:8);
  expect(mesh.vertices.length,108);
  expect(mesh.triangles.length,168);
  for(final face in mesh.triangles){
   for(final index in [face.a,face.b,face.c]){expect(index,inInclusiveRange(0,107));}
  }
 });
 test('rotation preserves geometry',(){
  final v=const Vec3(1,0,0).rotateY(math.pi/2);
  expect(v.x,closeTo(0,1e-9));expect(v.z,closeTo(-1,1e-9));
 });
 test('catalog has distinct geometry and rejects unknown characters',(){
  final a=CharacterCatalog.create('aura'),b=CharacterCatalog.create('nova');
  expect(a.id,isNot(b.id));
  expect(a.parts.first.mesh.vertices.first.y,isNot(b.parts.first.mesh.vertices.first.y));
  expect(()=>CharacterCatalog.create('unknown'),throwsArgumentError);
 });
 test('invalid mesh settings rejected',()=>expect(()=>Mesh.ellipsoid(segments:0),throwsArgumentError));
}
