// This class represents a single mesh constructed from
// a grid of connected particles. The joinMeshTo() function
// can be used to connect the corners of one mesh to specific
// points on one or more other meshes
class ParticleMesh {

  List<VerletParticle3D> particles=new ArrayList<VerletParticle3D>();
  TriangleMesh mesh;
  ReadonlyTColor col;
  int gridSize;
  
  ParticleMesh(int gridSize, int restLength, float strength, ReadonlyTColor col) {
    this.gridSize=gridSize;
    this.col=col;
    int totalWidth=gridSize*restLength;
    for(int y=0,idx=0; y<gridSize; y++) {
      for(int x=0; x<gridSize; x++) {
        VerletParticle3D p=new VerletParticle3D(x*restLength-totalWidth/2,y*restLength-totalWidth/2,0);
        physics.addParticle(p);
        particles.add(p);
        if (x>0) {
          VerletSpring3D s=new VerletSpring3D(p,particles.get(idx-1),restLength,strength);
          physics.addSpring(s);
        }
        if (y>0) {
          VerletSpring3D s=new VerletSpring3D(p,particles.get(idx-gridSize),restLength,strength);
          physics.addSpring(s);
        }
        idx++;
      }
    }
  }
  
  // (re)builds mesh from particle grid
  // constructs 2 triangles for each grid cell
  void buildMesh() {
    mesh=new TriangleMesh();
    for(int y=0,idx=0; y<gridSize; y++) {
      for(int x=0; x<gridSize; x++) {
        if (x>0 && y>0) {
          VerletParticle3D a=particles.get(idx-gridSize-1);
          VerletParticle3D b=particles.get(idx-1);
          VerletParticle3D c=particles.get(idx);
          VerletParticle3D d=particles.get(idx-gridSize);
          mesh.addFace(a,b,c);
          mesh.addFace(a,c,d);
        }
        idx++;
      }
    }
    mesh.computeVertexNormals();
  }
  
  // returns particle at the given grid position
  VerletParticle3D getParticleAt(Vec2D gridPos) {
    return particles.get(getIndexForPos(gridPos));
  }
  
  // 2D->1D projection: computes list index of particle at given grid position
  int getIndexForPos(Vec2D gridPos) {
    return (int)gridPos.x+(int)gridPos.y*gridSize;
  }
  
  // ab,b,c,d in clockwise direction
  void joinMeshTo(ParticleMesh ma, Vec2D a, ParticleMesh mb, Vec2D b, ParticleMesh mc, Vec2D c, ParticleMesh md, Vec2D d) {
    // store & map this mesh's corners to particles from source mesh(es)
    HashMap<Vec2D,VerletParticle3D> corners=new HashMap<Vec2D,VerletParticle3D>();
    corners.put(new Vec2D(0,0),ma.getParticleAt(a));
    corners.put(new Vec2D(gridSize-1,0),mb.getParticleAt(b));
    corners.put(new Vec2D(gridSize-1,gridSize-1),mc.getParticleAt(c));
    corners.put(new Vec2D(0,gridSize-1),md.getParticleAt(d));
  
    for(Vec2D pos : corners.keySet()) {
      int idx=getIndexForPos(pos);
      VerletParticle3D p=particles.get(idx);
      VerletParticle3D q=corners.get(pos);
      physics.addSpring(new VerletSpring3D(p,q,0,1));
    }
  }
}