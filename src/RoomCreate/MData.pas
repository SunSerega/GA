unit MData;

uses System.Drawing,OpenGL,GData;

var
  ///Mouse Flying Control Active
  LMS := false;
  ///Mouse Flying Control Last Position
  LMP: Point;
  ///Mouse Position
  MP: Point;

type
  FPoint = record
    
    cr, cg, cb, ca: Single;
    TX, TY: Single;
    X, Y, Z: real;
    
    constructor create(X, Y, Z: real; TX, TY: Single);
    begin
      self.X := X;
      self.Y := Y;
      self.Z := Z;
      self.TX := TX;
      self.TY := TY;
    end;
    
    constructor create(X, Y, Z: real; cr, cg, cb, ca: Single);
    begin
      self.X := X;
      self.Y := Y;
      self.Z := Z;
      self.cr := cr;
      self.cg := cg;
      self.cb := cb;
      self.ca := ca;
    end;
  
  end;
  glObject = class
    
    private class LastColorSet: (Single, Single, Single, Single);
  
  public 
    mode: GLenum;
    Tex: Texture;
    pts: array of FPoint;
    obj: array of glObject;
    
    public procedure Draw(r, g, b, a: Single);
    begin
      if Tex <> nil then
        Tex.Draw(mode, pts.ConvertAll(f -> new TexCoord(f.TX, f.TY, F.X, F.Y, F.Z)), r, g, b, a) else
      begin
        LastColorSet := nil;
        glBegin(mode);
        for i: integer := 0 to pts.Length - 1 do
        begin
          var CSet := (pts[i].cr, pts[i].cg, pts[i].cb, pts[i].ca);
          if CSet <> LastColorSet then
          begin
            glColor4f(pts[i].cr, pts[i].cg, pts[i].cb, pts[i].ca);
            LastColorSet := CSet;
          end;
          glVertex3d(pts[i].X, pts[i].Y, pts[i].Z);
        end;
        glEnd;
      end;
    end;
  
  public  procedure Draw := Draw(1, 1, 1, 1);
    
    public constructor create(mode: GLenum; Tex: Texture; params pts: array of FPoint);
    begin
      self.mode := mode;
      self.Tex := Tex;
      self.pts := pts;
      obj := new glObject[0];
    end;
  
  {$region 2D}
  
  public class function Polygon(Fill: boolean; cr, cg, cb, ca: Single; pts: array of PointF) := new glObject(Fill ? GL_POLYGON : GL_LINE_LOOP, nil, pts.ConvertAll(a -> new FPoint(a.X, a.Y, 0, cr, cg, cb, ca)));
  
  public class function Lines(cr, cg, cb, ca: Single; pts: array of PointF) := new glObject(GL_LINE_STRIP, nil, pts.ConvertAll(a -> new FPoint(a.X, a.Y, 0, cr, cg, cb, ca)));
  
  public class function Rectangle(Fill: boolean; cr, cg, cb, ca: Single; X, Y, W, H: Single) := new glObject(Fill ? GL_QUADS : GL_LINE_LOOP, nil, new FPoint[4](new FPoint(X, Y, 0, cr, cg, cb, ca), new FPoint(X + W, Y, 0, cr, cg, cb, ca), new FPoint(X + W, Y + H, 0, cr, cg, cb, ca), new FPoint(X, Y + H, 0, cr, cg, cb, ca)));
  
  public class function Rectangle(Tex: Texture; X, Y: Single) := new glObject(GL_QUADS, Tex, new FPoint[4](new FPoint(X, Y, 0, 0, 0), new FPoint(X + Tex.w, Y, 0, 1, 0), new FPoint(X + Tex.w, Y + Tex.h, 0, 1, 1), new FPoint(X, Y + Tex.h, 0, 0, 1)));
  
  public class function Rectangle(Tex: Texture; X, Y, W, H, TX, TY, TW, TH: Single) := new glObject(GL_QUADS, Tex, new FPoint[4](new FPoint(X, Y, 0, TX, TY), new FPoint(X + W, Y, 0, TX + TW, TY), new FPoint(X + W, Y + H, 0, TX + TW, TY + TH), new FPoint(X, Y + H, 0, TX, TY + TH)));
  
  public class function GetEllipseObj(Fill: boolean; cr, cg, cb, ca: Single; X, Y, W, H: Single) := new glObject(Fill ? GL_POLYGON : GL_LINE_LOOP, nil, gr.Ellipse(X, Y, W, H, 255).ConvertAll(a -> new FPoint(a.X, a.Y, 0, cr, cg, cb, ca)));
  
  {$endregion}
  
  {$region 3D}
  
  public class function Polygon(Fill: boolean; cr, cg, cb, ca: Single; pts: array of Point3f) := new glObject(Fill ? GL_POLYGON : GL_LINE_LOOP, nil, pts.ConvertAll(a -> new FPoint(a.X, a.Y, a.Z, cr, cg, cb, ca)));
  
  public class function Lines(cr, cg, cb, ca: Single; pts: array of Point3f) := new glObject(GL_LINE_STRIP, nil, pts.ConvertAll(a -> new FPoint(a.X, a.Y, a.Z, cr, cg, cb, ca)));
  
  public class function Cube(cr, cg, cb, ca: Single; X, Y, Z, dX, dY, dZ: real) := new glObject(GL_QUADS, nil, new FPoint[24](
  
  new FPoint(X + 0, Y + 0, Z + 0, cr, cg, cb, ca),
  new FPoint(X + 1, Y + 0, Z + 0, cr, cg, cb, ca),
  new FPoint(X + 1, Y + 1, Z + 0, cr, cg, cb, ca),
  new FPoint(X + 0, Y + 1, Z + 0, cr, cg, cb, ca),
  
  new FPoint(X + 0, Y + 0, Z + 1, cr, cg, cb, ca),
  new FPoint(X + 1, Y + 0, Z + 1, cr, cg, cb, ca),
  new FPoint(X + 1, Y + 1, Z + 1, cr, cg, cb, ca),
  new FPoint(X + 0, Y + 1, Z + 1, cr, cg, cb, ca),
  
  new FPoint(X + 0, Y + 0, Z + 0, cr, cg, cb, ca),
  new FPoint(X + 1, Y + 0, Z + 0, cr, cg, cb, ca),
  new FPoint(X + 1, Y + 0, Z + 1, cr, cg, cb, ca),
  new FPoint(X + 0, Y + 0, Z + 1, cr, cg, cb, ca),
  
  new FPoint(X + 0, Y + 1, Z + 0, cr, cg, cb, ca),
  new FPoint(X + 1, Y + 1, Z + 0, cr, cg, cb, ca),
  new FPoint(X + 1, Y + 1, Z + 1, cr, cg, cb, ca),
  new FPoint(X + 0, Y + 1, Z + 1, cr, cg, cb, ca),
  
  new FPoint(X + 0, Y + 0, Z + 0, cr, cg, cb, ca),
  new FPoint(X + 0, Y + 0, Z + 1, cr, cg, cb, ca),
  new FPoint(X + 0, Y + 1, Z + 1, cr, cg, cb, ca),
  new FPoint(X + 0, Y + 1, Z + 0, cr, cg, cb, ca),
  
  new FPoint(X + 1, Y + 0, Z + 0, cr, cg, cb, ca),
  new FPoint(X + 1, Y + 0, Z + 1, cr, cg, cb, ca),
  new FPoint(X + 1, Y + 1, Z + 1, cr, cg, cb, ca),
  new FPoint(X + 1, Y + 1, Z + 0, cr, cg, cb, ca)
    
    ));
  
  public class function GetSphereObj(cr, cg, cb, ca: Single; X, Y, Z, dX, dY, dZ: real; pc: integer): glObject;
  begin
    Result := new glObject(GL_QUADS, nil, new FPoint[pc * pc * 8]);
    var pts := gr.Sphere(X, Y, Z, dX, dY, dZ, pc);
    var i := 0;
    var lx := pc * 2 - 1;
    for ix: integer := 0 to pc * 2 - 1 do
    begin
      for iy: integer := 0 to pc - 1 do
      begin
        with pts[ix + 0, iy + 0] do Result.pts[i + 0] := new FPoint(X, Y, Z, cr, cg, cb, ca);
        with pts[lx + 0, iy + 0] do Result.pts[i + 1] := new FPoint(X, Y, Z, cr, cg, cb, ca);
        with pts[lx + 0, iy + 1] do Result.pts[i + 2] := new FPoint(X, Y, Z, cr, cg, cb, ca);
        with pts[ix + 0, iy + 1] do Result.pts[i + 3] := new FPoint(X, Y, Z, cr, cg, cb, ca);
        i += 4;
      end;
      lx := ix;
    end;
  end;

  {$endregion}

