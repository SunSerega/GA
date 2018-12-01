{$define DEBUG}

unit CFData;

interface

uses GData, PerlinNoiseData, OpenGL;

{$savepcu false}//ToDo костыль

{$region Consts,Vars}

const
  //TODO убрать из констант
  ///Временная константа для обычного трения пола
  FloorFriction = 1;
  
  ///Еденица ширины комнат и радиус зрения до тумана
  RW = 1500;
  ///Радиус прогрузки лабиринта
  MazeRad: byte = 50 * RW;
  ///Радиус отгрузки лабиринта
  MazeMaxRad: byte = 100 * RW;
  ///Попыток создать комнату
  RoomGetAttempts: cardinal = 10000;
  
  ///Расстояние от персонажа до камеры над ним
  CameraHeigth = 8500;//ToDo 0500
  ///Расстояние от пола до фокуса камеры
  CameraHover = 50;
  ///Высота стен
  WallHeigth = 750;//ToDo 750

var
  ///0=MainMenu
  ///1=GameM1
  GM: byte := 0;
  ///0=NaN
  ///1=3D
  MM: byte := 0;
  
  //DEBUG
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
  
  vec2i = GData.vec2i;
  vec3i = GData.vec3i;
  
  vec2f = GData.vec2f;
  vec3f = GData.vec3f;
  
  vec2d = GData.vec2d;
  vec3d = GData.vec3d;
  
  Tvec2d = GData.Tvec2d;
  Tvec3d = GData.Tvec3d;
  
  Cvec3d = GData.Cvec3d;
  
  ///Тип для отсчёта времени, как таймер только точный
  TimeReader = record
    lt: System.DateTime;
    te := System.TimeSpan.Zero;
    r := false;
    
    ///засекает время
    procedure Start;
    begin
      lt := System.DateTime.Now;
      r := true;
    end;
    ///пересчитывает время
    procedure Recalc;
    begin
      var ts := (System.DateTime.Now - lt);
      te := te.Add(ts);
      lt.Add(ts);
    end;
    ///останавливает счётчик и пересчитывает время
    procedure Stop;
    begin
      te := te.Add(System.DateTime.Now - lt);
      r := false;
    end;
    ///обнуляет счётчик
    procedure Reset;
    begin
      te := System.TimeSpan.Zero;
    end;
  
  end;
  
  ///Хранит 4 байта, по 1 на составляющую цвета
  SColor = record
    R, G, B, A: byte;
  end;
  ///Представляет хранилище информации о пиксельной картинки, удобное для загрузки и сохранения в поток
  SavedImage = class
    x, y, w, h: word;
    alpha: boolean;
    pts: array[,] of SColor;
    
    ///загружает картинку из потока str
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
    ///создаёт картинку из прямоугольника на битмапе
    constructor create(b: System.Drawing.Bitmap; x1, y1, x2, y2: integer);
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
    ///копирует информацию из другого SavedImage
    constructor create(s: SavedImage);
    begin
      self.x := s.x;
      self.y := s.y;
      self.w := s.w;
      self.h := s.h;
      self.pts := Copy(s.pts);
    end;
    ///преобразует изображение в массив байт
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
    ///создаёт изображение w x h по алгоритму Patern.
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
    ///сохраняет в поток str картинку
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
  
  ///Тип большинства хитбоксов, 2 vec2f в определённом порядке
  HitBoxT = record
    public p1, p2: vec2f;
    
    public class Empty: HitBoxT;
    
    public function rot: real;
    
    public function w: real;
    
    public function Senter: vec2f;
    
    public constructor(p1, p2: vec2f);
    
    public constructor(w, rot: Single; Sent: vec2f);
    
    public function Reverse: HitBoxT;
  
  end;
  ///Представляет данные о прямой
  SLine = record
  
  public 
    ///Отображены ли координаты относительно вектора (1;1)
    XYSwaped: boolean;
    ///Константа функции графика прямой(y=a*x+b или x=a*y+b)
    a, b: Single;
    
    constructor create(XYSwaped: boolean; a, b: Single);
    begin
      self.XYSwaped := XYSwaped;
      self.a := a;
      self.b := b;
    end;
    ///Вычисляет только A и XYSwaped параметры
    procedure ALineData(dx, dy: Single);
    begin
      XYSwaped := abs(dy) > abs(dx);
      a := XYSwaped ? dx / dy : dy / dx;
    end;
    ///Вычисляет только B параметр основываясь на A и XYSwaped
    procedure BLineData(p: vec2f);
    begin
      b := XYSwaped ? p.X - a * p.Y : p.Y - a * p.X;
    end;
    ///возвращает данные для перпендикулярной линии
    function Perpend: SLine;
    begin
      Result.a := -a;
      Result.XYSwaped := not XYSwaped;
    end;
    ///возвращает данные для перпендикулярной линии проходящей через точку p
    function Perpend(p: vec2f): SLine;
    begin
      Result.a := -a;
      Result.XYSwaped := not XYSwaped;
      Result.BLineData(p);
    end;
    ///Вычисляет все параметры для наклона dy/dx относительно точки p
    class function LineData(dx, dy: Single; p: vec2f): SLine;
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
    ///Вычисляет все параметры для прямой проходящей через точки p1 и p2
    class function LineData(p1, p2: vec2f) := LineData(p2.X - p1.X, p2.Y - p1.Y, p1);
  end;
  //ToDo
  ///Представляет объект с массой на плоскости
  MObject2D = record
    
    Mass: Single;
    Pos, Vec: vec2f;
    
    procedure Tick(MP: vec2i; Vmlt: Single);
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
    P, SP: vec2f;
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

    function Draw: array of vec2f;
    begin
      Result := new vec2f[pts.Length];
      var rpp := Pi * 2 / pts.Length;
      for i: integer := 0 to pts.Length - 1 do
        Result[i] := new vec2f(X + pts[i] * lvl * mlt * Cos(rpp * i + Rot) * Sin(Stage), Y + pts[i] * lvl * mlt * Sin(rpp * i + Rot) * Sin(Stage));

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
///Считывает нажатость и тригер клавиши №nVirtKey
function GetKeyState(nVirtKey: byte): byte;
///Нажимает(dwFlags=1)или отжимает(dwFlags=2) на клавиатуре клавишу bVk.
///bScan=69,dwExtraInfo=0
procedure keybd_event(bVk, bScan: byte; dwFlags, dwExtraInfo: cardinal);
{$endregion}

