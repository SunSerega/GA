unit EData;

uses REData, glObjectData, CFData, System.Drawing;

type
  Mob = abstract class(Entity)
  public 
    name: string;
  
  end;
  
  Slime = class(Mob)
  public 
    Rot, sz: Single;
    
    const MaxAcs = 0.5;
    const MaxVel = 3;
    const RotSp = 0.03;
    
    procedure Tick; override;
    begin
      
    end;
    
    procedure Draw; override;
    begin
      
    end;
    
    constructor create(sz: Single; Pos: PointF; Room: Segment);
    begin
      //self.sz := sz;
      //self.Pos := Pos;
      //self.Room := Room;
      //self.Rot := Random * Pi * 2;
      //self.name := self.GetType.ToString.ToLower;
    end;
  
  end;

end.