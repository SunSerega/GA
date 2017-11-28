unit PerlinNoiseData;

procedure WTF(name: string; params obj: array of object) := System.IO.File.AppendAllText(name, string.Join('', obj.ConvertAll(a -> _ObjectToString(a))) + char(13) + char(10));

type
  Perlin2D = class
  
  public 
    permutationTable: array of byte;
    
    public constructor(seed: integer := 0);
    begin
      var rand := new System.Random(seed);
      permutationTable := new byte[1024];
      rand.NextBytes(permutationTable);
    end;
    
    private function GetPseudoRandomGradientVector(x, y: integer): array of Single;
    begin
      var v := (((x * $6D73E55F) xor (y * $B11924E1) + $11E8D0A40) and $3FF);
      v := permutationTable[v] and $3;
      
      case v of
        0:  Result := new Single[](1,  0 );
        1:  Result := new Single[](0,  1 );
        2:  Result := new Single[](-1, 0 );
      else  Result := new Single[](0, -1 );
      end;
    end;
  
  private class function QunticCurve(t: Single): Single := t * t * t * (t * (t * 6 - 15) + 10);
  
  private class function Lerp(a, b, t: Single): Single := a + (b - a) * t;
  
  private class function Dot(a, b: array of Single): Single := a[0] * b[0] + a[1] * b[1];
    
    public function Noise(fx, fy: Single): Single;
    begin
      fx -= System.Math.Floor(fx/integer.MaxValue)*integer.MaxValue;
      fy -= System.Math.Floor(fy/integer.MaxValue)*integer.MaxValue;
      var left := Floor(fx);
      var top  := Floor(fy);
      var pointInQuadX := QunticCurve(fx - left);
      var pointInQuadY := QunticCurve(fy - top);
      
      var topLeftGradient     := GetPseudoRandomGradientVector(left,   top  );
      var topRightGradient    := GetPseudoRandomGradientVector(left + 1, top  );
      var bottomLeftGradient  := GetPseudoRandomGradientVector(left,   top + 1);
      var bottomRightGradient := GetPseudoRandomGradientVector(left + 1, top + 1);
      
      var distanceToTopLeft     := new Single[](pointInQuadX,   pointInQuadY   );
      var distanceToTopRight    := new Single[](pointInQuadX - 1, pointInQuadY   );
      var distanceToBottomLeft  := new Single[](pointInQuadX,   pointInQuadY - 1 );
      var distanceToBottomRight := new Single[](pointInQuadX - 1, pointInQuadY - 1 );
      
      var tx1 := Dot(distanceToTopLeft,     topLeftGradient);
      var tx2 := Dot(distanceToTopRight,    topRightGradient);
      var bx1 := Dot(distanceToBottomLeft,  bottomLeftGradient);
      var bx2 := Dot(distanceToBottomRight, bottomRightGradient);
      
      var tx := Lerp(tx1, tx2, pointInQuadX);
      var bx := Lerp(bx1, bx2, pointInQuadX);
      Result := Lerp(tx, bx, pointInQuadY);
      
      {
      WTF('Log.txt',fx,' ',fy);
      WTF('Log.txt',left,' ',top);
      WTF('Log.txt',pointInQuadX,' ',pointInQuadX);
      WTF('Log.txt','------------------------------------------------------');
      {}
    end;
    
    public function Noise(fx, fy: Single; octaves: integer; persistence: Single := 0.5): Single;
    begin
      var amplitude: Single := 1;
      var max: Single := 0;
      
      while octaves > 0 do
      begin
        max += amplitude;
        result += Noise(fx, fy) * amplitude;
        amplitude *= persistence;
        fx *= 2;
        fy *= 2;
        
        octaves -= 1;
      end;
      
      result /= max;
    end;
  
  end;

end.