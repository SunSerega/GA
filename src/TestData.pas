unit TestData;

interface

type
  t1=record
    
    private class _Empty := default(t1);
    public class property Empty:t1 read _Empty;
    
    public X,Y:integer;
    
  end;

implementation

begin
end.