unit RData;

uses CFData, TCData, glObjectData, System.Drawing, REData, EData, GData, OpenGl, PABCSystem, VData;

//                 -   N                  
//                     |                  
//                 W---M---E              
//                     |                  
//                     S   +              

type
  {$region Entrances}
  
  EntranceT1 = sealed class(Segment)
    
    {$region Static Data}
    
    {$region Hitboxes}
    
    private class W_Lhb := new HitBoxT(new PointF(-0.500 * RW, +0.500 * RW), new PointF(-0.500 * RW, -4.500 * RW));
    private class W_Rhb := new HitBoxT(new PointF(+0.500 * RW, -4.500 * RW), new PointF(+0.500 * RW, +0.500 * RW));
    
    private class E_Uhb := new HitBoxT(new PointF(+0.500 * RW, +0.500 * RW), new PointF(-0.500 * RW, +0.500 * RW));
    private class E_Dhb := new HitBoxT(new PointF(-0.500 * RW, -4.500 * RW), new PointF(+0.500 * RW, -4.500 * RW));
    
    private class StMapHB := new List<HitBoxT>(Arr(W_Lhb, W_Rhb, E_Uhb, E_Dhb));
    
    {$endregion}
    
    {$region Draw Points}
    
    private class W_Lpts := new TPoint[](
    new TPoint(-0.500 * RW, +0.500 * RW, +1 * RW - 0 * WallHeigth, 0.0, 1.0),
    new TPoint(-0.500 * RW, +0.500 * RW, +0 * RW - 1 * WallHeigth, 0.0, 0.0 + WallHeigth / RW / 2),
    new TPoint(-0.500 * RW, -0.500 * RW, +0 * RW - 1 * WallHeigth, 0.2, 0.0 + WallHeigth / RW / 2),
    new TPoint(-0.500 * RW, -3.500 * RW, +1 * RW - 1 * WallHeigth, 0.8, 0.5 + WallHeigth / RW / 2),
    new TPoint(-0.500 * RW, -4.500 * RW, +1 * RW - 1 * WallHeigth, 1.0, 0.5 + WallHeigth / RW / 2),
    new TPoint(-0.500 * RW, -4.500 * RW, +1 * RW - 0 * WallHeigth, 1.0, 1.0));
    
    private class W_Rpts := new TPoint[](
    new TPoint(+0.500 * RW, +0.500 * RW, +1 * RW - 0 * WallHeigth, 0.0, 1.0),
    new TPoint(+0.500 * RW, +0.500 * RW, +0 * RW - 1 * WallHeigth, 0.0, 0.0 + WallHeigth / RW / 2),
    new TPoint(+0.500 * RW, -0.500 * RW, +0 * RW - 1 * WallHeigth, 0.2, 0.0 + WallHeigth / RW / 2),
    new TPoint(+0.500 * RW, -3.500 * RW, +1 * RW - 1 * WallHeigth, 0.8, 0.5 + WallHeigth / RW / 2),
    new TPoint(+0.500 * RW, -4.500 * RW, +1 * RW - 1 * WallHeigth, 1.0, 0.5 + WallHeigth / RW / 2),
    new TPoint(+0.500 * RW, -4.500 * RW, +1 * RW - 0 * WallHeigth, 1.0, 1.0));
    
    private class F_1pts := new TPoint[](
    new TPoint(+0.500 * RW, +0.500 * RW, +0 * RW, 1, 1.0),
    new TPoint(+0.500 * RW, -0.500 * RW, +0 * RW, 1, 0.8),
    new TPoint(-0.500 * RW, -0.500 * RW, +0 * RW, 0, 0.8),
    new TPoint(-0.500 * RW, +0.500 * RW, +0 * RW, 0, 1.0));
    
    private class F_2pts := new TPoint[](
    new TPoint(+0.500 * RW, -0.500 * RW, +0 * RW, 1, 0.8),
    new TPoint(+0.500 * RW, -3.500 * RW, +1 * RW, 1, 0.2),
    new TPoint(-0.500 * RW, -3.500 * RW, +1 * RW, 0, 0.2),
    new TPoint(-0.500 * RW, -0.500 * RW, +0 * RW, 0, 0.8));
    
    private class F_3pts := new TPoint[](
    new TPoint(+0.500 * RW, -3.500 * RW, +1 * RW, 1, 0.2),
    new TPoint(+0.500 * RW, -4.500 * RW, +1 * RW, 1, 0.0),
    new TPoint(-0.500 * RW, -4.500 * RW, +1 * RW, 0, 0.0),
    new TPoint(-0.500 * RW, -3.500 * RW, +1 * RW, 0, 0.2));
    
    {$endregion}
    
    {$region DrawObj}
    
    MapDrawObj1 := new glCObject(GL_QUAD_STRIP, 0.5, 1.0, 0.5, 1, new PPoint[](
    new PPoint(+0.500 * RW, +0.500 * RW, +0 * RW),
    new PPoint(-0.500 * RW, +0.500 * RW, +0 * RW),
    new PPoint(+0.500 * RW, -0.500 * RW, +0 * RW),
    new PPoint(-0.500 * RW, -0.500 * RW, +0 * RW),
    new PPoint(+0.500 * RW, -3.500 * RW, +1 * RW),
    new PPoint(-0.500 * RW, -3.500 * RW, +1 * RW),
    new PPoint(+0.500 * RW, -4.500 * RW, +1 * RW),
    new PPoint(-0.500 * RW, -4.500 * RW, +1 * RW)));
    
    {$endregion}
    
    {$endregion}
    
    public function GetH(pX, pY: Single): Single; override;
    begin
      pY := -(Rotate(pX, pY, -rot).Y / RW - 0.5);
      if pY < 1 then Result := 0 else
      if pY < 4 then Result := (pY - 1) / 3 * RW else
        Result := RW;
    end;
    
    public constructor(D: Dangeon);
    begin
      
      rot := Random * Pi * 2;
      
      MapHitBox := StMapHB.ToList;
      
      Init(D, 0, 0, 0, 0, 1, 5, 2, 1);
      
      WallHitBox := (new List<HitboxT>(Arr(W_Lhb, W_Rhb))).Rotate(rot);
      Connections.Add(new ConnectionT(0, Rotate(E_Uhb, rot), self, nil));
      CloseWay(Connections[0]);
      Connections.Add(new ConnectionT(1, Rotate(E_Dhb, rot), self, nil));
      
      var FlTex := RTG.NextFloor(32, 128);
      DrawObj.Add(new glTObject(GL_POLYGON, RTG.NextWall(1024, 256), W_Lpts));
      DrawObj.Add(new glTObject(GL_POLYGON, RTG.NextWall(1024, 256), W_Rpts));
      
      {DrawObj.Add(new glTObject(GL_POLYGON, RTG.NextWall(512, 512), new TPoint[](
      new TPoint(-RW * 2, RW * 5, +RW * 2, 0.01, 0.01),
      new TPoint(+RW * 2, RW * 5, +RW * 2, 0.99, 0.01),
      new TPoint(+RW * 2, RW * 5, -RW * 2, 0.99, 0.99),
      new TPoint(-RW * 2, RW * 5, -RW * 2, 0.01, 0.99))));{}
      DrawObj.Add(new glTObject(GL_QUADS, FlTex, F_1pts));
      DrawObj.Add(new glTObject(GL_QUADS, FlTex, F_2pts));
      DrawObj.Add(new glTObject(GL_QUADS, FlTex, F_3pts));
      
      MapDrawObj.Add(MapDrawObj1);
      
      foreach var C in Connections do
        C.ADDToWait;
    end;
    
    
    public function ClassName: string; override := 'GA.EntranceT1';
  
  end;
  
  {$endregion}
  
  {$region Rooms}
  
  Hall = sealed class(Segment)
    
    {$region Static Data}
    
    private class Pre: SegmentPreData;
    
    private const TW = 10;
    
    private class W_ESpr := Mlt(new PointF[](new PointF(+0.5 * TW, +0.5), new PointF(+(0.5 * TW - 1), +1.0), new PointF(+(0.5 * TW - 1), +(0.5 * TW - 1)), new PointF(+1.0, +(0.5 * TW - 1)), new PointF(+0.5, +0.5 * TW)), RW);
    private class W_WSpr := Mlt(new PointF[](new PointF(-0.5, +0.5 * TW), new PointF(-1.0, +(0.5 * TW - 1)), new PointF(-(0.5 * TW - 1), +(0.5 * TW - 1)), new PointF(-(0.5 * TW - 1), +1.0), new PointF(-0.5 * TW, +0.5)), RW);
    private class W_WNpr := Mlt(new PointF[](new PointF(-0.5 * TW, -0.5), new PointF(-(0.5 * TW - 1), -1.0), new PointF(-(0.5 * TW - 1), -(0.5 * TW - 1)), new PointF(-1.0, -(0.5 * TW - 1)), new PointF(-0.5, -0.5 * TW)), RW);
    private class W_ENpr := Mlt(new PointF[](new PointF(+0.5, -0.5 * TW), new PointF(+1.0, -(0.5 * TW - 1)), new PointF(+(0.5 * TW - 1), -(0.5 * TW - 1)), new PointF(+(0.5 * TW - 1), -1.0), new PointF(+0.5 * TW, -0.5)), RW);
    
    private class function f1(p: PointF) := new PPoint(p.X, p.Y, 0);
    
    {$region Draw Objects}
    
    private class MapDrawObj1 := new glCObject(GL_POLYGON, 0.5, 0.5, 0.5, 1, (new PointF[](new PointF(0, 0), W_ENpr[W_ENpr.Length - 1]) + W_ESpr + W_WSpr + W_WNpr + W_ENpr).ConvertAll(f1));
    
    {$endregion}
    
    {$region Hitboxes}
    
    private class W_ENhb := PTHB(W_ENpr);
    private class W_EShb := PTHB(W_ESpr);
    private class W_WNhb := PTHB(W_WNpr);
    private class W_WShb := PTHB(W_WSpr);
    
    private class E_Nhb := new HitBoxT(new PointF(-0.5 * RW, -0.5 * TW * RW), new PointF(+0.5 * RW, -0.5 * TW * RW));
    private class E_Shb := new HitBoxT(new PointF(+0.5 * RW, +0.5 * TW * RW), new PointF(-0.5 * RW, +0.5 * TW * RW));
    private class E_Whb := new HitBoxT(new PointF(-0.5 * TW * RW, +0.5 * RW), new PointF(-0.5 * TW * RW, -0.5 * RW));
    private class E_Ehb := new HitBoxT(new PointF(+0.5 * TW * RW, -0.5 * RW), new PointF(+0.5 * TW * RW, +0.5 * RW));
    
    private class StMapHB := Lst(
    new HitBoxT(new PointF(-0.5 * TW * RW, -0.5 * TW * RW), new PointF(+0.5 * TW * RW, -0.5 * TW * RW)),
    new HitBoxT(new PointF(+0.5 * TW * RW, -0.5 * TW * RW), new PointF(+0.5 * TW * RW, +0.5 * TW * RW)),
    new HitBoxT(new PointF(+0.5 * TW * RW, +0.5 * TW * RW), new PointF(-0.5 * TW * RW, +0.5 * TW * RW)),
    new HitBoxT(new PointF(-0.5 * TW * RW, +0.5 * TW * RW), new PointF(-0.5 * TW * RW, -0.5 * TW * RW))).Mlt(0.99);
    
    {$endregion}
    
    {$region Draw Points}
    
    private class F_pts := new TPoint[](
    new TPoint(-0.5 * TW * RW, -0.5 * TW * RW, 0, 0, 0),
    new TPoint(+0.5 * TW * RW, -0.5 * TW * RW, 0, 1, 0),
    new TPoint(+0.5 * TW * RW, +0.5 * TW * RW, 0, 1, 1),
    new TPoint(-0.5 * TW * RW, +0.5 * TW * RW, 0, 0, 1));
    
    private class W_ENpts := new TPoint[](
    new TPoint(W_ENpr[0].X, W_ENpr[0].Y, +0 * WallHeigth, -sqrt(1.25) / (TW - 2), 0),
    new TPoint(W_ENpr[0].X, W_ENpr[0].Y, -1 * WallHeigth, -sqrt(1.25) / (TW - 2), 1),
    new TPoint(W_ENpr[1].X, W_ENpr[1].Y, +0 * WallHeigth, 0.0, 0),
    new TPoint(W_ENpr[1].X, W_ENpr[1].Y, -1 * WallHeigth, 0.0, 1),
    new TPoint(W_ENpr[2].X, W_ENpr[2].Y, +0 * WallHeigth, 0.5, 0),
    new TPoint(W_ENpr[2].X, W_ENpr[2].Y, -1 * WallHeigth, 0.5, 1),
    new TPoint(W_ENpr[3].X, W_ENpr[3].Y, +0 * WallHeigth, 1.0, 0),
    new TPoint(W_ENpr[3].X, W_ENpr[3].Y, -1 * WallHeigth, 1.0, 1),
    new TPoint(W_ENpr[4].X, W_ENpr[4].Y, +0 * WallHeigth, 1 + sqrt(1.25) / (TW - 2), 0),
    new TPoint(W_ENpr[4].X, W_ENpr[4].Y, -1 * WallHeigth, 1 + sqrt(1.25) / (TW - 2), 1));
    
    private class W_ESpts := new TPoint[](
    new TPoint(W_ESpr[0].X, W_ESpr[0].Y, +0 * WallHeigth, -sqrt(1.25) / (TW - 2), 0),
    new TPoint(W_ESpr[0].X, W_ESpr[0].Y, -1 * WallHeigth, -sqrt(1.25) / (TW - 2), 1),
    new TPoint(W_ESpr[1].X, W_ESpr[1].Y, +0 * WallHeigth, 0.0, 0),
    new TPoint(W_ESpr[1].X, W_ESpr[1].Y, -1 * WallHeigth, 0.0, 1),
    new TPoint(W_ESpr[2].X, W_ESpr[2].Y, +0 * WallHeigth, 0.5, 0),
    new TPoint(W_ESpr[2].X, W_ESpr[2].Y, -1 * WallHeigth, 0.5, 1),
    new TPoint(W_ESpr[3].X, W_ESpr[3].Y, +0 * WallHeigth, 1.0, 0),
    new TPoint(W_ESpr[3].X, W_ESpr[3].Y, -1 * WallHeigth, 1.0, 1),
    new TPoint(W_ESpr[4].X, W_ESpr[4].Y, +0 * WallHeigth, 1 + sqrt(1.25) / (TW - 2), 0),
    new TPoint(W_ESpr[4].X, W_ESpr[4].Y, -1 * WallHeigth, 1 + sqrt(1.25) / (TW - 2), 1));
    
    private class W_WNpts := new TPoint[](
    new TPoint(W_WNpr[0].X, W_WNpr[0].Y, +0 * WallHeigth, -sqrt(1.25) / (TW - 2), 0),
    new TPoint(W_WNpr[0].X, W_WNpr[0].Y, -1 * WallHeigth, -sqrt(1.25) / (TW - 2), 1),
    new TPoint(W_WNpr[1].X, W_WNpr[1].Y, +0 * WallHeigth, 0.0, 0),
    new TPoint(W_WNpr[1].X, W_WNpr[1].Y, -1 * WallHeigth, 0.0, 1),
    new TPoint(W_WNpr[2].X, W_WNpr[2].Y, +0 * WallHeigth, 0.5, 0),
    new TPoint(W_WNpr[2].X, W_WNpr[2].Y, -1 * WallHeigth, 0.5, 1),
    new TPoint(W_WNpr[3].X, W_WNpr[3].Y, +0 * WallHeigth, 1.0, 0),
    new TPoint(W_WNpr[3].X, W_WNpr[3].Y, -1 * WallHeigth, 1.0, 1),
    new TPoint(W_WNpr[4].X, W_WNpr[4].Y, +0 * WallHeigth, 1 + sqrt(1.25) / (TW - 2), 0),
    new TPoint(W_WNpr[4].X, W_WNpr[4].Y, -1 * WallHeigth, 1 + sqrt(1.25) / (TW - 2), 1));
    
    private class W_WSpts := new TPoint[](
    new TPoint(W_WSpr[0].X, W_WSpr[0].Y, +0 * WallHeigth, -sqrt(1.25) / (TW - 2), 0),
    new TPoint(W_WSpr[0].X, W_WSpr[0].Y, -1 * WallHeigth, -sqrt(1.25) / (TW - 2), 1),
    new TPoint(W_WSpr[1].X, W_WSpr[1].Y, +0 * WallHeigth, 0.0, 0),
    new TPoint(W_WSpr[1].X, W_WSpr[1].Y, -1 * WallHeigth, 0.0, 1),
    new TPoint(W_WSpr[2].X, W_WSpr[2].Y, +0 * WallHeigth, 0.5, 0),
    new TPoint(W_WSpr[2].X, W_WSpr[2].Y, -1 * WallHeigth, 0.5, 1),
    new TPoint(W_WSpr[3].X, W_WSpr[3].Y, +0 * WallHeigth, 1.0, 0),
    new TPoint(W_WSpr[3].X, W_WSpr[3].Y, -1 * WallHeigth, 1.0, 1),
    new TPoint(W_WSpr[4].X, W_WSpr[4].Y, +0 * WallHeigth, 1 + sqrt(1.25) / (TW - 2), 0),
    new TPoint(W_WSpr[4].X, W_WSpr[4].Y, -1 * WallHeigth, 1 + sqrt(1.25) / (TW - 2), 1));
  
    {$endregion}
  
    {$endregion}
  
  
  private 
    cN, cE, cS, cW: boolean;
    
    public const Name = 'GA.Hall';
    
    public class function Rarity := StRarity[Name];
    
    public class function RarityOk := Random * Rarity < 1;
    
    public class function PosOk(var nC: ConnectionT): boolean;
    begin
      
      Pre.ZMin := 0;
      Pre.ZMax := 0;
      Result := PreInit(Pre, nC.Whose.DangeonIn, nC, (new ConnectionT[](
        new ConnectionT(0, E_Nhb, nil, nil),
        new ConnectionT(0, E_Shb, nil, nil),
        new ConnectionT(0, E_Whb, nil, nil),
        new ConnectionT(0, E_Ehb, nil, nil))).ToList, StMapHB.ToList);
      
    end;
    
    public constructor(var nC: ConnectionT);
    begin
      
      cN := true;
      cE := true;
      cS := true;
      cW := true;
      
      Init(Pre, nC, W_ENhb + W_EShb + W_WNhb + W_WShb, 5, 1);
      
      DrawObj.Add(new glTObject(GL_QUAD_STRIP, RTG.NextWall(128 * (TW - 2), 128), W_ENpts));
      DrawObj.Add(new glTObject(GL_QUAD_STRIP, RTG.NextWall(128 * (TW - 2), 128), W_ESpts));
      DrawObj.Add(new glTObject(GL_QUAD_STRIP, RTG.NextWall(128 * (TW - 2), 128), W_WSpts));
      DrawObj.Add(new glTObject(GL_QUAD_STRIP, RTG.NextWall(128 * (TW - 2), 128), W_WNpts));
      DrawObj.Add(new glTObject(GL_QUADS, RTG.NextFloor(32 * TW, 32 * TW), F_pts));
      
      MapDrawObj.Add(MapDrawObj1);
      
    end;
    
    
    public procedure CloseWay(C: ConnectionT); override;
    begin
      if not Connections.Remove(C) then
        raise new System.ArgumentException('No such connection of this room');
      case Round((C.rot - rot) / Pi * 2) and 3 of
        0: cN := false;
        1: cE := false;
        2: cS := false;
        3: cW := false;
      end;
      var Res: glCObject;
      if MapDrawObj[0] = MapDrawObj1 then Res := new glCObject(MapDrawObj1.mode, MapDrawObj1.cr, MapDrawObj1.cg, MapDrawObj1.cb, MapDrawObj1.ca, new PPoint[0]) else Res := MapDrawObj[0];
      var pts := new List<PPoint>(MapDrawObj[0].pts.Count);
      pts.Add(new PPoint(0, 0, 0));
      var nHB := new List<HitBoxT>(WallHitBox.Count);
      var dNE := new List<TPoint>(10);
      var dSE := new List<TPoint>(10);
      var dSW := new List<TPoint>(10);
      var dNW := new List<TPoint>(10);
      var MoveTX: TPoint->TPoint := o -> new TPoint(o.X, o.Y, o.Z, 2, o.TY);
      
      
      pts.Add(new PPoint(W_ENpr[2].X, W_ENpr[2].Y, 0));
      
      if cE then
      begin
        nHB.Add(W_ENhb[2]); pts.Add(new PPoint(W_ENpr[3].X, W_ENpr[3].Y, 0));
        nHB.Add(W_ENhb[3]); pts.Add(new PPoint(W_ENpr[4].X, W_ENpr[4].Y, 0));
        nHB.Add(W_EShb[0]); pts.Add(new PPoint(W_ESpr[0].X, W_ESpr[0].Y, 0));
        nHB.Add(W_EShb[1]); pts.Add(new PPoint(W_ESpr[1].X, W_ESpr[1].Y, 0));
        
        dNE.Add(W_ENpts[9]);
        dNE.Add(W_ENpts[8]);
        dNE.Add(W_ENpts[7]);
        dNE.Add(W_ENpts[6]);
        
        dSE.Add(W_ESpts[0]);
        dSE.Add(W_ESpts[1]);
        dSE.Add(W_ESpts[2]);
        dSE.Add(W_ESpts[3]);
      end else
      begin
        nHB.Add(new HitBoxT(W_ENpr[2], W_ESpr[2]));
        
        dNE.Add(MoveTX(W_ESpts[5]));
        dNE.Add(MoveTX(W_ESpts[4]));
      end;
      
      pts.Add(new PPoint(W_ESpr[2].X, W_ESpr[2].Y, 0));
      
      dNE.Add(W_ENpts[5]);
      dNE.Add(W_ENpts[4]);
      
      dSE.Add(W_ESpts[4]);
      dSE.Add(W_ESpts[5]);
      
      if cS then
      begin
        nHB.Add(W_EShb[2]); pts.Add(new PPoint(W_ESpr[3].X, W_ESpr[3].Y, 0));
        nHB.Add(W_EShb[3]); pts.Add(new PPoint(W_ESpr[4].X, W_ESpr[4].Y, 0));
        nHB.Add(W_WShb[0]); pts.Add(new PPoint(W_WSpr[0].X, W_WSpr[0].Y, 0));
        nHB.Add(W_WShb[1]); pts.Add(new PPoint(W_WSpr[1].X, W_WSpr[1].Y, 0));
        
        dSE.Add(W_ESpts[6]);
        dSE.Add(W_ESpts[7]);
        dSE.Add(W_ESpts[8]);
        dSE.Add(W_ESpts[9]);
        
        dSW.Add(W_WSpts[0]);
        dSW.Add(W_WSpts[1]);
        dSW.Add(W_WSpts[2]);
        dSW.Add(W_WSpts[3]);
      end else
      begin
        nHB.Add(new HitBoxT(W_ESpr[2], W_WSpr[2]));
        
        dSE.Add(MoveTX(W_WSpts[4]));
        dSE.Add(MoveTX(W_WSpts[5]));
      end;
      
      pts.Add(new PPoint(W_WSpr[2].X, W_WSpr[2].Y, 0));
      
      dSW.Add(W_WSpts[4]);
      dSW.Add(W_WSpts[5]);
      
      if cW then
      begin
        nHB.Add(W_WShb[2]); pts.Add(new PPoint(W_WSpr[3].X, W_WSpr[3].Y, 0));
        nHB.Add(W_WShb[3]); pts.Add(new PPoint(W_WSpr[4].X, W_WSpr[4].Y, 0));
        nHB.Add(W_WNhb[0]); pts.Add(new PPoint(W_WNpr[0].X, W_WNpr[0].Y, 0));
        nHB.Add(W_WNhb[1]); pts.Add(new PPoint(W_WNpr[1].X, W_WNpr[1].Y, 0));
        
        dSW.Add(W_WSpts[6]);
        dSW.Add(W_WSpts[7]);
        dSW.Add(W_WSpts[8]);
        dSW.Add(W_WSpts[9]);
        
        dNW.Add(W_WNpts[0]);
        dNW.Add(W_WNpts[1]);
        dNW.Add(W_WNpts[2]);
        dNW.Add(W_WNpts[3]);
      end else
      begin
        nHB.Add(new HitBoxT(W_WSpr[2], W_WNpr[2]));
        
        dSW.Add(MoveTX(W_WNpts[4]));
        dSW.Add(MoveTX(W_WNpts[5]));
      end;
      
      pts.Add(new PPoint(W_WNpr[2].X, W_WNpr[2].Y, 0));
      
      dNW.Add(W_WNpts[4]);
      dNW.Add(W_WNpts[5]);
      
      if cN then
      begin
        nHB.Add(W_WNhb[2]); pts.Add(new PPoint(W_WNpr[3].X, W_WNpr[3].Y, 0));
        nHB.Add(W_WNhb[3]); pts.Add(new PPoint(W_WNpr[4].X, W_WNpr[4].Y, 0));
        nHB.Add(W_ENhb[0]); pts.Add(new PPoint(W_ENpr[0].X, W_ENpr[0].Y, 0));
        nHB.Add(W_ENhb[1]); pts.Add(new PPoint(W_ENpr[1].X, W_ENpr[1].Y, 0));
        
        dNW.Add(W_WNpts[6]);
        dNW.Add(W_WNpts[7]);
        dNW.Add(W_WNpts[8]);
        dNW.Add(W_WNpts[9]);
        
        dNE.Add(W_ENpts[3]);
        dNE.Add(W_ENpts[2]);
        dNE.Add(W_ENpts[1]);
        dNE.Add(W_ENpts[0]);
      end else
      begin
        nHB.Add(new HitBoxT(W_WNpr[2], W_ENpr[2]));
        
        dNW.Add(MoveTX(W_ENpts[4]));
        dNW.Add(MoveTX(W_ENpts[5]));
      end;
      
      pts.Add(new PPoint(W_ENpr[2].X, W_ENpr[2].Y, 0));
      
      
      Res.pts := pts.ToArray;
      MapDrawObj[0] := Res;
      WallHitBox := nHB.Rotate(rot);
      
      DrawObj[0] := new glTObject(GL_QUAD_STRIP, glTObject(DrawObj[0]).Tex, dNE);
      DrawObj[1] := new glTObject(GL_QUAD_STRIP, glTObject(DrawObj[1]).Tex, dSE);
      DrawObj[2] := new glTObject(GL_QUAD_STRIP, glTObject(DrawObj[2]).Tex, dSW);
      DrawObj[3] := new glTObject(GL_QUAD_STRIP, glTObject(DrawObj[3]).Tex, dNW);
      
      //DrawObj[0] := new glTObject(GL_QUAD_STRIP, glTObject(DrawObj[0]).Tex, new TPoint[0]);
      //DrawObj[1] := new glTObject(GL_QUAD_STRIP, glTObject(DrawObj[1]).Tex, dSE.ToArray);
      //DrawObj[2] := new glTObject(GL_QUAD_STRIP, glTObject(DrawObj[2]).Tex, new TPoint[0]);
      //DrawObj[3] := new glTObject(GL_QUAD_STRIP, glTObject(DrawObj[3]).Tex, new TPoint[0]);
      
      //DrawObj[0] := new glCObject(GL_QUAD_STRIP, 1,0,0,1, dNE.ConvertAll(p->new PPoint(p.X,p.Y,p.Z)).ToArray);
      //DrawObj[1] := new glCObject(GL_QUAD_STRIP, 0,1,0,1, dSE.ConvertAll(p->new PPoint(p.X,p.Y,p.Z)).ToArray);
      //DrawObj[2] := new glCObject(GL_QUAD_STRIP, 0,0,1,1, dSW.ConvertAll(p->new PPoint(p.X,p.Y,p.Z)).ToArray);
      //DrawObj[3] := new glCObject(GL_QUAD_STRIP, 1,1,0,1, dNW.ConvertAll(p->new PPoint(p.X,p.Y,p.Z)).ToArray);
      
      //DrawObj[0] := new glCObject(GL_QUAD_STRIP, 1,0,0,1, dNE.Rotate(-self.rot).ConvertAll(p->new PPoint(p.X,p.Y,p.Z)).ToArray);
      //DrawObj[1] := new glCObject(GL_QUAD_STRIP, 0,1,0,1, dSE.Rotate(-self.rot).ConvertAll(p->new PPoint(p.X,p.Y,p.Z)).ToArray);
      //DrawObj[2] := new glCObject(GL_QUAD_STRIP, 0,0,1,1, dSW.Rotate(-self.rot).ConvertAll(p->new PPoint(p.X,p.Y,p.Z)).ToArray);
      //DrawObj[3] := new glCObject(GL_QUAD_STRIP, 1,1,0,1, dNW.Rotate(-self.rot).ConvertAll(p->new PPoint(p.X,p.Y,p.Z)).ToArray);
      
    end;
    
    public function ClassName: string; override := Name;
  
  end;
  
  Canal = sealed class(Segment)
    
    {$region Static Data}
    
    private const TW = 2.5 * RW;
    private const CL = 1 * RW;
    private const ML = 7 * RW;
    private const TexW = 128;
    
    private class Pre: SegmentPreData;
    private class CF2: ConnectionT;
    
    private class Epr: array of PointF;
    private class Wpr: array of PointF;
    
    private class dZ: smallint;
  
    {$endregion}
  
  
  private 
    nZ: smallint;
    HB1, HB2: HitBoxT;
    p1, p2: PointF;
    LD1, LD2: SLine;
    
    public const Name = 'GA.Canal';
    
    public class function Rarity := StRarity[Name];
    
    public class function RarityOk := Random * Rarity < 1;
    
    public class function PosOk(var nC: ConnectionT): boolean;
    begin
      
      if nC.Whose.ClassName = Name then exit;
      
      var SS := nC.Senter;
      
      dZ := Random(-1, 1);
      var dY := -ML - Random * RW * 7;
      var dX := dY * Sin(Rand(Pi / 6) * Cos(Random * Pi));
      
      var dXY := Rotate(dX, dY, nC.rot) + SS;
      dX := dXY.X;
      dY := dXY.Y;
      
      var DangeonIn := nC.Whose.DangeonIn;
      var Segs := new List<Segment>;
      var Conns2 := new List<ConnectionT>;
      for var X := -1 to +1 do
        for var Y := -1 to +1 do
        begin
          var P := new Point3i(Round(X / DangeonIn.RegW) + X, Round(Y / DangeonIn.RegW) + Y, dZ);
          if DangeonIn.Regs.ContainsKey(P) then
            foreach var S in DangeonIn.Regs[P] do
              if not Segs.Contains(S) then
              begin
                Segs.Add(S);
                foreach var C: ConnectionT in S.Connections do
                  if C <> nC then
                    if C.ConTo = nil then
                    begin
                      
                      var nHB := new HitBoxT(nC.HB.Senter, C.HB.Senter);
                      
                      if Sin(nC.rot - nHB.rot) > 0.86 then
                        if Sin(C.rot - nHB.rot) < -0.86 then
                          Conns2.Add(C);
                    end;
              end;
        end;
      
      if (Random(2) = 0) and (Conns2.Count <> 0) then
      begin
        CF2 := Conns2.Rand;
        if CF2.Whose.ClassName = 'GA.Canal' then exit;
      end else
        CF2 := new ConnectionT(dZ, new HitBoxT(nC.w, Pi + nC.rot + Rand(Pi / 6), dXY), nil, nil);
      
      if (new HitBoxT(CF2.HB.Senter, nC.HB.Senter)).w < ML then exit;
      
      Epr := new PointF[4];Epr[0] := CF2.HB.p1 - SS;Epr[3] := nC.HB.p2 - SS;
      Wpr := new PointF[4];Wpr[0] := nC.HB.p1 - SS;Wpr[3] := CF2.HB.p2 - SS;
      
      begin
        var P := CF2.HB.Senter - SS;
        var rot := (new HitBoxT(CF2.HB.Senter, nC.HB.Senter)).rot + Pi / 2;
        P.X += CL * Sin(rot);
        P.Y -= CL * Cos(rot);
        Epr[1] := new PointF(P.X - TW / 2 * Cos(rot), P.Y - TW / 2 * Sin(rot));
        Wpr[2] := new PointF(P.X + TW / 2 * Cos(rot), P.Y + TW / 2 * Sin(rot));
        rot += Pi;
        P := new PointF(
         CL * Sin(rot),
        -CL * Cos(rot));
        Wpr[1] := new PointF(P.X - TW / 2 * Cos(rot), P.Y - TW / 2 * Sin(rot));
        Epr[2] := new PointF(P.X + TW / 2 * Cos(rot), P.Y + TW / 2 * Sin(rot));
      end;
      
      Pre.ZMin := Min(0, dZ);
      Pre.ZMax := Max(0, dZ);
      var MapHB := PTHB(Epr + Wpr, 8);
      var nHB := CF2.HB.Reverse - SS;
      MapHB.Add(nHB);
      Result := PreInit(Pre, nC.Whose.DangeonIn, nC, (new ConnectionT[](
        new ConnectionT(CF2.Whose = nil ? CF2.Z : (CF2.Z - nC.Z), nHB, nil, nil),
        new ConnectionT(0, nC.HB.Reverse - SS, nil, nil))).ToList, 1, MapHB);
      
      //Result := true;
      
    end;
    
    public constructor(var nC: ConnectionT);
    begin
      
      var W_Ehb := PTHB(Epr);
      var W_Whb := PTHB(Wpr);
      
      nZ := dZ;
      if nZ <> 0 then
      begin
        
        HB1 := new HitBoxT(Epr[2], Wpr[1]);
        HB2 := new HitBoxT(Wpr[2], Epr[1]);
        p1 := HB1.Senter;
        p2 := HB2.Senter;
        LD2 := SLine.LineData(HB1.p1, HB1.p2);
        LD1 := LD2.Perpend;
        
      end;
      Init(Pre, nC, W_Ehb + W_Whb, 2, 1);
      
      if CF2.Whose <> nil then
      begin
        
        var CF := CF2;
        var CT := Connections[0];
        
        CF.Next := CT;
        CT.Next := CF;
        
        CF.ConTo := CT.Whose;
        CT.ConTo := CF.Whose;
        
      end;
      
      var w, w1, w2: real;
      
      w1 := W_Whb[0].w / WallHeigth;
      w2 := W_Whb[1].w / WallHeigth;
      w := w1 + w2 + W_Whb[2].w / WallHeigth;
      
      DrawObj.Add(new glTObject(GL_QUAD_STRIP, RTG.NextWall(TexW, TexW), new TPoint[](
        new TPoint(Epr[0].X, Epr[0].Y, -1 * WallHeigth + nZ * RW, 0, 0),
        new TPoint(Epr[0].X, Epr[0].Y, -0 * WallHeigth + nZ * RW, 0, 1),
        new TPoint(Epr[1].X, Epr[1].Y, -1 * WallHeigth + nZ * RW, w1, 0),
        new TPoint(Epr[1].X, Epr[1].Y, -0 * WallHeigth + nZ * RW, w1, 1),
        new TPoint(Epr[2].X, Epr[2].Y, -1 * WallHeigth, w1 + w2, 0),
        new TPoint(Epr[2].X, Epr[2].Y, -0 * WallHeigth, w1 + w2, 1),
        new TPoint(Epr[3].X, Epr[3].Y, -1 * WallHeigth, w, 0),
        new TPoint(Epr[3].X, Epr[3].Y, -0 * WallHeigth, w, 1))));
      
      w1 := W_Whb[0].w / WallHeigth;
      w2 := W_Whb[1].w / WallHeigth;
      w := w1 + w2 + W_Whb[2].w / WallHeigth;
      
      DrawObj.Add(new glTObject(GL_QUAD_STRIP, RTG.NextWall(TexW, TexW), new TPoint[](
        new TPoint(Wpr[0].X, Wpr[0].Y, -1 * WallHeigth, 0, 0),
        new TPoint(Wpr[0].X, Wpr[0].Y, -0 * WallHeigth, 0, 1),
        new TPoint(Wpr[1].X, Wpr[1].Y, -1 * WallHeigth, w1, 0),
        new TPoint(Wpr[1].X, Wpr[1].Y, -0 * WallHeigth, w1, 1),
        new TPoint(Wpr[2].X, Wpr[2].Y, -1 * WallHeigth + nZ * RW, w1 + w2, 0),
        new TPoint(Wpr[2].X, Wpr[2].Y, -0 * WallHeigth + nZ * RW, w1 + w2, 1),
        new TPoint(Wpr[3].X, Wpr[3].Y, -1 * WallHeigth + nZ * RW, w, 0),
        new TPoint(Wpr[3].X, Wpr[3].Y, -0 * WallHeigth + nZ * RW, w, 1))));
      
      var pts := (Wpr + Epr).ConvertAll(p -> new PPoint(p.X, p.Y, 0));
      for var i := 2 to 5 do
        pts[i].Z := dZ * RW;
      
      MapDrawObj.Add(new glCObject(GL_POLYGON, 0.5, 0, 0.5, 1, pts));
      
      var Tpts := new TPoint[pts.Length];
      for var i := 0 to pts.Length - 1 do
        Tpts[i] := new TPoint(pts[i].X, pts[i].Y, pts[i].Z, (pts[i].X - pts[0].X) / RW / 5, (pts[i].Y - pts[0].Y) / RW / 5);
      DrawObj.Add(new glTObject(GL_POLYGON, RTG.NextFloor(TexW, TexW), Tpts));
      
    end;
    
    
    public function GetH(pX, pY: Single): Single; override;
    begin
      if nZ = 0 then exit;
      var pt := new PointF(pX, pY);
      if OnLeft(HB1.p1, HB1.p2, pt) then
        exit else
      if OnLeft(HB2.p1, HB2.p2, pt) then
        Result := nZ * RW else
      begin
        var Res := Isept(LD1, LD2);
        LD2.BLineData(pt);
        var Z1: smallint := 0;
        var Z2: smallint := nZ;
        if LD1.XYSwaped then begin
          
          var pMin := p1.Y;var pMax := p2.Y;
          if pMin > pMax then
          begin
            Swap(Z1, Z2);
            Swap(pMin, pMax);
          end;
          Result := (Z1 + (Z2 - Z1) * (Res.Y - pMin) / (pMax - pMin)) * RW;
          
        end else begin
          
          var pMin := p1.X;var pMax := p2.X;
          if pMin > pMax then
          begin
            Swap(Z1, Z2);
            Swap(pMin, pMax);
          end;
          Result := (Z1 + (Z2 - Z1) * (Res.X - pMin) / (pMax - pMin)) * RW;
          
        end;
      end;
    end;
    
    public function ForceConnecting: boolean; override := true;
    
    public function ClassName: string; override := Name;
  
  end;
  
  TSeg = sealed class(Segment)
    
    {$region Static Data}
    
    private const CW = RW * 7.5;//Circle Width
    private const TL1 = RW * 1.5;//Tranch Length 1
    private const TL2 = RW * 3.1;//Tranch Length 2
    private const STL = RW * 8.3;//Side Tranche Length
    private const STA = 15 * Pi / 180;//Side Tranche Angel
    private const SPC = 64;//Circle Points Count
    private const APCP = 2 * Pi / SPC;//Angel Per Circle Point
    private const SPS = 1;//Circle Points Skip
    private const TW = CW * 2 * Sin(APCP * (SPS + 1) / 2);//Tranche Width = 2205.38565741511
    
    private const STWd2 = TW / Cos(STA) / 2;
    
    private class Pre: SegmentPreData;
    
    
    private class TexSize: Point;
    
    private class Spts, Npts: array of PointF;
    private class Wpts1, Wpts2: array of PointF;
    private class Epts1, Epts2: array of PointF;
    
    {$region Hitboxes}
    
    private class W_Shb: List<HitBoxT>;
    private class W_WChb, W_EChb: List<HitBoxT>;
    private class W_WOhb, W_EOhb: List<HitBoxT>;
    
    private class E_Nhb: HitBoxT;
    private class E_Whb: HitBoxT;
    private class E_Ehb: HitBoxT;
    
    private class StMapHB: List<HitBoxT>;
    
    {$endregion}
    
    {$region Draw Objects}
    
    private class MapDrawObj1: glCObject;
    
    private class F_Wdo, F_Mdo, F_Edo: glObject;
    
    private class W_Sdo: List<glObject>;
    private class W_WCdo, W_ECdo: List<glObject>;
    private class W_WOdo, W_EOdo: List<glObject>;
    
    {$endregion}
    
    {$endregion}
    
    private Wc, Ec: boolean;
    
    private class procedure Init;
    begin
      
      var ang := APCP * (SPS + 1) / 2;
      Spts := new PointF[SPC - SPS];
      for var i := 0 to Spts.Length - 1 do
      begin
        Spts[i] := new PointF(CW * Sin(ang), -CW * Cos(ang));
        ang += APCP;
      end;
      
      Npts := new PointF[2];
      Npts[0] := new PointF(-Spts[0].X, Spts[0].Y - TL1 - TL2);
      //Npts[0] := new PointF(-RW/2, Spts[0].Y - TL1 - TL2);
      Npts[1] := new PointF(-Npts[0].X, Npts[0].Y);
      
      
      var nP1, nP2, dP1, dP2: PointF;
      
      nP1 := new PointF(-Spts[0].X, Spts[0].Y - TL1);
      nP2 := new PointF(nP1.X - STL * Cos(STA), nP1.Y + STL * Sin(STA));
      dP1 := new PointF(0, STWd2);
      dP2 := new PointF(TW * Sin(STA) / 2, TW * Cos(STA) / 2);
      
      Wpts1 := new PointF[2];Epts1 := new PointF[2];
      Wpts2 := new PointF[2];Epts2 := new PointF[2];
      
      
      Wpts1[0] := nP1 + dP1;
      Wpts1[1] := nP2 + dP2;
      
      Wpts2[1] := nP1 - dP1;
      Wpts2[0] := nP2 - dP2;
      
      
      Epts1[0] := new PointF(-Wpts2[1].X, Wpts2[1].Y);
      Epts1[1] := new PointF(-Wpts2[0].X, Wpts2[0].Y);
      
      Epts2[0] := new PointF(-Wpts1[1].X, Wpts1[1].Y);
      Epts2[1] := new PointF(-Wpts1[0].X, Wpts1[0].Y);
      
      
      
      W_Shb := PTHB(Spts);
      
      W_WChb := new List<HitBoxT>(1);W_EChb := new List<HitBoxT>(1);
      W_WOhb := new List<HitBoxT>(2);W_EOhb := new List<HitBoxT>(2);
      
      W_WChb.Add(new HitBoxT(Spts[Spts.Length - 1], Npts[0]));
      W_EChb.Add(new HitBoxT(Npts[1], Spts[0]));
      
      W_WOhb.Add(new HitBoxT(Wpts1[0], Wpts1[1])); W_WOhb.Add(new HitBoxT(Wpts2[0], Wpts2[1]));
      W_EOhb.Add(new HitBoxT(Epts1[0], Epts1[1])); W_EOhb.Add(new HitBoxT(Epts2[0], Epts2[1]));
      
      W_WOhb.Add(new HitBoxT(Spts[Spts.Length - 1], Wpts1[0])); W_WOhb.Add(new HitBoxT(Wpts2[1], Npts[0]));
      W_EOhb.Add(new HitBoxT(Epts2[1], Spts[0] )); W_EOhb.Add(new HitBoxT(Npts[1], Epts1[0]));
      
      
      E_Whb := new HitBoxT(Wpts1[1], Wpts2[0]);
      E_Ehb := new HitBoxT(Epts1[1], Epts2[0]);
      
      E_Nhb := new HitBoxT(Npts[0], Npts[1]);
      
      
      var MHBP := new PointF[7 + 1];
      
      MHBP[3 + 0] := new PointF(0, CW);
      
      var k_a := Max(-Tan(APCP), (CW - Wpts1[1].Y) / Wpts1[1].X);
      MHBP[3 - 1] := new PointF(Wpts2[0].X, CW - Wpts2[0].X * k_a);
      MHBP[3 + 1] := new PointF(-MHBP[3 - 1].X, MHBP[3 - 1].Y);
      
      MHBP[3 - 2] := Wpts2[0];
      MHBP[3 + 2] := new PointF(-MHBP[3 - 2].X, MHBP[3 - 2].Y);
      
      MHBP[3 - 3] := Npts[0];
      MHBP[3 + 3] := Npts[1];
      
      MHBP[7] := MHBP[0];
      
      StMapHB := PTHB(MHBP).Mlt(0.99);
      
      
      
      
      var PA_M := new TPoint[Spts.Length + 2];
      var PA_W := new TPoint[4];
      var PA_E := new TPoint[4];
      var i: integer;
      nP1 := Spts[0];nP2 := Spts[0];
      foreach var p in Spts + Npts do
      begin
        PA_M[i] := new TPoint(p.X, p.Y, +0 * WallHeigth, 0, 0);
        if p.X < nP1.X then nP1.X := p.X;
        if p.X > nP2.X then nP2.X := p.X;
        if p.Y < nP1.Y then nP1.Y := p.Y;
        if p.Y > nP2.Y then nP2.Y := p.Y;
        i += 1;
      end;
      i := 0;
      foreach var p in Wpts1 + Wpts2 do
      begin
        PA_W[i] := new TPoint(p.X, p.Y, +0 * WallHeigth, 0, 0);
        if p.X < nP1.X then nP1.X := p.X;
        if p.X > nP2.X then nP2.X := p.X;
        if p.Y < nP1.Y then nP1.Y := p.Y;
        if p.Y > nP2.Y then nP2.Y := p.Y;
        i += 1;
      end;
      i := 0;
      foreach var p in Epts1 + Epts2 do
      begin
        PA_E[i] := new TPoint(p.X, p.Y, +0 * WallHeigth, 0, 0);
        if p.X < nP1.X then nP1.X := p.X;
        if p.X > nP2.X then nP2.X := p.X;
        if p.Y < nP1.Y then nP1.Y := p.Y;
        if p.Y > nP2.Y then nP2.Y := p.Y;
        i += 1;
      end;
      
      dP1 := nP2 - nP1;
      var mlt := 256;
      TexSize := new Point(Ceil(dP1.X / 4 / mlt) shl 2, Ceil(dP1.Y / 4 / mlt) shl 2);
      
      for var i2: integer := 0 to PA_M.Length - 1 do
      begin
        PA_M[i2].TX := (PA_M[i2].X - nP1.X) / TexSize.X / mlt;
        PA_M[i2].TY := (PA_M[i2].Y - nP1.Y) / TexSize.Y / mlt;
      end;
      for var i2: integer := 0 to 3 do
      begin
        PA_W[i2].TX := (PA_W[i2].X - nP1.X) / TexSize.X / mlt;
        PA_W[i2].TY := (PA_W[i2].Y - nP1.Y) / TexSize.Y / mlt;
        PA_E[i2].TX := (PA_E[i2].X - nP1.X) / TexSize.X / mlt;
        PA_E[i2].TY := (PA_E[i2].Y - nP1.Y) / TexSize.Y / mlt;
      end;
      
      var Tex := RTG.NextFloor(TexSize.X, TexSize.Y);
      
      F_Wdo := new glTObject(GL_QUADS, Tex, PA_W);
      F_Edo := new glTObject(GL_QUADS, Tex, PA_E);
      
      F_Mdo := new glTObject(GL_POLYGON, Tex, PA_M);
      
      var w0: real := 0;
      var w1: real := 0;
      
      Tex := RTG.NextWall(128, 128);
      
      W_ECdo := HBTDOReverse(w0, w1, Tex, W_EChb);
      W_EOdo := HBTDOReverse(w0, w1, Tex, W_EOhb);
      
      W_Sdo := HBTDO(w0, w1, Tex, W_Shb);w0 := w1;
      
      W_WCdo := HBTDOReverse(w0, w1, Tex, W_WChb);
      W_WOdo := HBTDOReverse(w0, w1, Tex, W_WOhb);
      
      
      
      MapDrawObj1 := new glCObject(GL_POLYGON, 0, 0, 0, 0, new PPoint[0]);
      
    end;
    
    
    public const Name = 'GA.TSeg';
    
    public class function Rarity := StRarity[Name];
    
    public class function RarityOk := Random * Rarity < 1;
    
    public class function PosOk(var nC: ConnectionT): boolean;
    begin
      
      Pre.ZMin := 0;
      Pre.ZMax := 0;
      Result := PreInit(Pre, nC.Whose.DangeonIn, nC, (new ConnectionT[](
        new ConnectionT(0, E_Whb, nil, nil),
        new ConnectionT(0, E_Nhb, nil, nil),
        new ConnectionT(0, E_Ehb, nil, nil))).ToList, StMapHB.ToList.Mlt(0.099));//ToDo костыль!
      
    end;
    
    public constructor(var nC: ConnectionT);
    begin
      
      Wc := true;
      Ec := true;
      
      Init(Pre, nC, W_Shb + W_EOhb + W_WOhb, 3, 1);
      
      Connections[0].lbl := byte(0);
      Connections[1].lbl := byte(1);
      Connections[2].lbl := byte(2);
      
      DrawObj := W_WOdo + W_Sdo + W_EOdo;
      
      DrawObj.Add(F_Wdo);
      DrawObj.Add(F_Mdo);
      DrawObj.Add(F_Edo);
      
      MapDrawObj.Add(MapDrawObj1);
      
    end;
    
    
    public procedure CloseWay(C: ConnectionT); override;
    begin
      if Connections.Remove(C) then
      begin
        case byte(C.lbl) of
          1:
            begin
              var HB := Rotate(C.HB - new PointF(X, Y), -rot);
              DrawObj.Add(new glTObject(GL_QUADS, WPWTex, new TPoint[](
                new TPoint(HB.p1.X, HB.p1.Y, (C.Z - Z - 1) * RW, 0, 0),
                new TPoint(HB.p2.X, HB.p2.Y, (C.Z - Z - 1) * RW, 1, 0),
                new TPoint(HB.p2.X, HB.p2.Y, (C.Z - Z - 0) * RW, 1, 1),
                new TPoint(HB.p1.X, HB.p1.Y, (C.Z - Z - 0) * RW, 0, 1))));
              WallHitBox.Add(C.HB - new PointF(X, Y));
            end;
          0:
            begin
              Wc := false;
              DrawObj.Remove(F_Wdo);
              foreach var o in W_WOdo do DrawObj.Remove(o);
              foreach var o in W_WCdo do DrawObj.Add(o);
              WallHitBox := (W_Shb + (Ec ? W_EOhb : W_EChb) + W_WChb).Rotate(rot);
            end;
          2:
            begin
              Ec := false;
              DrawObj.Remove(F_Edo);
              foreach var o in W_EOdo do DrawObj.Remove(o);
              foreach var o in W_ECdo do DrawObj.Add(o);
              WallHitBox := (W_Shb + W_EChb + (Wc ? W_WOhb : W_WChb)).Rotate(rot);
            end;
        end;
      end else
        raise new System.ArgumentException('No such connection of this room');
    end;
    
    public function ClassName: string; override := Name;
  
  end;
  
  Treasury = sealed class(Segment)
    
    {$region Static Data}
    
    private class TW := 5 * RW;//ToDo костыль! class->const
    
    private class Pre: SegmentPreData;
    
    private class pts: array of PointF;
    
    private class w: real;
    private class WTex: Texture;
    
    {$region Hitboxes}
    
    private class E_Shb: HitBoxT;
    
    private class W_Nhb: List<HitBoxT>;
    
    private class StMapHB: List<HitBoxT>;
    
    {$endregion}
    
    {$region Draw Objects}
    
    private class StDrawObjs: List<glObject>;
    
    private class MapDrawObj1: glCObject;
    
    {$endregion}
    
    {$endregion}
    
    private class procedure Init;
    begin
      
      pts := new PointF[4];
      pts[0] := new PointF(-TW / 2, 0);
      pts[1] := new PointF(-TW / 2, -TW);
      pts[2] := new PointF(+TW / 2, -TW);
      pts[3] := new PointF(+TW / 2, 0);
      
      
      W_Nhb := PTHB(pts);
      StMapHB := W_Nhb.ToList;
      StMapHB.Capacity := 4;
      StMapHB.Add(new HitBoxT(pts[3], pts[0]));
      
      
      var w: real;
      WTex := RTG.NextWall(128, 128);
      StDrawObjs := HBTDO(0, w, WTex, W_Nhb);
      StDrawObjs.Capacity := 4;
      StDrawObjs.Add(new glTObject(GL_QUADS, RTG.NextFloor(128, 128), pts.ConvertAll(p -> new TPoint(p.X, p.Y, 0, (p.X - pts[0].X) / TW, (p.Y - pts[0].Y) / TW))));
      
      MapDrawObj1 := new glCObject(GL_QUADS, 1, 215 / 255, 0, 1, pts.Add3rd(0));//exit.w=TW?!
      
    end;
    
    
    public const Name = 'GA.Treasury';
    
    public class function Rarity := StRarity[Name];
    
    public class function RarityOk := Random * Rarity < 1;
    
    public class function PosOk(var nC: ConnectionT): boolean;
    begin
      
      w := nC.HB.w / 2;
      E_Shb := new HitBoxT(new PointF(+w, 0), new PointF(-w, 0));
      Pre.ZMin := 0;
      Pre.ZMax := 0;
      Result := PreInit(Pre, nC.Whose.DangeonIn, nC, Lst(
        new ConnectionT(0, E_Shb, nil, nil)), 0, StMapHB.ToList.Mlt(0.99));
      
    end;
    
    public constructor(var nC: ConnectionT);
    begin
      
      var W_hb := W_Nhb.ToList;
      W_hb.Capacity := 5;
      W_hb.Add(new HitBoxT(pts[3], new PointF(+w, 0)));
      W_hb.Add(new HitBoxT(new PointF(-w, 0), pts[0]));
      Init(Pre, nC, W_hb, 3, 1);
      
      DrawObj := StDrawObjs.ToList;
      DrawObj.Capacity := 5;
      DrawObj.Add(new glTObject(Rotate(W_hb[3], -rot), WTex));
      DrawObj.Add(new glTObject(Rotate(W_hb[4], -rot), WTex));
      
      MapDrawObj.Add(MapDrawObj1);
      
    end;
    
    
    public procedure CloseWay(C: ConnectionT); override;
    begin
      if Connections.Remove(C) then
        raise new System.ArgumentException('Этого не должно было случиться...') else
        raise new System.ArgumentException('No such connection of this room');
    end;
    
    public function ClassName: string; override := Name;
  
  end;
  
  StairTube = sealed abstract class(Segment)
    
    {$region Static Data}
    
    private const TW = 1 * RW;
    
    private class Pre: SegmentPreData;
    
    {$region Hitboxes}
    
    private class StMapHB: List<HitBoxT>;
    
    {$endregion}
    
    {$region Draw Objects}
    
    private class MapDrawObj1: glCObject;
    
    private class F_do: glObject;
    
    private class W_do: List<glObject>;
    
    {$endregion}
    
    {$endregion}
    
    private class procedure Init;
    begin
      
    end;
    
    
    public const Name = 'GA.StairTube';
    
    public class function Rarity := StRarity[Name];
    
    public class function RarityOk := Random * Rarity < 1;
    
    public class function PosOk(var nC: ConnectionT): boolean;
    begin
      
      Pre.ZMin := 0;
      Pre.ZMax := 0;
      Result := PreInit(Pre, nC.Whose.DangeonIn, nC, Lst(
        new ConnectionT(0, HitBoxT.Empty, nil, nil),
        new ConnectionT(0, HitBoxT.Empty, nil, nil)), 0, StMapHB.ToList.Mlt(0.99));
      
    end;
    
    public constructor(var nC: ConnectionT);
    begin
      
      Init(Pre, nC, new List<HitBoxT>, 0, 0);
      
      MapDrawObj.Add(MapDrawObj1);
      
    end;
    
    
    public function ClassName: string; override := Name;
  
  end;
  
  
  SegVoid = sealed abstract class(Segment)
    
    {$region Static Data}
    
    private const TW = 1 * RW;
    
    private class Pre: SegmentPreData;
    
    {$region Hitboxes}
    
    private class StMapHB: List<HitBoxT>;
    
    {$endregion}
    
    {$region Draw Objects}
    
    private class MapDrawObj1: glCObject;
    
    private class F_do: glObject;
    
    private class W_do: List<glObject>;
    
    {$endregion}
    
    {$endregion}
    
    private class procedure Init;
    begin
      
    end;
    
    
    public const Name = 'Void.SegVoid';
    
    public class function Rarity := StRarity[Name];
    
    public class function RarityOk := Random * Rarity < 1;
    
    public class function PosOk(var nC: ConnectionT): boolean;
    begin
      
      Pre.ZMin := 0;
      Pre.ZMax := 0;
      Result := PreInit(Pre, nC.Whose.DangeonIn, nC, Lst(
        new ConnectionT(0, HitBoxT.Empty, nil, nil),
        new ConnectionT(0, HitBoxT.Empty, nil, nil)), 0, StMapHB.ToList.Mlt(0.99));
      
    end;
    
    public constructor(var nC: ConnectionT);
    begin
      
      Init(Pre, nC, new List<HitBoxT>, 0, 0);
      
      MapDrawObj.Add(MapDrawObj1);
      
    end;
    
    
    public function ClassName: string; override := Name;
  
  end;

{$endregion}

function GetNewEntrance(self: Dangeon): Segment;
begin
  case Random(1) of
    0: Result := new EntranceT1(self);
  end;
end;

function GetRandSegment(var C: ConnectionT): Segment;
begin
  var someOk := false;
  
  var HallPosOk := Hall.PosOk(C);if HallPosOk then someOk := true;
  var CanalPosOk := Canal.PosOk(C);if CanalPosOk then someOk := true;
  var TSegPosOk := TSeg.PosOk(C);if TSegPosOk then someOk := true;
  var TreasuryPosOk := Treasury.PosOk(C);if TreasuryPosOk then someOk := true;
  
  if someOk then
    loop RoomGetAttempts do
    begin
      case Random(4) of
        
        0: if HallPosOk then     if Hall.RarityOk then     Result := new Hall(C);
        1: if CanalPosOk then    if Canal.RarityOk then    Result := new Canal(C);
        2: if TSegPosOk then     if TSeg.RarityOk then     Result := new TSeg(C);
        3: if TreasuryPosOk then if Treasury.RarityOk then Result := new Treasury(C);
      
      end;
      //if Result <> nil then while (GetKeyState(17) shr 7 = 1) and (GetKeyState(13) shr 7 = 1) do Sleep(10);
      //if Result <> nil then while (GetKeyState(17) shr 7 = 0) or (GetKeyState(13) shr 7 = 0) do Sleep(10);
      if Result <> nil then break;
    end else
    exit;
  
end;

begin
  
  TSeg.Init;
  Treasury.Init;
  StairTube.Init;
  
  Dangeon.GetNewEntrance := GetNewEntrance;
  Dangeon.GetRandSegment := GetRandSegment;

end.