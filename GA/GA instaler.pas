{$resource 'GA.exe'}{$resource 'Textures\Health Icon.bmp'}
function GetKeyState(nVirtKey: byte): byte;external 'User32.dll' name 'GetKeyState';


var
  f, data: System.IO.Stream;


var
  b: integer;


begin
System.IO.Directory.CreateDirectory('GA');
Writeln('Created Dir GA');
System.IO.Directory.CreateDirectory('GA\Textures');
Writeln('Created Dir GA\Textures');
f := System.IO.File.Create('GA\GA.exe');data := GetResourceStream('GA.exe');while true do begin b := data.ReadByte; if b = -1 then break else f.WriteByte(b); end; f.Close;
Writeln('Created File GA\GA.exe');
f := System.IO.File.Create('GA\Textures\Health Icon.bmp');data := GetResourceStream('Health Icon.bmp');while true do begin b := data.ReadByte; if b = -1 then break else f.WriteByte(b); end; f.Close;
Writeln('Created File GA\Textures\Health Icon.bmp');
writeln('нажмите Enter чтоб открыть папку' + char(10) + 'нажмите Esc для выхода');
while true do

  begin
Sleep(10);
if GetKeyState(13) div 128 = 1 then begin Exec('GA'); exit; end;
if GetKeyState(27) div 128 = 1 then exit;
end;
end.