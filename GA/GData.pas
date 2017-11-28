{$reference System.Windows.Forms.dll}
{$reference System.Drawing.dll}

{apptype windows}

unit GData;

uses OpenGL,System.Drawing, TData, PerlinNoiseData, CellTexData;

var
  StartTime := System.DateTime.Now;
  
  k := new boolean[256];

procedure WTF(name: string; params obj: array of object) := System.IO.File.AppendAllText(name, string.Join('', obj.ConvertAll(a -> _ObjectToString(a))) + char(13) + char(10));

procedure SaveError(params obj: array of object);
begin
  (new System.Threading.Thread(()->begin
    
    (new System.Threading.Thread(()->System.Console.Beep(1000, 1000))).Start;
    if not System.IO.File.Exists('Errors.txt') then
      WTF('Errors.txt', 'Started|', StartTime);
    var b := true;
    while b do
      try
        WTF('Errors.txt', new object[2](System.DateTime.Now, '|') + obj);
        b := false;
      except
      end;
    
  end)).Start;
end;

procedure Log(params data: array of object) := WTF('Log.txt', data);

procedure Log2(params data: array of object) := WTF('Log2.txt', data);

procedure Log3(params data: array of object) := WTF('Log3.txt', data);

{$region Dop}

type
  ST3 = (Single, Single, Single);

const
  ST30: ST3 = (Single(0), Single(0), Single(0));

function operator+(a, b: ST3): ST3; extensionmethod;
begin
  Result := (a.Item1 + b.Item1, a.Item2 + b.Item2, a.Item3 + b.Item3);
end;

function operator-(a, b: ST3): ST3; extensionmethod;
begin
  Result := (a.Item1 - b.Item1, a.Item2 - b.Item2, a.Item3 - b.Item3);
end;

function operator*(a: ST3; b: Single): ST3; extensionmethod;
begin
  Result := (a.Item1 * b, a.Item2 * b, a.Item3 * b);
end;

{$endregion}

var
  WW, WH: word;
  _hdc: HDC;
  MW: Single;
  MF: System.windows.forms.Form;

{$region external}

function GetDesktopWindow: system.IntPtr;
external 'User32.dll' name 'GetDesktopWindow';

procedure GetWindowRect(hWnd: system.IntPtr; var lpRect: system.Drawing.Rectangle);
external 'User32.dll' name 'GetWindowRect';

function GetKeyState(KeyId: byte): byte;
external 'User32.dll' name 'GetKeyState';

procedure SetCursorPos(x, y: integer);
external 'User32.dll' name 'SetCursorPos';

procedure GetCursorPos(p: ^Point);
external 'User32.dll' name 'GetCursorPos';

function GetCursorPos: Point;
begin
  GetCursorPos(@Result);
end;

procedure glGenTextures(n: integer; textures: Pointer);
external 'OpenGL32.dll' name 'glGenTextures';

procedure glBindTexture(target: GLenum; texture: GLuint);
external 'OpenGL32.dll' name 'glBindTexture';

{$endregion}

{$region 2D functions}

function ArcTg(dx, dy: real): real := (dx = 0 ? dy > 0 ? Pi / 2 : -Pi / 2 : ArcTan(dy / dx)) + (dx < 0 ? Pi : 0);

function Rotate(a, b, rot: real): PointF;
begin
  with Result do
  begin
    var r := sqrt(sqr(a) + sqr(b));
    var ang := ArcTg(a, b) + rot;
    X := Cos(ang) * r;
    Y := Sin(ang) * r;
  end;
end;

function Rotate(a: array of PointF; rot: real): array of PointF;
begin
  Result := new PointF[a.Length];
  for i: integer := 0 to a.Length - 1 do
    a[i] := Rotate(a[i].X, a[i].Y, rot);
  Result := a;
end;

function Rotate(p: PointF; rot: real) := Rotate(p.X, p.Y, rot);

procedure ChAngDif(var nCh: Single; tCh, ante: Single);
begin
  var dif := tCh - nCh;
  while dif < -Pi do dif += Pi * 2;
  while dif > Pi do dif -= Pi * 2;
  if abs(dif) < 0.03 then
    nCh := tCh else
    nCh += dif * ante;