end;

{$region abstract}

Manu = class
public 
  LPS: cardinal;
  obj: array of array of glObject;
  MainThread: System.Threading.Thread;
  DPos: PointF;
  active: word;
  
  
  public procedure Main; abstract;
  
  private procedure _Main;
  var
    ta: real;
    t: System.TimeSpan;
  begin
    
    while not (ta > 0) do
      ta := 1 / LPS;
    LPS := 0;
    
    var LT := System.DateTime.Now;
    while true do
      try
        Main;
        
        t := LT - System.DateTime.Now;
        if t.TotalMilliseconds > 0 then
          System.Threading.Thread.Sleep(t);
        LT := LT.AddMilliseconds(ta);
      except
        on e: System.Exception do
          SaveError('ManuMainThread:[', self.GetType, ']:', e);
      end;
    
  end;
  
  public procedure Tick2D(X, Y: Single; _data: object); virtual;begin end;
  
  public procedure Tick3D(X, Y: Single; data: object); virtual;begin end;
  
  
  
  public procedure Chandge; virtual;begin end;
  
  
  public class AllLvl0 := new List<Manu>;
  public class All := new List<Manu>;

public class procedure Tick2DAll(P: Point) := AllLvl0.ForEach(m -> begin m.Tick2D(P.X, P.Y, nil) end);

