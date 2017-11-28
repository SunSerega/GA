unit CFData;

interface

uses GData, System.Drawing, OpenGL;

{$savepcu false}//ToDo �������

{$region Consts,Vars}

const
  ///������� ������ ������ � ������ ������ �� ������
  RW = 1500;
  ///������ ��������� ���������
  MazeRad: byte = 50 * RW;
  ///������ �������� ���������
  MazeMaxRad: byte = 100 * RW;
  ///������� ������� �������
  RoomGetAttempts: cardinal = 10000;
  
  ///���������� �� ��������� �� ������ ��� ���
  CameraHeigth = 8500;//ToDo 0500
  ///���������� �� ���� �� ������ ������
  CameraHover = 50;
  ///������ ����
  WallHeigth = 750;//ToDo 750

var
  ///0=MainMenu
  ///1=GameM1
  GM: byte := 0;
  ///0=NaN
  ///1=3D
  MM: byte := 0;
  
  //Debag
  FPSShow,//FPS                               F3 ToDo
  
  LHShow,//Hitboxes                           F9
  ShowNewRooms,//not PlayerSeen               F10
  ShowWaitRooms,//not Created                 F11
  PlayerNotClipping//Player ignore Hitboxes   F12
  : boolean;

{$endregion}

{$region Dop Types}
type
  
  {$region Misk}
  
  ///��� 3D ����� � real ������������
  PPoint = GData.PPoint;
  ///��� 3D ����� � real ������������ � Single ������� � �����
  CPoint = GData.CPoint;
  
  ///��� ��� ������� �������, ��� ������ ������ ������
  TimeReader = record
    lt: System.DateTime;
    te := System.TimeSpan.Zero;
    r := false;
    
    ///�������� �����
    procedure Start;
    begin
      lt := System.DateTime.Now;
      r := true;
    end;
    ///������������� �����
    procedure Recalc;
    begin
      var ts := (System.DateTime.Now - lt);
      te := te.Add(ts);
      lt.Add(ts);
    end;
    ///������������� ������� � ������������� �����
    procedure Stop;
    begin
      te := te.Add(System.DateTime.Now - lt);
      r := false;
    end;
    ///�������� �������
    procedure Reset;
    begin
      te := System.TimeSpan.Zero;
    end;
  
  end;
  
  ///������ 4 �����, �� 1 �� ������������ �����
  SColor = record
    R, G, B, A: byte;
  end;
  ///������������ ��������� ���������� � ���������� ��������, ������� ��� �������� � ���������� � �����
  SavedImage = class
    x, y, w, h: word;
    alpha: boolean;
    pts: array[,] of SColor;
    
    ///��������� �������� �� ������ str
    constructor create(str: System.IO.Stream; alpha: boolean);
    begin
      self.alpha := alpha;
      var re := new System.IO.BinaryReader(str);
      w := re.ReadUInt16;
      h := re.ReadUInt16;
      pts := new SColor[w, h];
      for x: word := 0 to w - 1 do
        for y: word := 0 to h - 1 do
        begin
          pts[x, y].R := re.ReadByte;
          pts[x, y].G := re.ReadByte;
          pts[x, y].B := re.ReadByte;
          if alpha then
            pts[x, y].A := re.ReadByte;
        end;
    end;
    ///������ �������� �� �������������� �� �������
    constructor create(b: Bitmap; x1, y1, x2, y2: integer);
    begin
      w := abs(X2 - X1);
      h := abs(Y2 - Y1);
      x := Min(x1, x2);
      y := Min(y1, y2);
      pts := new SColor[w, h];
      if (w > 0) and (h > 0) then
        for nx: word := 0 to w - 1 do
          for ny: word := 0 to h - 1 do
          begin
            var c := b.GetPixel(x + nx, y + ny);
            pts[nx, ny].R := c.R;
            pts[nx, ny].G := c.G;
            pts[nx, ny].B := c.B;
            pts[nx, ny].A := c.A;
          end;
    end;
    ///�������� ���������� �� ������� SavedImage
    constructor create(s: SavedImage);
    begin
      self.x := s.x;
      self.y := s.y;
      self.w := s.w;
      self.h := s.h;
      self.pts := Copy(s.pts);
    end;
    ///����������� ����������� � ������ ����
    function GetBytes: array of byte;
    begin
      var BPP: byte := alpha ? 4 : 3;
      Result := new byte[w * h * BPP];
      for y: word := 0 to h - 1 do
        for x: word := 0 to w - 1 do
        begin
          var sp := (x + y * w) * BPP;
          var sc := pts[x, y];
          Result[sp + 0] := sc.R;
          Result[sp + 1] := sc.G;
          Result[sp + 2] := sc.B;
          if alpha then
            Result[sp + 3] := sc.A;
        end;
    end;
    ///������ ����������� w x h �� ��������� Patern.
    class function GetPaternImage(w, h: word; alpha: boolean; Patern: (word,word)->SColor): SavedImage;
    begin
      Result := new SavedImage;
      Result.w := w;
      Result.h := h;
      Result.pts := new SColor[w, h];
      for x: word := 0 to w - 1 do
        for y: word := 0 to h - 1 do
          Result.pts[x, y] := Patern(x, y);
    end;
    ///��������� � ����� str ��������
    procedure Save(str: System.IO.Stream);
    begin
      var wr := new System.IO.BinaryWriter(str);
      wr.Write(w);
      wr.Write(h);
      for y: word := 0 to h - 1 do
        for x: word := 0 to w - 1 do
        begin
          var c := pts[x, y];
          wr.Write(c.R);
          wr.Write(c.G);
          wr.Write(c.B);
          wr.Write(c.A);
        end;
    end;
  
  end;
  
  {$endregion}
  
  {$region 2D Calc}
  
  ///��� ����������� ���������, 2 PointF � ����������� �������
  HitBoxT = record
    p1, p2: PointF ;
    
    class function Empty:=default(HitBoxT);//ToDo �������! 
    
    function rot := CFData.ArcTg(p2.X - p1.X, p2.Y - p1.Y) ;
    
    function w := sqrt(sqr(p2.X - p1.X) + sqr(p2.Y - p1.Y)) ;
    
    function Senter := new PointF((p1.X + p2.X) / 2, (p1.Y + p2.Y) / 2);
    
    constructor(p1, p2: PointF);
    begin
      self.p1 := p1;
      self.p2 := p2;
    end;
    
    constructor(w, rot: Single; Sent: PointF);
    begin
      w /= 2;
      p1 := new PointF(Sent.X - w * Cos(rot), Sent.Y - w * Sin(rot));
      p2 := new PointF(Sent.X + w * Cos(rot), Sent.Y + w * Sin(rot));
    end;
    
    function Reverse := new HitBoxT(p2, p1);
  
  end;
  ///������������ ������ � ������
  SLine = record
  
  public 
    ///���������� �� ���������� ������������ ������� (1;1)
    XYSwaped: boolean;
    ///��������� ������� ������� ������(y=a*x+b ��� x=a*y+b)
    a, b: Single;
    
    constructor create(XYSwaped: boolean; a, b: Single);
    begin
      self.XYSwaped := XYSwaped;
      self.a := a;
      self.b := b;
    end;
    ///��������� ������ A � XYSwaped ���������
    procedure ALineData(dx, dy: Single);
    begin
      XYSwaped := abs(dy) > abs(dx);
      a := XYSwaped ? dx / dy : dy / dx;
    end;
    ///��������� ������ B �������� ����������� �� A � XYSwaped
    procedure BLineData(p: PointF);
    begin
      b := XYSwaped ? p.X - a * p.Y : p.Y - a * p.X;
    end;
    ///���������� ������ ��� ���������������� �����
    function Perpend: SLine;
    begin
      Result.a := -a;
      Result.XYSwaped := not XYSwaped;
    end;
    ///���������� ������ ��� ���������������� ����� ���������� ����� ����� p
    function Perpend(p: PointF): SLine;
    begin
      Result.a := -a;
      Result.XYSwaped := not XYSwaped;
      Result.BLineData(p);
    end;
    ///��������� ��� ��������� ��� ������� dy/dx ������������ ����� p
    class function LineData(dx, dy: Single; p: PointF): SLine;
    begin
      Result.XYSwaped := abs(dy) > abs(dx);
      if Result.XYSwaped then
      begin
        Result.a := dx / dy;
        Result.b := p.X - Result.a * p.Y;
      end else
      begin
        Result.a := dy / dx;
        Result.b := p.Y - Result.a * p.X;
      end;
    end;
    ///��������� ��� ��������� ��� ������ ���������� ����� ����� p1 � p2
    class function LineData(p1, p2: PointF) := LineData(p2.X - p1.X, p2.Y - p1.Y, p1);
  end;
  ///������������ ������ � ������ �� ���������
  MObject2D = record
    
    Mass: Single;
    Pos, Vec: PointF;
    
    procedure Tick(MP: Point; Vmlt: Single);
    begin
      Pos.X += Vec.X;
      Pos.Y += Vec.Y;
      Vec.X *= Vmlt;
      Vec.Y *= Vmlt;
    end;
  
  end;

  {$endregion}

