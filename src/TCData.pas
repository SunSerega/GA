unit TCData;

uses GData,CFData;

{$region Tex Gen Func Tryes...}

var
  CM1 := 3;
  CM2 := 2;

  {

  function GetStWallTex(w,h:cardinal) :=  new Texture(w,h,Texture.GetPerlinNoisePaternBytes1(3,w,h,0.7,0.7,0.7,0.005*CM1,0.020*CM1,0.040*CM1,1,16),false,true);

  function GetStFloorTex(w,h:cardinal) := new Texture(w,h,Texture.GetPerlinNoisePaternBytes1(3,w,h,0.5,0.5,0.5,0.005*CM2,0.020*CM2,0.040*CM2,1,16),false,true);

  {

  function GetStWallTex(w,h:cardinal) := new Texture(w,h,Texture.GetPaternBytes(w*h*3,i->((i div 3 div w + i div 3 mod w) mod 2=0) and (i div 3 mod 3 = i mod 3)?255:0),false,true);

  function GetStFloorTex(w,h:cardinal) := new Texture(w,h,Texture.GetPaternBytes(w*h*3,i->((i div 3 div w + i div 3 mod w) mod 2=0) and (i div 3 mod 3 = i mod 3)?255:0),false,true);

  {

  function GetStWallTex(w,h:cardinal) := new Texture(w,h,Texture.GetPaternBytes(w*h*3,i->((i div 3 div w + i div 3 mod w) mod 2=0) and (i mod 3 = (i div 18+i div w div 18) mod 3)?255:0),false,true);

  function GetStFloorTex(w,h:cardinal) := GetStWallTex(w,h);

  {}

  //function GetStWallTex(w, h: cardinal) :=  new Texture(w, h, Texture.GetPerlinNoisePaternBytes2(w, h, 0.7, 0.7, 0.7, 0.005 * CM1, 0.020 * CM1, 0.040 * CM1, 0.1, 3), false, true);

//function GetStFloorTex(w, h: cardinal) := new Texture(w, h, Texture.GetPerlinNoisePaternBytes2(w, h, 0.5, 0.5, 0.5, 0.005 * CM2, 0.020 * CM2, 0.040 * CM2, 0.1, 3), false, true);

function GetStFloorTex(w, h: cardinal): Texture;
begin
  try
    Result := new Texture(w, h, GetPerlinNoisePaternBytes2(w, h, 0.5, 0.5, 0.5, 0.005 * CM2, 0.020 * CM2, 0.040 * CM2, 0.1, 3), false, true);
  except
    on e: System.Exception do
      SaveError('GetStFloorTex:', e);
  end;
end;

  {}

function GetStWallTex_test1(w, h: cardinal): Texture;
begin
  var LT := System.DateTime.Now;
  
  var ba := new byte[w * h * 3];
  var sa := new Single[w * h * 3];
  var pc := Round(w * h / 40);
  pc := 1;
  var pts := new List<Cvec3d>(pc);
  loop pc do
    pts.Add(new Cvec3d(Random(w), Random(h), 0, 0.7 + Rand(0.0), 0.7 + Rand(0.0), 0.7 + Rand(0.0), 0));
  var ms: Single := Single.PositiveInfinity;
  for x: cardinal := 0 to w - 1 do
    for y: cardinal := 0 to h - 1 do
    begin
      var i: integer := (x + y * w) * 3;
      sa[i] := 0;
      var nP: Cvec3d;
      foreach var P in pts do
      begin
        //var r:Single := sqrt(sqr(P.X-x)+sqr(P.Y-y));
        var r: Single := 1 / (sqr(P.X - x + 0.5) + sqr(P.Y - y + 0.5));
        if r > Single.MaxValue / 10 then
          r := Single.MaxValue / 10;
        //var r:Single := Power(sqr(P.X-x)+sqr(P.Y-y),1);
        //var r := abs(P.X-x)+abs(P.Y-y);
        if r > sa[i] then
        begin
          sa[i] := r;
          nP := P;
        end;
        if sa[i] < ms then ms := sa[i];
        sa[i + 2] := sa[i] * nP.cb;
        sa[i + 1] := sa[i] * nP.cg;
        sa[i + 0] := sa[i] * nP.cr;
      end;
    end;
  
  for var i := 0 to sa.Length - 1 do
    ba[i] := Round(sa[i] / ms * 255);
  
  Log((w, h), System.DateTime.Now - LT);
  
  Result := new Texture(w, h, ba, false, true);
end;

var
  WallTexPart := new SavedImage(GetResourceStream('WallTexPart.im'), false);

function GetStWallTex_test2(w, h: cardinal): Texture;
const
  SrMRad = 30;
  MRad = 20;
  MaxMRad = SrMRad + MRad;
begin
  
  var LT := System.DateTime.Now;
  
  var ba := new byte[w * h * 3];
  var pts := new List<vec3d>;
  loop Round(w * h / (300 + Random(21))) do
    //loop 5 do
    pts.Add(new vec3d(Random * (w + 60) - 30, Random * (h + 60) - 30, SrMRad + Rand(MRad)));
  while pts.Count <> 0 do
  begin
    var nP := new vec3d(0, 0, 0);
    foreach var P in pts do
      if P.Z > nP.Z then
        nP := P;
    pts.Remove(nP);
    for x: cardinal := 0 to w - 1 do
      if abs(nP.X - x) <= MaxMRad then
        for y: cardinal := 0 to h - 1 do
          if abs(nP.Y - y) <= MaxMRad then
          begin
            var i := (x + y * w) * 3;
            var r := sqrt(sqr(nP.X - x) + sqr(nP.Y - y));
            if r > MaxMRad then continue;
            var nr := 1 / sqr(r / 10);
            if nr > Single.MaxValue / 10 then
              nr := Single.MaxValue / 10;
            var c: byte;
            try
              c := byte(System.Convert.ToInt64(System.Math.Round(nr * 25000)));
            except
              SaveError(nr);
            end;
            var k := Power(1 - r / 30, 0.01);
            if k > 0 then
              ba[i] := Round(ba[i] + (c - ba[i]) * k);
          end;
  end;
  
  WTF('Log.txt', (w, h), System.DateTime.Now - LT);
  
  Result := new Texture(w, h, ba, false, true);
  
end;

type
  WallCrack = class
    
    pts: array of vec2f;
    rpts: array of vec2f;
    X, Y, rot: Single;
    
    constructor create(nw, nh: cardinal);
    begin
      X := Random(nw);
      Y := Random(nh);
      var w := 3 + Random(7);
      var l := 10 + Random(20);
      pts := new vec2f[6](
      new vec2f(+l, +w),
      new vec2f(-l, +w),
      new vec2f(-l, -w),
      new vec2f(+l, -w),
      new vec2f(-l, 0),
      new vec2f(+l, 0));
      rot := Random * Pi;
    end;
    
    class function GetCracksList(nw, nh: cardinal): List<WallCrack>;
    begin
      Result := new List<WallCrack>(Round(nw * nh * 0.00025 * (1 + Rand(0.1))));
      loop Result.Capacity do
        Result.Add(new WallCrack(nw, nh));
      
    end;
  
  end;

function GetStWallTex(w, h: cardinal): Texture;
begin
    //var LT := System.DateTime.Now;
  
  var ba := new byte[w * h * 3];
  begin
    var dx := Random(WallTexPart.w);
    var dy := Random(WallTexPart.w);
    dx := 0;
    dy := 0;
    for x: cardinal := 0 to w - 1 do
      for y: cardinal := 0 to h - 1 do
      begin
        var i := (x + y * w) * 3;
        var C := WallTexPart.pts[(x + dx) mod WallTexPart.w, (y + dy) mod WallTexPart.w];
        ba[i + 0] := C.R;
        ba[i + 1] := C.G;
        ba[i + 2] := C.B;
      end;
  end;
  
  //var cracks := WallCrack.GetCracksList;
  
    //WTF('Log.txt', (w, h), System.DateTime.Now - LT);
  
  Result := new Texture(w, h, ba, false, true);
end;

{$endregion}

type
  ///Random Texture Generator
  RTG = static class
    
    private const TexSamples = 1;
    
    private class Walls := new Dictionary<(cardinal, cardinal), List<Texture>>;
    private class Floors := new Dictionary<(cardinal, cardinal), List<Texture>>;
    
    public class TCTC: word := 0;
    
    public class function NextWall(w, h: cardinal): Texture;
    begin
      var sz := (w, h);
      try
        Result := Walls[sz].Rand;
      except
        on e: System.Collections.Generic.KeyNotFoundException do
        begin
          Walls.Add(sz, new List<Texture>(TexSamples));
          var WW := Walls[sz];
          var lt := TexSamples;
          (new System.Threading.Thread(()->
          begin
            
            //TCTC+=1;
            //WTF('Log.txt', System.DateTime.Now, '|Started   ', sz, ' Wall Textures x ', lt);
            loop lt do
              WW.Add(GetStWallTex(w, h));
            //WTF('Log.txt', System.DateTime.Now, '|Done with ', sz, ' Wall Textures');
            //TCTC-=1;
            
          end)).Start;
          while WW.Count = 0 do Sleep(10);
          Result := WW[0];
        end;
        on e: System.Exception do
          SaveError('RandTexGenerator.NextFloor:', e);
      end;
    end;
    
    public class function NextFloor(w, h: cardinal): Texture;
    begin
      var sz := (w, h);
      try
        Result := Floors[sz].Rand;
      except
        on e: System.Collections.Generic.KeyNotFoundException do
        begin
          Floors.Add(sz, new List<Texture>(TexSamples));
          var WW := Floors[sz];
          var lt := TexSamples;
          (new System.Threading.Thread(()->
          begin
            
            //TCTC+=1;
            //WTF('Log.txt', System.DateTime.Now, '|Started   ', sz, ' Floor Textures x ', lt);
            loop lt do
              WW.Add(GetStFloorTex(w, h));
            //WTF('Log.txt', System.DateTime.Now, '|Done with ', sz, ' Floor Textures');
            //TCTC-=1;
            
          end)).Start;
          while WW.Count = 0 do Sleep(10);
          Result := WW[0];
        end;
        on e: System.Exception do
          SaveError('RandTexGenerator.NextFloor:', e);
      end;
    end;
  
  end;

end.