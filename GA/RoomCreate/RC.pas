uses Data,GData;

begin
  System.IO.File.Delete('Errors.txt');
  System.IO.File.Delete('Log.txt');
  try
    Init;
  except
    on e: System.Exception do
    begin
      SaveError('Initialization:', e);
      exit;
    end;
  end;
end.