end;

function Add(p: array of PointF; dX, dY: real): array of PointF;
begin
  for i: integer := 0 to p.Length - 1 do
  begin
    p[i].X += dX;
    p[i].Y += dY;
  end;
  Result := p;
end;

function Mlt(p: array of PointF; r: real): array of PointF;
begin
  for i: integer := 0 to p.Length - 1 do
  begin
    p[i].X *= r;
    p[i].Y *= r;
  end;
  Result := p;
end;

function Rand(r: real) := (Random * 2 - 1) * r;

{$endregion}

{$region 3DTypes}

type
  Point3i = record
    X, Y, Z: integer;
    
    constructor create(X, Y, Z: integer);
    begin
      self.X := X;
      self.Y := Y;
      self.Z := Z;
    end;
  end;
  
  PPoint = record
    
    X, Y, Z: real;
    
    constructor create(X, Y, Z: real);
    begin
      self.X := X;
      self.Y := Y;
      self.Z := Z;
    end;
  
  end;
  TPoint = record
    
    X, Y, Z: real;
    TX, TY: Single;
    
    constructor create(X, Y, Z: real; TX, TY: Single);
    begin
      self.X := X;
      self.Y := Y;
      self.Z := Z;
      self.TX := TX;
      self.TY := TY;
    end;
  
  
  end;
  CPoint = record
    
    X, Y, Z: real;
    cr, cg, cb, ca: Single;
    
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
  
  Texture = class
    
    private class TexCrProcs := new List<procedure>;
    
    protected class procedure AddTexCrProc(p:procedure);
    begin
      var nTexCrProcs := TexCrProcs.ToList;
      nTexCrProcs.Add(p);
      TexCrProcs := nTexCrProcs;
    end;
    
    public class procedure CreateWaitTextures(n: cardinal);
    begin
      loop n do
        if TexCrProcs.Count = 0 then exit else
        begin
          var p := TexCrProcs[0];
          if p <> nil then p();
          TexCrProcs.Remove(p);
        end;
    end;
    
    public class procedure CreateWaitTextures := CreateWaitTextures(TexCrProcs.Count);
    
    public class WaitToCreateTexture := true;
  
  public 
    id: cardinal;
    w, h: word;
    clrs: array of byte;
    FiltersNearest, NoMipmaps, alpha: boolean;
    
    
    procedure Redraw(FiltersNearest: boolean := false; NoMipmaps: boolean := false);
    begin
      glBindTexture(GL_TEXTURE_2D, id);
      if NoMipmaps then
        if alpha then
          glTexImage2D(GL_TEXTURE_2D, 0, 4, w, h, 0, GL_RGBA, GL_UNSIGNED_BYTE, @clrs[0]) else
          glTexImage2D(GL_TEXTURE_2D, 0, 3, w, h, 0, GL_RGB, GL_UNSIGNED_BYTE, @clrs[0]) else
      if alpha then
        gluBuild2DMipmaps(GL_TEXTURE_2D, 4, w, h, GL_RGBA, GL_UNSIGNED_BYTE, @clrs[0]) else
        gluBuild2DMipmaps(GL_TEXTURE_2D, 3, w, h, GL_RGB, GL_UNSIGNED_BYTE, @clrs[0]);
      if FiltersNearest then
      begin
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
      end;
      glBindTexture(GL_TEXTURE_2D, 0);
    end;
    
    procedure SetVal(w, h: word; clrs: array of byte; alpha: boolean := false; DoRedraw: boolean := false; FiltersNearest: boolean := false; NoMipmaps: boolean := false);
    begin
      self.w := w;
      self.h := h;
      self.clrs := clrs;
      self.alpha := alpha;
      self.FiltersNearest := FiltersNearest;
      self.NoMipmaps := NoMipmaps;
      
      if DoRedraw then
        if WaitToCreateTexture then
          TexCrProcs.Add(()->begin self.Redraw(FiltersNearest, NoMipmaps) end) else
          Redraw(FiltersNearest, NoMipmaps);
    end;
    
    constructor create(w, h: word; clrs: array of byte; alpha: boolean := false; DoRedraw: boolean := false; FiltersNearest: boolean := false; NoMipmaps: boolean := false);
    begin
      self.w := w;
      self.h := h;
      self.clrs := clrs;
      self.alpha := alpha;
      self.FiltersNearest := FiltersNearest;
      self.NoMipmaps := NoMipmaps;
      
      if WaitToCreateTexture then
        if DoRedraw then
          
          AddTexCrProc(()->begin
            glGenTextures(1, @id);
            self.Redraw(FiltersNearest, NoMipmaps);
          end) else
        
          AddTexCrProc(()->begin
            glGenTextures(1, @id);
          end) else
      
      begin
        glGenTextures(1, @id);
        if DoRedraw then
          Redraw(FiltersNearest, NoMipmaps);
      end;
    end;
    
    constructor create(re: System.IO.BinaryReader; alpha: boolean := false; DoRedraw: boolean := false; FiltersNearest: boolean := false; NoMipmaps: boolean := false);
    begin
      w := re.ReadUInt16;
      h := re.ReadUInt16;
      if alpha then
        clrs := new byte[w * h * 4] else
        clrs := new byte[w * h * 3];
      re.Read(clrs, 0, clrs.Length);
      
      self.alpha := alpha;
      self.FiltersNearest := FiltersNearest;
      self.NoMipmaps := NoMipmaps;
      
      if Texture.WaitToCreateTexture then
        if DoRedraw then
          
          AddTexCrProc(()->begin
          glGenTextures(1, @id);
          self.Redraw(FiltersNearest, NoMipmaps);
            end) else
        
          AddTexCrProc(()->begin
          glGenTextures(1, @id);
            end) else
      
      begin
        glGenTextures(1, @id);
        if DoRedraw then
          Redraw(FiltersNearest, NoMipmaps);
      end;
    end;
    
    constructor create(str: System.IO.Stream; CloseStream: boolean := false; alpha: boolean := false; Redraw: boolean := false; RQ: boolean := false);
    begin
      create(new System.IO.BinaryReader(str), alpha, Redraw, RQ);
      if CloseStream then
        str.Close;
    end;
    
    constructor create(f: string; alpha: boolean := false; Redraw: boolean := false; RQ: boolean := false);
    begin
      create(System.IO.File.OpenRead(f), true, alpha, Redraw, RQ);
    end;
    
    procedure Save(wr: System.IO.BinaryWriter; CloseStream: boolean := false);
    begin
      wr.Write(w);
      wr.Write(h);
      wr.Write(clrs);
      if CloseStream then
        wr.BaseStream.Close;
    end;
    
    procedure Save(str: System.IO.Stream; CloseStream: boolean := false) := Save(new System.IO.BinaryWriter(str), CloseStream) ;
    
    procedure Save(f: string) := Save(System.IO.File.Exists(f) ? System.IO.File.OpenRead(f) : System.IO.File.Create(f), true);
    
    class function GetPaternBytes(c: cardinal; func: integer->byte): array of byte;
    begin
      Result := new byte[c];
      Result.Fill(func);
    end;
    
    class function GetPaternBytes(w, h: cardinal; BPP: byte; func: (cardinal,cardinal,byte)->byte): array of byte;
    begin
      Result := new byte[w * h * BPP];
      for y: cardinal := 0 to h - 1 do
        for x: cardinal := 0 to w - 1 do
          for b: byte := 0 to BPP - 1 do
            Result[b + BPP * (x + w * y)] := func(x, y, b);
    end;
    
    class function GetPerlinNoisePaternBytes1(DetLvl: word; w, h: cardinal; cr, cg, cb, dcr, dcg, dcb: Single; Frq, Amp: Single; Step: Single := 2): array of byte;
    begin
      
      var Mtx := new ST3[w, h];
      Mtx.Fill((x, y)-> ST30);
      
      var k := Frq / Min(w, h);
      var tm: Single := 0;
      
      loop DetLvl do
      begin
        var nMtx := new ST3[Ceil(w * k) + 1, Ceil(h * k) + 1];
        nMtx.Fill((x, y)-> (Single(Rand(dcr * Amp)),
        Single(Rand(dcg * Amp)),
        Single(Rand(dcb * Amp))
        ));
        
        for x: cardinal := 0 to w - 1 do
          for y: cardinal := 0 to h - 1 do
          begin
            var nx1 := Floor(x * k);
            var nx2 := Ceil(x * k);
            var ny1 := Floor(y * k);
            var ny2 := Ceil(y * k);
            var x1 := nx1 / k;
            var x2 := nx2 / k;
            var y1 := ny1 / k;
            var y2 := ny2 / k;
            
            var v, v1, v2: ST3;
            
            if x1 = x2 then
            begin
              v1 := nMtx[nx1, ny1];
              v2 := nMtx[nx1, ny2];
            end else
            begin
              var xk := (x - x1) / (x2 - x1);
              v1 := nMtx[nx1, ny1] + (nMtx[nx2, ny1] - nMtx[nx1, ny1]) * xk;
              v2 := nMtx[nx1, ny2] + (nMtx[nx2, ny2] - nMtx[nx1, ny2]) * xk;
            end;
            
            if y1 = y2 then
              v := v1 else
            begin
              var yk := (y - y1) / (y2 - y1);
              v := v1 + (v2 - v1) * yk;
            end;
            
            Mtx[x, y] := Mtx[x, y] + v;
          end;
        
        tm += Amp;
        Amp /= Step;
        Frq *= Step;
      end;
      
      Result := new byte[w * h * 3];
      
      var i := 0;
      for y: cardinal := 0 to h - 1 do
        for x: cardinal := 0 to w - 1 do
        begin
          Result[i + 0] := Round((cr + Mtx[x, y].Item1 / tm) * 255);
          Result[i + 1] := Round((cg + Mtx[x, y].Item2 / tm) * 255);
          Result[i + 2] := Round((cb + Mtx[x, y].Item3 / tm) * 255);
          i += 3;
        end;
      
    end;
    
    class function GetPerlinNoisePaternBytes2(w, h: cardinal; cr, cg, cb, dcr, dcg, dcb: Single; scale: Single; octaves: integer; persistence: Single := 0.5): array of byte;
    begin
      var Pe := new Perlin2D(Random(65536));
      Pe := new Perlin2D;
      var dx1: Single := Random * 9000 + 1000;
      var dy1: Single := Random * 9000 + 1000;
      var dx2: Single := Random * 900000 + 100000;
      var dy2: Single := Random * 900000 + 100000;
      var dx3: Single := Random * 90000000 + 10000000;
      var dy3: Single := Random * 90000000 + 10000000;
      Result := new byte[w * h * 3];
      for x: cardinal := 0 to w - 1 do
        for y: cardinal := 0 to h - 1 do
        begin
          var di := (x + y * w) * 3;
          Result[di + 0] := Round(255 * (cr + dcr * Pe.Noise((x + dx1) * Scale, (y + dy1) * Scale, octaves, persistence)));
          Result[di + 1] := Round(255 * (cg + dcg * Pe.Noise((x + dx2) * Scale, (y + dy2) * Scale, octaves, persistence)));
          Result[di + 2] := Round(255 * (cb + dcb * Pe.Noise((x + dx3) * Scale, (y + dy3) * Scale, octaves, persistence)));
        end;
    end;
    
    class procedure CharOnBitMap(ch: char; x, y: cardinal; BitMap: array[,] of byte);
    begin
      var b := Leters[ch];
      for dx: byte := 0 to 7 do
        for dy: byte := 0 to 11 do
          try
            BitMap[x + dx, y + dy] := b[dx, dy];
          except
          end;
    end;
    
    class function GetTextTexture(s: string; cr, cg, cb, ca: byte; bcr, bcg, bcb, bca: byte): Texture;
    begin
      
      var w := 8 * s.Length + 4;
      var h := 12;
      var BitMap := new byte[w, h];
      var clrs := new byte[w * h * 4];
      var chs := s.ToCharArray;
      
      for i: integer := 0 to chs.Length - 1 do
        if Leters.ContainsKey(chs[i]) then
          CharOnBitMap(chs[i], i * 8 + 2, 0, BitMap) else
          WTF('Log.txt', 'No such leter as ', chs[i], ' ', ord(chs[i]));
      
      begin
        var i: cardinal := 0;
        for y: byte := 0 to h - 1 do
          for x: cardinal := 0 to w - 1 do
          begin
            var f := BitMap[x, y] = 1;
            clrs[i + 0] := f ? cr : bcr;
            clrs[i + 1] := f ? cg : bcg;
            clrs[i + 2] := f ? cb : bcb;
            clrs[i + 3] := f ? ca : bca;
            i += 4;
          end;
      end;
      
      Result := new Texture(w, h, clrs, true, true, true, true);
    end;
    
    procedure Draw(mode: GLenum; pts: sequence of TPoint; r, g, b, a: Single);
    begin
      glColor4f(r, g, b, a);
      glBindTexture(GL_TEXTURE_2D, id);
      glBegin(mode);
      foreach var pt in pts do
      begin
        glTexCoord2f(pt.TX, pt.TY);
        glVertex3d(pt.X, pt.Y, pt.Z);
      end;
      glEnd;
      glBindTexture(GL_TEXTURE_2D, 0);
    end;
    
    procedure Draw(mode: GLenum; pts: sequence of TPoint) := Draw(mode, pts, 1, 1, 1, 1);
  
  end;

