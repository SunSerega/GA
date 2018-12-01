{$define DEBUG}
{apptype windows}

uses
  VData, RData, EData, REData, CFData, GData, glObjectData, OpenGL, CData;

{$region ToDo}{

  TODO Entity


  ToDo New GData
  ToDo RData.StairTube
  ToDo Segment.MapHitBox type List<HitBoxT>->array of PointF
  ToDo Manu show
  ToDo Нормальные данные о игроке
  ToDo Оптимизировать создание новых комнат
  ToDo В Canal кривой пол
  ToDo Разнести серверный и клиенский потоки
  ToDo Сохранения
  ToDo Move Random from PosOk to RarityOk in Canal
  ToDo Улучшить скриншот(в ABCObjects есть улучшеная работа с Bitmap)

  ToDo привести все модули к нормальному виду
   -GData
   -TCData

  ToDo функции и типы CFData
   -vec3.Rotate
   -MO2DChain

  ToDo персонаж
   -Texture
   -All body parths phisics

  ToDo Z phisics
   -отражения вектора движения
   -Chardge Jump

  ToDo Static Init
   -EntranceT1

  ToDo TSeg
   -MapDrawObj
   -MapHitBox

  ToDo костыли
   -TCData.RTG                    #529 ?  $%&@*$%^
   -glObjectData.HBTDOReverse     #568 !  27.11.17
   -glObjectData.glTObject.create #575 ?
   -CFData.HitBoxT.Empty          #577 !  26.11.17
   -CFData [$savepcu false]       ToDo!!!!!!!!!!!!

  ToDo Textures
   -NORMAL text textures
   -TCData изменить создание текстур
   -Соеденение текстур
   -Подгрузка и отгрузка текстур
   -Переделать все текстуры комнат

  ToDo Entity
   -Mob
    -Slime
    -Spider
    -Skeleton
    -Ghost? How to make vulnerable? Or make it Prop?
    -Outhers
   -Item
   -Prop
   -Segment.DangeonTick

  ToDo Calc
   -Wep1
   -Wep2
   -Wep3

  ToDo Draw
   -2D
    -HP and ...?
   -3D
    -Player
    -Wep1
    -Wep2
    -Wep3

  ToDo Moding
   -LoadedEntity type
   -LoadedRoom type

{$endregion}

{$region Modules}{

VData RData EData REData CFData GData
PerlinNoiseData CellTexData TCData glObjectData AdvglObjData CData 
OpenGl

{$endregion}

{$region Threads}{

Ctrl+Alt+Esc Exit             ifdef DEBUG
Redrawing                     Allways active
CameraMovement                Allways active
WaitRoomsCreation             For each Dangeon
ScreenSave                    When screenshot taken
RTG.TexCreation               When new Texture requested

{$endregion}

{$region Resources}

{$resource 'WPW.im'}
{$resource 'WallTexPart.im'}

{$endregion}

procedure SwapMode(smto: byte);
begin
  if GM = 1 then
  begin
    
    PlayerDangeon.destroy;
    
    Currsor2.Close;
    
  end;
  
  if smto = 1 then
  begin
    
    PlayerDangeon := new Dangeon(RW * 4, RW * 100 * 1.7, RW / 3);
    Camera := new CameraT;
    Camera.PlayerRoom := PlayerDangeon.Rooms.First;
    Camera.RotX := -Camera.PlayerRoom.rot;
    
    if GetKeyState(9) shl 7 = 128 then
    begin
      keybd_event(9, 59, 1, 0);
      keybd_event(9, 59, 2, 0);
    end;
    
    Currsor2.Open;
    
  end;
  
  MM := 0;
  MW := 0;
  GM := smto;
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
  
  PlayerDangeon.Tick(Camera);
  
end;

{$endregion}

{$region Draw}

var
  nSp1, nSp2: vec3d;

procedure SetUpCamera(X, Y, Z: real; RX, RY, R: Single);
begin
  
  if Cos(RY) <= 0 then
    
    
    
    gluLookAt(
    
    X,
    Y,
    -R + Z,
    
    X, Y,  Z,         -Sin(RX), -Cos(RX), 0) else
  
  
  
    gluLookAt(
    
    X + R * Cos(RY) * Sin(RX),
    Y + R * Cos(RY) * Cos(RX),
    -Sin(RY) * R + Z,
    
    X, Y, Z,         0, 0, -1);
  
end;


procedure DrawGameM0;
begin
  var MP := GetCursorPos();
  
  glClearColor(single(0.0), single(0.0), single(0.0), single(0.0));
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  
  glLoadIdentity;
  glEnable(GL_DEPTH_TEST);
  glPushMatrix;
  glMatrixMode(GL_PROJECTION);
  gluPerspective(45.0, WW / WH, 0.1, real.MaxValue);
  
  begin
    var W := WW div 2 - 100;
    var H := W / WW * WH;
    glViewport(WW div 2 + 50, Round((WH - H) / 2), Round(W), Round(H));
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
  
  M0B1.Draw;
  M0B2.Draw;
  M0B3.Draw;
  M0B4.Draw;
  gr.DrawCurrsor(1, CAct, MP);
  
  glPopMatrix;
  
  if GetKeyState(1) shr 7 = 1 then
    if M0B1rect.Contains(MP) then
      SwapMode(1);
  
  if GetKeyState(1) shr 7 = 1 then
    if M0B4rect.Contains(MP) then
      System.Diagnostics.Process.GetCurrentProcess.Kill;
  
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
  gluPerspective(45.0, WW / WH, 256, 262144);//262144=2^18
  //glRotatef(ViewpointRot / Pi * 180, 0, 0, 1);
  
  var nCamera := Camera;
  var PlRoom := nCamera.PlayerRoom;
  SetUpCamera(nCamera.X, nCamera.Y, nCamera.Z - CameraHover, nCamera.RotX, nCamera.RotY, CameraHeigth);
  
  {$endregion}
  
  PlRoom.Draw(0, 0);
  
  gr.Sphere(true, 1, 0, 0, 1, nCamera.X, nCamera.Y, -PlayerR + nCamera.Z, PlayerR, PlayerR, PlayerR, 15);
  if LHShow then
  begin
    var Floor := nCamera.PlayerRoom.GetFloor(nCamera);
    var mtx := Floor.SurfMtx;
    
    gr.Lines(1, 0, 0, 1, new vec3d[](new vec3d(nCamera.X, nCamera.Y, -PlayerR + nCamera.Z), new vec3d(nCamera.X + 100, nCamera.Y, -PlayerR + nCamera.Z)));
    gr.Lines(0, 1, 0, 1, new vec3d[](new vec3d(nCamera.X, nCamera.Y, -PlayerR + nCamera.Z), new vec3d(nCamera.X, nCamera.Y + 100, -PlayerR + nCamera.Z)));
    gr.Lines(0, 0, 1, 1, new vec3d[](new vec3d(nCamera.X, nCamera.Y, -PlayerR + nCamera.Z), new vec3d(nCamera.X, nCamera.Y, -PlayerR + nCamera.Z + 100)));
    
    var nv := new vec3f(nCamera.dx, nCamera.dy, nCamera.dz) * mtx;
    
    gr.Lines(1, 0, 0, 1, new vec3d[](new vec3d(nCamera.X, nCamera.Y, -PlayerR + nCamera.Z), new vec3d(nCamera.X + mtx.a00 * nv.X, nCamera.Y + mtx.a01 * nv.X, -PlayerR + nCamera.Z + mtx.a02 * nv.X)));
    gr.Lines(0, 1, 0, 1, new vec3d[](new vec3d(nCamera.X, nCamera.Y, -PlayerR + nCamera.Z), new vec3d(nCamera.X + mtx.a10 * nv.Y, nCamera.Y + mtx.a11 * nv.Y, -PlayerR + nCamera.Z + mtx.a12 * nv.Y)));
    gr.Lines(0, 0, 1, 1, new vec3d[](new vec3d(nCamera.X, nCamera.Y, -PlayerR + nCamera.Z), new vec3d(nCamera.X + mtx.a20 * nv.Z, nCamera.Y + mtx.a21 * nv.Z, -PlayerR + nCamera.Z + mtx.a22 * nv.Z)));
    
    gr.Lines(1, 0, 1, 1, new vec3d[](new vec3d(nCamera.X, nCamera.Y, -PlayerR + nCamera.Z), new vec3d(nCamera.X + nCamera.dx, nCamera.Y + nCamera.dy, -PlayerR + nCamera.Z + nCamera.dz)));
    
    gr.Lines(0, 1, 1, 1, new vec3d[](
     new vec3d(nCamera.X, nCamera.Y, -PlayerR + nCamera.Z),
     new vec3d(nCamera.X + nSp1.X, nCamera.Y + nSp1.Y, -PlayerR + nCamera.Z + nSp1.Z)));
    gr.Lines(1, 1, 0, 1, new vec3d[](
     new vec3d(nCamera.X, nCamera.Y, -PlayerR + nCamera.Z),
     new vec3d(nCamera.X + nSp2.X, nCamera.Y + nSp2.Y, -PlayerR + nCamera.Z + nSp2.Z)));
    
    
    
    var lc := 256;
    var dang := Pi * 2 / lc;
//    if false then
//      for var i := 1 to lc do
//      begin
//        var ang := i * dang;
//        var dx := Cos(ang) * r;
//        var dy := Sin(ang) * r;
//        var Sp := sqrt(sqr(dx) + sqr(dy));
//        
//        var dz := Sp / sqrt(sqr(1 / Floor.slope.a) + 1) * Sin(Floor.rot - ArcTg(dx, dy));
//        
//        var r2 := sqrt(sqr(Sp) - sqr(dz)) / Sp;
//        //Log3((dx*r,dy*r,dz));
//        
//        gr.Lines(0, i div 8 mod 2 = 0 ? 1 : 0, 0, 1, new vec3d[](
//                 new vec3d(nCamera.X, nCamera.Y, -1 + nCamera.Z),
//                 new vec3d(nCamera.X + dx * r2, nCamera.Y + dy * r2, -1 + nCamera.Z + dz * 1)));
//      end;
  end;
  
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
  glDisable(GL_DEPTH_TEST);
  {$endregion}
  
  Currsor2.Draw(MP);
  
  glPopMatrix;
  {$endregion}
  
  if GetKeyState(9) shl 7 = 128 then
    SwapMapMode(1);
  
  if GetKeyState(27) shr 7 = 1 then
    SwapMode(0);
end;


procedure DrawMap3D;
begin
  {$region 3D}
  {$region 3D setup}
  glLoadIdentity;
  glEnable(GL_DEPTH_TEST);
  glPushMatrix;
  glMatrixMode(GL_PROJECTION);
  gluPerspective(45.0, WW / WH, 256, 16777216);//16777216=2^24
  //glRotatef(ViewpointRot / Pi * 180, 0, 0, 1);
  
  var nCamera := Camera;
  //Log2('-'*50);
  //Log2(nCamera);
  SetUpCamera(0, 0, 0, nCamera.RotX, nCamera.RotY, CameraHeigth * 30);
  
  {$endregion}
  
  gr.Lines(1, 0, 0, 1, new vec3d[](new vec3d(0, 0, 0), new vec3d(0, 0, -RW * 2)));
  
  PlayerDangeon.DrawMap(nCamera.X, nCamera.Y, nCamera.Z, RW * 50 * 20);
  
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
  glDisable(GL_DEPTH_TEST);
  {$endregion}
  
  Currsor2.Draw(MP);
  
  glPopMatrix;
  {$endregion}
  
  if GetKeyState(9) shl 7 = 0 then
    SwapMapMode(0);
  
end;

{$endregion}

{$region DopProcs}

procedure FormInit;
begin
  
  M0B1 := new glOObject(NewGlObj.Rectangle(false, 1, 1, 1, 1, M0B1rect), NewGlObj.TexInRectangle(Texture.GetTextTexture('Играть',     $FF, $FF, $FF, $FF,     $00, $00, $00, $00), M0B1rect));
  M0B2 := new glOObject(NewGlObj.Rectangle(false, 1, 1, 1, 1, M0B2rect), NewGlObj.TexInRectangle(Texture.GetTextTexture('*Заглушка*', $FF, $FF, $FF, $FF,     $00, $00, $00, $00), M0B2rect));
  M0B3 := new glOObject(NewGlObj.Rectangle(false, 1, 1, 1, 1, M0B3rect), NewGlObj.TexInRectangle(Texture.GetTextTexture('*Заглушка*', $FF, $FF, $FF, $FF,     $00, $00, $00, $00), M0B3rect));
  M0B4 := new glOObject(NewGlObj.Rectangle(false, 1, 1, 1, 1, M0B4rect), NewGlObj.TexInRectangle(Texture.GetTextTexture('Выход',      $FF, $FF, $FF, $FF,     $00, $00, $00, $00), M0B4rect));
  
  Texture.CreateWaitTextures;
  
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
    
    glClearColor(single(0.1), single(0.0), single(0.0), single(1.0));
    glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
    
    if GetKeyState(162) shr 7 = 1 then
      if GetKeyState(82) shr 7 = 1 then
        SwapMode(1);
    
    LHShow := GetKeyState(120) shl 7 = 128;
    ShowNewRooms := GetKeyState(121) shl 7 = 128;
    ShowWaitRooms := GetKeyState(122) shl 7 = 128;
    PlayerNotClipping := GetKeyState(123) shl 7 = 128;
    
    case GM of
      1: CalcGameM1;
    end;
    
    if LFF then
    begin
      
      if GM = 0 then
        DrawGameM0 else
      if MM = 0 then
        case GM of
          1: DrawGameM1;
        end else
        case MM of
          1: DrawMap3D;
        end;
      
      if GetKeyState(44) shr 7 = 1 <> k[44] then
      begin
        k[44] := not k[44];
        if k[44] then
        begin
          var pcs := new byte[4 * WW * WH];
          glReadPixels(0, 0, WW, WH, GL_RGBA, GL_UNSIGNED_BYTE, @pcs[0]);
          var ScreenSave := new System.Threading.Thread(()->try
            
            var b := new System.Drawing.Bitmap(WW, WH);
            var i := 0;
            for var y := WH - 1 downto 0 do
              for var x := 0 to WW - 1 do
              begin
                b.SetPixel(x, y, System.Drawing.Color.FromArgb(255, pcs[i + 0], pcs[i + 1], pcs[i + 2]));
                i += 4;
              end;
            System.Windows.Forms.Clipboard.SetImage(b);
            System.Console.Beep;
          
          except
            on e: System.Exception do
              SaveError('ScreenSave:', e);
          end);
          ScreenSave.ApartmentState := System.Threading.ApartmentState.STA;
          ScreenSave.Start;
        end;
      end;
      
    end;
    
    SwapBuffers(_hdc);
    
    LFF := MF.Focused;
    
    if LFF then
      MF.WindowState := System.Windows.Forms.FormWindowState.Maximized else
      MF.WindowState := System.Windows.Forms.FormWindowState.Minimized;
    ;
    
    Texture.CreateWaitTextures(1);
    
    TT.Stop;
    begin
      RGT.Reset;
      TT.Reset;
    end;
  
  except
    on e: System.Exception do
      SaveError('Redrawing:', e);
  end;
end;

type
  CameraTracking = static class
    
    private class t: System.TimeSpan;
    private const tps = 90;
    private const tw = 1000 / tps;
    
    private class nCamera: CameraT;
    private class lMP, nMP: vec2i;
    private class lk, nk: array of byte;
    
    public class Thread: System.Threading.Thread;
    
    private class procedure MovementTick;
    begin
      
      {$region Camera Rot}
      
      if nk[4] shr 7 = 1 then
      begin
        
        if lk[4] shr 7 = 1 then
        begin
          nCamera.drx -= (nMP.X - lMp.X) * Camera.RotSpeed;
          nCamera.dry += (nMP.Y - lMp.Y) * Camera.RotSpeed;
          var nnMP := GetCursorPos;
          if nMP <> nnMP then
            nMP := new vec2i(SenterScreen.X + nnMP.X - nMP.X, SenterScreen.Y + nnMP.Y - nMP.Y) else
            nMP := SenterScreen;
          SetCursorPos(nMP.X, nMP.Y);
        end else
        begin
          DrawMouse := false;
          SetCursorPos(SenterScreen.X, SenterScreen.Y);
          nMP := SenterScreen;
        end;
        
      end else
      begin
        
        if lk[4] shr 7 = 1 then
        begin
          SetCursorPos(MP.X, MP.Y);
          DrawMouse := true;
        end else
          MP := nMP;
        
      end;
      
      {$endregion}
      
      {$region WASD}
      
      var Floor := nCamera.PlayerRoom.GetFloor(nCamera);
      var FSS := 1 / sqrt(sqr(1 / Floor.slope.a) + 1);
      
      var r: real;
      
      if nCamera.Z - Floor.Slope.b > -5 then
      begin
        
        r := (Floor.Slope.a - 8.06) * (Floor.Slope.a + 0.56) / 9;//Magic Formula ;)
        var Sp := Camera.Speed * (2 + r) * (1 - r) / 2.25;
        
        if nk[162] shr 7 = 1 then Sp *= Camera.Boost;
        
        var dxm := ((nk[68] shr 7 = 1) ? Sp : 0) - ((nk[65] shr 7 = 1) ? Sp : 0);
        var dym := ((nk[83] shr 7 = 1) ? Sp : 0) - ((nk[87] shr 7 = 1) ? Sp : 0);
        
//        var dxm := (false ? Sp : 0) - (false ? Sp : 0);
//        var dym := (false ? Sp : 0) - (true  ? Sp : 0);
        
        (dxm, dym) := (+dxm * Cos(Camera.RotX) + dym * Sin(Camera.RotX),
        -dxm * Sin(Camera.RotX) + dym * Cos(Camera.RotX));
        
        var dzm := Sp * FSS * Sin(Floor.rot - ArcTg(dxm, dym));
        
        r := sqrt(sqr(Sp) - sqr(dzm)) / Sp;
        //r := 1;
        
        nCamera.dx += dxm * r;
        nCamera.dy += dym * r;
        nCamera.dz += dzm;
        
        if nk[32] shr 7 = 1 then nCamera.dz += -80;
        
      end;
      
      {$endregion}
      
      {$region After Calc}
      
      nCamera.dz += 7;
      
      var nv := new vec3f(
      Floor.SurfMtx.a00 * nCamera.dx   +   Floor.SurfMtx.a01 * nCamera.dy   +   Floor.SurfMtx.a02 * nCamera.dz,
      Floor.SurfMtx.a10 * nCamera.dx   +   Floor.SurfMtx.a11 * nCamera.dy   +   Floor.SurfMtx.a12 * nCamera.dz,
      Floor.SurfMtx.a20 * nCamera.dx   +   Floor.SurfMtx.a21 * nCamera.dy   +   Floor.SurfMtx.a22 * nCamera.dz);
      
      nCamera.dx := Floor.SurfMtx.a00 * nv.X   +   Floor.SurfMtx.a10 * nv.Y   +   Floor.SurfMtx.a20 * nv.Z;
      nCamera.dy := Floor.SurfMtx.a01 * nv.X   +   Floor.SurfMtx.a11 * nv.Y   +   Floor.SurfMtx.a21 * nv.Z;
      nCamera.dz := Floor.SurfMtx.a02 * nv.X   +   Floor.SurfMtx.a12 * nv.Y   +   Floor.SurfMtx.a22 * nv.Z;
      
      {$endregion}
      
      {$region Wall Exit Calc}
      
      var ExitNotHited: boolean;
      repeat
        ExitNotHited := true;
        
        var Pos := new vec2f(nCamera.X, nCamera.Y);
        var Vec := new vec2f(nCamera.dx, nCamera.dy);
        
        if not PlayerNotClipping then
        begin
          TestHit(PlayerR, nCamera.PlayerRoom.GetAllHB, Pos, Vec);
          
          nCamera.dx := Vec.X;
          nCamera.dy := Vec.Y;
        end;
        
        foreach var C in nCamera.PlayerRoom.Connections.ToList do
          if C.ConTo <> nil then
            if HaveIseptPPPD(C.HB.p1, C.HB.p2, Pos + new vec2f(C.Whose.X, C.Whose.Y), Vec) then
            begin
              nCamera.PlayerRoom := C.ConTo;
              nCamera.X += (C.Next.HB.p1.X - C.ConTo.X) - (C.HB.p2.X - C.Whose.X);
              nCamera.Y += (C.Next.HB.p1.Y - C.ConTo.Y) - (C.HB.p2.Y - C.Whose.Y);
              nCamera.Z += ((C.Next.Z * 1 - C.ConTo.Z * 1) - (C.Z * 1 - C.Whose.Z * 1)) * RW;
              
              Floor := nCamera.PlayerRoom.GetFloor(nCamera);
              
              ExitNotHited := false;
              break;
            end;
        
      until ExitNotHited;
      
      {$endregion}
      
      {$region Movement}
      
      nCamera.X += nCamera.dx;
      nCamera.Y += nCamera.dy;
      nCamera.Z += nCamera.dz;
      
      Floor := nCamera.PlayerRoom.GetFloor(nCamera);
      if nCamera.Z > Floor.slope.b then
      begin
        nCamera.Z := Floor.slope.b;
        if nCamera.dz > 0 then
          nCamera.dz := 0;
      end;
      
      nCamera.RotX += nCamera.drx;
      nCamera.RotY += nCamera.dry;
      
      if nCamera.RotY > Pi / 2 then nCamera.RotY := Pi / 2 else
      if nCamera.RotY < 0      then nCamera.RotY := 0;
      
      //if nCamera.Z = Floor.Slope.b then
      begin
        
        nCamera.dx *= 0.935;
        nCamera.dy *= 0.935;
        
      end;
      
      nCamera.drx *= 0.935;
      nCamera.dry *= 0.935;
      
      {$endregion}
      
    end;
    
    private class procedure Movement;
    begin
      
      SenterScreen := new vec2i(Round(WW / 2), Round(WH / 2));
      System.Threading.Thread.CurrentThread.IsBackground := true;
      System.Threading.Thread.CurrentThread.Priority := System.Threading.ThreadPriority.Highest;
      
      nk := new byte[256];
      nk.Fill(i -> GetKeyState(i));
      lk := nk.ToArray;
      
      GetCursorPos(@nMP);
      lMP := nMP;
      
      var LT := System.DateTime.Now;
      
      while true do
        try
          
          Currsor2.Tick(MP);
          
          if GM <> 1 then begin Sleep(100); continue; end;
          
          //if not LFF then continue;
          
          nCamera := Camera;
          
          GetCursorPos(@nMP);
          nk.Fill(i -> GetKeyState(i));
          if not LFF then
            nk[4] := 0;
          
          MovementTick;
          
          Camera := nCamera;
          lk := Copy(nk);
          lMP := nMP;
          
          t := LT - System.DateTime.Now;
          if t > System.TimeSpan.Zero then
            System.Threading.Thread.Sleep(t);
          LT := LT.AddMilliseconds(tw);
        
        except
          on e: System.Exception do
            SaveError('CameraMovementThread: ', e);
        end;
      
    end;
    
    public class procedure Start;
    begin
      Thread := new System.Threading.Thread(Movement);
      Thread.IsBackground := true;
      Thread.Start;
    end;
  
  end;

procedure Init;
begin
  
  CameraTracking.Start;
  
  MF := new MyFormType(0, 0, WW, WH, 15, FormInit, Redrawing);
  MF.WindowState := System.Windows.Forms.FormWindowState.Maximized;
  MF.FormBorderStyle := System.Windows.Forms.FormBorderStyle.None;
  
  MF.Icon := System.Drawing.Icon.FromHandle((new System.Drawing.Bitmap(1, 1)).GetHicon);
  MF.MouseWheel += OnMouseWheel;
  
  MF.Cursor.Dispose;
  MF.FormClosing += FormExit;
  
  System.Windows.Forms.Application.Run(MF);
  
end;

begin
  
  var i: integer;//эти 2 строчки только что дописал, чтоб показать
  i := i;
  
  {$ifdef DEBUG}
  
  System.IO.File.Delete('Errors.txt');
  System.IO.File.Delete('Log.txt');
  System.IO.File.Delete('Log2.txt');
  System.IO.File.Delete('Log3.txt');
  Log('Debug ON');
  Log('-' * 50);
  (new System.Threading.Thread(()->begin while true do if (GetKeyState(17) shr 7 = 1) and (GetKeyState(18) shr 7 = 1) and (GetKeyState(27) shr 7 = 1) then System.Diagnostics.Process.GetCurrentProcess.Kill else Sleep(30); end)).Start;
  
  {$endif}
  
  //(new System.Threading.Thread(()->begin
  try
    Init;
  except
    on e: System.Exception do
    begin
      SaveError('Initialization:', e);
      Sleep(300);
      System.Diagnostics.Process.GetCurrentProcess.Kill;
    end;
  end;
  //end)).Start;
end.