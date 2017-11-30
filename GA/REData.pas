unit REData;

interface

uses GData, glObjectData, CFData, TCData, System.Drawing, OpenGL;

type
  ConnectionT = class;
  Entity = class;
  Segment = class;
  Dangeon = class;
  
  {$region Dop Types}
  
  ///Тип данных которые сохраняются между PreInit и Init чтоб не вычислять их с 0 2 раза
  SegmentPreData = record
    X, Y: real;
    Z, ZMin, ZMax: smallint;
    rot: Single;
    MapHitBox: List<HitBoxT>;
    Connections: List<ConnectionT>;
    ConN: byte;
    Regs: List<Point3i>;
  end;
  ///Типо положения игрока в данный момент
  CameraT = record
    X, Y, Z, dx, dy, dz: real;
    RotX, RotY, drx, dry: Single;
    PlayerRoom: Segment;
    
    const Speed = 0.4 * 10;//ToDo 0.7*PlayerH/Camera tps
    const Boost = 1.9;//ToDo 1.5
    
    const RotSpeed = 0.0004;
    
    constructor;
    begin
      X := 0;
      Y := 0;
      Z := 0;
      RotX := 0;
      RotY := 0.5;
    end;
    
    procedure SaveToLog := Log('pos:[', (X, Y, Z), '->', (dx, dy, dz), '],dir:[', (RotX, RotY), '->', (drx, dry), ']');
  end;
  ///Данные о поле
  FloorData = record
    
    rot: real;
    slope: SLine;
    
    constructor create(rot: real; slope: SLine);
    begin
      self.rot := rot;
      self.slope := slope;
    end;
  
  end;
  
  {$endregion}
  
  ///Тип для соединений комнат
  ConnectionT = class
  
    //private class TC: int64 := 0;
  
  public 
    Z: smallint;
    HB: HitBoxT;
    w: word;
    Next: ConnectionT;
    Whose: Segment;
    ConTo: Segment;
    
    lbl: object;
    
    ///Находит направление вектора хитбокса
    public function rot: real;
    ///Возвращает true если пройти через это соединение не выйдет
    public function Empty: boolean;
    ///Возвращает центр хитбокса
    function Senter: PointF;
    ///Добавляет этот проход к списку ожидающих генерации
    public procedure AddToWait;
    
    public constructor(Z: smallint; p1, p2: PointF; Whose, ConTo: Segment);
    
    public constructor(Z: smallint; HB: HitBoxT; Whose, ConTo: Segment);
  
  end;
  //ToDo Init stTick stDraw Items(draw parts, ect)
  ///Тип всего динамичного(мобы, выщи валяющиеся на полу, предметы декора)
  Entity = abstract class
  
  public 
    Pos, Vel: PointF;
    
    public procedure Tick; abstract;
    
    public procedure Draw; abstract;
    
    protected procedure Init; virtual;
    begin
      
    end;
  
  end;
  ///Базовый тип комнат
  Segment = abstract class
  
  {$region var}
  
  protected 
    id: uint64;
    
    const MaxZ = smallint.MaxValue;
    class WPWTex := new Texture(GetResourceStream('WPW.im'), false, false, true, true);
    
    class MaxZGen: smallint;
    
    class StRarity := Dict(
    
    ('GA.Hall',  30),
    ('GA.Canal',   3),
    ('GA.TSeg',  45),
    ('GA.Treasury', 100),
    ('GA.StairTube',   0),
    
    ('Void.SegVoid',   0)
    
    );
    
    class StССRarity := Dict(
  
    ('GA.EntranceT1', (0.0,  true)),  
    ('GA.Hall', (1.5, false)),
    ('GA.Canal', (0.0,  true)),
    ('GA.TSeg', (1.5, false)),
    ('GA.Treasury', (1.5, false)),
    ('GA.StairTube', (1.5, false)),
    
    ('Void.SegVoid', (0.0, false))
    
    );
  
  public 
    X, Y: real;
    Z, ZMin, ZMax: smallint;
    rot: Single;
    PlayerSeen: boolean;
    DangeonIn: Dangeon;
    DrawObj: List<glObject>;//        +XY +Z +rot
    MapDrawObj: List<glCObject>;//    +XY +Z +rot
    Entities: List<Entity>;//         +XY +Z +rot
    
    WallHitBox: List<HitBoxT>;//      +XY +Z -rot
    
    MapHitBox: List<HitBoxT>;//       -XY    -rot
    
    Connections: List<ConnectionT>;// -XY -Z -rot
    
    {$endregion}
    
    {$region Room Data}
    
    ///Возвращает название комнаты. Обязано быть переопределено в каждом классе - комнате.
    public function ClassName: string; abstract;
    ///Возвращает данные о устойчивой поверхности под игроком
    public function GetFloor(nCamera: CameraT): FloorData; virtual;
    ///Возвращает список хитбоксов стен и не прогруженных проходов
    public function GetAllHB: List<HitBoxT>; virtual;
    ///Возвращает ссылку на список соединений которые ожидают генерации который храница в данже
    public function RoomWait: List<ConnectionT>;
    
    {$endregion}
    
    {$region Draw}
    
    ///[DEBAG] рисует регионы данжа
    public procedure DrawDangeonRegs;
    ///Рисует комнату и прилежащие ей
    public procedure Draw(dx, dy: Single); virtual;
    ///Упрощённо рисует комнату для карты
    public function DrawForMap(dx, dy, dz: Single): boolean; virtual;
    
    {$endregion}
    
    {$region Tick}
    
    ///Происходит каждый тик, в который игрок находится в данной комнате
    public procedure PlayerTick; virtual;
    ///Происходит каждый тик
    public procedure DangeonTick; virtual;
    
    {$endregion}
    
    {$region Connections}
    
    ///Процедура закрытия выхода из комнаты по причине невозможности прикрепить к нему другую комнату
    public procedure CloseWay(C: ConnectionT); virtual;
    ///Возвращает вероятность соединения 2 выходов которые находятся рядом на карте
    public function CCRarity: real; virtual;
    ///Возвращает принуждённость соединения 2 выходов разных комнат которые находятся рядом на карте
    public function ForceConnecting: boolean; virtual;
    ///Просчитывает вероятность соединения любого выхода этой комнаты с любым комнаты T
    public function WantConnect(T: Segment): boolean; virtual;
    
    {$endregion}
    
    {$region Init}
    
    ///Выполняет часть инициализации новой комнаты связаную с данжем
    public procedure AddToDangeon(D: Dangeon; Regs: List<Point3i>);
    ///Производит стандартную инициализацию для комнаты - вохода в данж
    protected procedure Init(DangeonIn: Dangeon; X, Y: real; Z, ZMin, ZMax: smallint; MinDrawObjC, MinMapDrawObjC, MinConnections: word);
    ///Производит начало часть стандартной инициализации, необходимую для определения подходит ли комната по расположению. Номер соединения - входа зафиксирован с CN
    protected class function PreInit(var Pre: SegmentPreData; DangeonIn: Dangeon; CF: ConnectionT; Conns: List<ConnectionT>; CN: integer; MapHitBox: List<HitBoxT>): boolean;
    ///Производит начало часть стандартной инициализации, необходимую для определения подходит ли комната по расположению
    protected class function PreInit(var Pre: SegmentPreData; DangeonIn: Dangeon; CF: ConnectionT; Conns: List<ConnectionT>; MapHitBox: List<HitBoxT>): boolean;
    ///Производит последнюю инициализацию, всё что не было вычислено в PreInit
    protected procedure Init(var Pre: SegmentPreData; var CF: ConnectionT; WallHitBox: List<HitBoxT>; MinDrawObj, MinMapDrawObj: integer);
  
  {$endregion}
  
  end;
  ///Стандартный тип для данжа
  Dangeon = sealed class
  
  {$region var}
  
  private 
    idused: uint64;
    WaitRoomsCreationThread: System.Threading.Thread;
    nCamera: CameraT;
  
  public 
    Rooms: List<Segment>;
    RoomWait: List<ConnectionT>;
    
    RegW: word;
    MaxR: real;
    VRmlt: real;
    Regs: Dictionary<Point3i, List<Segment>>;
    
    public class GetNewEntrance: function(self: Dangeon): Segment;
    public class GetRandSegment: function(var C: ConnectionT): Segment;
    
    {$endregion}
    
    {$region SegmentsAt}
    
    public function SegmentsAt(p: Point3i): List<Segment>;
    
    public function SegmentsAt(X, Y: integer; Z: smallint): List<Segment>;
    
    public function SegmentsAt(X, Y: real; Z: smallint): List<Segment>;
    
    {$endregion}
    
    {$region Schedule}
    
    public procedure DrawMap(X, Y, Z, R: Single);
    
    public procedure Tick(Camera: CameraT);
    
    public procedure WaitRoomsCreation;
    
    {$endregion}
    
    {$region create/destroy}
    
    public constructor(RegW: word; MaxR, VRmlt: real);
    //ToDo
    public destructor destroy;
  
    {$endregion}
  
  end;

