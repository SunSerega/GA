unit EData;

uses REData, glObjectData, CFData, AdvglObjData;

type
  Slime = sealed class(Mob)
    
    {$region static}
    
    private const MaxAcs = 0.5;
    private const MaxVel = 3;
    private const RotSp = 0.03;
    
    private const pc=50;
    
    {$endregion}
  
  private
    CBuffer:array[,] of array of byte;
  
  public 
    sz: Single;
    
    public const Name = 'GA.Slime';
    
    
    public constructor create(sz: Single; Pos: vec2f; Room: Segment);
    begin
      
      self.sz := sz;
      Init(Room, Pos.X, Pos.Y, 0, 1);
      
      DrawObj.Add(new PIcosahedron(0,0,-75,           200*sz,200*sz,120*sz,           0,0.5,0,0.6,            0,0.01,0,0.05,            4));
      
    end;
    
    
    public function ClassName: string; override := Name;
    
    public procedure Tick; override;
    begin
      
    end;
    
    
  end;

end.