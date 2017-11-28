uses
  VData, RData, EData, REData, CFData, System.Drawing, GData, glObjectData, OpenGL, CData;

{$region ToDo}{
  
  TODO Z phisics
  TODO перенести старые комнаты


  ToDo Segment.MapHitBox List<HitBoxT>->array of PointF
  ToDo привести все модули к нормальному виду
  ToDo Manu show
  ToDo перенести функции и типы из GData в CFData
  ToDo нормальные данные о игроке
  
  ToDo static Init
   -EntranceT1
   -Hall
   -Canal
  
  ToDo Canal
   -Пол кривой...
  
  ToDo TSeg
   -MapDrawObj
   -MapHitBox

  ToDo костыли
   -TCData.RTG                    #529 ?
   -glObjectData.HBTDOReverse     #568 !  27.11.17
   -glObjectData.glTObject.create #575 ?
   -CFData.HitBoxT.Empty          #577 !  26.11.17
   -CFData [$savepcu false]

  ToDo Textures
   -NORMAL text textures
   -TCData изменить создание текстур
   -Соеденение текстур
   -Подгрузка и отгрузка текстур
   -Переделать все текстуры комнат

  ToDo Rooms
   -Canal move Random from PosOk to RarityOk

  ToDo Entity
   -Mob
    -Slime
    -Outhers
   -Item
   -Prop

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

VData RData EData REData CFData glObjectData GData CData
PerlinNoiseData CellTexData TCData
System.Drawing OpenGl

{$endregion}

{$region Threads}{

Ctrl+Alt+Esc Exit             ifdef Debag
Redrawing                     Allways active
CameraMovement                Allways active
WaitRoomsCreation             For each Dangeon
ScreenSave                    When screenshot taken
RTG.TexCreation               When new Texture requested

{$endregion}

{$region Difined}

{$define Debug}

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
    gr.Lines(1, 0, 0, 1, new PPoint[](new PPoint(nCamera.X, nCamera.Y, -PlayerR + nCamera.Z), new PPoint(nCamera.X - 100, nCamera.Y, -PlayerR + nCamera.Z)));
    gr.Lines(0, 1, 0, 1, new PPoint[](new PPoint(nCamera.X, nCamera.Y, -PlayerR + nCamera.Z), new PPoint(nCamera.X, nCamera.Y - 100, -PlayerR + nCamera.Z)));
    gr.Lines(0, 0, 1, 1, new PPoint[](new PPoint(nCamera.X, nCamera.Y, -PlayerR + nCamera.Z), new PPoint(nCamera.X, nCamera.Y, -PlayerR + nCamera.Z - 100)));
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
  
  gr.Lines(1, 0, 0, 1, new PPoint[](new PPoint(0, 0, 0), new PPoint(0, 0, -RW * 2)));
  
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
            
            var b := new Bitmap(WW, WH);
            var i := 0;
            for var y := WH - 1 downto 0 do
              for var x := 0 to WW - 1 do
              begin
                b.SetPixel(x, y, Color.FromArgb(255, pcs[i + 0], pcs[i + 1], pcs[i + 2]));
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

{$region Camera}

procedure CameraMovementTick(var nCamera: CameraT; var lMP, nMP: Point; var lk, nk: array of byte);
begin
  
  {$region CameraRot}
  
  if nk[4] shr 7 = 1 then
  begin
    
    if lk[4] shr 7 = 1 then
    begin
      nCamera.drx -= (nMP.X - lMp.X) * Camera.RotSpeed;
      nCamera.dry += (nMP.Y - lMp.Y) * Camera.RotSpeed;
      var nnMP := GetCursorPos;
      if nMP <> nnMP then
        nMP := new Point(SenterScreen.X + nnMP.X - nMP.X, SenterScreen.Y + nnMP.Y - nMP.Y) else
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
  
  var sp := Camera.Speed;
  if nk[162] shr 7 = 1 then sp *= Camera.Boost;
  var dxm := ((nk[68] shr 7 = 1) ? Sp : 0) - ((nk[65] shr 7 = 1) ? Sp : 0);
  var dym := ((nk[83] shr 7 = 1) ? Sp : 0) - ((nk[87] shr 7 = 1) ? Sp : 0);
  
  nCamera.dx += dxm * Cos(+Camera.RotX) + dym * Sin(Camera.RotX);
  nCamera.dy += dxm * Sin(-Camera.RotX) + dym * Cos(Camera.RotX);
  
  begin
    var Pos := new PointF(nCamera.X, nCamera.Y);
    var Vec := new PointF(nCamera.dx, nCamera.dy);
    
    if not PlayerNotClipping then
    begin
      TestHit(PlayerR, nCamera.PlayerRoom.GetAllHB, Pos, Vec);
      
      nCamera.dx := Vec.X;
      nCamera.dy := Vec.Y;
    end;
    
    
    foreach var C in nCamera.PlayerRoom.Connections.ToList do
      if C.ConTo <> nil then
        if HaveIseptPPPD(C.HB.p1, C.HB.p2, Pos + new PointF(C.Whose.X, C.Whose.Y), Vec) then
        begin
          nCamera.PlayerRoom := C.ConTo;
          nCamera.X += (C.Next.HB.p1.X - C.ConTo.X) - (C.HB.p2.X - C.Whose.X);
          nCamera.Y += (C.Next.HB.p1.Y - C.ConTo.Y) - (C.HB.p2.Y - C.Whose.Y);
          break;
        end;
  end;
  
  nCamera.X += nCamera.dx;
  nCamera.Y += nCamera.dy;
  nCamera.Z := nCamera.PlayerRoom.GetH(nCamera.X, nCamera.Y);
  
  nCamera.dx *= 0.935;
  nCamera.dy *= 0.935;
  
  
  
  nCamera.RotX += nCamera.drx;
  nCamera.RotY += nCamera.dry;
  
  if nCamera.RotY > Pi / 2 then nCamera.RotY := Pi / 2 else
  if nCamera.RotY < 0    then nCamera.RotY := 0;
  
  nCamera.drx *= 0.935;
  nCamera.dry *= 0.935;
  
end;

procedure CameraMovement;
var
  t: System.TimeSpan;

const
  tps = 90;
  tw = 1000 / tps;

begin
  
  SenterScreen := new Point(Round(WW / 2), Round(WH / 2));
  System.Threading.Thread.CurrentThread.IsBackground := true;
  System.Threading.Thread.CurrentThread.Priority := System.Threading.ThreadPriority.Highest;
  
  var nk := new byte[256];
  nk.Fill(i -> GetKeyState(i));
  var lk := Copy(nk);
  
  var nMP, lMP: Point;
  GetCursorPos(@nMP);
  lMP := nMP;
  
  var nCamera: CameraT;
  
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
      
      CameraMovementTick(nCamera, lMP, nMP, lk, nk);
      
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

{$endregion}

procedure Init;
begin
  
  CameraMovementThread := new System.Threading.Thread(CameraMovement);
  CameraMovementThread.IsBackground := true;
  CameraMovementThread.Start;
  
  MF := new System.Windows.Forms.Form;
  MF.WindowState := System.Windows.Forms.FormWindowState.Maximized;
  MF.FormBorderStyle := system.windows.forms.FormBorderStyle.None;
  
  MF.Controls.Add(new GraphField(0, 0, WW, WH, 15, FormInit, Redrawing));
  
  MF.Icon := Icon.FromHandle((new Bitmap(1, 1)).GetHicon);
  MF.MouseWheel += OnMouseWheel;
  
  MF.Cursor.Dispose;
  MF.FormClosing += FormExit;
  
  system.windows.forms.Application.Run(MF);
  
end;

begin
  
  {$ifdef Debug}
  
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