implementation

///Float To Integer thru pointer
function fti(s: Single) := PInteger(pointer(@s))^; 

{$region extensionmethod}
///Поворачивает хитбоксы соединений на rot градусов вокруг 0;0
function Rotate(Self: List<ConnectionT>; rot: real): List<ConnectionT>; extensionmethod;
begin
  for i: integer := 0 to Self.Count - 1 do
    Self[i].HB := Rotate(Self[i].HB, rot);
  Result := Self;
end;
///Сдвигает хитбоксы соединений на вектор d
function AddToHB(Self: List<ConnectionT>; d: PointF): List<ConnectionT>; extensionmethod;
begin
  for i: integer := 0 to Self.Count - 1 do
    Self[i].HB := Self[i].HB + d;
  Result := Self;
end;

{$endregion}

{$region ConnectionT}

function ConnectionT.rot := HB.rot;

function ConnectionT.Empty := not (ConTo is Segment);

function ConnectionT.Senter := HB.Senter;

procedure ConnectionT.AddToWait := Whose.DangeonIn.RoomWait.Add(self);

constructor ConnectionT.create(Z: smallint; p1, p2: PointF; Whose, ConTo: Segment);
begin
  //TC += 1;
  //Log('TC:', TC);
  
  self.Z := Z;
  self.HB := new HitBoxT(p1, p2);
  self.Whose := Whose;
  self.ConTo := ConTo;
  w := Round(HB.w);
