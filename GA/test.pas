function Digits(c: byte; n: integer): array of byte;
begin
  Result := new byte[10]; 
  loop c do 
  begin
    Result[n mod 10] += 1; 
    n := n div 10; 
  end; 
end;

function Reverse(s: string): string;
begin
  Result := s; 
  for var i: byte := 1 to s.Length do 
    Result[s.Length - i + 1] := s[i]; 
end;

begin
  
  //reset(input, 'in.txt'); 
  //rewrite(output, 'out.txt'); 
  
  
  
  var a := Digits(5, 11333); 
  
  var s: byte := 255; 
  
  for i: byte := 0 to 9 do 
    if byte(a[i] shl 7) = 128 then 
      if s = 255 then 
        s := i else 
      begin
        writeln(-1); 
        //output.close; 
        exit; 
      end; 
  
  var r: string; 
  for var i := 0 to 9 do 
    if a[i] <> 0 then 
      r += i.ToString * (a[i] div 2); 
  
  if s = 255 then 
    r := r + Reverse(r) else 
    r := r + s.ToString + Reverse(r); 
  
  writeln(r); 
  //output.Close; 
end.