{$region 2D Calc}
///Вычисляет угол, тангенс которого равен dy/dx.
function ArcTg(dx, dy: real): real;
///Возвращает угол в радианах нормализованый до (-Pi;+Pi]
function NormAng(ang: real): real;
///Возвращает вектор (X;Y) на rot градусов против часовой стрелки
procedure Rotate(var X, Y: Single; rot: Single);
///Возвращает вектор (X;Y) на rot градусов против часовой стрелки
procedure Rotate(var X, Y: real; rot: real);
///Приближает угол nCh к tCh, оставляя разницу между ними ante от того что было
procedure ChAngDif(var nCh: Single; tCh, ante: Single);
///Возвращает случайное вещественное число в диапазоне [-r;+r)
function Rand(r: real): real;
///Округляет координаты точки
function Round(p: vec2f): vec2i;
///Округляет все координаты точек хитбокса
function Round(HB: HitBoxT): HitBoxT;
//ToDo///просчитывает физику цепи объектов с массой obj прикреплённых к точке ConTo. Не написано.
procedure MO2DChain(ConTo: vec2f; obj: array of MObject2D);
///вычисляет находится ли точка pt слева от вектора p1-p2 с данными про него в LD
function OnLeft(p1, p2, pt: vec2f; LD: SLine): boolean;
///вычисляет находится ли точка pt слева от вектора p1-p2
function OnLeft(p1, p2, pt: vec2f): boolean;
///находит координаты ячеек на сетке в которых была линия
procedure LineToPts(HB: HitBoxT; CellW: word; var nl: List<vec2i>);
{$endregion}

{$region arr funcs}
///Создаёт хитбоксы из соседних элементов массива точек
function PTHB(p: array of vec2f): List<HitBoxT>;
///Создаёт хитбоксы из соседних элементов массива точек давая вместительности списка значение c
function PTHB(p: array of vec2f; c: integer): List<HitBoxT>;
///Возвращает массив байтов для картинки сгенерированной шумом перлина
function GetPerlinNoisePaternBytes1(DetLvl: word; w, h: cardinal; cr, cg, cb, dcr, dcg, dcb: Single; Frq, Amp: Single; Step: Single := 2): array of byte;
///Возвращает массив байтов для картинки сгенерированной шумом перлина
function GetPerlinNoisePaternBytes2(w, h: cardinal; cr, cg, cb, dcr, dcg, dcb: Single; scale: Single; octaves: integer; persistence: Single := 0.5): array of byte;

{$endregion}

{$region Lines seption}
///Вычисляет точку пересечения 2 прямых
function Isept(LD1, LD2: SLine): vec2f;
///Вычисляет точку пересечения 2 прямых проходящих через данные точки
function Isept(p11, p12, p21, p22: vec2f): vec2f;
///Вычисляет расстояние между точками
function LBP(p1, p2: vec2f): Single;
///Вычисляет расстояние точки p до отрезка p1-p2 с данными и отрезке p1-p2 и перпендикулярной ему приямой проходящей через p
function LTL(p1, p2, p: vec2f; LD1, LD2: SLine): Single;
///Вычисляет расстояние точки p до отрезка p1-p2
function LTL(p1, p2, p: vec2f): Single;
///вычисляет расстояние между отрезками с зарание извесными данными о прямых на которых лежат отрезки
function LBL(p11, p12, p21, p22: vec2f; LD1, LD2: SLine): Single;
///вычисляет расстояние между отрезками
function LBL(p11, p12, p21, p22: vec2f): Single;
///Вычисляет находится ли точка p лежащая на прямой p1-p2 на отрезке p1-p2
function POL(p1, p2, p: vec2f; ver, hor: boolean): boolean;
///Вычисляет находится ли точка p лежащая на прямой p1-p2 на отрезке p1-p2
function POL(p1, p2, p: vec2f): boolean;
///Проверяет пересекается ли вектор p21-d2 с отрезком p11-p12
function HaveIseptPPPD(p11, p12, p21, d2: vec2f): boolean;
///Проверяет пересекается ли отрезок p21-p22 с отрезком p11-p12
function HaveIseptPPPP(p11, p12, p21, p22: vec2f): boolean;
{$endregion}

