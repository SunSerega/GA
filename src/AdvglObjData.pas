unit AdvglObjData;

uses CFData,glObjectData, OpenGL;

type
  PTriangle = record(glObject)
    
    p1, p2, p3: Cvec3d;
    
    procedure SetPoints;
    begin
      glColor4f(p1.cr,p1.cg,p1.cb,p1.ca); glVertex3f(p1.X, p1.Y, p1.Z);
      glColor4f(p2.cr,p2.cg,p2.cb,p2.ca); glVertex3f(p2.X, p2.Y, p2.Z);
      glColor4f(p3.cr,p3.cg,p3.cb,p3.ca); glVertex3f(p3.X, p3.Y, p3.Z);
    end;
    
    procedure Draw;
    begin
      glBegin(GL_TRIANGLES);
      SetPoints;
      glEnd;
    end;
    
    constructor(p1, p2, p3: Cvec3d);
    begin
      self.p1 := p1;
      self.p2 := p2;
      self.p3 := p3;
    end;
  
  end;
  
  PIcosahedron = record(glObject)
    
    public Triangles: List<PTriangle>;
    public X,Y,Z:real;
    public dX, dY, dZ: real;
    public cr, cg, cb, ca: Single;
    public dcr, dcg, dcb, dca: Single;
    
    procedure Draw;
    begin
      glPushMatrix;
      glTranslatef(X,Y,Z);
      glBegin(GL_TRIANGLES);
      foreach var t in Triangles do t.SetPoints;
      glEnd;
      glPopMatrix;
    end;
    
    private function ATP(aX, aY: Single) := new Cvec3d(-dX * Cos(aX) * Cos(aY), -dY * Sin(aX) * Cos(aY), dZ * Sin(aY), cr+Rand(dcr), cg+Rand(dcg), cb+Rand(dcb), ca+Rand(dca));
    
    private function SSP(p1, p2: Cvec3d): Cvec3d;
    begin
      
      var vec := new vec3d((p1.X + p2.X) / dX, (p1.Y + p2.Y) / dY, (p1.Z + p2.Z) / dZ);
      var l := sqrt(sqr(vec.X) + sqr(vec.Y) + sqr(vec.Z));
      
      Result := new Cvec3d(vec.X / l * dX, vec.Y / l * dY, vec.Z / l * dZ, cr+Rand(dcr), cg+Rand(dcg), cb+Rand(dcb), ca+Rand(dca));
      
    end;
    
    public procedure BiSect;
    begin
      
      var nTriangles := new List<PTriangle>(Triangles.Count * 4);
      foreach var t in Triangles do
      begin
        
        var p12 := SSP(t.p1, t.p2);
        var p23 := SSP(t.p2, t.p3);
        var p31 := SSP(t.p3, t.p1);
        
        nTriangles.Add(new PTriangle(t.p1, p12, p31));
        nTriangles.Add(new PTriangle(t.p2, p12, p23));
        nTriangles.Add(new PTriangle(t.p3, p23, p31));
        
        nTriangles.Add(new PTriangle(p12, p23, p31));
        
      end;
      
      Triangles := nTriangles;
      
    end;
    
    public constructor(X,Y,Z,dX, dY, dZ:real; cr,cg,cb,ca, dcr,dcg,dcb,dca: Single);
    begin
      
      self.X := X;self.Y := Y;self.Z := Z;
      self.dX := dX;self.dY := dY;self.dZ := dZ;
      self.cr := cr;self.cg := cg;self.cb := cb;self.ca := ca;
      self.dcr := dcr;self.dcg := dcg;self.dcb := dcb;self.dca := dca;
      var NP := new Cvec3d(0, 0, -dZ, cr+Rand(dcr), cg+Rand(dcg), cb+Rand(dcb), ca+Rand(dca));
      var SP := new Cvec3d(0, 0, +dZ, cr+Rand(dcr), cg+Rand(dcg), cb+Rand(dcb), ca+Rand(dca));
      var MAng := ArcTan(1 / 2);
      var NP2 := new Cvec3d[5];
      var SP2 := new Cvec3d[5];
      var dang := Pi / 2.5;
      for i: byte := 0 to 4 do
      begin
        NP2[i] := ATP(i * dang, -MAng);
        SP2[i] := ATP((i + 0.5) * dang, +MAng);
      end;
      
      Triangles := new List<PTriangle>(20);
      
      Triangles.Add(new PTriangle(SP, SP2[0], SP2[1]));
      Triangles.Add(new PTriangle(SP, SP2[1], SP2[2]));
      Triangles.Add(new PTriangle(SP, SP2[2], SP2[3]));
      Triangles.Add(new PTriangle(SP, SP2[3], SP2[4]));
      Triangles.Add(new PTriangle(SP, SP2[4], SP2[0]));
      
      Triangles.Add(new PTriangle(NP, NP2[0], NP2[1]));
      Triangles.Add(new PTriangle(NP, NP2[1], NP2[2]));
      Triangles.Add(new PTriangle(NP, NP2[2], NP2[3]));
      Triangles.Add(new PTriangle(NP, NP2[3], NP2[4]));
      Triangles.Add(new PTriangle(NP, NP2[4], NP2[0]));
      
      Triangles.Add(new PTriangle(NP2[0], SP2[0], NP2[1]));
      Triangles.Add(new PTriangle(NP2[1], SP2[1], NP2[2]));
      Triangles.Add(new PTriangle(NP2[2], SP2[2], NP2[3]));
      Triangles.Add(new PTriangle(NP2[3], SP2[3], NP2[4]));
      Triangles.Add(new PTriangle(NP2[4], SP2[4], NP2[0]));
      
      Triangles.Add(new PTriangle(SP2[0], NP2[1], SP2[1]));
      Triangles.Add(new PTriangle(SP2[1], NP2[2], SP2[2]));
      Triangles.Add(new PTriangle(SP2[2], NP2[3], SP2[3]));
      Triangles.Add(new PTriangle(SP2[3], NP2[4], SP2[4]));
      Triangles.Add(new PTriangle(SP2[4], NP2[0], SP2[0]));
      
    end;
    
    public constructor(X,Y,Z,dX, dY, dZ:real; cr,cg,cb,ca, dcr,dcg,dcb,dca: Single; BiSectCount: byte);
    begin
      
      create(X,Y,Z,dX, dY, dZ, cr,cg,cb,ca, dcr,dcg,dcb,dca);
      
      loop BiSectCount do BiSect;
      
    end;
  
  end;

end.