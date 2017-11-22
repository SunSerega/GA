{$reference 'System.Drawing.dll'}

procedure ConvertBMtSI(f, im: string; alpha: boolean := true; wte: boolean := true);
begin
  var b := new System.Drawing.Bitmap(f);
  var wr := System.IO.File.Create(im);
  
  wr.Write(new byte[4](b.Width div 256, b.Width mod 256, b.Height div 256, b.Height mod 256), 0, 4);
  for y: integer := 0 to b.Height - 1 do
    for x: integer := 0 to b.Width - 1 do
    begin
      var c := b.GetPixel(x, y);
      if alpha and wte and (c.R = 255) and (c.G = 255) and (c.B = 255) then
        wr.Write(new byte[4](0, 0, 0, 0), 0, 4) else
      if alpha then
        wr.Write(new byte[4](b.GetPixel(x, y).R, b.GetPixel(x, y).G, b.GetPixel(x, y).B, b.GetPixel(x, y).A), 0, 4) else
        wr.Write(new byte[3](b.GetPixel(x, y).R, b.GetPixel(x, y).G, b.GetPixel(x, y).B), 0, 3);
    end;
  wr.Close;
end;

begin
  
  ConvertBMtSI('exit.bmp', 'exit.im');
  ConvertBMtSI('teleport.bmp', 'teleport.im', true, false);
  ConvertBMtSI('save.bmp', 'save.im');
  ConvertBMtSI('wall.bmp', 'wall.im');
  ConvertBMtSI('settings.bmp', 'settings.im');
  ConvertBMtSI('WSTex.bmp', 'wstex.im', false, false);
  
end.