{$region Hitbox Hit Calc}
///Проверяет пересечение пути из вектора p21-d2 и радиуса dr с отрезком p11-p12 и если надо - урезает вектор
function Isept(dr: Single; p11, p12, p21: vec2f; var d2: vec2f): boolean;
///Полноценная проверка пути на пересечение со всеми хитбоксами
procedure TestHit(dr: Single; l: List<HitBoxT>; from: vec2f; var Sp: vec2f);
///Проверяет находится ли 1 полигон в другом путём проведения прямой через средние точки обоих полигонов и осмотра порядка её пересечения с гранями полигонов
function TRI(HB1l, HB2l: List<HitBoxT>): boolean;
///Проверяет если у полигонов общая область
function TRO(HB1l, HB2l: List<HitBoxT>): boolean;
{$endregion}

implementation

{$region external}

function GetKeyState(nVirtKey: byte): byte;external 'User32.dll' name 'GetKeyState';

procedure keybd_event(bVk, bScan: byte; dwFlags, dwExtraInfo: cardinal);external 'User32.dll' name 'keybd_event';

{$endregion}

{$region Dop Types}

{$region HitBoxT}

function HitBoxT.rot := ArcTg(p2.X - p1.X, p2.Y - p1.Y);

function HitBoxT.w := sqrt(sqr(p2.X - p1.X) + sqr(p2.Y - p1.Y));

function HitBoxT.Senter := new vec2f((p1.X + p2.X) / 2, (p1.Y + p2.Y) / 2);

constructor HitBoxT.create(p1, p2: vec2f);
begin
  self.p1 := p1;
  self.p2 := p2;
end;

constructor HitBoxT.create(w, rot: Single; Sent: vec2f);
begin
  w /= 2;
  p1 := new vec2f(Sent.X - w * Cos(rot), Sent.Y - w * Sin(rot));
  p2 := new vec2f(Sent.X + w * Cos(rot), Sent.Y + w * Sin(rot));
end;

function HitBoxT.Reverse := new HitBoxT(p2, p1);

{$endregion}

{$endregion}

{$region extensionmethod}

{$region vec}

{$region vec2f}

function Rotate(Self: vec2f; rot: Single): vec2f; extensionmethod;
begin
  var X := Self.X;
  var Y := Self.Y;
  Rotate(X, Y, rot);
  Result := new vec2f(X, Y);
end;

function Round(Self: vec2f); extensionmethod := new vec2i(Round(Self.X), Round(Self.Y));

{$endregion}

{$region vec3f}

function Rotate(Self, vec: vec3f; w: Single): vec3f; extensionmethod;
begin
  
  w /= 2;
  vec := vec * Sin(w);
  w := Cos(w);
  
  var s  := 2 / (vec.X * vec.X + vec.Y * vec.Y + vec.Z * vec.Z + w * w);
  
  var x2 := vec.x * s;    var y2 := vec.y * s;    var z2 := vec.z * s;
  var xx := vec.x * x2;   var xy := vec.x * y2;   var xz := vec.x * z2;
  var yy := vec.y * y2;   var yz := vec.y * z2;   var zz := vec.z * z2;
  var wx := w * x2;       var wy := w * y2;       var wz := w * z2;
  
  Result := new vec3f(
   (1 - (yy + zz)) * Self.X +     ((xy + wz)) * Self.Y +     ((xz - wy)) * Self.Z,
       ((xy - wz)) * Self.X + (1 - (xx + zz)) * Self.Y +     ((yz + wx)) * Self.Z,
       ((xz + wy)) * Self.X +     ((yz - wx)) * Self.Y + (1 - (xx + yy)) * Self.Z);
  
end;

function RotateZ(Self: vec3f; rot: Single): vec3f; extensionmethod;
begin
  var X := Self.X;
  var Y := Self.Y;
  Rotate(X, Y, rot);
  Result := new vec3f(X, Y, Self.Z);
end;

function Round(Self: vec3f); extensionmethod := new vec3i(Round(Self.X), Round(Self.Y), Round(Self.Z));

{$endregion}

{$region vec2d}

function Rotate(Self: vec2d; rot: Single): vec2d; extensionmethod;
begin
  var X := Self.X;
  var Y := Self.Y;
  Rotate(X, Y, rot);
  Result := new vec2d(X, Y);
end;

function Round(Self: vec2d); extensionmethod := new vec2i(Round(Self.X), Round(Self.Y));

{$endregion}

{$region vec3d}