end;

constructor ConnectionT.create(Z: smallint; HB: HitBoxT; Whose, ConTo: Segment);
begin
  //TC += 1;
  //Log('TC:', TC);
  
  self.Z := Z;
  self.HB := HB;
  self.Whose := Whose;
  self.ConTo := ConTo;
  w := Round(HB.w);
end;

{$endregion}

{$region Segment}

{$region Room Data}

function Segment.GetFloor(nCamera: CameraT) := default(FloorData);

function Segment.GetAllHB := WallHitBox + Connections.Where(C -> C.Empty).ToList.ConvertAll(C -> C.HB - new PointF(X, Y));

function Segment.RoomWait := self.DangeonIn.RoomWait;

{$endregion}

{$region Draw}

procedure Segment.DrawDangeonRegs;
begin
  glPushMatrix;
  glTranslatef(0, 0, RW * 5);
  //Log3(RTD);
  with DangeonIn do
    foreach p: Point3i in Regs.Keys.ToArray do
    begin
      var cr := p.X * 0.76452 + 100;
      var cg := p.Y * 0.65637 + 100;
      var cb := p.Z * 0.347636 + 100;
      gr.Rectangle(true, cr - System.Math.Truncate(cr), cg - System.Math.Truncate(cg), cb - System.Math.Truncate(cb), 1, p.X * RegW - X, p.Y * RegW - Y, RegW, RegW);
    end;
  glPopMatrix;
end;

procedure Segment.Draw(dx, dy: Single);
begin
  glPushMatrix;
  glRotatef(rot / Pi * 180, 0, 0, 1);
  foreach var glObj in DrawObj.ToArray do
    glObj.Draw;
  glPopMatrix;
  
  foreach var C in Connections do
    if C.ConTo is Segment then
      with C.ConTo do
      begin
        glPushMatrix;
        glTranslatef(X - self.X, Y - self.Y, (Z - self.Z) * RW);
        glRotatef(rot / Pi * 180, 0, 0, 1);
        foreach var glObj in DrawObj.ToArray do
          glObj.Draw;
        glPopMatrix;
      end;
  
  if LHShow then
  begin
    foreach var HB in GetAllHB do
      gr.Polygon(true, 1, 0, 0, 0.2, new PPoint[4](
            new PPoint(HB.p1.X, HB.p1.Y, +10000),
            new PPoint(HB.p2.X, HB.p2.Y, +10000),
            new PPoint(HB.p2.X, HB.p2.Y, -10000),
            new PPoint(HB.p1.X, HB.p1.Y, -10000)));
    foreach var C in Connections do
      with C do
        gr.Polygon(true, 0, 1, 0, 0.2, new PPoint[4](
              new PPoint(HB.p1.X - X, HB.p1.Y - Y, +10000),
              new PPoint(HB.p2.X - X, HB.p2.Y - Y, +10000),
              new PPoint(HB.p2.X - X, HB.p2.Y - Y, -10000),
              new PPoint(HB.p1.X - X, HB.p1.Y - Y, -10000)));
  end;
  
  if false then
    DrawDangeonRegs;
  
