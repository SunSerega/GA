{$define DEBUG}

unit RData;

uses CFData, TCData, glObjectData, REData, EData, GData, OpenGl, VData, AdvglObjData;

//                 -   N                  
//                     |                  
//                 W - M - E              
//                     |                  
//                     S   +              

type
  {$region Entrances}
  
  EntranceT1 = sealed class(Segment)
    
    {$region Static Data}
    
    {$region Hitboxes}
    
    private class W_Lhb := new HitBoxT(new vec2f(-0.500 * RW, +0.500 * RW), new vec2f(-0.500 * RW, -4.500 * RW));
    private class W_Rhb := new HitBoxT(new vec2f(+0.500 * RW, -4.500 * RW), new vec2f(+0.500 * RW, +0.500 * RW));
    
    private class E_Uhb := new HitBoxT(new vec2f(+0.500 * RW, +0.500 * RW), new vec2f(-0.500 * RW, +0.500 * RW));
    private class E_Dhb := new HitBoxT(new vec2f(-0.500 * RW, -4.500 * RW), new vec2f(+0.500 * RW, -4.500 * RW));
    
    private class StMapHB := new List<HitBoxT>(Arr(W_Lhb, W_Rhb, E_Uhb, E_Dhb));
    
    {$endregion}
    
    {$region Draw Points}
    
    private class W_Lpts := new Tvec3d[](
    new Tvec3d(-0.500 * RW, +0.500 * RW, +1 * RW - 0 * WallHeigth, 0.0, 1.0),
    new Tvec3d(-0.500 * RW, +0.500 * RW, +0 * RW - 1 * WallHeigth, 0.0, 0.0 + WallHeigth / RW / 2),
    new Tvec3d(-0.500 * RW, -0.500 * RW, +0 * RW - 1 * WallHeigth, 0.2, 0.0 + WallHeigth / RW / 2),
    new Tvec3d(-0.500 * RW, -3.500 * RW, +1 * RW - 1 * WallHeigth, 0.8, 0.5 + WallHeigth / RW / 2),
    new Tvec3d(-0.500 * RW, -4.500 * RW, +1 * RW - 1 * WallHeigth, 1.0, 0.5 + WallHeigth / RW / 2),
    new Tvec3d(-0.500 * RW, -4.500 * RW, +1 * RW - 0 * WallHeigth, 1.0, 1.0));
    
    private class W_Rpts := new Tvec3d[](
    new Tvec3d(+0.500 * RW, +0.500 * RW, +1 * RW - 0 * WallHeigth, 0.0, 1.0),
    new Tvec3d(+0.500 * RW, +0.500 * RW, +0 * RW - 1 * WallHeigth, 0.0, 0.0 + WallHeigth / RW / 2),
    new Tvec3d(+0.500 * RW, -0.500 * RW, +0 * RW - 1 * WallHeigth, 0.2, 0.0 + WallHeigth / RW / 2),
    new Tvec3d(+0.500 * RW, -3.500 * RW, +1 * RW - 1 * WallHeigth, 0.8, 0.5 + WallHeigth / RW / 2),
    new Tvec3d(+0.500 * RW, -4.500 * RW, +1 * RW - 1 * WallHeigth, 1.0, 0.5 + WallHeigth / RW / 2),
    new Tvec3d(+0.500 * RW, -4.500 * RW, +1 * RW - 0 * WallHeigth, 1.0, 1.0));
    
    private class F_1pts := new Tvec3d[](
    new Tvec3d(+0.500 * RW, +0.500 * RW, +0 * RW, 1, 1.0),
    new Tvec3d(+0.500 * RW, -0.500 * RW, +0 * RW, 1, 0.8),
    new Tvec3d(-0.500 * RW, -0.500 * RW, +0 * RW, 0, 0.8),
    new Tvec3d(-0.500 * RW, +0.500 * RW, +0 * RW, 0, 1.0));
    
    private class F_2pts := new Tvec3d[](
    new Tvec3d(+0.500 * RW, -0.500 * RW, +0 * RW, 1, 0.8),
    new Tvec3d(+0.500 * RW, -3.500 * RW, +1 * RW, 1, 0.2),
    new Tvec3d(-0.500 * RW, -3.500 * RW, +1 * RW, 0, 0.2),
    new Tvec3d(-0.500 * RW, -0.500 * RW, +0 * RW, 0, 0.8));
    
    private class F_3pts := new Tvec3d[](
    new Tvec3d(+0.500 * RW, -3.500 * RW, +1 * RW, 1, 0.2),
    new Tvec3d(+0.500 * RW, -4.500 * RW, +1 * RW, 1, 0.0),
    new Tvec3d(-0.500 * RW, -4.500 * RW, +1 * RW, 0, 0.0),
    new Tvec3d(-0.500 * RW, -3.500 * RW, +1 * RW, 0, 0.2));
    
    {$endregion}
    
    {$region DrawObj}
    
    MapDrawObj1 := new glCObject(GL_QUAD_STRIP, 0.5, 1.0, 0.5, 1, new vec3d[](
    new vec3d(+0.500 * RW, +0.500 * RW, +0 * RW),
    new vec3d(-0.500 * RW, +0.500 * RW, +0 * RW),
    new vec3d(+0.500 * RW, -0.500 * RW, +0 * RW),
    new vec3d(-0.500 * RW, -0.500 * RW, +0 * RW),
    new vec3d(+0.500 * RW, -3.500 * RW, +1 * RW),
    new vec3d(-0.500 * RW, -3.500 * RW, +1 * RW),
    new vec3d(+0.500 * RW, -4.500 * RW, +1 * RW),
    new vec3d(-0.500 * RW, -4.500 * RW, +1 * RW)));
    
    {$endregion}
    
    {$endregion}
    
    {$region var}
    
    private Fmtx1,Fmtx2:mtx3x3f;
    
    {$endregion}
    
    private class procedure Init;
    begin
      
    end;
    
    
    public function GetFloor(nCamera: CameraT): FloorData; override;
    begin
      
      var r := -((new vec2f(nCamera.X, nCamera.Y)).Rotate(-rot).Y / RW - 0.5);
      
      if r > 4 then Result := new FloorData(0, FloorFriction, new SLine(false, 0, RW)) else
      if r >= 1 then Result := new FloorData(rot, FloorFriction, new SLine(false, 1 / 3, (r - 1) / 3 * RW));
      
      //Result.rot := rot;
      //Result.slope.a := 1/Tan((r/2.5-1)*Pi/2);
      
      Result.SurfMtx := ((r >= 1) and (r <=4))?Fmtx2:Fmtx1;
      
    end;
    
    public constructor(D: Dangeon);
    begin
      
      rot := Random * Pi * 2;
      
      MapHitBox := StMapHB.ToList;
      
      Init(D, 0, 0, 0, 0, 1, 5, 2, 1);
      
      WallHitBox := (new List<HitboxT>(Arr(W_Lhb, W_Rhb))).Rotate(rot);
      Connections.Add(new ConnectionT(0, E_Uhb.Rotate(rot), self, nil));
      CloseWay(Connections[0]);
      Connections.Add(new ConnectionT(1, E_Dhb.Rotate(rot), self, nil));
      
      var FlTex := RTG.NextFloor(32, 128);
      //DrawObj.Add(new glTObject(GL_POLYGON, RTG.NextWall(1024, 256), W_Lpts));
      //DrawObj.Add(new glTObject(GL_POLYGON, RTG.NextWall(1024, 256), W_Rpts));
      
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
      
      Fmtx1 := new mtx3x3f(
       new vec3f(1,0,0),
       new vec3f(0,1,0),
       new vec3f(0,0,1));
     
     var dxy := 1/sqrt(10);
     var sr := Sin(-rot);
     var cr := Cos(-rot);
     var vz := new vec3f(sr*dxy, cr*dxy, dxy*3);
     
      Fmtx2.SetRow0(new vec3f(+cr,     -sr,     0                    ));
      Fmtx2.SetRow1(new vec3f(+vz.X*3, +vz.Y*3, -(vz.X*sr+vz.Y*cr)   ));
      Fmtx2.SetRow2(vz                                                );