function Rotate(Self, vec: vec3d; w: real): vec3d; extensionmethod;
begin
  
  w /= 2;
  vec := vec * Sin(w);
  w := Cos(w);
  
  var s  := 2 / (vec.X * vec.X + vec.Y * vec.Y + vec.Z * vec.Z + w * w);
  
  var x2 := vec.x * s;    var y2 := vec.y * s;    var z2 := vec.z * s;
  var xx := vec.x * x2;   var xy := vec.x * y2;   var xz := vec.x * z2;
  var yy := vec.y * y2;   var yz := vec.y * z2;   var zz := vec.z * z2;
  var wx := w * x2;       var wy := w * y2;       var wz := w * z2;
  
  Result := new vec3d(
   (1 - (yy + zz)) * Self.X +     ((xy + wz)) * Self.Y +     ((xz - wy)) * Self.Z,
       ((xy - wz)) * Self.X + (1 - (xx + zz)) * Self.Y +     ((yz + wx)) * Self.Z,
       ((xz + wy)) * Self.X +     ((yz - wx)) * Self.Y + (1 - (xx + yy)) * Self.Z);
  
end;

function RotateZ(Self: vec3d; rot: real): vec3d; extensionmethod;
begin
  var X := Self.X;
  var Y := Self.Y;
  Rotate(X, Y, rot);
  Result := new vec3d(X, Y, Self.Z);
end;

function Round(Self: vec3d); extensionmethod := new vec3i(Round(Self.X), Round(Self.Y), Round(Self.Z));

{$endregion}

{$region Tvec3d}

function Rotate(Self: Tvec3d; vec: vec3d; w: real): Tvec3d; extensionmethod;
begin
  
  w /= 2;
  vec := vec * Sin(w);
  w := Cos(w);
  
  var s  := 2 / (vec.X * vec.X + vec.Y * vec.Y + vec.Z * vec.Z + w * w);
  
  var x2 := vec.x * s;    var y2 := vec.y * s;    var z2 := vec.z * s;
  var xx := vec.x * x2;   var xy := vec.x * y2;   var xz := vec.x * z2;
  var yy := vec.y * y2;   var yz := vec.y * z2;   var zz := vec.z * z2;
  var wx := w * x2;       var wy := w * y2;       var wz := w * z2;
  
  Result := new Tvec3d(
   (1 - (yy + zz)) * Self.X +     ((xy + wz)) * Self.Y +     ((xz - wy)) * Self.Z,
       ((xy - wz)) * Self.X + (1 - (xx + zz)) * Self.Y +     ((yz + wx)) * Self.Z,
       ((xz + wy)) * Self.X +     ((yz - wx)) * Self.Y + (1 - (xx + yy)) * Self.Z, Self.TX, Self.TY);
  
end;

function RotateZ(Self: Tvec3d; rot: real): Tvec3d; extensionmethod;
begin
  var X := Self.X;
  var Y := Self.Y;
  Rotate(X, Y, rot);
  Result := new Tvec3d(X, Y, Self.Z, Self.TX, Self.TY);
end;

{$endregion}

{$endregion}

{$region HitBoxT}

function operator+(HB: HitBoxT; p: vec2f); extensionmethod := new HitBoxT(HB.p1 + p, HB.p2 + p);

function operator-(HB: HitBoxT; p: vec2f); extensionmethod := new HitBoxT(HB.p1 - p, HB.p2 - p);

function operator*(HB: HitBoxT; r: Single); extensionmethod := new HitBoxT(HB.p1 * r, HB.p2 * r);

function operator/(HB: HitBoxT; r: Single); extensionmethod := new HitBoxT(HB.p1 / r, HB.p2 / r);

function Rotate(Self: HitBoxT; rot: Single); extensionmethod := new HitBoxT(Self.p1.Rotate(rot), Self.p2.Rotate(rot));

function Round(Self: HitBoxT); extensionmethod := new HitBoxT(Self.p1.Round, Self.p2.Round);

{$endregion}

{$region Sequence}

{$region Misc}

function Rand<T>(Self: sequence of T); extensionmethod := Self.ElementAt(Random(Self.Count));

function operator+<T>(l: List<T>; a: T): List<T>; extensionmethod;
begin
  Result := new List<T>(l.Count + 1);
  Result.AddRange(l);
  Result.Add(a);
end;

function operator+<T>(a: T; l: List<T>): List<T>; extensionmethod;
begin
  Result := new List<T>(l.Count + 1);
  Result.Add(a);
  Result.AddRange(l);
end;

procedure RemoveRange<T>(Self, l: List<T>); extensionmethod;
begin
  foreach var o in l do Self.Remove(o);
end;

procedure operator+=<T>(var a: array of T; b: array of T); extensionmethod := a := a + b;

{$endregion}

{$region Rotate}

function Rotate(Self: array of vec2f; rot: real): array of vec2f; extensionmethod;
begin
  for i: integer := 0 to Self.Length - 1 do
    Self[i] := Self[i].Rotate(rot);
  Result := Self;
end;

function Rotate(Self: array of Tvec3d; rot: real): array of Tvec3d; extensionmethod;
begin
  for i: integer := 0 to Self.Count - 1 do
    Self[i] := Self[i].RotateZ(rot);
  Result := Self;
end;

function Rotate(Self: List<HitBoxT>; rot: real): List<HitBoxT>; extensionmethod;
begin
  for i: integer := 0 to Self.Count - 1 do
    Self[i] := Self[i].Rotate(rot);
  Result := Self;
end;

{$endregion}

{$region Round}

function Round(Self: List<HitBoxT>): List<HitBoxT>; extensionmethod;
begin
  for i: integer := 0 to Self.Count - 1 do
    Self[i] := Self[i].Round;
  Result := Self;