end;

function Segment.DrawForMap(dx, dy, dz: Single): boolean;
begin
  if ShowNewRooms or PlayerSeen then
  begin
    glPushMatrix;
    glTranslatef(dx + X, dy + Y, (dz + Z) * RW);
    glRotatef(rot / Pi * 180, 0, 0, 1);
    foreach var o in MapDrawObj.ToList do
      o.Draw;
    glPopMatrix;
    Result := true;
  end;
end;

{$endregion}

{$region Tick}

procedure Segment.PlayerTick;
begin
  PlayerSeen := true;
  foreach var C in Connections.ToList do
    if C.ConTo <> nil then
      C.ConTo.PlayerSeen := true;
end;
//ToDo
procedure Segment.DangeonTick;
begin
  //foreach Entity.Tick
end;

{$endregion}

{$region Connections}

procedure Segment.CloseWay(C: ConnectionT);
begin
  if Connections.Remove(C) then
  begin
    var HB := Rotate(C.HB - new PointF(X, Y), -rot);
    DrawObj.Add(new glTObject(GL_QUADS, WPWTex, new TPoint[](
          new TPoint(HB.p1.X, HB.p1.Y, (C.Z - Z - 1) * RW, 0, 0),
          new TPoint(HB.p2.X, HB.p2.Y, (C.Z - Z - 1) * RW, 1, 0),
          new TPoint(HB.p2.X, HB.p2.Y, (C.Z - Z - 0) * RW, 1, 1),
          new TPoint(HB.p1.X, HB.p1.Y, (C.Z - Z - 0) * RW, 0, 1))));
    WallHitBox.Add(C.HB - new PointF(X, Y));
  end else
    raise new System.ArgumentException('No such connection of this room');
end;

function Segment.CCRarity: real := StССRarity[ClassName].Item1;

function Segment.ForceConnecting := StССRarity[ClassName].Item2;

function Segment.WantConnect(T: Segment) := self.ForceConnecting or T.ForceConnecting or ((Random * self.CCRarity < 1) and (Random * T.CCRarity < 1));

{$endregion}

{$region Init}

procedure Segment.AddToDangeon(D: Dangeon; Regs: List<Point3i>);
begin
  id := D.idused;
  D.idused += 1;
  DangeonIn := D;
  var Rms := D.Rooms.ToList;
  Rms.Add(self);
  D.Rooms := Rms;
  foreach var pt in Regs do
  begin
    
    var R := DangeonIn.SegmentsAt(pt).ToList;
    
    foreach var C in Connections do
      if C.ConTo = nil then
      begin
        var p1 := Round(C.HB.p1);//Round(C.HB.p1 + new PointF(X, Y));
        var p2 := Round(C.HB.p2);//Round(C.HB.p2 + new PointF(X, Y));
        var Z := C.Z + self.Z;
        
        foreach var S in R do
        begin
          
          var found := false;
          foreach var nC in S.Connections do
            if nC.ConTo = nil then
              if Z = nC.Z + S.Z then
                if Round(nC.HB.p1 + new PointF(S.X, s.Y)) = p2 then
                  if Round(nC.HB.p2 + new PointF(S.X, s.Y)) = p1 then
                    if WantConnect(S) then
                    begin
                      
                      C.Next := nC;
                      nC.Next := C;
                      
                      C.ConTo := S;
                      nC.ConTo := self;
                      
                      found := true;
                      break;
                      
                    end;
          
          if found then
            break;
          
        end;
      end;
    
    R.Add(self);
    DangeonIn.Regs[pt] := R;
    
  end;
