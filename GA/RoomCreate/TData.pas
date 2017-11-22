{$resource 'TData.dll'}
unit TData;

var
  Leters := new Dictionary<char, array[,] of byte>;

begin
  var re := new System.IO.BinaryReader(GetResourceStream('TData.dll'));
  while re.BaseStream.Position <> re.BaseStream.Length do
  begin
    var ch := char(re.ReadByte * 256 + re.ReadByte);
    var Bitmap := new byte[8, 12];
    for y: byte := 0 to 11 do
    begin
      var b := re.ReadByte;
      Bitmap[7, y] := b shr 7; b := b shl 1;
      Bitmap[6, y] := b shr 7; b := b shl 1;
      Bitmap[5, y] := b shr 7; b := b shl 1;
      Bitmap[4, y] := b shr 7; b := b shl 1;
      Bitmap[3, y] := b shr 7; b := b shl 1;
      Bitmap[2, y] := b shr 7; b := b shl 1;
      Bitmap[1, y] := b shr 7; b := b shl 1;
      Bitmap[0, y] := b shr 7;
    end;
    Leters.Add(ch, Bitmap);
  end;
end.