end;

{$endregion}

{$region Add}

function Add(Self: array of vec2f; dX, dY: real): array of vec2f; extensionmethod;
begin
  for i: integer := 0 to Self.Count - 1 do
  begin
    var p := Self[i];
    Self[i] := new vec2f(p.X + dX, p.Y + dY);
  end;
  Result := Self;
end;

function Add(Self: array of vec3d; dX, dY, dZ: real): array of vec3d; extensionmethod;
begin
  for i: integer := 0 to Self.Count - 1 do
  begin
    var p := Self[i];
    Self[i] := new vec3d(p.X + dX, p.Y + dY, p.Z + dZ);
  end;
  Result := Self;
end;

function Add(Self: array of Cvec3d; dX, dY, dZ: real): array of Cvec3d; extensionmethod;
begin
  for i: integer := 0 to Self.Count - 1 do
  begin
    var p := Self[i];
    Self[i] := new Cvec3d(p.X + dX, p.Y + dY, p.Z + dZ, p.cr, p.cg, p.cb, p.ca);
  end;
  Result := Self;
end;

function AddToHB(Self: List<HitBoxT>; d: vec2f): List<HitBoxT>; extensionmethod;
begin
  for i: integer := 0 to Self.Count - 1 do
    Self[i] := Self[i] + d;
  Result := Self;
end;

{$endregion}

{$region Add3rd}

function Add3rd(Self: array of vec2f; Z: Single): array of vec3f; extensionmethod;
begin
  Result := new vec3f[Self.Count];
  for i: integer := 0 to Result.Length - 1 do
    Result[i] := new vec3f(Self[i].X, Self[i].Y, Z);
end;

function Add3rd(Self: array of vec2d; Z: real): array of vec3d; extensionmethod;
begin
  Result := new vec3d[Self.Count];
  for i: integer := 0 to Result.Length - 1 do
    Result[i] := new vec3d(Self[i].X, Self[i].Y, Z);
end;

{$endregion}

{$region Mlt}

function Mlt(Self: array of vec2f; r: Single): array of vec2f; extensionmethod;
begin
  for i: integer := 0 to Self.Count - 1 do
    Self[i] := Self[i] * r;
  Result := Self;
end;

function Mlt(Self: array of vec2d; r: real): array of vec2d; extensionmethod;
begin
  for i: integer := 0 to Self.Count - 1 do
    Self[i] := Self[i] * r;
  Result := Self;
end;

function Mlt(Self: array of vec3f; r: Single): array of vec3f; extensionmethod;
begin
  for i: integer := 0 to Self.Count - 1 do
    Self[i] := Self[i] * r;
  Result := Self;
end;

function Mlt(Self: array of vec3d; r: real): array of vec3d; extensionmethod;
begin
  for i: integer := 0 to Self.Count - 1 do
    Self[i] := Self[i] * r;
  Result := Self;
end;

function Mlt(Self: List<HitBoxT>; r: Single): List<HitBoxT>; extensionmethod;
begin
  for i: integer := 0 to Self.Count - 1 do
    Self[i] := Self[i] * r;
  Result := Self;
end;

{$endregion}

{$region Arr Conversion}

{$region ToVec2i}

function ToVec2iArr(Self: array of vec2i): array of vec2i; extensionmethod;
begin
  Result := new vec2i[Self.Count];
  for var i: integer := 0 to Self.Count - 1 do
    Result[i] := vec2i(Self[i]);
end;

function ToVec2iArr(Self: array of vec3i): array of vec2i; extensionmethod;
begin
  Result := new vec2i[Self.Count];
  for var i: integer := 0 to Self.Count - 1 do
    Result[i] := vec2i(Self[i]);
end;

function ToVec2iArr(Self: array of vec2f): array of vec2i; extensionmethod;
begin
  Result := new vec2i[Self.Count];
  for var i: integer := 0 to Self.Count - 1 do
    Result[i] := vec2i(Self[i]);
end;

function ToVec2iArr(Self: array of vec3f): array of vec2i; extensionmethod;
begin
  Result := new vec2i[Self.Count];
  for var i: integer := 0 to Self.Count - 1 do
    Result[i] := vec2i(Self[i]);
end;

function ToVec2iArr(Self: array of vec2d): array of vec2i; extensionmethod;
begin
  Result := new vec2i[Self.Count];
  for var i: integer := 0 to Self.Count - 1 do
    Result[i] := vec2i(Self[i]);
end;

function ToVec2iArr(Self: array of vec3d): array of vec2i; extensionmethod;
begin
  Result := new vec2i[Self.Count];
  for var i: integer := 0 to Self.Count - 1 do
    Result[i] := vec2i(Self[i]);
end;

{$endregion}

{$region ToVec3i}

function ToVec3iArr(Self: array of vec2i): array of vec3i; extensionmethod;
begin
  Result := new vec3i[Self.Count];
  for var i: integer := 0 to Self.Count - 1 do
    Result[i] := vec3i(Self[i]);
end;

function ToVec3iArr(Self: array of vec3i): array of vec3i; extensionmethod;
begin
  Result := new vec3i[Self.Count];
  for var i: integer := 0 to Self.Count - 1 do
    Result[i] := vec3i(Self[i]);