end;

procedure Segment.Init(DangeonIn: Dangeon; X, Y: real; Z, ZMin, ZMax: smallint; MinDrawObjC, MinMapDrawObjC, MinConnections: word);
begin
  self.X := X;
  self.Y := Y;
  self.Z := Z;
  self.ZMin := ZMin;
  self.ZMax := ZMax;
  DrawObj := new List<glObject>(MinDrawObjC);
  MapDrawObj := new List<glCObject>(MinMapDrawObjC);
  Connections := new List<ConnectionT>(MinConnections);
  Entities := new List<Entity>;
  PlayerSeen := false;
  
  MapHitBox.Rotate(rot);
  var l := new List<Point>;
  foreach var HB in MapHitBox do
    LineToPts(HB, DangeonIn.RegW, l);
  var Regs := new List<Point3i>;
  foreach var p in l do
    for var nZ := ZMin to ZMax do
      Regs.Add(new Point3i(p.X, p.Y, nZ));
  ADDToDangeon(DangeonIn, Regs);
end;

class function Segment.PreInit(var Pre: SegmentPreData; DangeonIn: Dangeon; CF: ConnectionT; Conns: List<ConnectionT>; CN: integer; MapHitBox: List<HitBoxT>): boolean;
begin
  
  Pre.MapHitBox := MapHitBox;
  Pre.ConN := CN;
  
  var CT := Conns[Pre.ConN];
  
  Pre.rot := NormAng(CF.rot - CT.rot + Pi);
  Pre.Connections := Conns.Rotate(Pre.rot);
  
  begin
    var p1 := CF.HB.p1;
    var p2 := CT.HB.p2;
    Pre.X := p1.X - p2.X;
    Pre.Y := p1.Y - p2.Y;
    Pre.Z := CF.Z - CT.Z;
    Pre.ZMin += Pre.Z;
    if Pre.ZMin < 1 then
    begin
      Result := false;
      exit;
    end;
    Pre.ZMax += Pre.Z;
  end;
  
  Pre.Connections.AddToHB(new PointF(Pre.X, Pre.Y));
  foreach var C in Pre.Connections do
    C.Z += Pre.Z;
  Pre.MapHitBox.Rotate(Pre.rot);
  Pre.MapHitBox.AddToHB(new PointF(Pre.X, Pre.Y));
  
  begin
    
    var l := new List<Point>;
    
    foreach var HB in Pre.MapHitBox do
      LineToPts(HB, DangeonIn.RegW, l);
    
    var Segs := new List<Segment>;
    
    Pre.Regs := new List<Point3i>(l.Count * (Pre.ZMax - Pre.ZMin + 1));
    foreach var p in l do
      for var Z := Pre.ZMin to Pre.ZMax do
        Pre.Regs.Add(new Point3i(p.X, p.Y, Z));
    
    foreach var pt in Pre.Regs do
      foreach var S in DangeonIn.SegmentsAt(pt) do
        if not Segs.Contains(S) then
        begin
          Segs.Add(S);
          
          //Log3(Pre.MapHitBox);
          //Log3(S.MapHitBox);
          
          //Log2(Pre.MapHitBox.ConvertAll(HB -> (fti(HB.p1.X), fti(HB.p1.Y), fti(HB.p2.X), fti(HB.p2.Y))));
          //Log2(S.MapHitBox.ConvertAll(HB -> (fti(HB.p1.X), fti(HB.p1.Y), fti(HB.p2.X), fti(HB.p2.Y))));
          if TRO(Pre.MapHitBox.Round, S.MapHitBox.Round) then
          begin
            Result := false;
            //Log2('+');
            //Log2;
            //Log2(Pre.MapHitBox);
            //Log2(S.MapHitBox);
            //Log2;
            exit;
          end;
          //Log2('-');
          //Log2;
        end;
    
  end;
  
  Result := true;
  
end;

class function Segment.PreInit(var Pre: SegmentPreData; DangeonIn: Dangeon; CF: ConnectionT; Conns: List<ConnectionT>; MapHitBox: List<HitBoxT>): boolean;
begin
  
  begin
    var w := CF.w;
    if not Conns.Any(HB -> Round(HB.w) = w) then
    begin
      Result := false;
      exit;
    end;
  end;
  
  Pre.ConN := Random(Conns.Count);
      //if Result then
  while CF.w <> Conns[Pre.ConN].w do
    Pre.ConN := Random(Conns.Count);
  
  Result := PreInit(Pre, DangeonIn, CF, Conns, Pre.ConN, MapHitBox);