{$endregion}

{$region was before}{
type
  Wep1zv = class
    P, SP: PointF;
  end;

  Wep3ProjT = class
    dir, vel: Single;
  end;

  Wep3Boom = class
    const StAdd = 0.3;
    const StRandAdd = 0.05;
    const mlt = 25;

    X, Y, lvl, Stage, Rot, RotSp: Single;
    pts: array of Single;

    function Draw: array of PointF;
    begin
      Result := new PointF[pts.Length];
      var rpp := Pi * 2 / pts.Length;
      for i: integer := 0 to pts.Length - 1 do
        Result[i] := new PointF(X + pts[i] * lvl * mlt * Cos(rpp * i + Rot) * Sin(Stage), Y + pts[i] * lvl * mlt * Sin(rpp * i + Rot) * Sin(Stage));

      Rot += RotSp;
      Stage += StAdd + StRandAdd * (Random * 2 - 1);
    end;

    constructor create(X, Y, lvl, RotSp: Single);
    begin
      self.X := X;
      self.Y := Y;
      self.lvl := lvl;
      self.RotSp := RotSp;
      Stage := 0;
      Rot := Random * Pi * 2;
      pts := new Single[Random(15) + 5];
      while true do
      begin
        pts[0] := 0.5 + Random * 0.5;
        for i: integer := 1 to pts.Length - 1 do
          repeat
            pts[i] := 0.5 + Random * 0.5;
          until abs(pts[i] - pts[i - 1]) >= 0.23;
        if abs(pts[0] - pts[pts.Length - 1]) >= 0.23 then
          break;
      end;
    end;
  end;

{$endregion}

{$region external}
///��������� ��������� � ������ ������� �nVirtKey
function GetKeyState(nVirtKey: byte): byte;
///��������(dwFlags=1)��� ��������(dwFlags=2) �� ���������� ������� bVk.
///bScan=69,dwExtraInfo=0
procedure keybd_event(bVk, bScan: byte; dwFlags, dwExtraInfo: cardinal);
{$endregion}

{$region 2D Calc}
///��������� ����, ������� �������� ����� dy/dx.
function ArcTg(dx, dy: real): real;
///���������� ���� � �������� �������������� �� (-Pi;+Pi]
function NormAng(ang: real): real;
///���������� ����� �� rot �������� ������ (0;0)
function Rotate(a, b, rot: real): PointF;
///���������� ����� �� rot �������� ������ (0;0)
function Rotate(p: PointF; rot: real): PointF;
///���������� ������� �� rot �������� ������ (0;0)
function Rotate(a: HitBoxT; rot: real): HitBoxT;
///���������� ���� nCh � tCh, �������� ������� ����� ���� ante �� ���� ��� ����
procedure ChAngDif(var nCh: Single; tCh, ante: Single);
///���������� ��������� ����� � ��������� [-r;+r)
function Rand(r: real): real;
///��������� ���������� �����
function Round(p: PointF): PointF;
///��������� ��� ���������� ����� ��������
function Round(HB: HitBoxT): HitBoxT;
///������������ ������ ���� �������� � ������ obj ������������ � ����� ConTo. �� ��������.
function MO2DChain(ConTo: PointF; obj: array of MObject2D): array of MObject2D;
///��������� ��������� �� ����� pt ����� �� ������� p1-p2 � ������� ��� ���� � LD
function OnLeft(p1, p2, pt: PointF; LD: SLine): boolean;
///��������� ��������� �� ����� pt ����� �� ������� p1-p2
function OnLeft(p1, p2, pt: PointF): boolean;
{$endregion}

{$region arr funcs}
///������ �������� �� �������� ��������� ������� �����
function PTHB(p: array of PointF): List<HitBoxT>;
///������ �������� �� �������� ��������� ������� ����� ����� ��������������� ������ �������� c
function PTHB(p: array of PointF; c: integer): List<HitBoxT>;
{$endregion}

{$region Lines seption}
///��������� ����� ����������� 2 ������
function Isept(LD1, LD2: SLine): PointF;
///��������� ����� ����������� 2 ������ ���������� ����� ������ �����
function Isept(p11, p12, p21, p22: PointF): PointF;
///��������� ���������� ����� �������
function LBP(p1, p2: PointF): Single;
///��������� ���������� ����� p �� ������� p1-p2 � ������� � ������� p1-p2 � ���������������� ��� ������� ���������� ����� p
function LTL(p1, p2, p: PointF; LD1, LD2: SLine): Single;
///��������� ���������� ����� p �� ������� p1-p2
function LTL(p1, p2, p: PointF): Single;
///��������� ���������� ����� ��������� � ������� ��������� ������� � ������ �� ������� ����� �������
function LBL(p11, p12, p21, p22: PointF; LD1, LD2: SLine): Single;
///��������� ���������� ����� ���������
function LBL(p11, p12, p21, p22: PointF): Single;
///��������� ��������� �� ����� p ������� �� ������ p1-p2 �� ������� p1-p2
function POL(p1, p2, p: PointF; ver, hor: boolean): boolean;
///��������� ��������� �� ����� p ������� �� ������ p1-p2 �� ������� p1-p2
function POL(p1, p2, p: PointF): boolean;
///��������� ������������ �� ������ p21-d2 � �������� p11-p12
function HaveIseptPPPD(p11, p12, p21, d2: PointF): boolean;
///��������� ������������ �� ������� p21-p22 � �������� p11-p12
function HaveIseptPPPP(p11, p12, p21, p22: PointF): boolean;
{$endregion}

{$region Hitbox Hit Calc}
///��������� ����������� ���� �� ������� p21-d2 � ������� dr � �������� p11-p12 � ���� ���� - ������� ������
function Isept(dr: Single; p11, p12, p21: PointF; var d2: PointF): boolean;
///����������� �������� ���� �� ����������� �� ����� ����������
procedure TestHit(dr: Single; l: List<HitBoxT>; from: PointF; var Sp: PointF);
///��������� ��������� �� 1 ������� � ������ ���� ���������� ������ ����� ������� ����� ����� ��������� � ������� ������� � ����������� � ������� ���������
function TRI(HB1l, HB2l: List<HitBoxT>): boolean;
///��������� ���� � ��������� ����� �������
function TRO(HB1l, HB2l: List<HitBoxT>): boolean;
{$endregion}

implementation

{$region external}

function GetKeyState(nVirtKey: byte): byte;external 'User32.dll' name 'GetKeyState';

procedure keybd_event(bVk, bScan: byte; dwFlags, dwExtraInfo: cardinal);external 'User32.dll' name 'keybd_event';

{$endregion}

{$region extensionmethod}

{$region PointF}

function operator+(p1, p2: PointF); extensionmethod := new PointF(p1.X + p2.X, p1.Y + p2.Y);

function operator-(p1, p2: PointF); extensionmethod := new PointF(p1.X - p2.X, p1.Y - p2.Y);

function operator*(p: PointF; r: Single); extensionmethod := new PointF(p.X * r, p.Y * r);

function operator/(p: PointF; r: Single); extensionmethod := new PointF(p.X / r, p.Y / r);

{$endregion}

{$region PPoint}

function operator+(p1, p2: PPoint); extensionmethod := new PPoint(p1.X + p2.X, p1.Y + p2.Y, p1.Z + p2.Z);

function operator-(p1, p2: PPoint); extensionmethod := new PPoint(p1.X - p2.X, p1.Y - p2.Y, p1.Z - p2.Z);

function operator*(p: PPoint; r: real); extensionmethod := new PPoint(p.X * r, p.Y * r, p.Z * r);

function operator/(p: PPoint; r: real); extensionmethod := new PPoint(p.X / r, p.Y / r, p.Z / r);

{$endregion}

{$region HitBoxT}

function operator+(HB: HitBoxT; p: PointF); extensionmethod := new HitBoxT(HB.p1 + p, HB.p2 + p);

function operator-(HB: HitBoxT; p: PointF); extensionmethod := new HitBoxT(HB.p1 - p, HB.p2 - p);

function operator*(HB: HitBoxT; r: Single); extensionmethod := new HitBoxT(HB.p1 * r, HB.p2 * r);

function operator/(HB: HitBoxT; r: Single); extensionmethod := new HitBoxT(HB.p1 / r, HB.p2 / r);

{$endregion}

{$region Sequence}

function Rotate(Self: array of PointF; rot: real): array of PointF; extensionmethod;
begin
  Result := new PointF[Self.Length];
  for i: integer := 0 to Self.Length - 1 do
    Self[i] := Rotate(Self[i].X, Self[i].Y, rot);
  Result := Self;
end;

function Rotate(Self: sequence of TPoint; rot: real): array of TPoint; extensionmethod;
var
  pt: PointF;
  o: TPoint;
begin
  Result := new TPoint[Self.Count];
  for i: integer := 0 to Self.Count - 1 do
  begin
    o := Self.ElementAt(i);
    pt := Rotate(o.X, o.Y, rot);
    Result[i] := new TPoint(pt.X, pt.Y, o.Z, o.TX, o.TY);
  end;
  Self := Result;
end;

function Rotate(Self: List<HitBoxT>; rot: real): List<HitBoxT>; extensionmethod;
begin
  for i: integer := 0 to Self.Count - 1 do
    Self[i] := Rotate(Self[i], rot);
  Result := Self;
end;

function Round(Self: List<HitBoxT>): List<HitBoxT>; extensionmethod;
begin
  Result := new List<HitBoxT>(Self.Count);
  foreach var HB in Self do
    Result.Add(new HitBoxT(Round(HB.p1), Round(HB.p2)));
end;

function Add(Self: array of PointF; dX, dY: real): array of PointF; extensionmethod;
begin
  for i: integer := 0 to Self.Length - 1 do
  begin
    var p := Self[i];
    Self[i] := new PointF(p.X + dX, p.Y + dY);
  end;
  Result := Self;
end;

function Add(Self: array of PPoint; dX, dY, dZ: real): array of PPoint; extensionmethod;
begin
  for i: integer := 0 to Self.Length - 1 do
  begin
    var p := Self[i];
    Self[i] := new PPoint(p.X + dX, p.Y + dY, p.Z + dZ);
  end;
  Result := Self;
end;

function Add(Self: array of CPoint; dX, dY, dZ: real): array of CPoint; extensionmethod;
begin
  for i: integer := 0 to Self.Length - 1 do
  begin
    var p := Self[i];
    Self[i] := new CPoint(p.X + dX, p.Y + dY, p.Z + dZ, p.cr, p.cg, p.cb, p.ca);
  end;
  Result := Self;
end;

function AddToHB(Self: List<HitBoxT>; d: PointF): List<HitBoxT>; extensionmethod;
begin
  for i: integer := 0 to Self.Count - 1 do
    Self[i] := Self[i] + d;
  Result := Self;
end;

function Add3rd(Self: array of PointF; Z: Single): array of PPoint; extensionmethod;
begin
  Result := new PPoint[Self.Length];
  for i: integer := 0 to Result.Length - 1 do
    Result[i] := new PPoint(Self[i].X, Self[i].Y, Z);
end;

function Mlt(Self: array of PointF; r: real): array of PointF; extensionmethod;
begin
  for i: integer := 0 to Self.Length - 1 do
    Self[i] := Self[i] * r;
  Result := Self;
end;

function Mlt(Self: array of PPoint; r: real): array of PPoint; extensionmethod;
begin
  for i: integer := 0 to Self.Length - 1 do
    Self[i] := Self[i] * r;
  Result := Self;
end;

function Mlt(Self: List<HitBoxT>; r: Single): List<HitBoxT>; extensionmethod;
begin
  for i: integer := 0 to Self.Count - 1 do
    Self[i] := Self[i] * r;
  Result := Self;
end;

procedure operator+=<T>(var a: array of T; b: array of T); extensionmethod;
begin
  a := a + b;
end;

function Rand<T>(Self: sequence of T); extensionmethod := Self.ElementAt(Random(Self.Count));

{$endregion}

{$endregion}

{$region 2D Calc}

function ArcTg(dx, dy: real): real := (dx = 0 ? (dy > 0 ? Pi / 2 : -Pi / 2 * 1) : ArcTan(dy / dx)) + (dx < 0 ? Pi : (dy < 0 ? Pi * 2 : 0));

function NormAng(ang: real): real;
const
  dPi = Pi * 2;
begin
  if real.IsInfinity(ang) then raise new System.InvalidOperationException;
  while ang <= -Pi do ang += dPi;
  while ang > +Pi do ang -= dPi;
  Result := ang;
end;

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

function Rotate(p: PointF; rot: real) := Rotate(p.X, p.Y, rot);

function Rotate(a: HitBoxT; rot: real): HitBoxT;
begin
  a.p1 := Rotate(a.p1, rot);
  a.p2 := Rotate(a.p2, rot);
  Result := a;
end;

procedure ChAngDif(var nCh: Single; tCh, ante: Single);
begin
  var dif := tCh - nCh;
  while dif < -Pi do dif += Pi * 2;
  while dif > Pi do dif -= Pi * 2;
  nCh += dif * ante;
  if abs(dif) < 0.003 then
    nCh := tCh;
end;

function Rand(r: real) := (Random * 2 - 1) * r;

function Round(p: PointF) := new PointF(Round(p.X), Round(p.Y));

function Round(HB: HitBoxT) := new HitBoxT(Round(HB.p1), Round(HB.p2));

function MO2DChain(ConTo: PointF; obj: array of MObject2D): array of MObject2D;
begin
  
  {
  var l := sqrt(sqr(p1.X - p2.X) + sqr(p1.Y - p2.Y));
  var pr := pr1 + pr2;
  if l = 0 then
  begin
  var ang := ArcTg(d2.X, d2.Y);
  d1 := new PointF(0, 0);
  d2 := new PointF(Cos(ang) * MinL, Sin(ang) * MinL);
  end else if l > MaxL then
  begin
  var dl := (l - MaxL) / 2;
  var d := new PointF((p2.X - p1.X) / l * dl, (p2.Y - p1.Y) / l * dl);
  
  var nd1 := new PointF((d1.X * pr2 + d2.X * pr1) / pr, (d1.Y * pr2 + d2.Y * pr1) / pr);
  d1 := nd1;d2 := nd1;
  
  d1.X += d.X / 0.8 / pr * pr1 / 2;d1.Y += d.Y / 0.8 / pr * pr1 / 2;
  d2.X -= d.X / 0.8 / pr * pr2 / 2;d2.Y -= d.Y / 0.8 / pr * pr2 / 2;
  
  p2.X -= d.X / 0.8 / pr * pr2;p2.Y -= d.Y / 0.8 / pr * pr2;
  end else if l < MinL then
  begin
  var dl := (MinL - l) / 2;
  var d := new PointF((p1.X - p2.X) / l * dl, (p1.Y - p2.Y) / l * dl);
  d1.X += d.X / 0.8 / pr * pr1;d1.Y += d.Y / 0.8 / pr * pr1;
  d2.X -= d.X / 0.8 / pr * pr2;d2.Y -= d.Y / 0.8 / pr * pr2;
  end;
  {}
end;

function OnLeft(p1, p2, pt: PointF; LD: SLine): boolean;
begin
  var LD2 := LD;
  LD.BLineData(pt);
  Result := LD.XYSwaped ? ((LD.b < LD2.b) xor (p2.Y > p1.Y)) : ((LD.b > LD2.b) xor (p2.X > p1.X));
end;

function OnLeft(p1, p2, pt: PointF) := OnLeft(p1, p2, pt, SLine.LineData(p1, p2));

{$endregion}

{$region arr funcs}

function PTHB(p: array of PointF): List<HitBoxT>;
begin
  Result := new List<HitBoxT>(p.Length - 1);
  for i: integer := 0 to p.Length - 2 do
    Result.Add(new HitBoxT(p[i], p[i + 1]));
end;

function PTHB(p: array of PointF; c: integer): List<HitBoxT>;
begin
  Result := new List<HitBoxT>(c);
  for i: integer := 0 to p.Length - 2 do
    Result.Add(new HitBoxT(p[i], p[i + 1]));
end;

{$endregion}

{$region Lines seption}

function Isept(LD1, LD2: SLine): PointF;
begin
  if LD1.XYSwaped = LD2.XYSwaped then
    Result.X := (LD2.b - LD1.b) / (LD1.a - LD2.a) else
    Result.X := (LD1.b * LD2.a + LD2.b) / (1 - LD1.a * LD2.a);
  if Single.IsNaN(Result.X) then exit;
  Result.Y := LD1.a * Result.X + LD1.b;
  if LD1.XYSwaped then
    Result := new PointF(Result.Y, Result.X);
end;

function Isept(p11, p12, p21, p22: PointF) := Isept(SLine.LineData(p11, p12), SLine.LineData(p21, p22));

function LBP(p1, p2: PointF) := sqrt(sqr(p2.X - p1.X) + sqr(p2.Y - p1.Y));

function LTL(p1, p2, p: PointF; LD1, LD2: SLine): Single;
begin
  
  if p1 = p2 then
  begin
    Result := LBP(p1, p);
    exit;
  end;
  
  var Res := Isept(LD1, LD2);
  
  if LD1.XYSwaped then
  begin
    
    if p1.Y > p2.Y then Swap(p1, p2);
    if Res.Y < p1.Y then Res := p1 else
    if Res.Y > p2.Y then Res := p2;
    
  end else
  begin
    
    if p1.X > p2.X then Swap(p1, p2);
    if Res.X < p1.X then Res := p1 else
    if Res.X > p2.X then Res := p2;
    
  end;
  
  Result := LBP(p, Res);
  
end;

function LTL(p1, p2, p: PointF): Single;
begin
  var LD1 := SLine.LineData(p1, p2);
  Result := LTL(p1, p2, p, LD1, LD1.Perpend(p));
end;

function LBL(p11, p12, p21, p22: PointF; LD1, LD2: SLine): Single;
begin
  
  if p11 = p12 then begin
    Result := LTL(p21, p22, p11);
    exit;
  end; if p21 = p22 then begin
    Result := LTL(p11, p12, p21);
    exit;
  end;
  
  begin
    var Res := Isept(LD1, LD2);
    
    if POL(p11, p12, Res) and POL(p21, p22, Res) then
      exit;
  end;
  
  Result := Min(Min(LTL(p11, p12, p21), LTL(p11, p12, p22)), Min(LTL(p21, p22, p11), LTL(p21, p22, p12)));
  
end;

function LBL(p11, p12, p21, p22: PointF) := LBL(p11, p12, p21, p22, SLine.LineData(p11, p12), SLine.LineData(p21, p22));

function POL(p1, p2, p: PointF; ver, hor: boolean) :=
(ver or ((p1.X < p2.X) ? (p1.X < p.X) and (p.X < p2.X) : (p1.X > p.X) and (p.X > p2.X))) and
  (hor or ((p1.Y < p2.Y) ? (p1.Y < p.Y) and (p.Y < p2.Y) : (p1.Y > p.Y) and (p.Y > p2.Y)));

function POL(p1, p2, p: PointF) := POL(p1, p2, p, p2.X = p1.X, p2.Y = p1.Y);

function HaveIseptPPPD(p11, p12, p21, d2: PointF): boolean;
begin
  var d1 := p12 - p11;
  if NormAng(ArcTg(d1.X, d1.Y) - ArcTg(d2.X, d2.Y) - Pi) >= 0 then exit;
  
  var LD1, LD2: SLine;
  LD1.ALineData(d1.X, d1.Y); if Single.IsNaN(LD1.a) then exit;
  LD2.ALineData(d2.X, d2.Y); if Single.IsNaN(LD2.a) then exit;
  if LD1.a = LD2.a then if LD1.XYSwaped = LD2.XYSwaped then exit;
  LD1.BLineData(p11);
  LD2.BLineData(p21);
  
  var Res := Isept(LD1, LD2);
  
  if POL(p11, p12, Res, d1.X = 0, d1.Y = 0) then
  begin
    var p22 := p21 + d2;
    Result := POL(p21, p22, Res, d2.X = 0, d2.Y = 0);
  end;
end;

function HaveIseptPPPP(p11, p12, p21, p22: PointF): boolean;
begin
  var d1 := p12 - p11;
  var d2 := p22 - p21;
  
  var LD1, LD2: SLine;
  LD1.ALineData(d1.X, d1.Y); if Single.IsNaN(LD1.a) then exit;
  LD2.ALineData(d2.X, d2.Y); if Single.IsNaN(LD2.a) then exit;
  if LD1.a = LD2.a then if LD1.XYSwaped = LD2.XYSwaped then exit;
  LD1.BLineData(p11);
  LD2.BLineData(p21);
  
  var Res := Isept(LD1, LD2);
  
  if Single.IsNaN(Res.X) then exit;
  
  Result := POL(p11, p12, Res, d1.X = 0, d1.Y = 0) and POL(p21, p22, Res, d2.X = 0, d2.Y = 0);
end;

{$endregion}

{$region Hitbox Hit Calc}

function Isept(dr: Single; p11, p12, p21: PointF; var d2: PointF): boolean;
begin
  var d1 := new PointF(p12.X - p11.X, p12.Y - p11.Y);
  if NormAng(ArcTg(d1.X, d1.Y) - ArcTg(d2.X, d2.Y) - Pi) >= 0 then exit;
  
  var LD1, LD2: SLine;
  LD1.ALineData(d1.X, d1.Y); if Single.IsNaN(LD1.a) then exit;
  LD2.ALineData(d2.X, d2.Y); if Single.IsNaN(LD2.a) then exit;
  if LD1.a = LD2.a then if LD1.XYSwaped = LD2.XYSwaped then exit;
  LD1.BLineData(p11);
  LD2.BLineData(p21);
  
  var p22 := p21 + d2;
  if LBL(p11, p12, p21, p22, LD1, LD2) >= dr then exit;
  
  Result := true;
  LD2 := LD1.Perpend(p22);
  var Res := Isept(LD1, LD2);
  if LD2.XYSwaped then
  begin
    if p11.X > p12.X then
      Res.Y -= dr / sqrt(sqr(LD2.a) + 1) else
      Res.Y += dr / sqrt(sqr(LD2.a) + 1);
    Res.X := LD2.a * Res.Y + LD2.b;
  end else
  begin
    if p11.Y < p12.Y then
      Res.X -= dr / sqrt(sqr(LD2.a) + 1) else
      Res.X += dr / sqrt(sqr(LD2.a) + 1);
    Res.Y := LD2.a * Res.X + LD2.b;
  end;
  
  d2 := Res - p21;
  
  //Res.Y := LD1.a * Res.X + LD1.b;
  
end;

procedure TestHit(dr: Single; l: List<HitBoxT>; from: PointF; var Sp: PointF);
begin
  
  var Hit := true;
  var Hn := 0;
  var HH := l.ConvertAll(h -> new class(HB := h, Hited := false));
  while Hit and (Hn <= 3) do
  begin
    Hit := false;
    foreach var H in HH do
      if not H.Hited then
        if Isept(dr, H.HB.p1, H.HB.p2, from, Sp) then
        begin;
          Hit := true;
          H.Hited := true;
          
          //Log(H.HB);
          
          break;
        end;
    Hn += 1;
  end;
  
  //Log('-'*50);
  
end;

function TRI(HB1l, HB2l: List<HitBoxT>): boolean;
type
  HBFL = record
    
    fst: boolean;
    n: byte;
    l: Single;
    
    constructor create(fst: boolean; n: byte; l: Single);
    begin
      self.fst := fst;
      self.n := n;
      self.l := l;
    end;
  
  end;

var
  LD: SLine;
  p1, p2: PointF;

begin
  //������� ������� ����� ���������
  foreach var HB in HB1l do
    p1 := p1 + HB.p1;
  foreach var HB in HB2l do
    p2 := p2 + HB.p1;
  p1 := p1 / HB1l.Count;
  p2 := p2 / HB2l.Count;
  LD := SLine.LineData(p1, p2);
  if Single.IsNaN(LD.a) then
  begin
    Result := true;
    //Log(char(9),' Exited TRI p1=p2, ',p1,'=',p2);
    exit;
  end;
  //���������� ��� � ���� �����������
  var HBs := new List<HBFL>;
  var l := LD.XYSwaped ? p2.Y - p1.Y : p2.X - p1.X;
  for i: integer := 0 to HB1l.Count - 1 do
  begin
    var HB := HB1l[i];
    var Res := Isept(SLine.LineData(HB.p1, HB.p2), LD);
    if POL(HB.p1, HB.p2, Res, HB.p1.X = HB.p2.X, HB.p1.Y = HB.p2.Y) then HBs.Add(new HBFL(true, i, LD.XYSwaped ? (Res.Y - p1.Y) / l : (Res.X - p1.X) / l));
  end;
  for i: integer := 0 to HB2l.Count - 1 do
  begin
    var HB := HB2l[i];
    var Res := Isept(SLine.LineData(HB.p1, HB.p2), LD);
    if POL(HB.p1, HB.p2, Res, HB.p1.X = HB.p2.X, HB.p1.Y = HB.p2.Y) then HBs.Add(new HBFL(false, i, LD.XYSwaped ? (Res.Y - p1.Y) / l : (Res.X - p1.X) / l));
  end;
  //���� ���� ����� ����� ������ ���� � ����� ���������
  var in1 := false;
  var in2 := false;
  while HBs.Count <> 0 do
  begin
    var HB := HBs[0];
    for var i := 1 to HBs.Count - 1 do
      if HBs[i].l < HB.l then
        HB := HBs[i];
    if HB.fst then
      in1 := not in1 else
      in2 := not in2;
    if in1 and in2 then
    begin
      Result := true;
      exit;
    end;
    HBs.Remove(HB);
  end;
end;

function TRO(HB1l, HB2l: List<HitBoxT>): boolean;
begin
  //Log;
  //Log('Started TRO');
  //Log(HB1l);
  //Log(HB2l);
  if false then
    foreach var HB1 in HB1l do
      foreach var HB2 in HB2l do
        if Round(HB1) = Round(HB2) then
        begin
          Result := true;
          //Log('Exited TRO ',HB1,' = ', HB2);
          exit;
        end;
  foreach var HB1 in HB1l do
    foreach var HB2 in HB2l do
    begin;
      if HaveIseptPPPP(HB1.p1, HB1.p2, HB2.p1, HB2.p2) then
      //if HaveIseptPPPP(Round(HB1.p1), Round(HB1.p2), Round(HB2.p1), Round(HB2.p2)) then
      begin
        Result := true;
        //Log('Exited TRO HaveIseptPPPP(',HB1,',',HB2,')=true');
        exit;
      end;
    end;
  //Result := TRI(HB1l.Round, HB2l.Round);
  Result := TRI(HB1l, HB2l);
  //if Result then
  //  Log('Exited TRO TRI=true') else
  //  Log('Ok TRO');
end;

{$endregion}

end.