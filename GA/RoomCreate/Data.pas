unit Data;

uses
  System.Drawing,OpenGl, GData, MData;

const
  StFloorW = 128;

{$region Floor Creation}

type
  ST3 = (Single, Single, Single);

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

function GetFloorBytes: array of byte;
const
  DetLvl = 3;

begin
  
  var Mtx := new ST3[StFloorW, StFloorW];
  Mtx.Fill((x, y)-> (Single(0), Single(0), Single(0)));
  
  begin
    var Amp: Single := 1;
    var Frq := 16;
    //var Frq := 1 shl DetLvl;
    //var Frq := StFloorW shr 5;
    loop DetLvl do
    begin
      var nMtx := new ST3[Frq + 1, Frq + 1];
      nMtx.Fill((x, y)-> (
      Single(Rand(0.005 * Amp)),
      Single(Rand(0.020 * Amp)),
      Single(Rand(0.040 * Amp))
      ));
      
      for x: word := 0 to StFloorW - 1 do
        for y: word := 0 to StFloorW - 1 do
        begin
          var k := Frq / StFloorW;
          
          var nx1 := Floor(x * k);
          var nx2 := Ceil(x * k);
          var ny1 := Floor(y * k);
          var ny2 := Ceil(y * k);
          var x1 := nx1 / k;
          var x2 := nx2 / k;
          var y1 := ny1 / k;
          var y2 := ny2 / k;
          
          var xk := (x - x1) / (x2 - x1);
          var yk := (y - y1) / (y2 - y1);
          
          var v, v1, v2: ST3;    
          
          if x1 = x2 then
          begin
            v1 := nMtx[nx1, ny1];
            v2 := nMtx[nx1, ny2];
          end else
          begin
            v1 := nMtx[nx1, ny1] + (nMtx[nx2, ny1] - nMtx[nx1, ny1]) * xk;
            v2 := nMtx[nx1, ny2] + (nMtx[nx2, ny2] - nMtx[nx1, ny2]) * xk;
          end;
          
          if y1 = y2 then
            v := v1 else
            v := v1 + (v2 - v1) * yk;
          
          Mtx[x, y] := Mtx[x, y] + v;
        end;
      
      Amp /= 2;
      Frq := Frq shl 1;
    end;
    
    var k := 1 / (2 - Amp);
    for x: word := 0 to StFloorW - 1 do
      for y: word := 0 to StFloorW - 1 do
        Mtx[x, y] := Mtx[x, y] * k;
    
  end;
  
  Result := new byte[StFloorW * StFloorW * 3];
  
  var i := 0;
  foreach var r in Mtx do
  begin
    Result[i + 0] := Round((0.5 + r.Item1) * 255);
    Result[i + 1] := Round((0.5 + r.Item2) * 255);
    Result[i + 2] := Round((0.5 + r.Item3) * 255);
    i += 3;
  end;
  
end;

{$endregion}

{$region var}