end;

procedure Segment.Init(var Pre: SegmentPreData; var CF: ConnectionT; WallHitBox: List<HitBoxT>; MinDrawObj, MinMapDrawObj: integer);
begin
  
  Connections := Pre.Connections;
  MapHitBox := Pre.MapHitBox;
  ZMax := Pre.ZMax;
  ZMin := Pre.ZMin;
  rot := Pre.rot;
  X := Pre.X;
  Y := Pre.Y;
  Z := Pre.Z;
  MaxZGen := Max(MaxZGen, Z);
  for i: integer := 0 to Connections.Count - 1 do
    Connections[i].Whose := self;
  
  self.WallHitBox := WallHitBox.Rotate(rot);
  Entities := new List<Entity>;
  DrawObj := new List<glObject>(MinDrawObj);
  MapDrawObj := new List<glCObject>(MinMapDrawObj);
  
  AddToDangeon(CF.Whose.DangeonIn, Pre.Regs);
  PlayerSeen := false;
  
  var CT := Pre.Connections[Pre.ConN];
  
  CF.Next := CT;
  CT.Next := CF;
  
  CF.ConTo := CT.Whose;
  CT.ConTo := CF.Whose;
  
  foreach var C in Connections do
    C.AddToWait;
  
end;

{$endregion}

{$endregion}

{$region Dangeon}

    {$region SegmentsAt}

function Dangeon.SegmentsAt(p: Point3i): List<Segment>;
begin
  if Regs.ContainsKey(p) then
    Result := Regs[p] else
  begin
    var nl := new List<Segment>;
    Result := nl;
    Regs.Add(p, nl);
  end;
end;

function Dangeon.SegmentsAt(X, Y: integer; Z: smallint) := SegmentsAt(new Point3i(X, Y, Z));

function Dangeon.SegmentsAt(X, Y: real; Z: smallint) := SegmentsAt(Round(X / RegW), Round(Y / RegW), Z);

    {$endregion}

    {$region Schedule}

procedure Dangeon.DrawMap(X, Y, Z, R: Single);
begin
  var PlayerRoom := nCamera.PlayerRoom;
  X += PlayerRoom.X;
  Y += PlayerRoom.Y;
  Z := Z / RW + PlayerRoom.Z;
  var ZMax := Ceil(Z);
  var ZMin := Floor(Z);
  
  var Segs := new List<Segment>;
  var LSegs := new List<Segment>;
  LSegs.Add(PlayerRoom);
  Segs.Add(PlayerRoom);
  PlayerRoom.DrawForMap(-X, -Y, -Z);
  while true do
  begin
    var nLSegs := LSegs.ToList;
    LSegs.Clear;
    foreach var S in nLSegs do
      foreach var C in S.Connections.ToList do
        if C.ConTo <> nil then
          if (C.ConTo.ZMin <= ZMax) and (C.ConTo.ZMax >= ZMin) then
            if sqrt(sqr(C.ConTo.X - X) + sqr(C.ConTo.Y - Y)) < R then
              if not Segs.Contains(C.ConTo) then
                if C.ConTo.DrawForMap(-X, -Y, -Z) then
                begin
                  Segs.Add(C.ConTo);
                  LSegs.Add(C.ConTo);
                end;
    if LSegs.Count = 0 then break;
  end;
  exit;
  var RS := new Point(Round(X / RegW), Round(Y / RegW));
  for var RX := RS.X - 70 to RS.X + 70 do
    for var RY := RS.Y - 70 to RS.Y + 70 do
      for var RZ := PlayerRoom.ZMin to PlayerRoom.ZMax do
      begin
        var P := new Point3i(RX, RY, RZ);
        if Regs.ContainsKey(P) then
          foreach var S: Segment in Regs[P].ToList do
            if not Segs.Contains(S) then
            begin
              Segs.Add(S);
              S.DrawForMap(-X, -Y, -Z);
            end;
      end;
end;

