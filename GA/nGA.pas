uses
  GData, VData, RData, EData, CFData, System.Drawing, OpenGL;
  //GData, glObjectData, System.Drawing, OpenGl, VData, REData, RData, EData, CFData;


{$region ToDo}{
  ToDo Dangeon
   -Room Finding
    -Dangeon Sectors
   -Room Creation
  ToDo Manu Text
   -Text Textures
  ToDo Up/Down
   -Staircase(0,0,0,0,0,2) Gen Error
   -Walk Up/Down
  ToDo Manu Show
  ToDo Arr->List
  ToDo vRoom? What was this?! forgot(((
  ToDo Keys detect in Calc when map is on... this to...

  ToDo Entity
   -Slime
   -Outhers

  ToDo Calc
   -Wep1 Realism?!
   -Wep2
   -Wep3

  ToDo Draw
   -Player Tex
   -3D
    -Wep1
    -Wep2 and Invisible?!
    -Wep3

  ToDo Wep
   -var->type

  ToDo Moding
   -LoadedEntity Type
   -LoadedRoom Type
{$endregion}

type
  Dangeon = class
    
    RoomArray: List<Segment>;
    
    RoomWait: List<ConectionT>;
    
    //ToDo
    function GetSegment(X, Y, Z: integer): Segment;
    begin
      
    end;
    
    //ToDo
    function GetClosestSegment(X, Y, Z: integer): Segment;
    begin
      {
      var l := sqrt(sqr(RoomArray[0].X - X) + sqr(RoomArray[0].Y - Y) + sqr(RoomArray[0].Z - Z));
      var n := 0;
      for i: integer := 1 to RoomArray.Length - 1 do
      begin
      var nl := sqrt(sqr(RoomArray[i].X - X) + sqr(RoomArray[i].Y - Y) + sqr(RoomArray[i].Z - Z));
      if nl < l then
      begin
      l := nl;
      n := i;
      end;
      end;
      Result := RoomArray[n];
      {}
    end;
    
    {$region New}
    
    //ToDo
    function RandSegment(C: ConectionT): Segment;
    begin
      {
      var n: integer;
      for nn: integer := 1 to RoomGetAttempts do
      begin
      n := Random(6);
      var Fit: boolean;
      case n of
      0: Fit := (1 > Random * StRarity.Hall) and Hall.Fit(State, X, Y, Z);
      1: Fit := (1 > Random * StRarity.Canal) and Canal.Fit(State, X, Y, Z);
      2: Fit := (1 > Random * StRarity.Corner) and Corner.Fit(State, X, Y, Z);
      3: Fit := (1 > Random * StRarity.TSeg) and TSeg.Fit(State, X, Y, Z);
      4: Fit := (1 > Random * StRarity.Treasury) and Treasury.Fit(State, X, Y, Z);
      5: Fit := (1 > Random * StRarity.Staircase) and Staircase.Fit(State, X, Y, Z);
      end;
      if Fit then break;
      
      if nn = RoomGetAttempts then
      exit;
      end;
      
      case n of
      0: Result := new Hall(X, Y, Z);
      1: Result := new Canal(State, X, Y, Z);
      2: Result := new Corner(State, X, Y, Z);
      3: Result := new TSeg(State, X, Y, Z);
      4: Result := new Treasury(State, X, Y, Z);
      5: Result := new Staircase(State, X, Y, Z);
      end;
      {}
    end;
    
    constructor;
    begin
      RoomArray := new List<Segment>(Seq(RandSegment(new ConectionT(CDT.Up, new PointF(-RW * 0.05, -RW * 0.05), new PointF(+RW * 0.05, +RW * 0.05), nil))));
      RoomWait := new List<ConectionT>;
    end;
    
    {$endregion}
    
    {$region Wait}
    
    //ToDo
    class procedure AddToWaitRoom();
    begin
      
    end;
    
    //ToDo
    class procedure CreateWaitRooms(Relat: point3f);
    begin
      RGT.Start;
      {
      for n: integer := 1 to Round(RGHR / 20) do
      begin
        var i := Random(RoomArray.Length);
        if sqrt(sqr(RoomArray[i].X) + sqr(RoomArray[i].Y) + sqr(RoomArray[i].Z)) > MazeMaxRad then
        begin
          RoomArray[i] := RoomArray[RoomArray.Length - 1];
          SetLength(RoomArray, RoomArray.Length - 1);
        end else
        begin
          var a := RoomArray[i].GetData.State;
          if a.L = 2 then if GetSegment(RoomArray[i].X - 1, RoomArray[i].Y + 0, RoomArray[i].Z + 0) = nil then AddToWaitRoom(RoomArray[i].X - 1, RoomArray[i].Y + 0, RoomArray[i].Z + 0);
          if a.R = 2 then if GetSegment(RoomArray[i].X + 1, RoomArray[i].Y + 0, RoomArray[i].Z + 0) = nil then AddToWaitRoom(RoomArray[i].X + 1, RoomArray[i].Y + 0, RoomArray[i].Z + 0);
          if a.N = 2 then if GetSegment(RoomArray[i].X + 0, RoomArray[i].Y - 1, RoomArray[i].Z + 0) = nil then AddToWaitRoom(RoomArray[i].X + 0, RoomArray[i].Y - 1, RoomArray[i].Z + 0);
          if a.S = 2 then if GetSegment(RoomArray[i].X + 0, RoomArray[i].Y + 1, RoomArray[i].Z + 0) = nil then AddToWaitRoom(RoomArray[i].X + 0, RoomArray[i].Y + 1, RoomArray[i].Z + 0);
          if a.U = 2 then if GetSegment(RoomArray[i].X + 0, RoomArray[i].Y + 0, RoomArray[i].Z + 1) = nil then AddToWaitRoom(RoomArray[i].X + 0, RoomArray[i].Y + 0, RoomArray[i].Z + 1);
          if a.D = 2 then if GetSegment(RoomArray[i].X + 0, RoomArray[i].Y + 0, RoomArray[i].Z - 1) = nil then AddToWaitRoom(RoomArray[i].X + 0, RoomArray[i].Y + 0, RoomArray[i].Z - 1);
        end;
      end;
      
      for i: integer := RoomWait.Length - 1 downto 0 do
      begin
        var Rad := sqrt(sqr(RoomWait[i].X - Relat.X) + sqr(RoomWait[i].Y - Relat.Y) + sqr(RoomWait[i].Z - Relat.Z));
        if Random * Power(Rad - RoomDrawLimit, RoomWait.Length / RGHR) < 1 then
        begin
          if Rad <= MazeRad then
          begin
            var X := RoomWait[i].X;
            var Y := RoomWait[i].Y;
            var Z := RoomWait[i].Z;
      
            var Res: Segment;
            var L, R, N, S, U, D: byte;
            var SL, SR, SN, SS, SU, SD: Segment;
      
            SL := GetSegment(X - 1, Y, Z);
            SR := GetSegment(X + 1, Y, Z);
            SN := GetSegment(X, Y - 1, Z);
            SS := GetSegment(X, Y + 1, Z);
            SU := GetSegment(X, Y, Z + 1);
            SD := GetSegment(X, Y, Z - 1);
              //writeln(((X,Y,Z),(SL=nil?1:0,SR=nil?1:0,SN=nil?1:0,SS=nil?1:0,SU=nil?1:0,SD=nil?1:0)));
      
            L := SL = nil ? 1 : SL.GetData.State.R;
            R := SR = nil ? 1 : SR.GetData.State.L;
            N := SN = nil ? 1 : SN.GetData.State.S;
            S := SS = nil ? 1 : SS.GetData.State.N;
            U := SU = nil ? 1 : SU.GetData.State.D;
            D := SD = nil ? 1 : SD.GetData.State.U;
      
            var State := new StateT(L, R, N, S, U, D);
            Res := RandSegment(State, X, Y, Z);
            if Rad <= 1 then
            begin
              for nn: integer := 1 to 1000 do
              begin
                if Res <> nil then break else
                  Res := RandSegment(State, X, Y, Z);
              end;
              if Res = nil then
              begin
                if SL <> nil then SL.CloseWay(2);
                if SR <> nil then SR.CloseWay(1);
                if SN <> nil then SN.CloseWay(4);
                if SS <> nil then SS.CloseWay(3);
      
                RoomWait[i] := RoomWait[RoomWait.Length - 1];
                SetLength(RoomWait, RoomWait.Length - 1);
                continue;
              end;
            end else
            if Res = nil then
              continue;
              //write(State,'->');
            State := Res.GetData.State;
              //writeln(State);
      
            if State.L = 2 then if SL = nil then AddToWaitRoom(X - 1, Y, Z);
            if State.R = 2 then if SR = nil then AddToWaitRoom(X + 1, Y, Z);
            if State.N = 2 then if SN = nil then AddToWaitRoom(X, Y - 1, Z);
            if State.S = 2 then if SS = nil then AddToWaitRoom(X, Y + 1, Z);
            if State.U = 2 then if SU = nil then AddToWaitRoom(X, Y, Z + 1);
            if State.D = 2 then if SD = nil then AddToWaitRoom(X, Y, Z - 1);
      
            var B := true;
            for i2: integer := 0 to RoomArray.Length - 1 do
              if RoomArray[i2].X = X then
                if RoomArray[i2].Y = Y then
                  if RoomArray[i2].Z = Z then
                  begin
                    RoomArray[i2] := Res;
                    B := false;
                    break;
                  end;
            if B then
              RoomArray := RoomArray + new Segment[1](Res);
          end;
      
          RoomWait[i] := RoomWait[RoomWait.Length - 1];
          SetLength(RoomWait, RoomWait.Length - 1);
        end;
      end;
      {}
      RGT.Stop;
    end;
  
    {$endregion}
  
  end;


procedure SwapMode(smto: byte);
begin
  if smto = 1 then
  begin
    System.Windows.Forms.Cursor.Position := new Point(Round(WW / 2), Round(WH / 2));
    if GetKeyState(9) shl 7 = 128 then
    begin
      keybd_event(9, 59, 1, 0);
      keybd_event(9, 59, 2, 0);
    end;  
  end;
  
  GM := smto;
  MM := 0;
  MW := 0;
end;

procedure SwapMapMode(smto: byte);
begin
  if smto = 1 then
  begin
    glLoadIdentity;
    glEnable(GL_DEPTH_TEST);
    glMatrixMode(GL_PROJECTION);
  end
  ;
  
  MM := smto;
  MW := 0;
end;

procedure OnMouseWheel(sender: System.Object; e: System.Windows.Forms.MouseEventArgs);
begin
  if GM <> 1 then exit;
  
  if e.Delta > 0 then MW += 1 else
  if e.Delta < 0 then MW -= 1;
end;

procedure OnMouseUp(sender: System.Object; e: System.Windows.Forms.MouseEventArgs);
begin
  if GM = 0 then
  begin
    
  end;
end;

{$region Calc}

procedure CalcGameM1;
{$region Navigation}{
       -<> RRect
       -Common
         -MouseStay
         -Weapon Control
           -Wep3
       -Weapon
         -Select
         -W1
           -0 - Player
           -i - i+1
           -n=1
           -TestHit
           -n>1
           -MW
         -W2
         -W3
         -W0
{$endregion}
begin
  
  {$region <> RRect}
  if not RRect.Contains(Player.X, Player.Y) then
  begin
      //writeln('Player<>',RRect);
    var Sh := new RCPoint(0, 0, 0);
    if Player.X < RRect.Left then Sh.X := -1 else
    if Player.X > RRect.Right then Sh.X := +1 else
    if Player.Y < RRect.Top then Sh.Y := -1 else
    if Player.Y > RRect.Bottom then Sh.Y := +1;
    
    Room := Dangeon.GetClosestSegment(Sh.X, Sh.Y, Sh.Z);
    
      //write((Player.X,Player.Y),'->');
    
    Player.X -= Sh.X * RW;
    Player.Y -= Sh.Y * RW;
    
      //writeln((Player.X,Player.Y));
    
    if Weapon = 1 then
      for i: integer := 0 to Wep1.Length - 1 do
      begin
        Wep1[i].P.X -= Sh.X * RW;
        Wep1[i].P.Y -= Sh.Y * RW;
      end;
    
    for i: integer := 0 to Wep3Booms.Length - 1 do
    begin
      Wep3Booms[i].X -= Sh.X * RW;
      Wep3Booms[i].Y -= Sh.Y * RW;
    end;
    
    var RX := Room.X;
    var RY := Room.Y;
    for i: integer := 0 to Dangeon.RoomArray.Length - 1 do
    begin
      Dangeon.RoomArray[i].X -= RX;
      Dangeon.RoomArray[i].Y -= RY;
    end;
    for i: integer := 0 to Dangeon.RoomWait.Length - 1 do
    begin
      Dangeon.RoomWait[i].X -= RX;
      Dangeon.RoomWait[i].Y -= RY;
    end;
  end;
  {$endregion}
  
  Room := Dangeon.GetClosestSegment(Round((Viewpoint.X + Player.X) / RW), Round((Viewpoint.Y + Player.Y) / RW), Player.MZ);
  SegToDraw := new Segment[0];
  l := Mlt(Rotate(Add(Room.HitBox(0, RoomDrawLimit), -Viewpoint.X - Player.X + Room.X * RW, -Viewpoint.Y - Player.Y + Room.Y * RW), -ViewpointRot), 1);
  
  {$region Common}
  
  {$region MouseStay}
  if MM = 0 then
  begin
    var P := System.Windows.Forms.Cursor.Position;
    
    var dx := P.X - WW / 2;
    var dy := P.Y - WH / 2;
    
    begin
      var r := sqrt(sqr(dx) + sqr(dy));
      var mr := 150;
      if r > mr then
      begin
        dx *= mr / r;
        dy *= mr / r;
        
        P.X := Round(dx + WW / 2);
        P.Y := Round(dy + WH / 2);
      end;
    end;
    
    Player.dX += dx / 5;
    Player.dY += dy / 5;
    
    System.Windows.Forms.Cursor.Position := new Point(Round(WW / 2), Round(WH / 2));
  end;
  {$endregion}
  
  {$region Weapon Control}
  
  {$region Wep3}
  if Wep3fly then
  begin
    var SP := new PointF(Wep3Proj.vel * Cos(Wep3Proj.dir) * 0.3, Wep3Proj.vel * Sin(Wep3Proj.dir) * 0.3);
    
    Wep3Charge -= Power(Wep3Proj.vel, 1.5) / 30000;
    
    var nSP := SP;
    TestHit(2, l, new PointF(0, 0), nSP);
    
    if (GetKeyState(81) shr 7 = 1) or (nSP <> SP) or (Wep3Charge <= 0) then
    begin
      Wep3Booms := Wep3Booms + new Wep3Boom[1](new Wep3Boom(Player.X + Viewpoint.X + nSP.X, Player.Y + Viewpoint.Y + nSP.Y, Wep3Proj.vel, Rand(0.5)));
      
      Wep3fly := false;
      Wep3Charge := 0;
    end else
    begin
      Viewpoint.X += SP.X;
      Viewpoint.Y += SP.Y;
      
      if Player.dY < 0 then
        Wep3Proj.vel += (15 - Wep3Proj.vel) * 0.05 else
      if Player.dY > 0 then
        Wep3Proj.vel += (5 - Wep3Proj.vel) * 0.05;
      Wep3Proj.dir += Player.dX / 700;
      Player.dX := 0;
      Player.dY := 0;
    end;
  end;
  {$endregion}
  
  {$endregion}
  
  for sn: integer := 0 to {CR.Length} -1 do
  begin
    var Entitys := CR[sn].GetData.Entitys;
    for i1: integer := Entitys.Length - 1 downto 0 do
    begin
      Entitys[i1].Tick;
      var a := EGeD(Entitys[i1].GetData);
      var b := new EGiD;
      
      var nbreak := false;
      
      for i2: integer := 0 to a.Colisions.Length - 1 do
      begin
        var Pos1 := new PointF(a.Pos.X + a.Colisions[i2].X, a.Pos.Y + a.Colisions[i2].Y);
        
        for i: integer := 0 to Wep3Booms.Length - 1 do
          with Wep3Booms[i] do
          begin
            var lvlmlt := lvl * mlt;
            var r := sqrt(sqr(X - Pos1.X) + sqr(Y - Pos1.Y));
            if r < power(lvlmlt, 1.3) then
            begin
              b.GMass -= lvlmlt / Power(r, 1.5) * 300;
              a.Vel.X -= (X - Pos1.X) / Power(r, 1.2) * lvlmlt / 3;
              a.Vel.Y -= (Y - Pos1.Y) / Power(r, 1.2) * lvlmlt / 3;
            end;
          end;
        
        for i12: integer := 0 to Entitys.Length - 1 do
          if i1 <> i12 then
          begin
            var a2 := EGeD(Entitys[i12].GetData);
            
            for i22: integer := 0 to a2.Colisions.Length - 1 do
            begin
              var Pos2 := new PointF(a2.Pos.X + a2.Colisions[i22].X, a2.Pos.Y + a2.Colisions[i22].Y);
              var r := sqrt(sqr(Pos1.X - Pos2.X) + sqr(Pos1.Y - Pos2.Y));
              var nr := a.Colisions[i2].X + a2.Colisions[i22].X;
              if r < nr then
              begin
                var pth := (1 - Power(1 / (nr - r), 30));
                if pth < 0 then pth := 0;
                a.Vel.X += Sign(Pos1.X - Pos2.X) * pth * (nr - r) / 2;
                a.Vel.Y += Sign(Pos1.Y - Pos2.Y) * pth * (nr - r) / 2;
              end;
            end;
          end;
        
        if Entitys[i1] is Slime then
        begin
          if a.Colisions[i2].X < 10 then
          begin
            Entitys[i1] := Entitys[Entitys.Length - 1];
            SetLength(Entitys, Entitys.Length - 1);
            nbreak := true;
            break;
          end;
          
          var Pos2 := new PointF(Player.X - CR[sn].X * RW, Player.Y - CR[sn].Y * RW);
          var r := sqrt(sqr(Pos1.X - Pos2.X) + sqr(Pos1.Y - Pos2.Y));
          var nr := a.Colisions[i2].X + 10;
          if r < nr then
          begin
            var pth := (1 - Power(1 / (nr - r), 30));
            if pth < 0 then pth := 0;
            Player.Hp -= a.Colisions[i2].Y;
            Player.dX += Pos1.X - Pos2.X;
            Player.dY += Pos1.Y - Pos2.Y;
          end;
          
          if Weapon = 1 then
          begin
            
            TestHit(a.Colisions[i2].X, l, new PointF(a.Pos.X - Player.X + CR[sn].X * RW + a.Colisions[i2].X, a.Pos.Y - Player.Y + CR[sn].Y * RW + a.Colisions[i2].Y), a.Vel);
            
            Pos2 := new PointF(Wep1[Wep1.Length - 1].P.X - CR[sn].X * RW, Wep1[Wep1.Length - 1].P.Y - CR[sn].Y * RW);
            r := sqrt(sqr(Pos1.X - Pos2.X) + sqr(Pos1.Y - Pos2.Y));
            nr := a.Colisions[i2].X + 10;
            if r < nr then
            begin
              b.GMass += 15 - sqrt(sqr(Wep1[Wep1.Length - 1].SP.X - a.Vel.X) + sqr(Wep1[Wep1.Length - 1].SP.Y - a.Vel.Y));
              var pth := (1 - Power(1 / (nr - r), 30));
              if pth < 0 then pth := 0;
              Wep1[Wep1.Length - 1].SP.X /= 10;
              Wep1[Wep1.Length - 1].SP.Y /= 10;
              Wep1[Wep1.Length - 1].SP.X += Pos1.X - Pos2.X;
              Wep1[Wep1.Length - 1].SP.Y += Pos1.Y - Pos2.Y;
            end;
            
          end else
          
        end else
        ;
      end;
      if nbreak then
      begin
        CR[sn].Entitys := Entitys;
        continue;
      end;
      
      for i2: integer := 0 to a.Colisions.Length - 1 do
        TestHit(a.Colisions[i2].X, l, new PointF(a.Pos.X - Player.X + CR[sn].X * RW + a.Colisions[i2].X, a.Pos.Y - Player.Y + CR[sn].Y * RW + a.Colisions[i2].Y), a.Vel);
      
      var dX, dY: Single;
      dX := a.Vel.X * 1;
      dY := a.Vel.Y * 1;
      
      b.Pos := new PointF(a.Pos.X + dX, a.Pos.Y + dY);
      b.PlSeg := new Segment[1](Room);
      b.Pl := new PointF(Player.X + RW / 2, Player.Y + RW / 2);
      Entitys[i1].GiveData(b);
    end;
  end;
  
  begin
    
    
    EntToProc := new Entity[0];
  end;
  
  begin
    Player.Hp += 0.03;
    if Player.Hp > 200 then Player.Hp := 200;
    if Player.Hp < 0 then Player.Hp := 0;
  end;
  
  nViewpointRot := 0;
  if Wep3fly then
    nViewpointRot := 1 * (Wep3Proj.dir + Pi / 2) else
  begin
    Viewpoint.X *= 0.85;
    Viewpoint.Y *= 0.85;
  end;
  
  ChAngDif(ViewpointRot, nViewpointRot, 0.1);
  
  if not Wep3fly then
  begin
    Player.Rot := ArcTg(Player.dX, Player.dY);
    var Sp := new PointF(Player.dX, Player.dY);
    
    if not PlayerNotClipping then
      TestHit(2, l, new PointF(-Viewpoint.X, -Viewpoint.Y), Sp);
    
    Player.dX := Sp.X;
    Player.dY := Sp.Y;
  end;
  
  begin
    var dx := Player.dX * 0.3;
    var dy := Player.dY * 0.3;
    Player.X += dx;Player.Y += dy;
    Player.dX -= dx;Player.dY -= dy;
  end;
  
  Dangeon.CreateWaitRooms(new RCPoint(Room.X, Room.Y, Room.Z));
  
  {$endregion}
  
  {$region Weapon}
  
  {$region Select}
  if GetKeyState(48) div 128 = 1 then nWeapon := 0 else
  if GetKeyState(49) div 128 = 1 then nWeapon := 1 else
  if GetKeyState(50) div 128 = 1 then nWeapon := 2 else
  if GetKeyState(51) div 128 = 1 then nWeapon := 3 else
      ;
  
  if Weapon <> nWeapon then
    if Weapon = 0 then
    begin
      if nWeapon = 1 then
      begin
        Wep1 := new Wep1zv[1];
        Wep1[0].P.X := Player.X;
        Wep1[0].P.Y := Player.Y;
        Wep1[0].SP.X := 0;
        Wep1[0].SP.Y := 0;
        MW := 0;
      end else
      if nWeapon = 2 then
      begin
        Wep2L := 5;
        Wep2dL := 0;
        MW := 0;
        Wep2rot := Player.Rot;
      end else
      if nWeapon = 3 then
      begin
        Wep3Charge := 0;
        MW := 0;
      end;
      Weapon := nWeapon;
    end else
    
    
    if Weapon = 1 then
    begin
      if Wep1.Length = 1 then
      begin
        SetLength(Wep1, 0);
        Weapon := 0;
      end else
      if sqrt(sqr(Wep1[0].P.X - Player.X) + sqr(Wep1[0].P.Y - Player.Y)) < 9 then
      begin
        for i: integer := 0 to Wep1.Length - 2 do
          Wep1[i] := Wep1[i + 1];
        SetLength(Wep1, Wep1.Length - 1);
      end;
    end else
    if Weapon = 2 then
    begin
      Weapon := 0;
    end else
    if Weapon = 3 then
    begin
      Wep3p3[1].X := 25;
      if not Wep3fly then
        Weapon := 0;
    end;
      {$endregion}
  
  {$region W1}
  if Weapon = 1 then
  begin
    {$region 0 - Player}
    if Wep1.Length > 1 then
    begin
      var SP := new PointF(Player.dX, Player.dY);
      var P := new PointF(Player.X, Player.Y);
      Con2CE(SP, Wep1[0].SP, P, Wep1[0].P, 2, 5, 1, 100);
      Player.dX := SP.X;
      Player.dY := SP.Y;
      Player.X := P.X;
      Player.Y := P.Y;
    end;{$endregion}
    
    {$region i - i+1}
    for i: integer := 0 to Wep1.Length - 2 do
      Con2CE(Wep1[i].SP, Wep1[i + 1].SP, Wep1[i].P, Wep1[i + 1].P, 1.9, 2.1, 1, 1);
    {$endregion}
    
    {$region n=1}if Wep1.Length = 1 then
    begin
      var r := sqrt(sqr(Wep1[0].P.X - Player.X) + sqr(Wep1[0].P.Y - Player.Y));
      var nr: real := 2;
      nr := (r * 0 + nr * 9) / 9;
      if r = 0 then
      begin
        r := 1;nr := 1;
      end;
      var nX := Player.X + (Wep1[0].P.X - Player.X) / r * nr;
      var nY := Player.Y + (Wep1[0].P.Y - Player.Y) / r * nr;
      Wep1[0].SP.X := 0;
      Wep1[0].SP.Y := 0;
      Wep1[0].P.X := nX;
      Wep1[0].P.Y := nY;
    end;{$endregion}
    
    for i: integer := 0 to Wep1.Length - 2 do
    begin
      Wep1[i].SP.X *= 0.8;
      Wep1[i].SP.Y *= 0.8;
    end;
    
    {$region TestHit}
    for i: integer := 0 to Wep1.Length - 1 do
      with Wep1[i] do
        TestHit(i = Wep1.Length - 1 ? 15 : 5, l, new PointF(P.X - Player.X, P.Y - Player.Y), SP);
    {$endregion}
    
    {$region n>1}if Wep1.Length > 1 then
    begin
      var dr := (1 - 1 / Max(1, sqrt(sqr(Wep1[Wep1.Length - 1].SP.X) + sqr(Wep1[Wep1.Length - 1].SP.Y))));
      if dr.Equals(real.NegativeInfinity) then dr := 1 else
        dr := Power(dr, 5);
      Wep1[Wep1.Length - 1].SP.X *= dr;
      Wep1[Wep1.Length - 1].SP.Y *= dr;
    end;
    for i: integer := 0 to Wep1.Length - 1 do
    begin
      Wep1[i].P.X += Wep1[i].SP.X;
      Wep1[i].P.Y += Wep1[i].SP.Y;
    end;{$endregion}
    
    {$region MW}
    if Wep1.Length - MW < 1 then MW := Wep1.Length - 1 else
    if Wep1.Length - MW > Wep1L then MW := Wep1.Length - Wep1L;
    
    if MW > 0 then
    begin
      if Wep1.Length = 1 then MW := 0 else
      if sqrt(sqr(Wep1[0].P.X - Player.X) + sqr(Wep1[0].P.Y - Player.Y)) <= 15 then
      begin
        for i: integer := 0 to Wep1.Length - 2 do
          Wep1[i] := Wep1[i + 1];
        SetLength(Wep1, Wep1.Length - 1);
        MW -= 1;
      end else
        writeln(sqrt(sqr(Wep1[0].P.X - Player.X) + sqr(Wep1[0].P.Y - Player.Y)));
    end else if MW < 0 then
    begin
      if Wep1.Length = Wep1L then MW := 0 else
      begin
        SetLength(Wep1, Wep1.Length + 1);
        for i: integer := Wep1.Length - 2 downto 0 do
          Wep1[i + 1] := Wep1[i];
        Wep1[0].P.X := (Wep1[1].P.X + Player.X) / 2;
        Wep1[0].P.Y := (Wep1[1].P.Y + Player.Y) / 2;
        MW += 1;
      end;
      
    end;{$endregion}
  end else
  {$endregion}
  {$region W2}
  if Weapon = 2 then
  begin
    if MW <> 0 then
    begin
      Wep2dL += MW * 3;
      MW := 0;
    end;
    
    Wep2L += Wep2dL;
    if Wep2L < 5 then
    begin
      Wep2L := 5;
      Wep2dL := 0;
    end else
    if Wep2L > 25 then
    begin
      Wep2L := 25;
      Wep2dL := 0;
    end else
      Wep2dL *= 0.5;
    
    begin
      var dr: real;
      with Player do
        dr := sqrt(sqr(dX) + sqr(dY));
      if dr <> 0 then
      begin
        dr := 1 - 1 / power(dr, 0.3);
        
        if dr < 0 then dr := 0;
        
        ChAngDif(Wep2rot, Player.Rot, 0.5 / (1 + Power(Wep2L, 0.5)));
      end;
    end;
    
    try
      var Sp := new PointF(Player.dX / 200, Player.dY / 200);
      var nSp := Sp;
      TestHit(Wep2L, l, new PointF(-nWep2[11].X, -nWep2[11].Y), nSp);
      if nSp <> Sp then
      begin
        Player.dX := nSp.X / 50;
        Player.dY := nSp.Y / 50;
      end;
    except
    end;
  end;
  {$endregion}
  {$region W3}
  if Weapon = 3 then
  begin
    if MW <> 0 then
    begin
      if not Wep3fly then
        if MW < 0 then
          Wep3Charge += 0.02;
      if Wep3Charge > 1 then Wep3Charge := 1;
      Wep3p3[1].X := 25 - 12 * Wep3Charge;
      MW := 0;
    end;
    
    if not Wep3fly then
      if Wep3Charge = 1 then
        if GetKeyState(4) div 128 = 1 then
        begin
          Wep3fly := true;
          Wep3Proj.dir := Player.Rot;
          Wep3Proj.vel := 10;
          Player.dX := 0;
          Player.dY := 0;
          Wep3p3[1].X := 25;
        end;
    
  end;
  {$endregion}
  
  {$region W0}
  if Weapon = 0 then
  begin
    
  end;
  {$endregion}
  
  {$endregion}
  
end;

{$endregion}

{$region Draw}

procedure DrawGameM0;
begin
  var MP := System.Windows.Forms.Cursor.Position;
  
  glClearColor(single(0.0), single(0.0), single(0.0), single(0.0));
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  
  glLoadIdentity;
  glEnable(GL_DEPTH_TEST);
  glPushMatrix;
  glMatrixMode(GL_PROJECTION);
  gluPerspective(45.0, WW / WH, 0.1, real.MaxValue);
  
  begin
    var VPs: SizeF;
    VPs.Width := WW div 2 - 100;
    VPs.Height := VPs.Width / WW * WH;
    
    glViewport(WW div 2 + 50, Round((WH - VPs.Height) / 2), Round(VPs.Width), Round(VPs.Height));
  end;
  
    //3D
  
  
  
    //gluLookAt(Camera.X, Camera.Y, Camera.Z,          Camera.X + Cos(Camera.RotY) * Sin(Camera.RotX), Camera.Y - Sin(Camera.RotY), Camera.Z + Cos(Camera.RotY) * Cos(Camera.RotX),          0, 1, 0);
  
  
  
  glPopMatrix;
  
  glLoadIdentity;
  glDisable(GL_DEPTH_TEST);
  glPushMatrix;
  glMatrixMode(GL_MODELVIEW);
  gluOrtho2D(0, WW, WH, 0);
  glViewport(0, 0, WW, WH);
  
    //2D
  
  bmp.Rectangle(false, 1, 1, 1, 1, M0B1.Left, M0B1.Top, M0B1.Width, M0B1.Height);
  bmp.Rectangle(false, 1, 1, 1, 1, M0B2.Left, M0B2.Top, M0B2.Width, M0B2.Height);
  bmp.Rectangle(false, 1, 1, 1, 1, M0B3.Left, M0B3.Top, M0B3.Width, M0B3.Height);
  bmp.Rectangle(false, 1, 1, 1, 1, M0B4.Left, M0B4.Top, M0B4.Width, M0B4.Height);
  
  bmp.DrawCurrsor(MP);
  
  CAct += 1;
  
  glPopMatrix;
  
  glFlush;
  SwapBuffers(_hdc);
  
  if GetKeyState(1) div 128 = 1 then
    if M0B1.Contains(MP) then
      SwapMode(1);
  
  if GetKeyState(113) div 128 = 1 then
  begin
    var b := new Bitmap(WW, WH);
    var gr := Graphics.FromImage(b);
    gr.CopyFromScreen(0, 0, 0, 0, b.Size);
    b.Save('Screen.bmp');
  end;
end;

procedure DrawGameM1;
{$region Navigation}{
       -3D
        -Booms
        -Wep1
        -Wep2
        -Wep3
       -2D
        -Toolbar
         -Wep1
         -Wep2
         -Wep3
        -LH
{$endregion}
begin
  
  {$region 3D}
  {$region 3D setup}
  glLoadIdentity;
  glEnable(GL_DEPTH_TEST);
  glPushMatrix;
  glMatrixMode(GL_PROJECTION);
  gluPerspective(45.0, WW / WH, 0.1, real.MaxValue);
  glRotatef(ViewpointRot / Pi * 180, 0, 0, 1);
  gluLookAt(-Player.X - Viewpoint.X, -Player.Y - Viewpoint.Y, -RoomHeigth,         -Player.X - Viewpoint.X, -Player.Y - Viewpoint.Y, RoomDepth,         0, 1, 0);
    {$endregion} 
  
  for i: integer := 0 to SegToDraw.Length - 1 do
    with SegToDraw[i] do
      Draw(-(X + 0.5) * RW, -(Y + 0.5) * RW);
  
  glTranslatef(-Player.X - Viewpoint.X * 1, -Player.Y - Viewpoint.Y * 1, 0);
  
  bmp.DrawPlayer;
  
  {$region Booms}
  for i: integer := Wep3Booms.Length - 1 downto 0 do
    with Wep3Booms[i] do
    begin
      var lvlmlt := lvl * mlt;
      begin
        var r := sqrt(sqr(X - Player.X) + sqr(Y - Player.Y));
        if r < power(lvlmlt, 1.3) then
        begin
          Player.Hp -= lvlmlt / Power(r, 1.5) * 100;
          Player.dX -= (X - Player.X) / Power(r, 1.2) * lvlmlt / 3;
          Player.dY -= (Y - Player.Y) / Power(r, 1.2) * lvlmlt / 3;
        end;
        
        //ToDo Entitys
      end;
      
      var St := Stage;
      var Dpts := Add(Draw, -Player.X, -Player.Y);
      bmp.Polygon(true, 1, 1, 0, 1, Add3rd(Dpts, RoomDepth));
      bmp.Polygon(false, 1, 0, 0, 1, Add3rd(Dpts, RoomDepth));
      
      if (St < Pi / 2) and (Stage > Pi / 2) then
      begin
        if lvl > 2 then
          for n: integer := 0 to 1 + Random(2) do
            if Wep3Booms.Length < MaxBoobC then
              Wep3Booms := Wep3Booms + new Wep3Boom[1](new Wep3Boom(X + lvlmlt * (Random * 2 - 1), Y + lvlmlt * (Random * 2 - 1), lvl - 3 - Random * 3, Max(Min(RotSp + Random - 0.5, 1), -1)));
      end else
      if Stage > Pi then
      begin
        Wep3Booms[i] := Wep3Booms[Wep3Booms.Length - 1];
        SetLength(Wep3Booms, Wep3Booms.Length - 1);
      end;
    end;
  {$endregion}
  
  {$region Wep1}
  if Weapon = 1 then
  begin
    for i: integer := 0 to Wep1.Length - 2 do
      bmp.Ellipse(true, 0.6, 0.6, 0.6, 1, Player.X - Wep1[i].P.X, Player.Y - Wep1[i].P.Y, 1, 1);
    bmp.Polygon(true, 1, 0, 0, 1, Add(Copy(Wep1End), Player.X - Wep1[Wep1.Length - 1].P.X, Player.Y - Wep1[Wep1.Length - 1].P.Y));
  end else
  {$endregion}
  {$region Wep2}
  if Weapon = 2 then
  begin
    nWep2 := Rotate(Wep2Grip + Add(Copy(Wep2Blade), Wep2L / 10, 0), Wep2rot + Pi);
    
    bmp.Polygon(true, 0.8, 0.8, 0.8, 1, Add3rd(nWep2, 45));
    bmp.Polygon(false, 0, 0, 0, 1, Add3rd(nWep2, 45));
  end else
    {$endregion}
  {$region Wep3}
  if Weapon = 3 then
  begin
    if Wep3fly then
    begin
      var nWep3Rocket := Rotate(Copy(Wep3Rocket), Wep3Proj.dir + Pi);
      bmp.Polygon(true, 0.5, 0.1, 0.1, 1, nWep3Rocket);
      bmp.Lines(0, 0, 0, 1, nWep3Rocket);
      var Jet := Add(new PointF[13], -20, 0);
      for i: integer := 0 to Jet.Length - 1 do
        Jet[i].Y := i - 6;
      for i: integer := 1 to Jet.Length - 2 do
        Jet[i].X -= Random * Wep3Proj.vel / 1.5;
      Rotate(Jet, Wep3Proj.dir + Pi);
      bmp.Polygon(true, 1, 0, 0, 1, Jet);
    end;
    
    var nWep3 := Add(Rotate(Copy(Wep3), Player.Rot + Pi), Viewpoint.X, Viewpoint.Y);
    var nWep3p2 := Add(Rotate(Copy(Wep3p2), Player.Rot + Pi), Viewpoint.X, Viewpoint.Y);
    var nWep3p3 := Add(Rotate(Copy(Wep3p3), Player.Rot + Pi), Viewpoint.X, Viewpoint.Y);
    
    bmp.Polygon(true, 0.31, 0.35, 0.15, 1, nWep3);
    bmp.Polygon(true, 0.31, 0.35, 0.15, 1, nWep3p2);
    bmp.Polygon(true, 0.31, 0.35, 0.15, 1, nWep3p3);
  end else
    {$endregion}
    ;
  glPopMatrix;
  {$endregion}
  {$region 2D}
  {$region 2D setup}
  glLoadIdentity;
  glDisable(GL_DEPTH_TEST);
  glPushMatrix;
  glMatrixMode(GL_MODELVIEW);
  gluOrtho2D(0, WW, WH, 0);
  glViewport(0, 0, WW, WH);
  {$endregion}
  
  {$region Toolbar}
  begin
    var w := WW / 3;
    w := Min(w, w / 200 * Player.Hp);
    bmp.Rectangle(true, 1, 0, 0, 1, WW - 10, 10, -w, 40);
    bmp.Rectangle(false, 0.5, 0, 0.5, 1, WW - 10, 10, -WW / 3, 40);
    //bmp.DrawImage(Textures.HpIcon, WW - Textures.HpIcon.Width, 0); ToDo
  end;
  
    {$region Wep1}
  if Weapon = 1 then
  begin
    for i: integer := 0 to Wep1.Length - 2 do
      bmp.Ellipse(true, 0.6, 0.6, 0.6, 1, 10 + i * 10, 15, 3, 3);
    bmp.Polygon(true, 1, 0, 0, 1, Add(Copy(Wep1End), 10 + Wep1.Length * 10, 15));
    var px2 := 27 + Wep1.Length * 10;
    bmp.Polygon(false, 1, 0, 0, 1, new PointF[6](new PointF(3, 32), new PointF(3, 17), new PointF(3, 32), new PointF(px2, 32), new PointF(px2, 17), new PointF(px2, 32)));
    var s := Wep1.Length.ToString;
    if nWeapon <> 1 then
      s += ' (' + Max(Min(Wep1.Length - MW - 1000, 15), 0) + ')' else
    if MW <> 0 then
      s += ' (' + Max(Min(Wep1.Length - MW, 15), 1) + ')';
    bmp.DrawString(s, 1, 12, c, (px2 + 3) / 2, 35);
  end else
    {$endregion}
    {$region Wep1}
  if Weapon = 2 then
  begin
    
  end else
    {$endregion}
    {$region Wep3}
  if Weapon = 3 then
  begin
    bmp.Rectangle(true, 0.7, 0.35, 0.15, 1, 10, 10, WW / 3 * Wep3Charge, 40);
    bmp.Rectangle(false, 0.5, 0, 0.5, 1, 10, 10, WW / 3, 40);
  end else
    {$endregion}
      ;
    {$endregion}
  
  glPushMatrix;
  glTranslatef(WW / 2, WH / 2, 0);
  
    {$region LH}
  if LHShow then
    if l <> nil then
    begin
      for i: integer := 0 to l.Length - 1 do
        bmp.Lines(0, 0, 1, 1, l[i]);
      
      if LH <> -1 then
        if l.Length > 0 then
          try
            bmp.Lines(1, 0, 0, 1, l[LH]);
          except
          end;
      LH := -1;
    end;
    {$endregion}
  
  glPopMatrix;
  glPopMatrix;
    {$endregion}
  
  glFlush;
  SwapBuffers(_hdc);
  
  if GetKeyState(9) shl 7 = 128 then
    SwapMapMode(1);
end;

procedure DrawMap3D;
begin
  glPushMatrix;
  glMatrixMode(GL_PROJECTION);
  
  {$region MouseStay}
  begin
    Map3DScale *= Power(1.05, MW);
    MW *= 0.7;
    if Map3DScale < 0.1 then Map3DScale := 0.1 else
    if Map3DScale > 100 then Map3DScale := 100;
    
    var P := System.Windows.Forms.Cursor.Position;
    
    var dx := P.X - WW / 2;
    var dy := P.Y - WH / 2;
    
    begin
      var r := sqrt(sqr(dx) + sqr(dy));
      var mr := 150;
      if r > mr then
      begin
        dx *= mr / r;
        dy *= mr / r;
        
        P.X := Round(dx + WW / 2);
        P.Y := Round(dy + WH / 2);
      end;
    end;
    
    Map3DRotX += dx / 100;
    Map3DRotY += dy / 100;
    
    if Map3DRotX > Pi * 2 then Map3DRotX -= Pi * 2;
    if Map3DRotX < 0 then Map3DRotX += Pi * 2;
    
    if Map3DRotY > +Pi / 2 then Map3DRotY := +Pi / 2;
    if Map3DRotY < -Pi / 2 then Map3DRotY := -Pi / 2;
    
    
    System.Windows.Forms.Cursor.Position := new Point(Round(WW / 2), Round(WH / 2));
  end;
  {$endregion}
  
  {$region Rooms Draw}
  
  glPushMatrix;
  gluPerspective(45.0, WW / WH, 0.0625, 1073741824);
  gluLookAt(100 * Cos(Map3DRotX) * Cos(Map3DRotY), 100 * Sin(Map3DRotY), 100 * Sin(Map3DRotX) * Cos(Map3DRotY),         0, 0, 0,         0, 1, 0);
  
  begin
    var ptsX := new Point3f[0];
    var ptsY := new Point3f[0];
    var ptsZ := new Point3f[0];
    glPushMatrix;
    glRotatef(-ViewpointRot / Pi * 180, 0, 1, 0);
    bmp.DrawCube(0.5, 0, 0.5, 1, 0 * Map3DScale * MRW, 0.5 * Map3DScale * MRW, -0.5 * Map3DScale * MRW, 0.03 * Map3DScale, 0.03 * Map3DScale, 0.5 * Map3DScale * MRW);
    glPopMatrix;
    
    var c1 := Map3DSR / WH * sqr(Map3DScale);
    
    for i: integer := 0 to Dangeon.RoomArray.Length - 1 do
      with Dangeon.RoomArray[i] do
        if PlayerSeen or ShowNewRooms then
        begin
          var r := MRW * (Map3DScale / 2 - sqrt(sqr(X - Room.X) + sqr(Y - Room.Y) + sqr(Z - Room.Z)) * c1);
          if r > 0 then
            if Dangeon.RoomArray[i] = Room then
              bmp.DrawCube(0, 1, 0, 1, X * Map3DScale, Z * Map3DScale, Y * Map3DScale, r, r, r) else
            if Dangeon.RoomArray[i] = Room then
              bmp.DrawCube(0, 0, 1, 1, X * Map3DScale, Z * Map3DScale, Y * Map3DScale, r, r, r) else
              bmp.DrawCube(0, 0.5, 0, 1, 0, 0, 0, 1, X * Map3DScale, Z * Map3DScale, Y * Map3DScale, r, r, r);
          
          if r > -MRW * c1 then
          begin
            
            if State.L = 2 then ptsX := ptsX + new Point3f[1](new Point3f(X - 0.5, Z, Y));
            if State.N = 2 then ptsZ := ptsZ + new Point3f[1](new Point3f(X, Z, Y - 0.5));
            if State.D = 2 then ptsY := ptsY + new Point3f[1](new Point3f(X, Z - 0.5, Y));
            
            var SR := Dangeon.GetSegment(X + 1, Y, Z);var SS := Dangeon.GetSegment(X, Y, Z + 1);var SU := Dangeon.GetSegment(X, Y + 1, Z);
            if State.R = 2 then if (SR = nil) or (not (SR.PlayerSeen or ShowNewRooms)) then ptsX := ptsX + new Point3f[1](new Point3f(X + 0.5, Z, Y));
            if State.S = 2 then if (SS = nil) or (not (SS.PlayerSeen or ShowNewRooms)) then ptsZ := ptsZ + new Point3f[1](new Point3f(X, Z, Y + 0.5));
            if State.U = 2 then if (SU = nil) or (not (SU.PlayerSeen or ShowNewRooms)) then ptsY := ptsY + new Point3f[1](new Point3f(X, Z + 0.5, Y));
            
          end;
        end;
    
    if ShowWaitRooms then
      for i: integer := 0 to Dangeon.RoomWait.Length - 1 do
        with Dangeon.RoomWait[i] do
        begin
          var r := MRW * (Map3DScale / 2 - sqrt(sqr(X - Room.X) + sqr(Y - Room.Y) + sqr(Z - Room.Z)) * c1);
          if r > 0 then
            bmp.DrawCube(0, 1, 1, 1, 0, 0, 0, 1, X * Map3DScale, Z * Map3DScale, Y * Map3DScale, r, r, r);
        end;
    
    for i: integer := 0 to ptsX.Length - 1 do
      with ptsX[i] do
      begin
        var r := MRSW * (Map3DScale / 2  - sqrt(sqr(X - Room.X) + sqr(Y - Room.Y) + sqr(Z - Room.Z)) * c1);
        if r > 0 then
          bmp.DrawCube(0.5, 0, 0, 1, X * Map3DScale, Y * Map3DScale, Z * Map3DScale, 0.5 * Map3DScale, r, r);
      end;
    
    for i: integer := 0 to ptsY.Length - 1 do
      with ptsY[i] do
      begin
        var r := MRSW * (Map3DScale / 2  - sqrt(sqr(X - Room.X) + sqr(Y - Room.Y) + sqr(Z - Room.Z)) * c1);
        if r > 0 then
          bmp.DrawCube(0.5, 0, 0, 1, X * Map3DScale, Y * Map3DScale, Z * Map3DScale, r, 0.5 * Map3DScale, r);
      end;
    
    for i: integer := 0 to ptsZ.Length - 1 do
      with ptsZ[i] do
      begin
        var r := MRSW * (Map3DScale / 2  - sqrt(sqr(X - Room.X) + sqr(Y - Room.Y) + sqr(Z - Room.Z)) * c1);
        if r > 0 then
          bmp.DrawCube(0.5, 0, 0, 1, X * Map3DScale, Y * Map3DScale, Z * Map3DScale, r, r, 0.5 * Map3DScale);
      end;
  end;
  
  glPopMatrix;
  
  {$endregion}
  
  glPopMatrix;
  
  glFlush;
  SwapBuffers(_hdc);
  
  if GetKeyState(9) shl 7 = 0 then
    SwapMapMode(0);
  
end;

{$endregion}

{$region DopProcs}

procedure FormInit;
begin
  
  Room := Dangeon.GetNew;
  
end;

//ToDo Saving
procedure FormExit(sender: System.Object; e: System.Windows.Forms.FormClosingEventArgs);
begin
  if e.CloseReason = System.Windows.Forms.CloseReason.WindowsShutDown then
  begin
    SwapBuffers(_hdc);
    System.Diagnostics.Process.GetCurrentProcess.Kill;
  end;
  
  SwapBuffers(_hdc);
  System.Diagnostics.Process.GetCurrentProcess.Kill;
end;

{$endregion}

procedure Redrawing;
begin
  try
    TT.Start;
    Milliseconds;
    
    glClearColor(single(0.0), single(0.0), single(0.0), single(0.0));
    glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
    
    if GetKeyState(162) shr 7 = 1 then
      if GetKeyState(82) shr 7 = 1 then
        Room := Dangeon.GetNew;
    
    LHShow := GetKeyState(120) shl 7 = 128;
    ShowNewRooms := GetKeyState(121) shl 7 = 128;
    ShowWaitRooms := GetKeyState(122) shl 7 = 128;
    PlayerNotClipping := GetKeyState(123) shl 7 = 128;
    
    case GM of
      1: CalcGameM1;
    end;
    
    if GM = 0 then
      DrawGameM0 else
    if MM = 0 then
      case GM of
        1: DrawGameM1;
      end else
      case MM of
        1: DrawMap3D;
      end;
    
    TT.Stop;
    begin
      var tte: real := TT.te.TotalMilliseconds;
      if tte > 0 then
      begin
        var tw: real := 1000 / nFPS;
        var rte: real := RGT.te.TotalMilliseconds;
        var tk := sqrt(rte / tte + 0.1);
        if tk < 0 then tk := 0 else if tk > 1 then tk := 1;
        RGHR += (tw - tte) * tk;
        if RGHR < 0000 then RGHR := 0000 else
        if RGHR > 1000 then RGHR := 1000;
        if FPSShow then
          writeln(RGHR:10:5, tte:10:5, tk:10:5);
        RGT.Reset;
        TT.Reset;
      end;
    end;
  
  except
    on ee: system.Exception do
      writeln(ee);
  end;
end;

procedure BufferIO;
type
  Clipboard = System.Windows.Forms.Clipboard;
begin
  while true do
    try
      Sleep(50);
      if BufferData[0] <> 0 then
      begin
        var Dat: array of byte;
        Dat := BufferData[1:BufferData.Length];
        var ProcID := BufferData[0];
        BufferData := new byte[1](0);
        case ProcID of
          1:
            begin
              var b := new Bitmap(WW, WH);
              var i := 0;
              for var y := WH - 1 downto 0 do
                for var x := 0 to WW - 1 do
                begin
                  b.SetPixel(x, y, Color.FromArgb(255, Dat[i + 0], Dat[i + 1], Dat[i + 2]));
                  i += 4;
                end;
              Clipboard.SetImage(b);
              System.Console.Beep;
            end;
        end;
      end;
    except
      on e: System.Exception do
        SaveError('BufferIO:', e);
    end;
end;

procedure Init;
begin
  
  BufferIOThread := new System.Threading.Thread(BufferIO);
  BufferIOThread.ApartmentState := System.Threading.ApartmentState.STA;
  BufferIOThread.Start;
  
  MF := new System.Windows.Forms.Form;
  MF.WindowState := System.Windows.Forms.FormWindowState.Maximized;
  MF.FormBorderStyle := system.windows.forms.FormBorderStyle.None;
  MF.Controls.Add(new GraphField(0, 0, WW, WH, 15, FormInit, Redrawing));
  MF.Icon := Icon.FromHandle((new Bitmap(1, 1)).GetHicon);
  MF.MouseWheel += OnMouseWheel;
  
  Camera.SetStandart;
  
  MF.Cursor.Dispose;
  MF.FormClosing += FormExit;
  system.windows.forms.Application.Run(MF);
  
end;

begin
  Init;
end.