end;

function ToVec3iArr(Self: array of vec2f): array of vec3i; extensionmethod;
begin
  Result := new vec3i[Self.Count];
  for var i: integer := 0 to Self.Count - 1 do
    Result[i] := vec3i(Self[i]);
end;

function ToVec3iArr(Self: array of vec3f): array of vec3i; extensionmethod;
begin
  Result := new vec3i[Self.Count];
  for var i: integer := 0 to Self.Count - 1 do
    Result[i] := vec3i(Self[i]);
end;

function ToVec3iArr(Self: array of vec2d): array of vec3i; extensionmethod;
begin
  Result := new vec3i[Self.Count];
  for var i: integer := 0 to Self.Count - 1 do
    Result[i] := vec3i(Self[i]);
end;

function ToVec3iArr(Self: array of vec3d): array of vec3i; extensionmethod;
begin
  Result := new vec3i[Self.Count];
  for var i: integer := 0 to Self.Count - 1 do
    Result[i] := vec3i(Self[i]);
end;

{$endregion}

{$region ToVec2f}

function ToVec2fArr(Self: array of vec2i): array of vec2f; extensionmethod;
begin
  Result := new vec2f[Self.Count];
  for var i: integer := 0 to Self.Count - 1 do
    Result[i] := vec2f(Self[i]);
end;

function ToVec2fArr(Self: array of vec3i): array of vec2f; extensionmethod;
begin
  Result := new vec2f[Self.Count];
  for var i: integer := 0 to Self.Count - 1 do
    Result[i] := vec2f(Self[i]);
end;

function ToVec2fArr(Self: array of vec2f): array of vec2f; extensionmethod;
begin
  Result := new vec2f[Self.Count];
  for var i: integer := 0 to Self.Count - 1 do
    Result[i] := vec2f(Self[i]);
end;

function ToVec2fArr(Self: array of vec3f): array of vec2f; extensionmethod;
begin
  Result := new vec2f[Self.Count];
  for var i: integer := 0 to Self.Count - 1 do
    Result[i] := vec2f(Self[i]);
end;

function ToVec2fArr(Self: array of vec2d): array of vec2f; extensionmethod;
begin
  Result := new vec2f[Self.Count];
  for var i: integer := 0 to Self.Count - 1 do
    Result[i] := vec2f(Self[i]);
end;

function ToVec2fArr(Self: array of vec3d): array of vec2f; extensionmethod;
begin
  Result := new vec2f[Self.Count];
  for var i: integer := 0 to Self.Count - 1 do
    Result[i] := vec2f(Self[i]);
end;

{$endregion}

{$region ToVec3f}

function ToVec3fArr(Self: array of vec2i): array of vec3f; extensionmethod;
begin
  Result := new vec3f[Self.Count];
  for var i: integer := 0 to Self.Count - 1 do
    Result[i] := vec3f(Self[i]);
end;

function ToVec3fArr(Self: array of vec3i): array of vec3f; extensionmethod;
begin
  Result := new vec3f[Self.Count];
  for var i: integer := 0 to Self.Count - 1 do
    Result[i] := vec3f(Self[i]);
end;

function ToVec3fArr(Self: array of vec2f): array of vec3f; extensionmethod;
begin
  Result := new vec3f[Self.Count];
  for var i: integer := 0 to Self.Count - 1 do
    Result[i] := vec3f(Self[i]);
end;

function ToVec3fArr(Self: array of vec3f): array of vec3f; extensionmethod;
begin
  Result := new vec3f[Self.Count];
  for var i: integer := 0 to Self.Count - 1 do
    Result[i] := vec3f(Self[i]);
end;

function ToVec3fArr(Self: array of vec2d): array of vec3f; extensionmethod;
begin
  Result := new vec3f[Self.Count];
  for var i: integer := 0 to Self.Count - 1 do
    Result[i] := vec3f(Self[i]);
end;

function ToVec3fArr(Self: array of vec3d): array of vec3f; extensionmethod;
begin
  Result := new vec3f[Self.Count];
  for var i: integer := 0 to Self.Count - 1 do
    Result[i] := vec3f(Self[i]);
end;

{$endregion}

{$region ToVec2d}

function ToVec2dArr(Self: array of vec2i): array of vec2d; extensionmethod;
begin
  Result := new vec2d[Self.Count];
  for var i: integer := 0 to Self.Count - 1 do
    Result[i] := vec2d(Self[i]);
end;

function ToVec2dArr(Self: array of vec3i): array of vec2d; extensionmethod;
begin
  Result := new vec2d[Self.Count];
  for var i: integer := 0 to Self.Count - 1 do
    Result[i] := vec2d(Self[i]);
end;

function ToVec2dArr(Self: array of vec2f): array of vec2d; extensionmethod;
begin
  Result := new vec2d[Self.Count];
  for var i: integer := 0 to Self.Count - 1 do
    Result[i] := vec2d(Self[i]);
end;

function ToVec2dArr(Self: array of vec3f): array of vec2d; extensionmethod;
begin
  Result := new vec2d[Self.Count];
  for var i: integer := 0 to Self.Count - 1 do
    Result[i] := vec2d(Self[i]);
end;