public class procedure Tick3DAll(P: Point) := AllLvl0.ForEach(m -> begin m.Tick3D(P.X, P.Y, nil) end);
  
  
  public procedure Suspend; virtual;
  begin
    if active = 0 then
      MainThread.Suspend;
    if active <> word.MaxValue then
      active += 1;
  end;
  
  public procedure Resume; virtual;
  begin
    if active <> 0 then
    begin
      active -= 1;
      if active = 0 then
        MainThread.Resume;
    end;
  end;
  
  
  public procedure Init(LPS: cardinal);
  begin
    AllLvl0.Add(self);
    All.Add(self);
    self.LPS := LPS;
    MainThread := new System.Threading.Thread(_Main);
    MainThread.Start;
  end;
  
  public procedure UnInit;
  begin
    MainThread.Abort;
    MainThread.Resume;
    AllLvl0.Remove(self);
  end;

end;

ManuContener = class(Manu)
public 
  X, Y: Single;
  mns: List<Manu>;
  
  public procedure Tick2DAll(P: Point);
  begin
    glPushMatrix;
    glTranslatef(X, Y, 0);
    foreach var M in mns do
      M.Tick2D(P.X - X, P.Y - Y, nil);
    glPopMatrix;
  end;
  
  
  public procedure AddManu(M: Manu);
  begin
    AllLvl0.Remove(M);
    self.mns.Add(M);
    M.DPos.X := X + DPos.X;
    M.DPos.Y := Y + DPos.Y;
  end;
  
  public procedure RemoveManu(M: Manu);
  begin
    self.mns.Remove(M);
    AllLvl0.Add(M);
    M.DPos.X := DPos.X;
    M.DPos.Y := DPos.Y;
  end;
  
  
  public procedure Init(LPS: cardinal; X, Y: Single);
  begin
    self.X := X;
    self.Y := Y;
    self.mns := new List<Manu>;
    Init(LPS);
  end;
  
  public procedure UnInit;
  begin
    inherited UnInit;
    foreach var M in mns do
    begin
      AllLvl0.Add(M);
      M.DPos.X := DPos.X;
      M.DPos.Y := DPos.Y;
    end;
    mns.Clear;
  end;

