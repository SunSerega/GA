unit CellTexData;

interface

function GetCellTexBytes(w, h: cardinal; size: word): array of byte;

implementation

type
  PointF = class
    X, Y: Single;
    
    constructor(X, Y: Single);
    begin
      self.X := X;
      self.Y := Y;
    end;
  end;
  RectangleF = class
    X, Y, W, H: Single;
    
    constructor(X, Y, W, H: Single);
    begin
      self.X := X;
      self.Y := Y;
      self.W := W;
      self.H := H;
    end;
  end;
  
  BinaryRegionPart = class
    
    obj: PointF;
    reg: RectangleF;
    Hor: boolean;
    p1, p2: BinaryRegionPart;
    
    procedure Add(p: PointF);
    begin
      if p1 <> nil then
        if Hor then
        begin
          if p.X < 0 then
        end else
        begin
          
        end else
      if obj = nil then obj := p else
      
    end;
  
  end;

function GetCellTexBytes(w, h: cardinal; size: word): array of byte;
begin
  
  
  
  {
  
  if size<2 then
  size := 2;
  var cellX:integer = w div size + 2;
  var cellY:integer = h div size + 2;
  var pointsX := new integer[cellX,cellY];
  var pointsY := new integer[cellX,cellY];
  for i:integer := 0 to CellX-1 do
  for j:integer := 0 to CellY-1 do
  begin
  pointsX[i][j] = i*size+rand()%((int)(size*0.7))+size*0.15-size;
  pointsY[i][j] = j*size+rand()%((int)(size*0.7))+size*0.15-size;
  end;
  
  int distBuff[n];
  int maxDist = INT_MIN;
  
  for (int i=0; i<n; i++)
  begin
  int x = i%w;
  int y = i/w;
  int min = INT_MAX;
  int min2 = INT_MAX;
  int startX = x/size;
  int finishX = startX+3;
  for (int cp=-1, point=0; startX<finishX; startX++)
  begin
  int startY = y/size;
  int finishY = startY+3;
  for (; startY<finishY; startY++, point++) begin
  if (startX<0 || startX>=cellX || startY<0 || startY>=cellY)
  continue;
  int d = distance(x, y, pointsX[startX][startY], pointsY[startX][startY]);
  if (d<min)
  begin
  cp = point;
  min2 = min;
  min = d;
  end;
  if (d<min2 && cp!=point)
  min2 = d;
  end;
  end;
  distBuff[i] = min2-min;
  if (maxDist<distBuff[i])
  maxDist = distBuff[i];
  end;
  
  unsigned char *img = new unsigned char[n];
  
  for (int i=0; i<n; i++)
  img[i] = (distBuff[i]*255)/maxDist;
  return img;
  
  {}
  
end;

end.