function ToVec2dArr(Self: array of vec2d): array of vec2d; extensionmethod;
begin
  Result := new vec2d[Self.Count];
  for var i: integer := 0 to Self.Count - 1 do
    Result[i] := vec2d(Self[i]);
end;

function ToVec2dArr(Self: array of vec3d): array of vec2d; extensionmethod;
begin
  Result := new vec2d[Self.Count];
  for var i: integer := 0 to Self.Count - 1 do
    Result[i] := vec2d(Self[i]);
end;

{$endregion}

{$region ToVec3d}

function ToVec3dArr(Self: array of vec2i): array of vec3d; extensionmethod;
begin
  Result := new vec3d[Self.Count];
  for var i: integer := 0 to Self.Count - 1 do
    Result[i] := vec3d(Self[i]);
end;

function ToVec3dArr(Self: array of vec3i): array of vec3d; extensionmethod;
begin
  Result := new vec3d[Self.Count];
  for var i: integer := 0 to Self.Count - 1 do
    Result[i] := vec3d(Self[i]);
end;

function ToVec3dArr(Self: array of vec2f): array of vec3d; extensionmethod;
begin
  Result := new vec3d[Self.Count];
  for var i: integer := 0 to Self.Count - 1 do
    Result[i] := vec3d(Self[i]);
end;

function ToVec3dArr(Self: array of vec3f): array of vec3d; extensionmethod;
begin
  Result := new vec3d[Self.Count];
  for var i: integer := 0 to Self.Count - 1 do
    Result[i] := vec3d(Self[i]);
end;

function ToVec3dArr(Self: array of vec2d): array of vec3d; extensionmethod;
begin
  Result := new vec3d[Self.Count];
  for var i: integer := 0 to Self.Count - 1 do
    Result[i] := vec3d(Self[i]);
end;

function ToVec3dArr(Self: array of vec3d): array of vec3d; extensionmethod;
begin
  Result := new vec3d[Self.Count];
  for var i: integer := 0 to Self.Count - 1 do
    Result[i] := vec3d(Self[i]);
end;

{$endregion}

{$endregion}

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

procedure Rotate(var X, Y: Single; rot: Single);
begin
  var sr := Sin(rot); var cr := Cos(rot);
  (X, Y) := (
   +X * cr - Y * sr,
   +X * sr + Y * cr);
end;

procedure Rotate(var X, Y: real; rot: real);
begin
  var sr := Sin(rot); var cr := Cos(rot);
  (X, Y) := (
   +X * cr - Y * sr,
   +X * sr + Y * cr);
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

function Round(p: vec2f) := new vec2i(Round(p.X), Round(p.Y));

function Round(HB: HitBoxT) := new HitBoxT(Round(HB.p1), Round(HB.p2));