end;

ClickRectManu = class(Manu)

private 
  BRect: RectangleF;
  LMB: boolean;
  LMBOnBRect: boolean;
  
  public class WallTex := new Texture(GetResourceStream('wall.im'), false, true, true, true);
  public class SettingsTex := new Texture(GetResourceStream('settings.im'), false, true, true, true);
  public class TeleporTex := new Texture(GetResourceStream('teleport.im'), false, true, true, true);
  public class SaveTex := new Texture(GetResourceStream('save.im'), false, true, true, true);
  public class ExitTex := new Texture(GetResourceStream('exit.im'), false, true, true, true);
  
  public class WallBottonManu: ClickRectManu;
  public class WallSettingsManu: ClickRectManu;
  public class TeleportBackManu: ClickRectManu;
  public class SaveBottonManu: ClickRectManu;
  public class ExitBottonManu: ClickRectManu;

public 
  CTP: Point;
  Tex, HelpTextTex: Texture;
  ClickProc: procedure;
  
  public class All := new List<ClickRectManu>;
  
  
  public class procedure MoveCol(from, &to: Point);
  begin
    var dx := &to.X - from.X;
    var dy := &to.Y - from.Y;
    foreach var CRM in All do
      if CRM.CTP = from then
      begin
        CRM.CTP := &to;
        foreach var arrobj in CRM.obj do
          foreach var obj in arrobj do
            foreach var pt in obj.pts do
            begin
              pt.X += dx;
              pt.Y += dy;
            end;
      end;
  end;
  
  
  public procedure DopRedraw(X, Y: integer); virtual;
  begin
    BRect := new Rectangle(X, Y, Tex.w, Tex.h);
  end;
  
  public class procedure RedrawCol(P: PointF);
  begin
    var h := 0;
    foreach var CRM in All do
      if CRM.active = 0 then
        if (CRM.DPos.X + CRM.CTP.X = P.X) and (CRM.DPos.Y + CRM.CTP.Y = P.Y) then
        begin
          CRM.obj[0][0] := glObject.Rectangle(CRM.Tex, CRM.CTP.X, CRM.CTP.Y + h);
          if CRM.DPos.X + CRM.CTP.X + CRM.Tex.w + CRM.HelpTextTex.w > WH then
            CRM.obj[1][0] := glObject.Rectangle(CRM.HelpTextTex, CRM.CTP.X - CRM.HelpTextTex.w, CRM.CTP.Y + h) else
            CRM.obj[1][0] := glObject.Rectangle(CRM.HelpTextTex, CRM.CTP.X + CRM.Tex.w, CRM.CTP.Y + h);
          CRM.DopRedraw(CRM.CTP.X, CRM.CTP.Y + h);
          h += CRM.Tex.h + 8;
        end;
  end;

