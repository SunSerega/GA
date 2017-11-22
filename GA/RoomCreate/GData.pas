{$apptype windows}

{$resource 'teleport.im'}
{$resource 'save.im'}
{$resource 'exit.im'}
{$resource 'wall.im'}
{$resource 'settings.im'}

{$resource 'wstex.im'}

{$reference System.Windows.Forms.dll}
{$reference System.Drawing.dll}

unit GData;

uses OpenGL,System.Drawing,TData;

var
  StartTime := System.DateTime.Now;
  
  k := new boolean[256];

procedure WTF(name: string; params obj: array of object) := System.IO.File.AppendAllText(name, string.Join('', obj.ConvertAll(a -> _ObjectToString(a))) + char(13) + char(10));

procedure SaveError(params obj: array of object);
begin
  (new System.Threading.Thread(()->begin
    
    {}
    System.Console.Beep(1000, 1000);
    if not System.IO.File.Exists('Errors.txt') then
      WTF('Errors.txt', 'Started|', StartTime);
    var b := true;
    while b do
      try
        WTF('Errors.txt', new object[2](System.DateTime.Now, '|') + obj);
        b := false;
      except
      end;
    {}
    
  end)).Start;
end;

type
  Camera = record
    class X, Y, Z, dx, dy, dz: real;
    class RotX, RotY, drx, dry: Single;
    const Speed = 1;
    const Boost = 4;
    
    class procedure SetStandart;
    begin
      Camera.X := 0;
      Camera.Y := 1600;
      Camera.Z := -2000;
      Camera.RotX := 0;
      Camera.RotY := 0.675;
    end;
    
    class procedure SaveToLog := WTF('Log.txt', 'pos:[', (X, Y, Z), '->', (dx, dy, dz), '],dir:[', (RotX, RotY), '->', (drx, dry), ']');
  end;

var
  WW, WH: word;
  _hdc: HDC;
  MW: real;
  MF: System.windows.forms.Form;

{$region external}

function GetDesktopWindow: system.IntPtr;
external 'User32.dll' name 'GetDesktopWindow';

procedure GetWindowRect(hWnd: system.IntPtr; var lpRect: system.Drawing.Rectangle);
external 'User32.dll' name 'GetWindowRect';

function GetKeyState(nVirtKey: byte): byte;
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
  
  Point3f = record
    X, Y, Z: Single;
    
    constructor create(X, Y, Z: Single);
    begin
      self.X := X;
      self.Y := Y;
      self.Z := Z;
    end;
  end;
  Point3i = record
    X, Y, Z: integer;
    
    constructor create(X, Y, Z: integer);
    begin
      self.X := X;
      self.Y := Y;
      self.Z := Z;
    end;
  end;
  
  TexCoord = record
    TX, TY: Single;
    X, Y, Z: real;
    
    constructor create(TX, TY: Single; X, Y, Z: real);
    begin
      self.TX := TX;
      self.TY := TY;
      self.X := X;
      self.Y := Y;
      self.Z := Z;
    end;
  end;
  Texture = class
    
    id: cardinal;
    w, h: word;
    clrs: array of byte;
    alpha: boolean;
    
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
    
    procedure SetVal(w, h: word; clrs: array of byte; alpha: boolean := false; Redraw: boolean := false; FiltersNearest: boolean := false; NoMipmaps: boolean := false);
    begin
      self.w := w;
      self.h := h;
      self.clrs := clrs;
      self.alpha := alpha;
      if Redraw then
        self.Redraw(FiltersNearest, NoMipmaps);
    end;
    
    constructor create(w, h: word; clrs: array of byte; alpha: boolean := false; Redraw: boolean := false; FiltersNearest: boolean := false; NoMipmaps: boolean := false);
    begin
      glGenTextures(1, @id);
      self.w := w;
      self.h := h;
      self.clrs := clrs;
      self.alpha := alpha;
      if Redraw then
        self.Redraw(FiltersNearest, NoMipmaps);
    end;
    
    class function GetPaternBytes(c: integer; func: integer->byte): array of byte;
    begin
      Result := new byte[c];
      for i: integer := 0 to c - 1 do
        Result[i] := func(i);
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
    
    class function GetTextTexture(s: string; alpha: boolean; cr, cg, cb, ca: byte): Texture;
    begin
      
      var w := 8 * s.Length + 4;
      var h := 12;
      var BitMap := new byte[w, h];
      var BPP := alpha ? 4 : 3;
      var clrs := new byte[w * h * BPP];
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
            clrs[i + 0] := f ? cr : 255;
            clrs[i + 1] := f ? cg : 255;
            clrs[i + 2] := f ? cb : 255;
            if alpha then
              clrs[i + 3] := f ? ca : 0;
            i += BPP;
          end;
      end;
      
      Result := new Texture(w, h, clrs, alpha, true, true, true);
    end;
    
    procedure Draw(mode: GLenum; pts: array of TexCoord; r, g, b, a: Single);
    begin
      glColor4f(r, g, b, a);
      glBindTexture(GL_TEXTURE_2D, id);
      glBegin(mode);
      for i: integer := 0 to pts.Length - 1 do
      begin
        glTexCoord2f(pts[i].TX, pts[i].TY);
        glVertex3d(pts[i].X, pts[i].Y, pts[i].Z);
      end;
      glEnd;
      glBindTexture(GL_TEXTURE_2D, 0);
    end;
    
    procedure Draw(mode: GLenum; pts: array of TexCoord) := Draw(mode, pts, 1, 1, 1, 1);
    
    constructor create(re: System.IO.BinaryReader; alpha: boolean := false; Redraw: boolean := false; RQ: boolean := false);
    begin
      glGenTextures(1, @id);
      
      w := re.ReadByte * 256 + re.ReadByte;
      h := re.ReadByte * 256 + re.ReadByte;
      if alpha then
        clrs := new byte[w * h * 4] else
        clrs := new byte[w * h * 3];
      re.Read(clrs, 0, clrs.Length);
      
      self.alpha := alpha;
      if Redraw then
        self.Redraw(RQ);
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
    
    procedure Save(wr: System.IO.BinaryWriter);
    begin
      wr.Write(new byte[2](w shr 8, w), 0, 2);
      wr.Write(new byte[2](h shr 8, h), 0, 2);
      wr.Write(clrs);
    end;
    
    procedure Save(str: System.IO.Stream) := Save(new System.IO.BinaryWriter(str));
    
    procedure Save(f: string) := Save(System.IO.File.Create(f));
  
  end;

