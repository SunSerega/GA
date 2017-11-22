{$reference 'System.Drawing.dll'}

procedure ConvertBMtSI(f, im: string; alpha: boolean := true; wte: boolean := true);
begin
  var b := new System.Drawing.Bitmap(f);
  var wr := new System.IO.BinaryWriter(System.IO.File.Create(im));
  
  wr.Write(word(b.Width));
  wr.Write(word(b.Height));
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
  
  System.IO.File.Delete('CFData.pcu');
  
  ConvertBMtSI('стена забитая досками.bmp', 'WPW.im', false);
  ConvertBMtSI('WallTexPart.bmp', 'WallTexPart.im', false);
  
  {
  var w := 32;
  var b := new System.Drawing.Bitmap(w, w);
  for var x := 0 to w-1 do
    for var y := 0 to w-1 do
    begin
      var r := 1 / sqrt(sqr((w-1)/2 - x) + sqr((w-1)/2 - y));
      if r = real.PositiveInfinity then r := 0;
      var c:byte := Round(r * w / sqrt(2) * 255 * 5);
      b.SetPixel(x, y, System.Drawing.Color.FromArgb(255, c, c, c));
    end;
  
  for var x := 0 to w-1 do
    for var y := 0 to w-1 do
    begin
      var c: Single := 0;
      var n: Single := 0;
      for var nx := x - 1 to x + 1 do
        for var ny := y - 1 to y + 1 do
        begin
          var k := 1 / sqrt(sqr(nx - x) + sqr(ny - y));
          if k = real.PositiveInfinity then k := 10;
          k += 1;
          c += b.GetPixel((nx + w) mod w, (ny + w) mod w).R * k;
          n += k;
        end;
      var nc := Round(c / n);
      b.SetPixel(x, y, System.Drawing.Color.FromArgb(255, nc, nc, nc));
    end;
  b.Save('WallTexPart.bmp');
  Exec('WallTexPart.bmp');
  {}
  
end.