public  procedure RedrawCol := RedrawCol(new PointF(DPos.X + CTP.X, DPos.Y + CTP.Y));
  
  
  public class procedure ColToForvard(P: PointF);
  begin
    var nAll := new List<ClickRectManu>(All.Count);
    
    foreach var CRM in All do
      if (CRM.DPos.X + CRM.CTP.X = P.X) and (CRM.DPos.Y + CRM.CTP.Y = P.Y) then
        nAll.Add(CRM);
    foreach var CRM in All do
      if (CRM.DPos.X + CRM.CTP.X <> P.X) or (CRM.DPos.Y + CRM.CTP.Y <> P.Y) then
        nAll.Add(CRM);
    
    All := nAll;
  end;
  
  public class procedure ColToBack(P: PointF);
  begin
    var nAll := new List<ClickRectManu>(All.Count);
    
    foreach var CRM in All do
      if (CRM.DPos.X + CRM.CTP.X <> P.X) or (CRM.DPos.Y + CRM.CTP.Y <> P.Y) then
        nAll.Add(CRM);
    foreach var CRM in All do
      if (CRM.DPos.X + CRM.CTP.X = P.X) and (CRM.DPos.Y + CRM.CTP.Y = P.Y) then
        nAll.Add(CRM);
    
    All := nAll;
  end;
  
  
  public procedure Chandge; override;
  begin
    RedrawCol;
  end;
  
  public procedure Suspend; override;
  begin
    if active <> word.MaxValue then
      active += 1;
    if active = 1 then
    begin
      MainThread.Suspend;
      RedrawCol;
    end;
  end;
  
  public procedure Resume; override;
  begin
    if active <> 0 then
    begin
      active -= 1;
      if active = 0 then
      begin
        MainThread.Resume;
        RedrawCol;
      end;
    end;
  end;
  
  
  public procedure StMain;
  begin
    var MP := System.Windows.Forms.Cursor.Position;
    var nLMBOnBRect := BRect.Contains(MP.X - DPos.X, MP.Y - DPos.Y);
    var nLMB := GetKeyState(1) shr 7 = 1;
    if LMBOnBRect and nLMBOnBRect and not LMB and nLMB and (ClickProc <> nil) then
      ClickProc;
    LMB := nLMB;
    LMBOnBRect := nLMBOnBRect;
  end;
  
  public procedure StTick(X, Y: Single);
  begin
    try
      obj[0][0].Draw;
      if BRect.Contains(X, Y) then
        obj[1][0].Draw;
    except
      on e: System.Exception do
        SaveError('Redrawing of type ', self.GetType, '|', e);
    end;
  end;
  
  
  public procedure Init(Tex: Texture; X, Y: integer; HelpText: string);
  begin
    SetLength(obj, 3);
    SetLength(obj[0], 1);
    SetLength(obj[1], 1);
    SetLength(obj[2], 1);
    
    Init(1);
    CTP := new Point(X, Y);
    self.Tex := Tex;
    HelpTextTex := Texture.GetTextTexture(HelpText, false, 0, 0, 0, 255);
    
    All.Add(self);
  end;

end;

ScrollManuElement = class(Manu)

public 
  MainTex, HelpTextTex: Texture;
  
  public class WsTexTex := new Texture(GetResourceStream('wstex.im'), false, false, true, true);
  
  public class WSTexManu: ScrollManuElement;
  
  
  public procedure StMain;
  begin
    
  end;
  
  public procedure StTick(X, Y, dx, dy, dr: Single);
  begin
    var clr := 1 - dr / 500;
    obj[0][0].Draw(1, 1, 1, clr);
    obj[1][0].Draw(1, 1, 1, clr);
  end;
  
  
  public procedure Init(Tex: Texture; HelpText: string);
  begin
    Init(1);
    MainTex := Tex;
    HelpTextTex := Texture.GetTextTexture(HelpText, false, 0, 0, 0, 255);
    SetLength(obj, 2);
    obj[0] := new glObject[1](glObject.Rectangle(MainTex, -64, -64));
    obj[1] := new glObject[1](glObject.Rectangle(HelpTextTex, -HelpTextTex.w / 2, 64));
  end;

end;

{$endregion}

{$region functional}

ScrollManu = class(Manu)

private 
  class LMP: Point;
  
  class LAct: ScrollManu;
  class nCY: Single;
  class SpcfForce: Single := 1;
  //ToDo On Screen List

