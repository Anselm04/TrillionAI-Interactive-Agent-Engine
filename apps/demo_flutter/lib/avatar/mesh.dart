import 'dart:math' as math;

class Vec3 {
  final double x, y, z;
  const Vec3(this.x, this.y, this.z);
  Vec3 rotateY(double a) => Vec3(x * math.cos(a) + z * math.sin(a), y, -x * math.sin(a) + z * math.cos(a));
  Vec3 rotateX(double a) => Vec3(x, y * math.cos(a) - z * math.sin(a), y * math.sin(a) + z * math.cos(a));
}
class Triangle {
  final int a, b, c;
  const Triangle(this.a, this.b, this.c);
}
class Mesh {
  final List<Vec3> vertices;
  final List<Triangle> triangles;
  Mesh(List<Vec3> vertices, List<Triangle> triangles)
      : vertices = List.unmodifiable(vertices), triangles = List.unmodifiable(triangles);
  factory Mesh.ellipsoid({double rx=1, double ry=1, double rz=1, Vec3 center=const Vec3(0,0,0), int segments=24, int rings=16}) {
    if (segments<3 || rings<2 || segments>128 || rings>128 || [rx,ry,rz].any((v)=>!v.isFinite || v<=0)) {
      throw ArgumentError('Invalid mesh dimensions');
    }
    final vertices=<Vec3>[];
    final faces=<Triangle>[];
    for(var i=0;i<=rings;i++){
      final phi=math.pi*i/rings;
      for(var j=0;j<segments;j++){
        final theta=2*math.pi*j/segments;
        vertices.add(Vec3(center.x+rx*math.sin(phi)*math.cos(theta),center.y+ry*math.cos(phi),center.z+rz*math.sin(phi)*math.sin(theta)));
      }
    }
    for(var i=0;i<rings;i++){
      for(var j=0;j<segments;j++){
        final a=i*segments+j,b=i*segments+(j+1)%segments,c=a+segments,d=b+segments;
        if(i>0) faces.add(Triangle(a,b,c));
        if(i<rings-1) faces.add(Triangle(b,d,c));
      }
    }
    return Mesh(vertices,faces);
  }
}