//      Fmtx2 := new mtx3x3f(
//       ,
//       new vec3f(+vz.X*3, +vz.Y*3, -(vz.X*sr+vz.Y*cr)   ),
//       vz                                               );
      
    end;
    
    
    public function ClassName: string; override := 'GA.EntranceT1';
  
  end;
  
  {$endregion}
  
  {$region Rooms}
  
  Hall = sealed class(Segment)
    
    {$region Static Data}
    
    private class Pre: SegmentPreData;
    
    private class TW := 9;//ToDo костыль class -> const
    
    {$region Hitboxes}
    
    private class W_NOhb: List<HitBoxT>;
    private class W_EOhb: List<HitBoxT>;
    private class W_SOhb: List<HitBoxT>;
    private class W_WOhb: List<HitBoxT>;
    
    private class W_NChb: List<HitBoxT>;
    private class W_EChb: List<HitBoxT>;
    private class W_SChb: List<HitBoxT>;
    private class W_WChb: List<HitBoxT>;
    
    private class E_Nhb, E_Shb, E_Whb, E_Ehb: HitBoxT;
    
    private class StMapHB: List<HitBoxT>;
    
    {$endregion}
    
    {$region Draw Points}
    
    private class F_pts: array of Tvec3d;
    
    private class W_ENpts: array of Tvec3d;
    
    private class W_ESpts: array of Tvec3d;
    
    private class W_WNpts: array of Tvec3d;
    
    private class W_WSpts: array of Tvec3d;
    
    {$endregion}
    
    {$region Draw Objects}
    
    private class F_Mdo: glTObject;
    
    private class F_Ndo: glObject;
    private class F_Edo: glObject;
    private class F_Sdo: glObject;
    private class F_Wdo: glObject;
    
    
    private class W_NOdo: List<glObject>;
    private class W_EOdo: List<glObject>;
    private class W_SOdo: List<glObject>;
    private class W_WOdo: List<glObject>;
    
    private class W_NCdo: glObject;
    private class W_ECdo: glObject;
    private class W_SCdo: glObject;
    private class W_WCdo: glObject;
    
    
    private class M_Mdo: glCObject;
    
    private class M_Ndo: glCObject;
    private class M_Edo: glCObject;
    private class M_Sdo: glCObject;
    private class M_Wdo: glCObject;
    
    {$endregion}
    
    {$endregion}
    
    private cN, cE, cS, cW: boolean;
    
    private class procedure Init;
    begin
      
      var N1pr := Arr(new vec2f(-1.0, -0.5 * TW), new vec2f(-0.5, -(0.5 * TW + 1))).Mlt(RW);
      var N2pr := Arr(new vec2f(+0.5, -(0.5 * TW + 1)), new vec2f(+1.0, -0.5 * TW)).Mlt(RW);
      
      var NEpr := Arr(new vec2f(+0.5 * TW, -0.5 * TW)).Mlt(RW);
      
      var E1pr := Arr(new vec2f(+0.5 * TW, -1.0), new vec2f(+(0.5 * TW + 1), -0.5)).Mlt(RW);
      var E2pr := Arr(new vec2f(+(0.5 * TW + 1), +0.5), new vec2f(+0.5 * TW, +1.0)).Mlt(RW);
      
      var ESpr := Arr(new vec2f(+0.5 * TW, +0.5 * TW)).Mlt(RW);
      
      var S1pr := Arr(new vec2f(+1.0, +0.5 * TW), new vec2f(+0.5, +(0.5 * TW + 1))).Mlt(RW);
      var S2pr := Arr(new vec2f(-0.5, +(0.5 * TW + 1)), new vec2f(-1.0, +0.5 * TW)).Mlt(RW);
      
      var SWpr := Arr(new vec2f(-0.5 * TW, +0.5 * TW)).Mlt(RW);
      
      var W1pr := Arr(new vec2f(-0.5 * TW, +1.0), new vec2f(-(0.5 * TW + 1), +0.5)).Mlt(RW);
      var W2pr := Arr(new vec2f(-(0.5 * TW + 1), -0.5), new vec2f(-0.5 * TW, -1.0)).Mlt(RW);
      
      var WNpr := Arr(new vec2f(-0.5 * TW, -0.5 * TW)).Mlt(RW);
      
      
      
      W_NOhb := PTHB(WNpr + N1pr) + PTHB(N2pr + NEpr);
      W_EOhb := PTHB(NEpr + E1pr) + PTHB(E2pr + ESpr);
      W_SOhb := PTHB(ESpr + S1pr) + PTHB(S2pr + SWpr);
      W_WOhb := PTHB(SWpr + W1pr) + PTHB(W2pr + WNpr);
      
      W_NChb := PTHB(WNpr + NEpr);
      W_EChb := PTHB(NEpr + ESpr);
      W_SChb := PTHB(ESpr + SWpr);
      W_WChb := PTHB(SWpr + WNpr);
      
      E_Nhb := new HitBoxT(N1pr[1], N2pr[0]);AddRandW(E_Nhb.w, Rarity);
      E_Ehb := new HitBoxT(E1pr[1], E2pr[0]);AddRandW(E_Ehb.w, Rarity);
      E_Shb := new HitBoxT(S1pr[1], S2pr[0]);AddRandW(E_Shb.w, Rarity);
      E_Whb := new HitBoxT(W1pr[1], W2pr[0]);AddRandW(E_Whb.w, Rarity);
      
      StMapHB := Lst(
        new HitBoxT(NEpr[0], ESpr[0]),
        new HitBoxT(ESpr[0], SWpr[0]),
        new HitBoxT(SWpr[0], WNpr[0]),
        new HitBoxT(WNpr[0], NEpr[0]));
      
      
      
      var Mpts := (NEpr + ESpr + SWpr + WNpr).ToVec3dArr;
      
      var Npts := (N1pr + N2pr).ToVec3dArr;
      var Epts := (E1pr + E2pr).ToVec3dArr;
      var Spts := (S1pr + S2pr).ToVec3dArr;
      var Wpts := (W1pr + W2pr).ToVec3dArr;
      
      
      
      var FTex := RTG.NextFloor(32 * TW, 32 * TW);
      var W_NETex := RTG.NextWall(128, 128);
      var W_ESTex := RTG.NextWall(128, 128);
      var W_SWTex := RTG.NextWall(128, 128);
      var W_WNTex := RTG.NextWall(128, 128);
      
      F_Mdo := new glTObject(GL_QUADS, FTex, Mpts.ConvertAll(p -> new Tvec3d(p.X, p.Y, p.Z, p.X / TW / RW, p.Y / TW / RW)));
      
      F_Ndo := new glTObject(GL_QUADS, FTex, Npts.ConvertAll(p -> new Tvec3d(p.X, p.Y, p.Z, p.X / TW / RW, p.Y / TW / RW)));
      F_Edo := new glTObject(GL_QUADS, FTex, Epts.ConvertAll(p -> new Tvec3d(p.X, p.Y, p.Z, p.X / TW / RW, p.Y / TW / RW)));
      F_Sdo := new glTObject(GL_QUADS, FTex, Spts.ConvertAll(p -> new Tvec3d(p.X, p.Y, p.Z, p.X / TW / RW, p.Y / TW / RW)));
      F_Wdo := new glTObject(GL_QUADS, FTex, Wpts.ConvertAll(p -> new Tvec3d(p.X, p.Y, p.Z, p.X / TW / RW, p.Y / TW / RW)));
      
      
      var w: real;
      
      W_NOdo := HBTDO(0, w, W_WNTex, PTHB(WNpr + N1pr)) + HBTDOReverse(0, w, W_NETex, PTHB(N2pr + NEpr));
      W_EOdo := HBTDO(0, w, W_NETex, PTHB(NEpr + E1pr)) + HBTDOReverse(0, w, W_ESTex, PTHB(E2pr + ESpr));
      W_SOdo := HBTDO(0, w, W_ESTex, PTHB(ESpr + S1pr)) + HBTDOReverse(0, w, W_SWTex, PTHB(S2pr + SWpr));
      W_WOdo := HBTDO(0, w, W_SWTex, PTHB(SWpr + W1pr)) + HBTDOReverse(0, w, W_WNTex, PTHB(W2pr + WNpr));
      
      W_NCdo := HBTDO(0, w, W_WNTex, PTHB(WNpr + NEpr)).First;
      W_ECdo := HBTDO(0, w, W_NETex, PTHB(NEpr + ESpr)).First;
      W_SCdo := HBTDO(0, w, W_ESTex, PTHB(ESpr + SWpr)).First;
      W_WCdo := HBTDO(0, w, W_SWTex, PTHB(SWpr + WNpr)).First;
      
      
      M_Mdo := new glCObject(GL_QUADS, 0.5, 0.5, 0.5, 1, Mpts);
      
      M_Ndo := new glCObject(GL_QUADS, 0.5, 0.5, 0.5, 1, Npts);
      M_Edo := new glCObject(GL_QUADS, 0.5, 0.5, 0.5, 1, Epts);
      M_Sdo := new glCObject(GL_QUADS, 0.5, 0.5, 0.5, 1, Spts);
      M_Wdo := new glCObject(GL_QUADS, 0.5, 0.5, 0.5, 1, Wpts);
      
    end;
    
    
    public const Name = 'GA.Hall';
    
    public class function Rarity := StRarity[Name];
    
    public class function RarityOk := Random * Rarity < 1;
    
    public class function PosOk(var nC: ConnectionT): boolean;
    begin
      
      Pre.ZMin := 0;
      Pre.ZMax := 0;
      Result := PreInit(Pre, nC.Whose.DangeonIn, nC, (new ConnectionT[](
        new ConnectionT(0, E_Nhb, nil, nil),
        new ConnectionT(0, E_Ehb, nil, nil),
        new ConnectionT(0, E_Shb, nil, nil),
        new ConnectionT(0, E_Whb, nil, nil))).ToList, StMapHB.ToList);
      
    end;
    
    public constructor(var nC: ConnectionT);
    begin
      
      (cN, cE, cS, cW) := (true, true, true, true);
      
      Init(Pre, nC, W_NOhb + W_EOhb + W_SOhb + W_WOhb, 5 + 16, 5);
      
      for var i: byte := 0 to 3 do Connections[i].lbl := i;
      
      
      
      DrawObj.Add(F_Mdo);
      
      DrawObj.Add(F_Ndo);
      DrawObj.Add(F_Edo);
      DrawObj.Add(F_Wdo);
      DrawObj.Add(F_Sdo);
      
      
      DrawObj.AddRange(W_NOdo);
      DrawObj.AddRange(W_EOdo);
      DrawObj.AddRange(W_SOdo);
      DrawObj.AddRange(W_WOdo);
      
      
      
      MapDrawObj.Add(M_Mdo);
      
      MapDrawObj.Add(M_Ndo);
      MapDrawObj.Add(M_Edo);
      MapDrawObj.Add(M_Sdo);
      MapDrawObj.Add(M_Wdo);
      
      
      Entities.Add(new Slime(5, vec2f.Empty, self));
      
      //DrawObj.Add(new PIcosahedron(0,0,-25,50,50,30,0,0.5,0,0.9,0,0.05,0,0.05,4));
      
    end;
    
    
    public procedure CloseWay(C: ConnectionT); override;
    begin
      if not Connections.Remove(C) then raise new System.ArgumentException('No such connection of this room');
      
      case byte(C.lbl) of
        0:
          begin
            cN := false;
            WallHitBox := ((cN ? W_NOhb : W_NChb) + (cE ? W_EOhb : W_EChb) + (cS ? W_SOhb : W_SChb) + (cW ? W_WOhb : W_WChb)).Rotate(rot);
            DrawObj.RemoveRange(W_NOdo);
            DrawObj.Add(W_NCdo);
            DrawObj.Remove(F_Ndo);
            MapDrawObj.Remove(M_Ndo);
          end;
        1:
          begin
            cE := false;
            WallHitBox := ((cN ? W_NOhb : W_NChb) + (cE ? W_EOhb : W_EChb) + (cS ? W_SOhb : W_SChb) + (cW ? W_WOhb : W_WChb)).Rotate(rot);
            DrawObj.RemoveRange(W_EOdo);
            DrawObj.Add(W_ECdo);
            DrawObj.Remove(F_Edo);
            MapDrawObj.Remove(M_Edo);
          end;
        2:
          begin
            cS := false;
            WallHitBox := ((cN ? W_NOhb : W_NChb) + (cE ? W_EOhb : W_EChb) + (cS ? W_SOhb : W_SChb) + (cW ? W_WOhb : W_WChb)).Rotate(rot);
            DrawObj.RemoveRange(W_SOdo);
            DrawObj.Add(W_SCdo);
            DrawObj.Remove(F_Sdo);
            MapDrawObj.Remove(M_Sdo);
          end;
        3:
          begin
            cW := false;
            WallHitBox := ((cN ? W_NOhb : W_NChb) + (cE ? W_EOhb : W_EChb) + (cS ? W_SOhb : W_SChb) + (cW ? W_WOhb : W_WChb)).Rotate(rot);
            DrawObj.RemoveRange(W_WOdo);
            DrawObj.Add(W_WCdo);
            DrawObj.Remove(F_Wdo);
            MapDrawObj.Remove(M_Wdo);
          end;
      end;
      
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
    
    private class Epr: array of vec2f;
    private class Wpr: array of vec2f;
    
    private class dZ: smallint;
  
    {$endregion}
  
  
  private 
    nZ: smallint;
    HB1, HB2: HitBoxT;
    p1, p2: vec2f;
    LD1, LD2: SLine;
    SlopeA: Single;
    
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
      
      var dXY := (new vec2f(dX, dY)).Rotate(nC.rot) + SS;
      dX := dXY.X;
      dY := dXY.Y;
      
      var DangeonIn := nC.Whose.DangeonIn;
      var Segs := new List<Segment>;
      var Conns2 := new List<ConnectionT>;
      for var X := -1 to +1 do
        for var Y := -1 to +1 do
        begin
          var P := new vec3i(Round(X / DangeonIn.RegW) + X, Round(Y / DangeonIn.RegW) + Y, dZ);
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
        CF2 := new ConnectionT(dZ, new HitBoxT(GetRandW, Pi + nC.rot + Rand(Pi / 6), dXY), nil, nil);
      
      if (new HitBoxT(CF2.HB.Senter, nC.HB.Senter)).w < ML then exit;
      
      Epr := new vec2f[4];Epr[0] := CF2.HB.p1 - SS;Epr[3] := nC.HB.p2 - SS;
      Wpr := new vec2f[4];Wpr[0] := nC.HB.p1 - SS;Wpr[3] := CF2.HB.p2 - SS;
      
      begin
        var P := CF2.HB.Senter - SS;
        var rot := (new HitBoxT(CF2.HB.Senter, nC.HB.Senter)).rot + Pi / 2;
        P.X += CL * Sin(rot);
        P.Y -= CL * Cos(rot);
        Epr[1] := new vec2f(P.X - TW / 2 * Cos(rot), P.Y - TW / 2 * Sin(rot));
        Wpr[2] := new vec2f(P.X + TW / 2 * Cos(rot), P.Y + TW / 2 * Sin(rot));
        rot += Pi;
        P := new vec2f(
         CL * Sin(rot),
        -CL * Cos(rot));
        Wpr[1] := new vec2f(P.X - TW / 2 * Cos(rot), P.Y - TW / 2 * Sin(rot));
        Epr[2] := new vec2f(P.X + TW / 2 * Cos(rot), P.Y + TW / 2 * Sin(rot));
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
        SlopeA := nZ / sqrt(sqr(p1.X - p2.X) + sqr(p1.Y - p2.Y));
        
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
      
      DrawObj.Add(new glTObject(GL_QUAD_STRIP, RTG.NextWall(TexW, TexW), new Tvec3d[](
        new Tvec3d(Epr[0].X, Epr[0].Y, -1 * WallHeigth + nZ * RW, 0, 0),
        new Tvec3d(Epr[0].X, Epr[0].Y, -0 * WallHeigth + nZ * RW, 0, 1),
        new Tvec3d(Epr[1].X, Epr[1].Y, -1 * WallHeigth + nZ * RW, w1, 0),
        new Tvec3d(Epr[1].X, Epr[1].Y, -0 * WallHeigth + nZ * RW, w1, 1),
        new Tvec3d(Epr[2].X, Epr[2].Y, -1 * WallHeigth, w1 + w2, 0),
        new Tvec3d(Epr[2].X, Epr[2].Y, -0 * WallHeigth, w1 + w2, 1),
        new Tvec3d(Epr[3].X, Epr[3].Y, -1 * WallHeigth, w, 0),
        new Tvec3d(Epr[3].X, Epr[3].Y, -0 * WallHeigth, w, 1))));
      
      w1 := W_Whb[0].w / WallHeigth;
      w2 := W_Whb[1].w / WallHeigth;
      w := w1 + w2 + W_Whb[2].w / WallHeigth;
      
      DrawObj.Add(new glTObject(GL_QUAD_STRIP, RTG.NextWall(TexW, TexW), new Tvec3d[](
        new Tvec3d(Wpr[0].X, Wpr[0].Y, -1 * WallHeigth, 0, 0),
        new Tvec3d(Wpr[0].X, Wpr[0].Y, -0 * WallHeigth, 0, 1),
        new Tvec3d(Wpr[1].X, Wpr[1].Y, -1 * WallHeigth, w1, 0),
        new Tvec3d(Wpr[1].X, Wpr[1].Y, -0 * WallHeigth, w1, 1),
        new Tvec3d(Wpr[2].X, Wpr[2].Y, -1 * WallHeigth + nZ * RW, w1 + w2, 0),
        new Tvec3d(Wpr[2].X, Wpr[2].Y, -0 * WallHeigth + nZ * RW, w1 + w2, 1),
        new Tvec3d(Wpr[3].X, Wpr[3].Y, -1 * WallHeigth + nZ * RW, w, 0),
        new Tvec3d(Wpr[3].X, Wpr[3].Y, -0 * WallHeigth + nZ * RW, w, 1))));
      
      var pts := (Wpr + Epr).ToVec3dArr;
      for var i := 2 to 5 do
        pts[i].Z := dZ * RW;
      
      MapDrawObj.Add(new glCObject(GL_POLYGON, 0.5, 0, 0.5, 1, pts));
      
      var Tpts := new Tvec3d[pts.Length];
      for var i := 0 to pts.Length - 1 do
        Tpts[i] := new Tvec3d(pts[i].X, pts[i].Y, pts[i].Z, (pts[i].X - pts[0].X) / RW / 5, (pts[i].Y - pts[0].Y) / RW / 5);
      DrawObj.Add(new glTObject(GL_POLYGON, RTG.NextFloor(TexW, TexW), Tpts));
      
    end;
    
    
    public function GetFloor(nCamera: CameraT): FloorData; override;
    begin
      if nZ = 0 then exit;
      var pX := nCamera.X;
      var pY := nCamera.Y;
      var pt := new vec2f(pX, pY);
      if OnLeft(HB1.p1, HB1.p2, pt) then exit else
      if OnLeft(HB2.p1, HB2.p2, pt) then Result := new FloorData(0, FloorFriction, new SLine(false, 0, nZ * RW)) else
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
          Result := new FloorData(rot, FloorFriction, new SLine(false, SlopeA, (Z1 + (Z2 - Z1) * (Res.Y - pMin) / (pMax - pMin)) * RW));
          
        end else begin
          
          var pMin := p1.X;var pMax := p2.X;
          if pMin > pMax then
          begin
            Swap(Z1, Z2);
            Swap(pMin, pMax);
          end;
          Result := new FloorData(rot, FloorFriction, new SLine(false, SlopeA, (Z1 + (Z2 - Z1) * (Res.X - pMin) / (pMax - pMin)) * RW));
          
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
    
    
    private class TexSize: vec2i;
    
    private class Spts, Npts: array of vec2f;
    private class Wpts1, Wpts2: array of vec2f;
    private class Epts1, Epts2: array of vec2f;
    
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
      Spts := new vec2f[SPC - SPS];
      for var i := 0 to Spts.Length - 1 do
      begin
        Spts[i] := new vec2f(CW * Sin(ang), -CW * Cos(ang));
        ang += APCP;
      end;
      
      Npts := new vec2f[2];
      Npts[0] := new vec2f(-Spts[0].X, Spts[0].Y - TL1 - TL2);
      //Npts[0] := new PointF(-RW/2, Spts[0].Y - TL1 - TL2);
      Npts[1] := new vec2f(-Npts[0].X, Npts[0].Y);
      
      
      var nP1, nP2, dP1, dP2: vec2f;
      
      nP1 := new vec2f(-Spts[0].X, Spts[0].Y - TL1);
      nP2 := new vec2f(nP1.X - STL * Cos(STA), nP1.Y + STL * Sin(STA));
      dP1 := new vec2f(0, STWd2);
      dP2 := new vec2f(TW * Sin(STA) / 2, TW * Cos(STA) / 2);
      
      Wpts1 := new vec2f[2];Epts1 := new vec2f[2];
      Wpts2 := new vec2f[2];Epts2 := new vec2f[2];
      
      
      Wpts1[0] := nP1 + dP1;
      Wpts1[1] := nP2 + dP2;
      
      Wpts2[1] := nP1 - dP1;
      Wpts2[0] := nP2 - dP2;
      
      
      Epts1[0] := new vec2f(-Wpts2[1].X, Wpts2[1].Y);
      Epts1[1] := new vec2f(-Wpts2[0].X, Wpts2[0].Y);
      
      Epts2[0] := new vec2f(-Wpts1[1].X, Wpts1[1].Y);
      Epts2[1] := new vec2f(-Wpts1[0].X, Wpts1[0].Y);
      
      
      
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
      
      AddRandW(E_Whb.w, Rarity);
      AddRandW(E_Ehb.w, Rarity);
      AddRandW(E_Nhb.w, Rarity);
      
      
      var MHBP := new vec2f[7 + 1];
      
      MHBP[3 + 0] := new vec2f(0, CW);
      
      var k_a := Max(-Tan(APCP), (CW - Wpts1[1].Y) / Wpts1[1].X);
      MHBP[3 - 1] := new vec2f(Wpts2[0].X, CW - Wpts2[0].X * k_a);
      MHBP[3 + 1] := new vec2f(-MHBP[3 - 1].X, MHBP[3 - 1].Y);
      
      MHBP[3 - 2] := Wpts2[0];
      MHBP[3 + 2] := new vec2f(-MHBP[3 - 2].X, MHBP[3 - 2].Y);
      
      MHBP[3 - 3] := Npts[0];
      MHBP[3 + 3] := Npts[1];
      
      MHBP[7] := MHBP[0];
      
      StMapHB := PTHB(MHBP).Mlt(0.99);
      
      
      
      
      var PA_M := new Tvec3d[Spts.Length + 2];
      var PA_W := new Tvec3d[4];
      var PA_E := new Tvec3d[4];
      var i: integer;
      nP1 := Spts[0];nP2 := Spts[0];
      foreach var p in Spts + Npts do
      begin
        PA_M[i] := new Tvec3d(p.X, p.Y, +0 * WallHeigth, 0, 0);
        if p.X < nP1.X then nP1.X := p.X;
        if p.X > nP2.X then nP2.X := p.X;
        if p.Y < nP1.Y then nP1.Y := p.Y;
        if p.Y > nP2.Y then nP2.Y := p.Y;
        i += 1;
      end;
      i := 0;
      foreach var p in Wpts1 + Wpts2 do
      begin
        PA_W[i] := new Tvec3d(p.X, p.Y, +0 * WallHeigth, 0, 0);
        if p.X < nP1.X then nP1.X := p.X;
        if p.X > nP2.X then nP2.X := p.X;
        if p.Y < nP1.Y then nP1.Y := p.Y;
        if p.Y > nP2.Y then nP2.Y := p.Y;
        i += 1;
      end;
      i := 0;
      foreach var p in Epts1 + Epts2 do
      begin
        PA_E[i] := new Tvec3d(p.X, p.Y, +0 * WallHeigth, 0, 0);
        if p.X < nP1.X then nP1.X := p.X;
        if p.X > nP2.X then nP2.X := p.X;
        if p.Y < nP1.Y then nP1.Y := p.Y;
        if p.Y > nP2.Y then nP2.Y := p.Y;
        i += 1;
      end;
      
      dP1 := nP2 - nP1;
      var mlt := 256;
      TexSize := new vec2i(Ceil(dP1.X / 4 / mlt) shl 2, Ceil(dP1.Y / 4 / mlt) shl 2);
      
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
      
      
      
      MapDrawObj1 := new glCObject(GL_POLYGON, 0, 0, 0, 0, new vec3d[0]);
      
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
      
      if not Connections.Remove(C) then raise new System.ArgumentException('No such connection of this room');
      
      case byte(C.lbl) of
        1:
          begin
            var HB := (C.HB - new vec2f(X, Y)).Rotate(-rot);
            DrawObj.Add(new glTObject(GL_QUADS, WPWTex, new Tvec3d[](
                new Tvec3d(HB.p1.X, HB.p1.Y, (C.Z - Z - 1) * RW, 0, 0),
                new Tvec3d(HB.p2.X, HB.p2.Y, (C.Z - Z - 1) * RW, 1, 0),
                new Tvec3d(HB.p2.X, HB.p2.Y, (C.Z - Z - 0) * RW, 1, 1),
                new Tvec3d(HB.p1.X, HB.p1.Y, (C.Z - Z - 0) * RW, 0, 1))));
            WallHitBox.Add(C.HB - new vec2f(X, Y));
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
      
    end;
    
    public function ClassName: string; override := Name;
  
  end;
  
  Treasury = sealed class(Segment)
    
    {$region Static Data}
    
    private class TW := 5 * RW;//ToDo костыль! class->const
    private class MinW: word := Round(TW / 2);
    
    private class Pre: SegmentPreData;
    
    private class pts: array of vec2f;
    
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
      
      pts := new vec2f[4];
      pts[0] := new vec2f(-TW / 2, 0);
      pts[1] := new vec2f(-TW / 2, -TW);
      pts[2] := new vec2f(+TW / 2, -TW);
      pts[3] := new vec2f(+TW / 2, 0);
      
      
      W_Nhb := PTHB(pts);
      StMapHB := W_Nhb.ToList;
      StMapHB.Capacity := 4;
      StMapHB.Add(new HitBoxT(pts[3], pts[0]));
      
      
      var w: real;
      WTex := RTG.NextWall(128, 128);
      StDrawObjs := HBTDO(0, w, WTex, W_Nhb);
      StDrawObjs.Capacity := 4;
      StDrawObjs.Add(new glTObject(GL_QUADS, RTG.NextFloor(128, 128), pts.ConvertAll(p -> new Tvec3d(p.X, p.Y, 0, (p.X - pts[0].X) / TW, (p.Y - pts[0].Y) / TW))));
      
      MapDrawObj1 := new glCObject(GL_QUADS, 1, 215 / 255, 0, 1, pts.ToVec3dArr);
      
    end;
    
    
    public const Name = 'GA.Treasury';
    
    public class function Rarity := StRarity[Name];
    
    public class function RarityOk := Random * Rarity < 1;
    
    public class function PosOk(var nC: ConnectionT): boolean;
    begin
      
      if nC.w < MinW then exit;
      w := nC.HB.w / 2;
      E_Shb := new HitBoxT(new vec2f(+w, 0), new vec2f(-w, 0));
      Pre.ZMin := 0;
      Pre.ZMax := 0;
      Result := PreInit(Pre, nC.Whose.DangeonIn, nC, Lst(
        new ConnectionT(0, E_Shb, nil, nil)), 0, StMapHB.ToList.Mlt(0.99));
      
    end;
    
    public constructor(var nC: ConnectionT);
    begin
      
      var W_hb := W_Nhb.ToList;
      W_hb.Capacity := 5;
      W_hb.Add(new HitBoxT(pts[3], new vec2f(+w, 0)));
      W_hb.Add(new HitBoxT(new vec2f(-w, 0), pts[0]));
      Init(Pre, nC, W_hb, 3, 1);
      
      DrawObj := StDrawObjs.ToList;
      DrawObj.Capacity := 5;
      DrawObj.Add(new glTObject(W_hb[3].Rotate(-rot), WTex));
      DrawObj.Add(new glTObject(W_hb[4].Rotate(-rot), WTex));
      
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
  
  StairTube = sealed class(Segment)
    
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
  
  
  SegVoid = sealed class(Segment)
    
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
  //var TSegPosOk := TSeg.PosOk(C);if TSegPosOk then someOk := true;
  var TreasuryPosOk := Treasury.PosOk(C);if TreasuryPosOk then someOk := true;
  
  if someOk then
    loop RoomGetAttempts do
    begin
      case Random(4) of
        
        0: if HallPosOk then     if Hall.RarityOk then     Result := new Hall(C);
        1: if CanalPosOk then    if Canal.RarityOk then    Result := new Canal(C);
        //2: if TSegPosOk then     if TSeg.RarityOk then     Result := new TSeg(C);
        3: if TreasuryPosOk then if Treasury.RarityOk then Result := new Treasury(C);
      
      end;
      //if Result <> nil then while (GetKeyState(17) shr 7 = 1) and (GetKeyState(13) shr 7 = 1) do Sleep(10);
      //if Result <> nil then while (GetKeyState(17) shr 7 = 0) or (GetKeyState(13) shr 7 = 0) do Sleep(10);
      if Result <> nil then break;
    end else
    exit;
  
end;

begin
  
  Hall.Init;
  //TSeg.Init;
  Treasury.Init;
  StairTube.Init;
  
  Dangeon.GetNewEntrance := GetNewEntrance;
  Dangeon.GetRandSegment := GetRandSegment;

end.