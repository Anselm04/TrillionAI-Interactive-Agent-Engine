import 'mesh.dart';

class CharacterPart {
  final String id;
  final Mesh mesh;
  final int color;
  CharacterPart(this.id,this.mesh,this.color);
}
class Character {
  final String id, name;
  final List<CharacterPart> parts;
  Character(this.id,this.name,List<CharacterPart> parts):parts=List.unmodifiable(parts);
}
class CharacterCatalog {
  static Character create(String id){
    switch(id){
      case 'aura': return _build(id,'Aura',0xff75b7ef,1.0,1.02);
      case 'nova': return _build(id,'Nova',0xff96d6bb,0.85,1.18);
      default: throw ArgumentError('Unknown character');
    }
  }
  static Character _build(String id,String name,int color,double rx,double ry)=>Character(id,name,[
    CharacterPart('head',Mesh.ellipsoid(rx:rx,ry:ry,rz:.82),color),
    CharacterPart('left-eye',Mesh.ellipsoid(rx:.13,ry:.17,rz:.07,center:const Vec3(-.32,.16,.79)),0xff183457),
    CharacterPart('right-eye',Mesh.ellipsoid(rx:.13,ry:.17,rz:.07,center:const Vec3(.32,.16,.79)),0xff183457),
    CharacterPart('mouth',Mesh.ellipsoid(rx:.23,ry:.07,rz:.07,center:const Vec3(0,-.29,.80)),0xff183457),
  ]);
}
