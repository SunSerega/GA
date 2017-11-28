unit VData;

uses REData, glObjectData, CFData, System.Drawing, GData;

var
  TempTex: Texture;
  
  PlayerR := 25.0;
  PlayerDangeon: Dangeon;
  CR: array of Segment;
  
  BufferIOThread: System.Threading.Thread;
  BufferData := new byte[1](0);
  
  CameraMovementThread: System.Threading.Thread;
  MP: Point;
  DrawMouse := true;
  SenterScreen: Point;
  
  LFF := false;
  
  CAct:byte;
  
  Camera := new CameraT;
  
  M0B1rect := new RectangleF(50, WH / 2 - 11 / 30 * WH, WW / 3.2, WH / 7.5);
  M0B2rect := new RectangleF(50, WH / 2 - 05 / 30 * WH, WW / 3.2, WH / 7.5);
  M0B3rect := new RectangleF(50, WH / 2 + 01 / 30 * WH, WW / 3.2, WH / 7.5);
  M0B4rect := new RectangleF(50, WH / 2 + 07 / 30 * WH, WW / 3.2, WH / 7.5);
  
  M0B1: glObject;
  M0B2: glObject;
  M0B3: glObject;
  M0B4: glObject;
  
  CurrentHitBox: List<HitBoxT>;
  
  Weapon, nWeapon: byte;
  //How To Add:
  //1:  var WepN
  //2:  Draw.3D->WepN
  //3:  Calc.Weapon->Select
  //4:  Calc.Weapon->WepN
  
  Map3DRotX := Pi / 2;
  Map3DRotY := Pi / 4;
  
  Map3DScale := 15.0;
  
  {
  Wep1: array of Wep1zv;
  Wep1End := new PointF[10](new PointF(0, 0), new PointF(0, 15), new PointF(-5, 5), new PointF(-15, 0), new PointF(-5, -5), new PointF(0, -15), new PointF(5, -5), new PointF(15, 0), new PointF(5, 5), new PointF(0, 15));
  Wep1L := 60;
  
  Wep2rot: Single;
  Wep2L, Wep2dL: Single;
  Wep2Grip := new PointF[10](new PointF(0.6, 0.15), new PointF(0.6, 0.35), new PointF(0.3, 0.35), new PointF(0.3, 0.1), new PointF(0, 0.1), new PointF(0, -0.1), new PointF(0.3, -0.1), new PointF(0.3, -0.35), new PointF(0.6, -0.35), new PointF(0.6, -0.15));
  Wep2Blade := new PointF[3](new PointF(0.6, -0.15), new PointF(0.9, 0), new PointF(0.6, 0.15));
  nWep2: array of PointF;
  
  Wep3 := new PointF[3](new PointF(0, -3), new PointF(0, 3), new PointF(25, 0));
  Wep3p2 := new PointF[6](new PointF(20, -10), new PointF(24, 0), new PointF(20, 10), new PointF(21, 10), new PointF(26, 0), new PointF(21, -10));
  Wep3p3 := Copy(Wep3p2);
  Wep3Charge: Single;
  Wep3fly := false;
  Wep3Proj: Wep3ProjT;
  Wep3Rocket := new PointF[7](new PointF(-20, -6), new PointF(0, -6), new PointF(11, -2), new PointF(12, 0), new PointF(11, 2), new PointF(0, 6), new PointF(-20, 6));
  Wep3Booms := new Wep3Boom[0];
  {}
  
  TT:=new TimeReader;
  //DT:=newTimeReader;
  //CT:=newTimeReader;
  RGT:=new TimeReader;

end.