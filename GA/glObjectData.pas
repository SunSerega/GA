unit glObjectData;

interface

uses System.Drawing,OpenGL,GData,CFData;

type
  glObject = interface
    
    procedure Draw;
  end;
  
  glTObject = record(glObject)
  
  public 
    mode: GLenum;
    Tex: Texture;
    pts: sequence of TPoint;
    
    public procedure Draw;
    
    public constructor create(mode: GLenum; Tex: Texture; params pts: array of TPoint);
    begin
      self.mode := mode;
      self.Tex := Tex;
      self.pts := pts;
    end;
    
    public constructor create(mode: GLenum; Tex: Texture; pts: sequence of TPoint);
    begin
      self.mode := mode;
      self.Tex := Tex;
      self.pts := pts;
    end;
    
    public constructor create(HB: HitBoxT; Tex: Texture; TX, TY, TW, TH: Single; h: integer);
    begin
      self.mode := GL_QUADS;
      self.Tex := Tex;
      self.pts := new TPoint[4](
        new TPoint(HB.p1.X, HB.p1.Y, 0 * h, TX + 0 * TW, TY + 0 * TH),
        new TPoint(HB.p2.X, HB.p2.Y, 0 * h, TX + 1 * TW, TY + 0 * TH),
        new TPoint(HB.p2.X, HB.p2.Y, 1 * h, TX + 1 * TW, TY + 1 * TH),
        new TPoint(HB.p1.X, HB.p1.Y, 1 * h, TX + 0 * TW, TY + 1 * TH));
    end;
    
    public constructor create(HB: HitBoxT; Tex: Texture; TX, TY, TW, TH: Single);begin create(HB, Tex, TX, TY, TW, TH, -WallHeigth); end;//ToDo костыль!
    
    public constructor create(HB: HitBoxT; Tex: Texture; h: integer);begin create(HB, Tex, 0, 0, HB.w / h, 1, h); end;//ToDo костыль!
    
    public constructor create(HB: HitBoxT; Tex: Texture);begin create(HB, Tex, 0, 0, -HB.w / WallHeigth, 1, -WallHeigth); end;//ToDo костыль!
  
  end;
  glPObject = record(glObject)
  
  public 
    mode: GLenum;
    pts: array of CPoint;
    
    public procedure Draw;
    
    public constructor create(mode: GLenum; params pts: array of CPoint);
    begin
      self.mode := mode;
      self.pts := pts;
    end;
  end;
  glCObject = record(glObject)
  
  public 
    mode: GLenum;
    cr, cg, cb, ca: Single;
    pts: array of PPoint;
    
    public procedure Draw;
    
    public constructor create(mode: GLenum; cr, cg, cb, ca: Single; params pts: array of PPoint);
    begin
      self.mode := mode;
      self.cr := cr;
      self.cg := cg;
      self.cb := cb;
      self.ca := ca;
      self.pts := pts;
    end;
  end;
  glOObject = record(glObject)
  
  public 
    obj: array of glObject;
    
    public procedure Draw;
    
    public constructor create(params obj: array of glObject);
    begin
      self.obj := obj;
    end;
  end;
  
  NewGlObj = sealed abstract class
    
    {$region 2D}
    
    class function Polygon(Fill: boolean; cr, cg, cb, ca: Single; pts: array of PointF) := new glCObject(Fill ? GL_POLYGON : GL_LINE_LOOP, cr, cg, cb, ca, pts.ConvertAll(a -> new PPoint(a.X, a.Y, 0))) ;
    
    class function Lines(&Loop: boolean; cr, cg, cb, ca: Single; pts: array of PointF) := new glCObject(&Loop ? GL_LINE_LOOP : GL_LINE_STRIP, cr, cg, cb, ca, pts.ConvertAll(a -> new PPoint(a.X, a.Y, 0))) ;
    
    class function Rectangle(Fill: boolean; cr, cg, cb, ca: Single; X, Y, W, H: Single) := new glCObject(Fill ? GL_QUADS : GL_LINE_LOOP, cr, cg, cb, ca, new PPoint[4](new PPoint(X, Y, 0), new PPoint(X + W, Y, 0), new PPoint(X + W, Y + H, 0), new PPoint(X, Y + H, 0))) ;
    
    class function Rectangle(Fill: boolean; cr, cg, cb, ca: Single; rect: RectangleF) := Rectangle(Fill, cr, cg, cb, ca, rect.X, rect.Y, rect.Width, rect.Height) ;
    
    class function Rectangle(Tex: Texture; X, Y: Single) := new glTObject(GL_QUADS, Tex, new TPoint[4](new TPoint(X, Y, 0, 0, 0), new TPoint(X + Tex.w, Y, 0, 1, 0), new TPoint(X + Tex.w, Y + Tex.h, 0, 1, 1), new TPoint(X, Y + Tex.h, 0, 0, 1)));
    
    class function TexInRectangle(Tex: Texture; X, Y, W, H: Single): glTObject;
    begin
      var scx := W / Tex.w;
      var scy := H / Tex.h;
      Result := new glTObject(GL_QUADS, Tex, scx < scy ? (new TPoint[4](
    
      new TPoint(X,     Y - H / 2 * (scx / scy - 1), 0, 0, 0),
      new TPoint(X + W, Y - H / 2 * (scx / scy - 1), 0, 1, 0),
      new TPoint(X + W, Y + H / 2 * (scx / scy + 1), 0, 1, 1),
      new TPoint(X,     Y + H / 2 * (scx / scy + 1), 0, 0, 1))
    
      ) : (new TPoint[4](
    
      new TPoint(X - W / 2 * (scy / scx - 1), Y,     0, 0, 0),
      new TPoint(X + W / 2 * (scy / scx + 1), Y,     0, 1, 0),
      new TPoint(X + W / 2 * (scy / scx + 1), Y + H, 0, 1, 1),
      new TPoint(X - W / 2 * (scy / scx - 1), Y + H, 0, 0, 1))
    
      ));
    end;
    
    public class function TexInRectangle(Tex: Texture; rect: RectangleF) := TexInRectangle(Tex, rect.X, rect.Y, rect.Width, rect.Height);
    
    public class function Rectangle(Tex: Texture; X, Y, W, H, TX, TY, TW, TH: Single) := new glTObject(GL_QUADS, Tex, new TPoint[4](new TPoint(X, Y, 0, TX, TY), new TPoint(X + W, Y, 0, TX + TW, TY), new TPoint(X + W, Y + H, 0, TX + TW, TY + TH), new TPoint(X, Y + H, 0, TX, TY + TH)));
    
    public class function GetEllipseObj(Fill: boolean; cr, cg, cb, ca: Single; X, Y, W, H: Single; pc: integer) := new glCObject(Fill ? GL_POLYGON : GL_LINE_LOOP, cr, cg, cb, ca, gr.Ellipse(X, Y, W, H, pc).ConvertAll(a -> PPoint(new PPoint(a.X, a.Y, 0))));
    
    {$endregion}
    
    {$region 3D}
    
    public class function Polygon(Fill: boolean; cr, cg, cb, ca: Single; pts: array of PPoint) := new glCObject(Fill ? GL_POLYGON : GL_LINE_LOOP, cr, cg, cb, ca, pts);
    
    public class function Lines(&Loop: boolean; cr, cg, cb, ca: Single; pts: array of PPoint) := new glCObject(&Loop ? GL_LINE_LOOP : GL_LINE_STRIP, cr, cg, cb, ca, pts);
    
    public class function Cube(cr, cg, cb, ca: Single; X, Y, Z, dX, dY, dZ: real) := new glCObject(GL_QUADS, cr, cg, cb, ca, new PPoint[24](
    
    new PPoint(X + 00, Y + 00, Z + 00),
    new PPoint(X + dX, Y + 00, Z + 00),
    new PPoint(X + dX, Y + dY, Z + 00),
    new PPoint(X + 00, Y + dY, Z + 00),
    
    new PPoint(X + 00, Y + 00, Z + dZ),
    new PPoint(X + dX, Y + 00, Z + dZ),
    new PPoint(X + dX, Y + dY, Z + dZ),
    new PPoint(X + 00, Y + dY, Z + dZ),
    
    new PPoint(X + 00, Y + 00, Z + 00),
    new PPoint(X + dX, Y + 00, Z + 00),
    new PPoint(X + dX, Y + 00, Z + dZ),
    new PPoint(X + 00, Y + 00, Z + dZ),
    
    new PPoint(X + 00, Y + dY, Z + 00),
    new PPoint(X + dX, Y + dY, Z + 00),
    new PPoint(X + dX, Y + dY, Z + dZ),
    new PPoint(X + 00, Y + dY, Z + dZ),
    
    new PPoint(X + 00, Y + 00, Z + 00),
    new PPoint(X + 00, Y + 00, Z + dZ),
    new PPoint(X + 00, Y + dY, Z + dZ),
    new PPoint(X + 00, Y + dY, Z + 00),
    
    new PPoint(X + dX, Y + 00, Z + 00),
    new PPoint(X + dX, Y + 00, Z + dZ),
    new PPoint(X + dX, Y + dY, Z + dZ),
    new PPoint(X + dX, Y + dY, Z + 00)
    
    ));
  
  public class function GetSphereObj(cr, cg, cb, ca: Single; X, Y, Z, dX, dY, dZ: real; pc: integer): glCObject;
  begin
    if pc < 2 then raise new System.ArgumentOutOfRangeException;
    Result := new glCObject(GL_QUADS, cr, cg, cb, ca, new PPoint[sqr(pc) * 8]);
    var pts := gr.Sphere(X, Y, Z, dX, dY, dZ, pc);
    var i := 0;
    var lx := pc * 2 - 1;
    for ix: integer := 0 to pc * 2 - 1 do
    begin
      for iy: integer := 0 to pc - 1 do
      begin
        with pts[ix + 0, iy + 0] do Result.pts[i + 0] := new PPoint(X, Y, Z);
        with pts[lx + 0, iy + 0] do Result.pts[i + 1] := new PPoint(X, Y, Z);
        with pts[lx + 0, iy + 1] do Result.pts[i + 2] := new PPoint(X, Y, Z);
        with pts[ix + 0, iy + 1] do Result.pts[i + 3] := new PPoint(X, Y, Z);
        i += 4;
      end;
      lx := ix;
    end;
  end;

    {$endregion}