var
  
  {$region Bool}
  
  ///Last Tick Form Fockused
  LFF := false;
  
  {$endregion}
  
  {$region Texures}
  
  ///Floor Texture
  FloorTex: Texture;
  
  {$endregion}
  
  {$region Menu}
  
  ///левая выдвигающаяся штука
  LeftSlider: LeftSlideManuContener;
  ///левая выдвигающаяся штука
  RigthSlider: RigthSlideManuContener;
  ///меню настроек стенки
  WallSettingsManu: ScrollManu;
  
  {$endregion}
  
  {$region proc's}
  
  {$endregion}
  
  BufferIOThread: System.Threading.Thread;
  BufferData := new byte[1](0);
  //byte0:
  //0=Nothing
  //1=ImageToBuffer
  
  LFS := System.DateTime.Now;
  fr := 0;
  fps: Single;
  fpsTex: Texture;

{$endregion}

{$region DopProcs}

procedure TrigerWallSettingsManu;
begin
  WallSettingsManu.Resume;
  ScrollManu.UpdateActive;
end;

procedure FormInit;
begin
  FloorTex := new Texture(StFloorW, StFloorW, GetFloorBytes, false, true, true);
  
  LeftSlider := new LeftSlideManuContener(0, 80, WH);
  LeftSlider.AddManu(new WallSettings(TrigerWallSettingsManu));
  LeftSlider.AddManu(new WallBotton);
  
  RigthSlider := new RigthSlideManuContener(0, 80, WH);
  RigthSlider.AddManu(new TeleportBack);
  RigthSlider.AddManu(new SaveBotton);
  RigthSlider.AddManu(new ExitBotton);
  
  WallSettingsManu := new ScrollManu;
  WallSettingsManu.AddElement(new WSTex);
  WallSettingsManu.AddElement(new WSTex);
  WallSettingsManu.AddElement(new WSTex);
  WallSettingsManu.AddElement(new WSTex);
  WallSettingsManu.AddElement(new WSTex);
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

procedure MouseStay;
begin
  
  if k[192] or k[112] <> LMS then
  begin
    LMS := not LMS;
    if LMS then
    begin
      LMP := MP;
      MP := new Point(Round(WW / 2), Round(WH / 2));
      SetCursorPos(MP.X, MP.Y);
    end else
    begin
      MP := LMP;
      SetCursorPos(LMP.X, LMP.Y);
    end;
  end;
  if (LMS and (ScrollManu.TP < 0)) or k[112] then
  begin
    with Camera do
    begin
      RotX += (WW / 2 - MP.X) * 0.003;
      RotY -= (WH / 2 - MP.Y) * 0.003;
      
      while RotX > Pi do RotX -= 2 * Pi;
      while RotX < -Pi do RotX += 2 * Pi;
      
      if RotY > 1.57 then RotY := 1.57;
      if RotY < -1.57 then RotY := -1.57;
      
      drx *= 0.95;
      dry *= 0.95;
    end;
    
    var Speed := Camera.Speed;
    if GetKeyState(162) shr 7 = 1 then
      Speed *= Camera.Boost;
    
    if GetKeyState(32) div 128 = 1 then Camera.dY += Speed;
    if GetKeyState(160) div 128 = 1 then Camera.dY -= Speed;
    
    begin
      var dx := 0;
      var dz := 0;
      
      if GetKeyState(65) div 128 = 1 then dx += 1;
      if GetKeyState(68) div 128 = 1 then dx -= 1;
      
      if GetKeyState(87) div 128 = 1 then dz += 1;
      if GetKeyState(83) div 128 = 1 then dz -= 1;
      
      Camera.dX += (dx * Cos(Camera.RotX) + dz * Sin(Camera.RotX)) * Speed;
      Camera.dZ += (dz * Cos(Camera.RotX) - dx * Sin(Camera.RotX)) * Speed;
    end;
    
    SetCursorPos(Round(WW / 2), Round(WH / 2));
    
  end;
  
  Camera.X += Camera.dx;
  Camera.Y += Camera.dy;
  Camera.Z += Camera.dz;
  
  Camera.dx *= 0.85;
  Camera.dy *= 0.85;
  Camera.dz *= 0.85;
  
  gluLookAt(Camera.X, Camera.Y, Camera.Z,          Camera.X + Cos(Camera.RotY) * Sin(Camera.RotX), Camera.Y - Sin(Camera.RotY), Camera.Z + Cos(Camera.RotY) * Cos(Camera.RotX),          0, 1, 0);
end;

procedure OnMouseWheel(sender: System.Object; e: System.Windows.Forms.MouseEventArgs);
begin
  MW += Sign(e.Delta);
end;

procedure Redrawing;
begin
  try
    
    {$region Navigation}{
    {$endregion}
    
    {$region Calc}
    
    k[192] := GetKeyState(192) shl 7 = 128;
    k[112] := GetKeyState(112) shl 7 = 128;
    
    fr += 1;
    var tm := (System.DateTime.Now - LFS).TotalMilliseconds;
    if tm >= 1000 then
    begin
      fps := fr / tm * 1000;
      fr := 0;
      LFS := LFS.AddMilliseconds(tm);
    end;
    
    {$endregion}
    
    {$region Draw}
    if MF.Focused then
    begin
      if not LFF and LMS then
        SetCursorPos(Round(WW / 2), Round(WH / 2)) else
        GetCursorPos(@MP);
      
      glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
      
      {$region 3D}
      {$region 3D setup}
      glLoadIdentity;
      glEnable(GL_DEPTH_TEST);
      glPushMatrix;
      glMatrixMode(GL_PROJECTION);
      gluPerspective(45.0, WW / WH, 0.1, real.MaxValue);
      MouseStay;
      {$endregion}
      
      //Sleep(100);
      
      if k[112] or (ScrollManu.TP <> 0) then
      begin
        
        gr.Sphere(true, 1, 0, 0, 1, 0, 0, 1020, 20, 20, 20, 2);
        
        FloorTex.Draw(GL_QUADS, new TexCoord[4](
        new TexCoord(0, 0, -1000, 0, -1000),
        new TexCoord(1, 0, +1000, 0, -1000),
        new TexCoord(1, 1, +1000, 0, +1000),
        new TexCoord(0, 1, -1000, 0, +1000)));
        
        
        
      end;
      
      if not k[112] then
      begin
        Manu.Tick3DAll(MP);
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
      {$endregion}
      
      if not k[112] then
      begin
        
        if ScrollManu.TP <> 0 then
          Manu.Tick2DAll(MP);
        
        ScrollManu.CTick2D;
        
      end;
      
      if k[112] or (not LMS and (ScrollManu.TP <> 0)) then
      begin
        gr.Ellipse(true, 0, 0, 0, 1, MP.X, MP.Y, 4, 4, 16);
        gr.Ellipse(true, 1, 1, 1, 1, MP.X, MP.Y, 3, 3, 16);
      end;
      
      if GetKeyState(114) shl 7 = 128 then
      begin
        fpsTex := Texture.GetTextTexture((fps).ToString, false, 0, 0, 0, 1);
        fpsTex.Draw(GL_QUADS, new TexCoord[4](
        new TexCoord(0, 0, 5, 5, 0),
        new TexCoord(1, 0, 5 + fpsTex.w, 5, 0),
        new TexCoord(1, 1, 5 + fpsTex.w, 5 + fpsTex.h, 0),
        new TexCoord(0, 1, 5, 5 + fpsTex.h, 0)));
      end;
      
      glPopMatrix;
      
      {$endregion}
      
      if GetKeyState(44) shr 7 = 1 <> k[44] then
      begin
        k[44] := GetKeyState(44) shr 7 = 1;
        if k[44] then
        begin
          while BufferData.Length > 1 do Sleep(1);
          var pcs := new byte[4 * WW * WH];
          glReadPixels(0, 0, WW, WH, GL_RGBA, GL_UNSIGNED_BYTE, @pcs[0]);
          BufferData := new byte[1](1) + pcs;
        end;
      end;
      
    end;
    
    SwapBuffers(_hdc);
    
    {$endregion}
    
    //Camera.SaveToLog;
    
    LFF := MF.Focused;
    
    if LFF then
      MF.WindowState := System.Windows.Forms.FormWindowState.Maximized else
      MF.WindowState := System.Windows.Forms.FormWindowState.Minimized;
  ;
  
  except
    on e: system.Exception do
      SaveError('Redrawing:', e);
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

end.