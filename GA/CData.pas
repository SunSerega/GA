unit CData;

interface

uses CFData,GData,System.Drawing,OpenGL;

type
  Currsor2 = sealed abstract class
  
  private 
    
    class _Showing: boolean;
    
    class Tcls: array[,] of PointF;
  
  public 
    
    class Showing: boolean;
    
    class Waiting: Single;
    
    public class procedure Close;
    begin
      _Showing := false;
    end;
    
    public class procedure Open;
    begin
      _Showing := true;
      Showing := true;
    end;
    
    public class procedure Tick(MP: Point);
    
    public class procedure Draw(MP: Point);
  
  end;

implementation

const
  TC = 6;
  TPC = 5;
  TPL = 12.5;
  Precision = 0.17;
  Tension = 0.6;
  Vmlt = 0.85;
  RotSp:real=0.02;//курсор начинает дрожать когда включаешь вращение
  CR = 5.5;
  
  Pi2 = Pi * 2;
  ABT = Pi2 / TC;

class procedure Currsor2.Tick(MP: Point);
begin
  if _Showing or Showing then
  begin
    
    var rot: real;
    for var x := 0 to TC - 1 do
    begin
      //var drot := ABT * x;
      for var y := 0 to TPC - 1 do
        rot += ArcTg(Tcls[x, y].X - MP.X, Tcls[x, y].Y - MP.Y);// - drot;
    end;
    rot -= Pi*(TC-1);
    rot /= TC * TPC;
    //rot += RotSp;
    //Log('Currsor2 Tick with ', (Tcls, RadToDeg(rot)));
    
    for var y := 0 to TPC - 1 do
    begin
      var r := Power(y, 1.3) * 7 + 15 + CR * Waiting;
      for var x := 0 to TC - 1 do
      begin
        var drot := ABT * x;
        Tcls[x, y].X += (MP.X + Cos(rot + drot) * r - Tcls[x, y].X) * (Power(Precision, (y + 1) / 5 + 0.2) + 0.0);
        Tcls[x, y].Y += (MP.Y + Sin(rot + drot) * r - Tcls[x, y].Y) * (Power(Precision, (y + 1) / 5 + 0.2) + 0.0);
      end;
    end;
    
    if not _Showing then
    begin
      Waiting -= 0.05;
      if Waiting <= 0 then
      begin
        Showing := false;
        Waiting := 0;
      end;
      for var x := 0 to TC - 1 do
        for var y := 0 to TPC - 1 do
        begin
          //Tcls[x].TP[y].Vec.X += (MP.X - Tcls[x].TP[y].Pos.X) * Waiting;
          //Tcls[x].TP[y].Vec.Y += (MP.Y - Tcls[x].TP[y].Pos.Y) * Waiting;
        end;
    end else
    if Waiting < 1 then
    begin
      Waiting += 0.05;
      if Waiting >= 1 then
        Waiting := 1;
    end;
    
  end else
    for var x := 0 to TC - 1 do
      for var y := 0 to TPC - 1 do
        Tcls[x, y] := new PointF(MP.X, MP.Y);
end;

class procedure Currsor2.Draw(MP: Point);
begin
  var pts := gr.Ellipse(MP.X, MP.Y, CR * Waiting, CR * Waiting, 16);
  gr.Polygon(true, 1, 1, 1, 1, pts);
  gr.Polygon(false, 0, 0, 0, 1, pts);
  glBegin(GL_LINES);
  for var x := 0 to TC - 1 do
    for var y := 1 to TPC - 1 do
      glVertex2f(Tcls[x, y].X, Tcls[x, y].Y);
  glEnd;exit;
  //DEBAG
  glColor3f(1, 0, 0);
  for var x := 1 to TC - 1 do
    for var y := 0 to TPC - 2 do
      glVertex2f(Tcls[x, y].X, Tcls[x, y].Y);
  glColor3f(0, 1, 0);
  for var y := 0 to TPC - 2 do
    glVertex2f(Tcls[0, y].X, Tcls[0, y].Y);
  glEnd;
end;

begin
  Currsor2.Tcls := new PointF[TC, TPC];
end. 