end;

///Создаёт стенки комнат из хитбоксов
function HBTDO(w0: real; var w1: real; Tex: Texture; HBs: List<HitBoxT>): List<glObject>;
///Создаёт стенки комнат из хитбоксов
function HBTDOReverse(w0: real; var w1: real; Tex: Texture; HBs: List<HitBoxT>): List<glObject>;

implementation

var
  LastColor: (Single, Single, Single, Single);

procedure SetColor(cr, cg, cb, ca: Single);
begin
  var CSet := (cr, cg, cb, ca);
  if CSet <> LastColor then
  begin
    glColor4f(cr, cg, cb, ca);
    LastColor := CSet;
  end;
end;

procedure SetColor(pt: CPoint) := SetColor(pt.cr, pt.cg, pt.cb, pt.ca);

procedure glTObject.Draw := Tex.Draw(mode, pts);

procedure glPObject.Draw;
begin
  glBegin(mode);
  foreach var pt in pts do
  begin
    SetColor(pt);
    glVertex3d(pt.X, pt.Y, pt.Z);
  end;
  glEnd;
end;

procedure glCObject.Draw;
begin
  glBegin(mode);
  SetColor(cr, cg, cb, ca);
  foreach var pt in pts do
    glVertex3d(pt.X, pt.Y, pt.Z);
  glEnd;