{$endregion}

type
  GraphField = class(System.Windows.Forms.PictureBox)
    
    timer: System.Windows.Forms.Timer;
    components: System.ComponentModel.IContainer;
    
    RedrawProc: procedure ;
    
    procedure TimerTick(sender: Object; e: system.EventArgs) := RedrawProc;
    
    constructor(x, y, w, h, I: integer; Init, Redraw: procedure);
    begin
      self.Left := x;
      self.top := y;
      self.Width := w;
      self.Height := h;
      self.RedrawProc := Redraw;
      components := new System.ComponentModel.Container;
      timer := new System.Windows.Forms.Timer(self.components);
      SuspendLayout;
      timer.Enabled := true;
      timer.Interval := I;
      _hdc := GetDC(self.Handle.ToInt32());
      OpenGLInit(self.Handle);
      
      glShadeModel(GL_SMOOTH);
      
      glEnable(GL_DEPTH_TEST);
      glDepthFunc(GL_LEQUAL);
      glClearDepth(1.0);
      glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);
      
      glEnable(GL_BLEND);
      glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
      
      glEnable(GL_TEXTURE_2D);
      Init;
      
      glMatrixMode(GL_PROJECTION);
      glLoadIdentity;
      glViewport(0, 0, Width, Height);
      gluPerspective(45.0, Width / Height, 0.1, real.MaxValue);
      glClearColor(0.0, 0.0, 0.0, 1.0);
      
      glMatrixMode(GL_MODELVIEW);
      
      Cursor.Dispose;
      timer.Tick += TimerTick;
    end;
  
  end;