procedure MO2DChain(ConTo: vec2f; obj: array of MObject2D);
begin
  {
  var l := sqrt(sqr(p1.X - p2.X) + sqr(p1.Y - p2.Y));
  var pr := pr1 + pr2;
  if l = 0 then
  begin
  var ang := ArcTg(d2.X, d2.Y);
  d1 := new vec2f(0, 0);
  d2 := new vec2f(Cos(ang) * MinL, Sin(ang) * MinL);
  end else if l > MaxL then
  begin
  var dl := (l - MaxL) / 2;
  var d := new vec2f((p2.X - p1.X) / l * dl, (p2.Y - p1.Y) / l * dl);
  
  var nd1 := new vec2f((d1.X * pr2 + d2.X * pr1) / pr, (d1.Y * pr2 + d2.Y * pr1) / pr);
  d1 := nd1;d2 := nd1;
  
  d1.X += d.X / 0.8 / pr * pr1 / 2;d1.Y += d.Y / 0.8 / pr * pr1 / 2;
  d2.X -= d.X / 0.8 / pr * pr2 / 2;d2.Y -= d.Y / 0.8 / pr * pr2 / 2;
  
  p2.X -= d.X / 0.8 / pr * pr2;p2.Y -= d.Y / 0.8 / pr * pr2;
  end else if l < MinL then
  begin
  var dl := (MinL - l) / 2;
  var d := new vec2f((p1.X - p2.X) / l * dl, (p1.Y - p2.Y) / l * dl);
  d1.X += d.X / 0.8 / pr * pr1;d1.Y += d.Y / 0.8 / pr * pr1;
  d2.X -= d.X / 0.8 / pr * pr2;d2.Y -= d.Y / 0.8 / pr * pr2;
  end;
  {}
end;

function OnLeft(p1, p2, pt: vec2f; LD: SLine): boolean;
begin
  var LD2 := LD;
  LD.BLineData(pt);
  Result := LD.XYSwaped ? ((LD.b < LD2.b) xor (p2.Y > p1.Y)) : ((LD.b > LD2.b) xor (p2.X > p1.X));
end;

function OnLeft(p1, p2, pt: vec2f) := OnLeft(p1, p2, pt, SLine.LineData(p1, p2));

procedure LineToPts(HB: HitBoxT; CellW: word; var nl: List<vec2i>);
begin
  
  var l := nl;
  
  var AddToL: procedure(p: vec2f) := p -> begin
    
    var np := new vec2i(Round(p.X / CellW), Round(p.Y / CellW));
    if not l.Contains(np) then l.Add(np);
    
  end;
  
  var x1 := HB.p1.X;var x2 := HB.p2.X;
  var y1 := HB.p1.Y;var y2 := HB.p2.Y;
  
  var dx := x2 - x1;
  var dy := y2 - y1;
  
  if (dx <> 0) or (dy <> 0) then
  begin
    
    var XYSwaped := abs(dx) < abs(dy);
    if XYSwaped then
    begin
      Swap(dx, dy);
      Swap(x1, y1);
      Swap(x2, y2);
    end;
    
    if dx < 0 then
    begin
      Swap(x1, x2);
      Swap(y1, y2);
      dx := -dx;
      dy := -dy;
    end;
    
    if XYSwaped then begin
      AddToL(new vec2f(y1, x1));
      AddToL(new vec2f(y2, x2));
    end else begin
      AddToL(new vec2f(x1, y1));
      AddToL(new vec2f(x2, y2));
    end;
    
    var a := dy / dx;
    
    for var x := Round(x1) to Round(x2) - 1 do
      if XYSwaped then begin
        AddToL(new vec2f((x + 0.5 - x1) * a + y1, x + 0));
        AddToL(new vec2f((x + 0.5 - x1) * a + y1, x + 1));
      end else begin
        AddToL(new vec2f(x + 0, (x + 0.5 - x1) * a + y1));
        AddToL(new vec2f(x + 1, (x + 0.5 - x1) * a + y1));
      end;
    
  end else
    AddToL(HB.p1);
  
  nl := l;
end;

{$endregion}

{$region arr funcs}

function PTHB(p: array of vec2f): List<HitBoxT>;
begin
  Result := new List<HitBoxT>(p.Length - 1);
  for i: integer := 0 to p.Length - 2 do
    Result.Add(new HitBoxT(p[i], p[i + 1]));
end;

function PTHB(p: array of vec2f; c: integer): List<HitBoxT>;
begin
  Result := new List<HitBoxT>(c);
  for i: integer := 0 to p.Length - 2 do
    Result.Add(new HitBoxT(p[i], p[i + 1]));
end;

function GetPerlinNoisePaternBytes1(DetLvl: word; w, h: cardinal; cr, cg, cb, dcr, dcg, dcb: Single; Frq, Amp: Single; Step: Single): array of byte;
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

function GetPerlinNoisePaternBytes2(w, h: cardinal; cr, cg, cb, dcr, dcg, dcb: Single; scale: Single; octaves: integer; persistence: Single): array of byte;
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

{$endregion}

{$region Lines seption}

function Isept(LD1, LD2: SLine): vec2f;
begin
  if LD1.XYSwaped = LD2.XYSwaped then
    Result.X := (LD2.b - LD1.b) / (LD1.a - LD2.a) else
    Result.X := (LD1.b * LD2.a + LD2.b) / (1 - LD1.a * LD2.a);
  if Single.IsNaN(Result.X) then exit;
  Result.Y := LD1.a * Result.X + LD1.b;
  if LD1.XYSwaped then
    Result := new vec2f(Result.Y, Result.X);
end;

function Isept(p11, p12, p21, p22: vec2f) := Isept(SLine.LineData(p11, p12), SLine.LineData(p21, p22));

function LBP(p1, p2: vec2f) := sqrt(sqr(p2.X - p1.X) + sqr(p2.Y - p1.Y));

function LTL(p1, p2, p: vec2f; LD1, LD2: SLine): Single;
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

function LTL(p1, p2, p: vec2f): Single;
begin
  var LD1 := SLine.LineData(p1, p2);
  Result := LTL(p1, p2, p, LD1, LD1.Perpend(p));
end;

function LBL(p11, p12, p21, p22: vec2f; LD1, LD2: SLine): Single;
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

function LBL(p11, p12, p21, p22: vec2f) := LBL(p11, p12, p21, p22, SLine.LineData(p11, p12), SLine.LineData(p21, p22));

function POL(p1, p2, p: vec2f; ver, hor: boolean) :=
(ver or ((p1.X < p2.X) ? (p1.X < p.X) and (p.X < p2.X) : (p1.X > p.X) and (p.X > p2.X))) and
  (hor or ((p1.Y < p2.Y) ? (p1.Y < p.Y) and (p.Y < p2.Y) : (p1.Y > p.Y) and (p.Y > p2.Y)));

function POL(p1, p2, p: vec2f) := POL(p1, p2, p, p2.X = p1.X, p2.Y = p1.Y);

function HaveIseptPPPD(p11, p12, p21, d2: vec2f): boolean;
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

function HaveIseptPPPP(p11, p12, p21, p22: vec2f): boolean;
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

function Isept(dr: Single; p11, p12, p21: vec2f; var d2: vec2f): boolean;
begin
  var d1 := new vec2f(p12.X - p11.X, p12.Y - p11.Y);
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

procedure TestHit(dr: Single; l: List<HitBoxT>; from: vec2f; var Sp: vec2f);
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
  p1, p2: vec2f;

begin
  //находим средние точки полигонов
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
  //записываем что с ними пересеклось
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
  //ищем чтоб какая часть прямой была в обоих полигонах
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