procedure Dangeon.Tick(Camera: CameraT);
begin
  nCamera := Camera;
  nCamera.PlayerRoom.PlayerTick;
  foreach var R in Rooms.ToList do
    R.DangeonTick;
end;

procedure Dangeon.WaitRoomsCreation;
begin
  System.Threading.Thread.CurrentThread.IsBackground := true;
  System.Threading.Thread.CurrentThread.Priority := System.Threading.ThreadPriority.Lowest;
  
  while true do
    try
      var PlayerRoom := nCamera.PlayerRoom;
          {
          System.Console.Clear;
          writeln('Комнат сгенерировано:                ', Rooms.Count);
          writeln('Комнат ожидает генерации:            ', RoomWait.Count);
          writeln('Глубина погружения:                  ', PlayerRoom.Z);
          writeln('Глубина сгенерированого подземелья:  ', Segment.MaxZGen);
          writeln('Примерная максимальная глубина:      ', MaxR / VRmlt);
          {}
      if RoomWait.Count = 0 then begin Sleep(100); continue; end;
      var C := RoomWait[0];
      var ForceCreation := false;
      begin
        var Segs2 := new List<Segment>;
        var Segs1 := new List<Segment>;
        foreach var nnC in PlayerRoom.Connections do
          if nnC.ConTo = nil then
          begin
            ForceCreation := true;
            C := nnC;
            break;
          end else
            Segs2.Add(nnC.ConTo);
        if not ForceCreation then
        begin
          foreach var S in Segs2 do
            foreach var nnC in S.Connections do
              if nnC.ConTo = nil then
              begin
                ForceCreation := true;
                C := nnC;
                break;
              end else
                Segs1.Add(nnC.ConTo);
        end;
        if not ForceCreation then
        begin
          Segs2.Clear;
          foreach var S in Segs1 do
            foreach var nnC in S.Connections do
              if nnC.ConTo = nil then
              begin
                ForceCreation := true;
                C := nnC;
                break;
              end;
        end;
        if not ForceCreation then
        begin
          var maxl: real := 0;
              //var mindZ := smallint.MaxValue;
          loop 3 do
          begin
            var nC := RoomWait.Rand;
            var l := abs(nC.Whose.X - PlayerRoom.X) + abs(nC.Whose.Y - PlayerRoom.Y) + abs(nC.Whose.Z - PlayerRoom.Z) * VRmlt;
            if l > maxl then
            begin
              maxl := l;
              C := nC;
            end;
          end;
        end;
      end;
      
          //if not ForceCreation then
          //  C := RoomWait.Rand;
      
      if not ForceCreation then
        if RTG.TCTC <> 0 then continue;
      
      RoomWait.Remove(C);
      
      if not C.Empty then continue;
      
      if (Random < Power(sqrt(sqr(C.Whose.X) + sqr(C.Whose.Y) + sqr((C.Whose.Z) * VRmlt)) / MaxR, 10)) or (GetRandSegment(C) = nil) then
      begin
        Log(C.ConTo = nil ? 'nil' : C.ConTo.ToString);
        Log(C.Empty);
        Log('-' * 50);
        C.Whose.CloseWay(C);
      end;
    
          //System.GC.Collect(System.GC.MaxGeneration, System.GCCollectionMode.Optimized);
    
    except
      on e: System.Exception do
        if e is System.Threading.ThreadAbortException then
          exit else
          SaveError('WaitRoomsCreation Thread:', e);
    end;
end;

    {$endregion}

    {$region create/destroy}

constructor Dangeon.create(RegW: word; MaxR, VRmlt: real);
begin
  self.RegW := RegW;
  self.MaxR := MaxR;
  self.VRmlt := VRmlt;
  Regs := new Dictionary<Point3i, List<Segment>>;
  Rooms := new List<Segment>(1024);
  RoomWait := new List<ConnectionT>;
  nCamera.PlayerRoom := GetNewEntrance(self);
  Tick(nCamera);
  WaitRoomsCreationThread := new System.Threading.Thread(WaitRoomsCreation);
  WaitRoomsCreationThread.Start;
end;
    //ToDo
destructor Dangeon.destroy;
begin
  Rooms.Clear;//*facepalm*... Можно подумать это сработает
  RoomWait.Clear;
  Regs.Clear;
  WaitRoomsCreationThread.Abort;
end;

    {$endregion}

{$endregion}

end.