{$endregion}

type
  GraphField = class(System.Windows.Forms.PictureBox)
    timer: System.Windows.Forms.Timer;
    components: System.ComponentModel.IContainer;
    
    RedrawProc: procedure;
    
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

type
  gr = record
    
    {$region 2D}
    
    class procedure Polygon(Fill: boolean; cr, cg, cb, ca: Single; pts: array of PointF);
    begin
      if Fill then
        glBegin(GL_POLYGON) else
        glBegin(GL_LINE_LOOP);
      glColor4f(cr, cg, cb, ca);
      for i: integer := 0 to pts.Length - 1 do
        glVertex2f(pts[i].X, pts[i].Y);
      glEnd;
    end;
    
    class procedure Lines(cr, cg, cb, ca: Single; pts: array of PointF);
    begin
      glBegin(GL_LINE_STRIP);
      glColor4f(cr, cg, cb, ca);
      for i: integer := 0 to pts.Length - 1 do
        glVertex2f(pts[i].X, pts[i].Y);
      glEnd;
    end;
    
    class procedure Rectangle(Fill: boolean; cr, cg, cb, ca: Single; X, Y, W, H: Single);
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
    
    class function Ellipse(X, Y, W, H: Single; pc: integer): array of PointF;
    begin
      Result := new PointF[pc];
      var dang := Pi * 2 / pc;
      for i: integer := 0 to pc - 1 do
        Result[i] := new PointF(X + W * Cos(dang * i), Y + H * Sin(dang * i));
    end;
    
    class procedure Ellipse(Fill: boolean; cr, cg, cb, ca: Single; X, Y, W, H: Single; pc: integer) := Polygon(Fill, cr, cg, cb, ca, Ellipse(X, Y, W, H, pc));
    
    {$endregion}
    
    {$region 3D}
    
    class procedure Polygon(Fill: boolean; cr, cg, cb, ca: Single; pts: array of Point3f);
    begin
      if Fill then
        glBegin(GL_POLYGON) else
        glBegin(GL_LINE_LOOP);
      glColor4f(cr, cg, cb, ca);
      for i: integer := 0 to pts.Length - 1 do
        glVertex3d(pts[i].X, pts[i].Y, pts[i].Z);
      glEnd;
    end;
    
    class procedure Lines(cr, cg, cb, ca: Single; pts: array of Point3f);
    begin
      glBegin(GL_LINE_STRIP);
      glColor4f(cr, cg, cb, ca);
      for i: integer := 0 to pts.Length - 1 do
        glVertex3d(pts[i].X, pts[i].Y, pts[i].Z);
      glEnd;
    end;
    
    class procedure Cube(cr, cg, cb, ca: Single; X, Y, Z, dX, dY, dZ: real);
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
    
    class procedure Sphere(Fill: boolean; cr, cg, cb, ca, X, Y, Z, dX, dY, dZ: Single; pc: integer) := Sphere(Fill, cr, cg, cb, ca, Sphere(X, Y, Z, dX, dY, dZ, pc));
    
    class procedure Sphere(Fill: boolean; cr, cg, cb, ca: Single; pts: array[,] of Point3f);
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
    
    class function Sphere(X, Y, Z, dX, dY, dZ: Single; pc: integer): array[,] of Point3f;
    begin
      var w := pc * 2;
      var h := pc + 1;
      Result := new Point3f[w, h];
      var dangx := Pi / pc;
      var dangy := Pi / pc;
      for ix: integer := 0 to w - 1 do
      begin
        Result[ix, 0] := new Point3f(X, Y + dY, Z);
        for iy: integer := 1 to h - 2 do
        begin
          var AX := ix * dangx;
          var AY := iy * dangy;
          Result[ix, iy] := new Point3f(X + dX * Cos(AX) * Sin(AY), Y + dY * Cos(AY), Z + dZ * Sin(AX) * Sin(AY));
        end;
        Result[ix, h - 1] := new Point3f(X, Y - dY, Z);
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