public 
  class Allact := new List<ScrollManu>;
  class All := new List<ScrollManu>;
  class NaNact := true;
  class TP: Single := -2;
  
  private class procedure MainScrollManuProc;
  var
    sp := 0.007;
  begin
    
    var LT := System.DateTime.Now;
    var t: System.TimeSpan;
    
    while true do
      try
        
        if Allact.Count = 0 <> NaNact then
          NaNact := not NaNact;
        if NaNact and (TP > -2) then
        begin
          TP -= sp;
          if TP < -2 then TP := -2;
        end else
        begin
          if not NaNact and (TP = -2) then TP := 2;
          if not NaNact and (TP > 0) then
          begin
            var nTP := TP - sp;
            if nTP < 0 then nTP := 0;
            TP := nTP;
          end;
        end;
        
        if TP = 0 then
        begin
          
        end;
        
        if GetKeyState(27) shr 7 = 1 then
          while Allact.Count > 0 do
            Allact[0].Suspend;
        
        t := LT - System.DateTime.Now;
        if t.TotalMilliseconds > 0 then
          System.Threading.Thread.Sleep(t);
        LT := LT.AddMilliseconds(1);
      
      except
        on e: System.Exception do
          SaveError('Main ScrollManu Thread:', e);
      end;
    
  end;
  
  public class procedure CTick2D;
  begin
    if TP = -2 then exit;
    gr.Rectangle(true, 0, 0, 0, 1, TP * WW, 0, WW * 2, WH);
    foreach var M in All do
      M.Tick2D(MP.X, MP.Y, nil);
  end;
  
  private class function InitMainThread: System.Threading.Thread;
  begin
    Result := new System.Threading.Thread(MainScrollManuProc);
    Result.Start;
  end;
  
  private class MainScrollManuThread := InitMainThread;

public 
  mns: List<ScrollManuElement>;
  CX, CY: Single;
  
  public procedure Main; override;
  begin
    if LMS then exit;
    var MP := System.Windows.Forms.Cursor.Position;
  end;
  
  
  public procedure Tick2D(X, Y: Single; _data: object); override;
  begin
    if (Allact.Count <> 0) and (active <> 0) then exit;
    if abs(TP) > 1 then exit;
    var dx := 75 - mns.Count * 150 / 2 + CX;
    var ShiftY := WH / 2 + CY;
    foreach var M in mns do
    begin
      glPushMatrix;
      var ShiftX := TP * WW + dx + WW / 2;
        //var ShiftX := TP * WW+dx+X;
      glTranslatef(ShiftX, ShiftY, 0);
      
      M.Tick2D(X - ShiftX, Y - ShiftY, (Single(dx), Single(CY)));
      
      glPopMatrix;
      dx += 150;
    end;
  end;
  
  
  public class procedure UpdateActive;
  begin
    if Allact.Count = 0 then exit;
    var dy := -Allact.Count * 75;
    foreach var M in Allact do
    begin
      M.CY := dy;
      dy += 150;
    end;
  end;
  
  
  public procedure AddElement(E: ScrollManuElement);
  begin
    AllLvl0.Remove(E);
    mns.Add(E);
  end;
  
  public procedure RemoveElement(E: ScrollManuElement);
  begin
    mns.Remove(E);
    AllLvl0.Add(E);
  end;
  
  
  public procedure Suspend; override;
  begin
    if active = 0 then
    begin
      MainThread.Suspend;
      Allact.Remove(self);
    end;
    if active <> word.MaxValue then
      active += 1;
  end;
  
  public procedure Resume; override;
  begin
    if active <> 0 then
    begin
      active -= 1;
      if active = 0 then
      begin
        MainThread.Resume;
        if Allact.Count = 0 then
        begin
          LAct := self;
          nCY := 0;
          
        end else
        begin
          
        end;
        Allact.Add(self);
      end;
    end;
  end;
  
  
  public constructor;
  begin
    SetLength(obj, 0);
    mns := new List<ScrollManuElement>;
    
    Init(1);
    MainThread.Suspend;
    active := 1;
    AllLvl0.Remove(self);
    All.Add(self);
  end;
  
  public destructor destroy;
  begin
    UnInit;
  end;

end;