//ToDo
type
  gr = abstract sealed class
    
    {$region 2D}
    
    public class procedure Polygon(Fill: boolean; cr, cg, cb, ca: Single; pts: array of PointF);
    begin
      if Fill then
        glBegin(GL_POLYGON) else
        glBegin(GL_LINE_LOOP);
      glColor4f(cr, cg, cb, ca);
      for i: integer := 0 to pts.Length - 1 do
        glVertex2f(pts[i].X, pts[i].Y);
      glEnd;
    end;
    
    public class procedure Lines(cr, cg, cb, ca: Single; pts: array of PointF);
    begin
      glBegin(GL_LINE_STRIP);
      glColor4f(cr, cg, cb, ca);
      for i: integer := 0 to pts.Length - 1 do
        glVertex2f(pts[i].X, pts[i].Y);
      glEnd;
    end;
    
    public class procedure Rectangle(Fill: boolean; cr, cg, cb, ca: Single; X, Y, W, H: Single);
    begin
      if Fill then
        glBegin(GL_QUADS) else
        glBegin(GL_LINE_LOOP);
      //glBindTexture(GL_TEXTURE_2D, TempTex);
      //gluBuild2DMipmaps(GL_TEXTURE_2D, 3, 1, 1, GL_RGB, GL_UNSIGNED_BYTE, @(new byte[3](0,0,0))[0]);
      glColor4f(cr, cg, cb, ca);
      glVertex2f(X, Y);
      glVertex2f(X + W, Y);
      glVertex2f(X + W, Y + H);
      glVertex2f(X, Y + H);
      glEnd;
    end;
    
    public class function Ellipse(X, Y, W, H: Single; pc: integer): array of PointF;
    begin
      Result := new PointF[pc];
      var dang := Pi * 2 / pc;
      for i: integer := 0 to pc - 1 do
        Result[i] := new PointF(X + W * Cos(dang * i), Y + H * Sin(dang * i));
    end;
    
    public class procedure Ellipse(Fill: boolean; cr, cg, cb, ca: Single; X, Y, W, H: Single; pc: integer) := Polygon(Fill, cr, cg, cb, ca, Ellipse(X, Y, W, H, pc));
    
    //ToDo
    public class procedure Donut(ec1, ec2, ec3, ec4, ic1, ic2, ic3, ic4: byte; X, Y, eW, eH, iW, iH: Single);
    const
      EllipseQuality = 255;
    begin
      var DonPts: array[0..1] of array[1..EllipseQuality] of PointF;
      
      var dang := Pi * 2 / EllipseQuality;
      for i: byte := 1 to EllipseQuality do
      begin
        DonPts[0, i] := new PointF(X + iW * Cos(dang * i), Y + iH * Sin(dang * i));
        DonPts[1, i] := new PointF(X + eW * Cos(dang * i), Y + eH * Sin(dang * i));
      end;
      
      glBegin(GL_QUAD_STRIP);
      for i: integer := 1 to EllipseQuality do
      begin
        glColor4ub(ic1, ic2, ic3, ic4);
        glVertex2f(DonPts[0, i].X, DonPts[0, i].Y);
        glColor4ub(ec1, ec2, ec3, ec4);
        glVertex2f(DonPts[1, i].X, DonPts[1, i].Y);
      end;
      glColor4ub(ic1, ic2, ic3, ic4);
      glVertex2f(DonPts[0, 1].X, DonPts[0, 1].Y);
      glColor4ub(ec1, ec2, ec3, ec4);
      glVertex2f(DonPts[1, 1].X, DonPts[1, 1].Y);
      glEnd;
    end;
    
    private class LastCurrsorPoss := new Point[0];
    private class ArrN: byte := 0;
    
    private class procedure CT2p1top2(var p1: PointF; p2: Point);
    begin
      var Sh := new PointF(p2.X - p1.X, p2.Y - p1.Y);
      var r := Power(sqr(Sh.X) + sqr(Sh.Y), -0.3);
      if real.IsNaN(r) or (r > 1) then r := 1;
      p1.X += Sh.X * r;
      p1.Y += Sh.Y * r;
    end;
    
    public class procedure DrawCurrsor(CT: byte; var CAct: byte; MP: Point);
    
    const
      CT2PetalCount: byte = 8;
      CT2PursueCount: byte = 12;
      l1 = 20;
      l2 = 120;
    
    begin
      if CT = 0 then exit;
      
      if CT = 1 then begin
        
        if LastCurrsorPoss.Length <> 0 then
          LastCurrsorPoss := new Point[0];
        
        var ang := CAct / 256 * Pi * 3;
        var ext := 30 - abs(Sin(ang * 2)) * 10;
        
        glBegin(GL_TRIANGLE_FAN);
        
        glColor4f(0.5, 0.5, 0.5, 0.3 + abs(sin(ang * 2)) * 0.2);
        glVertex2f(MP.X, MP.Y);
        
        glColor4f(0.5, 0.5, 0.5, 1);
        glVertex2f(MP.X + Cos(ang + Pi / 4 * 0) * ext, MP.Y + Sin(ang + Pi / 4 * 0) * ext);
        glVertex2f(MP.X + Cos(ang + Pi / 4 * 1) * 10, MP.Y + Sin(ang + Pi / 4 * 1) * 10);
        glVertex2f(MP.X + Cos(ang + Pi / 4 * 2) * ext, MP.Y + Sin(ang + Pi / 4 * 2) * ext);
        glVertex2f(MP.X + Cos(ang + Pi / 4 * 3) * 10, MP.Y + Sin(ang + Pi / 4 * 3) * 10);
        glVertex2f(MP.X + Cos(ang + Pi / 4 * 4) * ext, MP.Y + Sin(ang + Pi / 4 * 4) * ext);
        glVertex2f(MP.X + Cos(ang + Pi / 4 * 5) * 10, MP.Y + Sin(ang + Pi / 4 * 5) * 10);
        glVertex2f(MP.X + Cos(ang + Pi / 4 * 6) * ext, MP.Y + Sin(ang + Pi / 4 * 6) * ext);
        glVertex2f(MP.X + Cos(ang + Pi / 4 * 7) * 10, MP.Y + Sin(ang + Pi / 4 * 7) * 10);
        glVertex2f(MP.X + Cos(ang + Pi / 4 * 0) * ext, MP.Y + Sin(ang + Pi / 4 * 0) * ext);
        
        glEnd;
        
        CAct += 1;
        
      end else if CT = 2 then begin
        
        if LastCurrsorPoss.Length <> 256 then
        begin
          LastCurrsorPoss := new Point[256];
          LastCurrsorPoss.Fill(i -> MP);
        end else
          LastCurrsorPoss[ArrN] := MP;
        
        gr.Ellipse(true, 0, 0, 0, 1, MP.X, MP.Y, 7, 7, 16);
        gr.Ellipse(true, 1, 1, 1, 1, MP.X, MP.Y, 6, 6, 16);
        
        var sang := CAct / 256 * Pi * 5;
        glColor4f(0, 0, 0, 1);
        glBegin(GL_LINES);
        
        for i: byte := 1 to CT2PetalCount do
        begin
          
          var ang := sang + i / CT2PetalCount * Pi * 2;
          
          var p1 := new PointF(MP.X + Cos(ang) * l1, MP.Y + Sin(ang) * l1);
          var p2 := new PointF(MP.X + Cos(ang) * l2, MP.Y + Sin(ang) * l2);
          
          for i2: byte := 0 to CT2PursueCount do
          begin
            //CT2p1top2(p1,LastCurrsorPoss[byte(ArrN-i2)]);
            CT2p1top2(p2, LastCurrsorPoss[byte(ArrN - i2)]);
          end;
          
          if false then
          begin
            var r := 45;
            var nr := sqrt(sqr(p2.X - MP.X) + sqr(p2.Y - MP.Y));
            p2.X := (p2.X - MP.X) / nr * r + MP.X;
            p2.Y := (p2.Y - MP.Y) / nr * r + MP.Y;
          end;
          
          glVertex2f(p1.X, p1.Y);
          glVertex2f(p2.X, p2.Y);
          
        end;
        
        glEnd;
        
        ArrN += 1;
        CAct += 1;
        
      end else;
    end;
    
    {$endregion}
    
    {$region 3D}
    
    public class procedure Polygon(Fill: boolean; cr, cg, cb, ca: Single; pts: array of PPoint);
    begin
      if Fill then
        glBegin(GL_POLYGON) else
        glBegin(GL_LINE_LOOP);
      glColor4f(cr, cg, cb, ca);
      for i: integer := 0 to pts.Length - 1 do
        glVertex3d(pts[i].X, pts[i].Y, pts[i].Z);
      glEnd;
    end;
    
    public class procedure Lines(cr, cg, cb, ca: Single; pts: array of PPoint);
    begin
      glBegin(GL_LINE_STRIP);
      glColor4f(cr, cg, cb, ca);
      for i: integer := 0 to pts.Length - 1 do
        glVertex3d(pts[i].X, pts[i].Y, pts[i].Z);
      glEnd;
    end;
    
    public class procedure Cube(cr, cg, cb, ca: Single; X, Y, Z, dX, dY, dZ: real);
    begin
      
      glBegin(GL_QUADS);
      glColor4f(cr, cg, cb, ca);
      
      glVertex3d(X + 00, Y + 00, Z + 00);
      glVertex3d(X + dX, Y + 00, Z + 00);
      glVertex3d(X + dX, Y + dY, Z + 00);
      glVertex3d(X + 00, Y + dY, Z + 00);
      
      glVertex3d(X + 00, Y + 00, Z + dZ);
      glVertex3d(X + dX, Y + 00, Z + dZ);
      glVertex3d(X + dX, Y + dY, Z + dZ);
      glVertex3d(X + 00, Y + dY, Z + dZ);
      
      glVertex3d(X + 00, Y + 00, Z + 00);
      glVertex3d(X + dX, Y + 00, Z + 00);
      glVertex3d(X + dX, Y + 00, Z + dZ);
      glVertex3d(X + 00, Y + 00, Z + dZ);
      
      glVertex3d(X + 00, Y + dY, Z + 00);
      glVertex3d(X + dX, Y + dY, Z + 00);
      glVertex3d(X + dX, Y + dY, Z + dZ);
      glVertex3d(X + 00, Y + dY, Z + dZ);
      
      glVertex3d(X + 00, Y + 00, Z + 00);
      glVertex3d(X + 00, Y + 00, Z + dZ);
      glVertex3d(X + 00, Y + dY, Z + dZ);
      glVertex3d(X + 00, Y + dY, Z + 00);
      
      glVertex3d(X + dX, Y + 00, Z + 00);
      glVertex3d(X + dX, Y + 00, Z + dZ);
      glVertex3d(X + dX, Y + dY, Z + dZ);
      glVertex3d(X + dX, Y + dY, Z + 00);
      glEnd;
      
    end;
    
    public class procedure Sphere(Fill: boolean; cr, cg, cb, ca, X, Y, Z, dX, dY, dZ: Single; pc: integer) := Sphere(Fill, cr, cg, cb, ca, Sphere(X, Y, Z, dX, dY, dZ, pc));
    
    public class procedure Sphere(Fill: boolean; cr, cg, cb, ca: Single; pts: array[,] of PPoint);
    begin
      var w := pts.RowCount;
      var h := pts.ColCount;
      glColor4f(cr, cg, cb, ca);
      if Fill then
      begin
        glBegin(GL_QUADS);
        var lx := w - 1;
        for ix: integer := 0 to w - 1 do
        begin
          for iy: integer := 0 to h - 2 do
          begin
            with pts[ix, iy + 0] do glVertex3d(X, Y, Z);
            with pts[lx, iy + 0] do glVertex3d(X, Y, Z);
            with pts[lx, iy + 1] do glVertex3d(X, Y, Z);
            with pts[ix, iy + 1] do glVertex3d(X, Y, Z);
          end;
          lx := ix;
        end;
      end else
      begin
        glBegin(GL_LINES);
        for ix: integer := 0 to w - 1 do
          for iy: integer := 0 to h - 2 do
          begin
            with pts[ix, iy + 0] do glVertex3d(X, Y, Z);
            with pts[ix, iy + 1] do glVertex3d(X, Y, Z);
          end;
        for iy: integer := 1 to h - 2 do
        begin
          var lx := w - 1;
          for ix: integer := 0 to w - 1 do
          begin
            with pts[lx, iy] do glVertex3d(X, Y, Z);
            with pts[ix, iy] do glVertex3d(X, Y, Z);
            lx := ix;
          end;
        end;
      end;
      glEnd;
    end;
    
    public class function Sphere(X, Y, Z, dX, dY, dZ: Single; pc: integer): array[,] of PPoint;
    begin
      var w := pc * 2;
      var h := pc + 1;
      Result := new PPoint[w, h];
      var dangx := Pi / pc;
      var dangy := Pi / pc;
      for ix: integer := 0 to w - 1 do
      begin
        Result[ix, 0] := new PPoint(X, Y + dY, Z);
        for iy: integer := 1 to h - 2 do
        begin
          var AX := ix * dangx;
          var AY := iy * dangy;
          Result[ix, iy] := new PPoint(X + dX * Cos(AX) * Sin(AY), Y + dY * Cos(AY), Z + dZ * Sin(AX) * Sin(AY));
        end;
        Result[ix, h - 1] := new PPoint(X, Y - dY, Z);
      end;
    end;
  
    {$endregion}
  
  end;

begin
  begin
    var a: system.Drawing.Rectangle;
    GetWindowRect(GetDesktopWindow, a);
    WW := a.Width;
    WH := a.Height;
  end;
end.