end;

procedure glOObject.Draw := foreach var obj1 in obj do obj1.Draw;

function HBTDO(w0: real; var w1: real; Tex: Texture; HBs: List<HitBoxT>): List<glObject>;
begin
  
  Result := new List<glObject>(HBs.Count);
  
  w1 := w0 + HBs[0].w;
  
  foreach var HB in HBs.Reverse do
  begin
    Result.Add(new glTObject(GL_QUADS, Tex, new TPoint[4](
            new TPoint(HB.p1.X, HB.p1.Y, -1 * WallHeigth, w0 / WallHeigth, 1),
            new TPoint(HB.p2.X, HB.p2.Y, -1 * WallHeigth, w1 / WallHeigth, 1),
            new TPoint(HB.p2.X, HB.p2.Y, -0 * WallHeigth, w1 / WallHeigth, 0),
            new TPoint(HB.p1.X, HB.p1.Y, -0 * WallHeigth, w0 / WallHeigth, 0))));
    w0 := w1;
    w1 += HB.w;
  end;
  
end;

function HBTDOReverse(w0: real; var w1: real; Tex: Texture; HBs: List<HitBoxT>): List<glObject>;
begin
  
  HBs := HBs.Reverse.ToList;//ToDo Костыль!
  Result := new List<glObject>(HBs.Count);
  
  w1 := w0 - HBs[0].w;
  
  foreach var HB in HBs.Reverse do
  begin
    Result.Add(new glTObject(GL_QUADS, Tex, new TPoint[4](
            new TPoint(HB.p1.X, HB.p1.Y, -1 * WallHeigth, w1 / WallHeigth, 1),
            new TPoint(HB.p2.X, HB.p2.Y, -1 * WallHeigth, w0 / WallHeigth, 1),
            new TPoint(HB.p2.X, HB.p2.Y, -0 * WallHeigth, w0 / WallHeigth, 0),
            new TPoint(HB.p1.X, HB.p1.Y, -0 * WallHeigth, w1 / WallHeigth, 0))));
    w0 := w1;
    w1 -= HB.w;
  end;
  
end;

end.