LeftSlideManuContener = class(ManuContener)
  
  W: Single;
  
  public procedure Main; override;
  begin
    if LMS then exit;
    if ScrollManu.TP <> -2 then exit;
    var MP := System.Windows.Forms.Cursor.Position;
    var nX := X;
    if (MP.X <= X + W) and (MP.Y >= Y) and (MP.Y <= Y + obj[0][0].pts[2].Y) then
      X += 0.6 else
      X -= 0.6;
    if X < -W then X := -W else
    if X > 0 then X := 0;
    if nX <> X then
      foreach var M in mns do
      begin
        M.DPos.X := DPos.X + X;
        M.Chandge;
      end;
  end;
  
  public procedure Tick2D(X, Y: Single; _data: object); override;
  begin
    if active > 0 then exit;
    if self.X = -W then exit;
    glPushMatrix;
    glTranslatef(self.X, self.Y, 0);
    obj[0][0].Draw;
    foreach var M in mns do
      M.Tick2D(X - self.X, Y - self.Y, nil);
    glPopMatrix;
  end;
  
  
  public constructor(Y, W, H: Single);
  begin
    self.W := W;
    SetLength(obj, 1);
    obj[0] := new glObject[1](glObject.Rectangle(true, 0.7, 0.7, 0.7, 0.8, 0, 0, W, H));
    
    Init(1, -W, Y);
  end;
  
  public destructor destroy;
  begin
    UnInit;
  end;

end;

RigthSlideManuContener = class(ManuContener)
  
  W: Single;
  
  public procedure Main; override;
  begin
    if LMS then exit;
    if ScrollManu.TP <> -2 then exit;
    var MP := System.Windows.Forms.Cursor.Position;
    var nX := X;
    if (MP.X >= X - 1) and (MP.Y >= Y) and (MP.Y <= Y + obj[0][0].pts[2].Y) then
      X -= 0.6 else
      X += 0.6;
    if X < WW - W then X := WW - W else
    if X > WW then X := WW;
    if nX <> X then
      foreach var M in mns do
      begin
        M.DPos.X := DPos.X + X;
        M.Chandge;
      end;
  end;
  
  public procedure Tick2D(X, Y: Single; _data: object); override;
  begin
    if active > 0 then exit;
    if self.X = WW then exit;
    glPushMatrix;
    glTranslatef(self.X, self.Y, 0);
    obj[0][0].Draw;
    foreach var M in mns do
      M.Tick2D(X - self.X, Y - self.Y, nil);
    glPopMatrix;
  end;
  
  
  public constructor(Y, W, H: Single);
  begin
    SetLength(obj, 1);
    obj[0] := new glObject[1](glObject.Rectangle(true, 0.7, 0.7, 0.7, 0.8, 0, 0, W, H));
    self.W := W;
    
    Init(1, WW, Y);
  end;
  
  public destructor destroy;
  begin
    UnInit;
  end;

end;

{$endregion}

{$region specific}

{$region LSlider}

WallSettings = class(ClickRectManu)

private 
  class It: MData.WallSettings;
  
  public procedure DopRedraw(X, Y: integer); override;
  begin
    obj[2][0] := glObject.Rectangle(true, 0, 0, 0, 0.2, X, Y, Tex.w, Tex.h);
    BRect := new Rectangle(X, Y, Tex.w, Tex.h);
  end;
  
  public procedure Main; override;
  begin
    if ScrollManu.TP <> -2 then exit;
    StMain;
  end;
  
  public procedure Tick2D(X, Y: Single; _data: object); override;
  begin
    if active <> 0 then exit;
    StTick(X, Y);
    if not BRect.Contains(X, Y) then
      obj[2][0].Draw;
  end;
  
  
  constructor(OnClick: procedure);
  begin
    It := self;
    
    ClickProc := OnClick;
    
    WallSettingsManu := self;
    RedrawCol;
    Init(SettingsTex, 8, 8, 'Изменение параметров добавляемой стенки');
  end;
  
  destructor destroy;
  begin
    UnInit;
  end;

end;

WallBotton = class(ClickRectManu)
  
  public procedure DopRedraw(X, Y: integer); override;
  begin
    obj[2][0] := glObject.Rectangle(true, 0, 0, 0, 0.2, X, Y, Tex.w, Tex.h);
    BRect := new Rectangle(X, Y, Tex.w, Tex.h);
  end;
  
  public procedure Main; override;
  begin
    if ScrollManu.TP <> -2 then exit;
    StMain;
  end;
  
  public procedure Tick2D(X, Y: Single; _data: object); override;
  begin
    if active <> 0 then exit;
    StTick(X, Y);
    if not BRect.Contains(X, Y) then
      obj[2][0].Draw;
  end;
  
  
  constructor;
  begin
    ClickProc := nil;
    
    WallBottonManu := self;
    
    Init(WallTex, 8, 8, 'Добавление стенки');
    RedrawCol;
  end;
  
  destructor destroy;
  begin
    UnInit;
  end;

end;

{$endregion}

{$region RSlider}

TeleportBack = class(ClickRectManu)
  
  public procedure DopRedraw(X, Y: integer); override;
  begin
    obj[2][0] := glObject.Rectangle(true, 0, 0, 0, 0.2, X, Y, Tex.w, Tex.h);
    BRect := new Rectangle(X, Y, Tex.w, Tex.h);
  end;
  
  public procedure Main; override;
  begin
    if ScrollManu.TP <> -2 then exit;
    StMain;
  end;
  
  public procedure Tick2D(X, Y: Single; _data: object); override;
  begin
    if active <> 0 then exit;
    StTick(X, Y);
    if not BRect.Contains(X, Y) then
      obj[2][0].Draw;
  end;
  
  
  constructor;
  begin
    ClickProc := Camera.SetStandart;
    TeleportBackManu := self;
    
    Init(TeleporTex, 8, 8, 'Телепорт назад');
    RedrawCol;
  end;
  
  destructor destroy;
  begin
    UnInit;
  end;

end;

SaveBotton = class(ClickRectManu)
  
  public procedure DopRedraw(X, Y: integer); override;
  begin
    obj[2][0] := glObject.Rectangle(true, 0, 0, 0, 0.2, X, Y, Tex.w, Tex.h);
    BRect := new Rectangle(X, Y, Tex.w, Tex.h);
  end;
  
  public procedure Main; override;
  begin
    if ScrollManu.TP <> -2 then exit;
    StMain;
  end;
  
  public procedure Tick2D(X, Y: Single; _data: object); override;
  begin
    if active <> 0 then exit;
    StTick(X, Y);
    if not BRect.Contains(X, Y) then
      obj[2][0].Draw;
  end;
  
  
  constructor;
  begin
    ClickProc := nil;
    SaveBottonManu := self;
    
    Init(SaveTex, 8, 8, 'Сохранение');
    RedrawCol;
  end;
  
  destructor destroy;
  begin
    UnInit;
  end;

end;

ExitBotton = class(ClickRectManu)
  
  public procedure DopRedraw(X, Y: integer); override;
  begin
    obj[2][0] := glObject.Rectangle(true, 0, 0, 0, 0.2, X, Y, Tex.w, Tex.h);
    BRect := new Rectangle(X, Y, Tex.w, Tex.h);
  end;
  
  public procedure Main; override;
  begin
    if ScrollManu.TP <> -2 then exit;
    StMain;
  end;
  
  public procedure Tick2D(X, Y: Single; _data: object); override;
  begin
    if active <> 0 then exit;
    StTick(X, Y);
    if not BRect.Contains(X, Y) then
      obj[2][0].Draw;
  end;
  
  
  constructor;
  begin
    ClickProc := MF.Close;
    ExitBottonManu := self;
    
    RedrawCol;
    Init(ExitTex, 8, 8, 'Выход из программы');
  end;
  
  destructor destroy;
  begin
    UnInit;
  end;

end;

{$endregion}

{$region ScrolElements}

WSTex = class(ScrollManuElement)
  
  public procedure Main; override;
  begin
    
  end;
  
  public procedure Tick2D(X, Y: Single; _data: object); override;
  type
    Single2 = (Single, Single);
  begin
    var (dx, dy) := Single2(_data);
    StTick(X, Y, dx, dy, sqrt(sqr(dx) + sqr(dy)));
  end;
  
  constructor;
  begin
    Init(WsTexTex, 'Настройки текстуры');
  end;
  
  destructor destroy;
  begin
    UnInit;
  end;

end;

{$endregion}

{$endregion}

end.