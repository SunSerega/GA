{$define DEBUG}

{$reference System.Windows.Forms.dll}
{$reference System.Drawing.dll}

unit GData;

uses OpenGL, TData, CellTexData;

var
  k := new boolean[256];

{$region Loging}

var
  StartTime := System.DateTime.Now;
  
procedure WTF(name: string; params obj: array of object) := lock name do System.IO.File.AppendAllText(name, string.Join('', obj.ConvertAll(a -> _ObjectToString(a))) + char(13) + char(10));

procedure SaveError(params obj: array of object);
begin
  (new System.Threading.Thread(()->begin
    
    (new System.Threading.Thread(()->System.Console.Beep(1000, 1000))).Start;
    if not System.IO.File.Exists('Errors.txt') then
      WTF('Errors.txt', 'Started|', StartTime);
    var b := true;
    while b do
      try
        WTF('Errors.txt', new object[2](System.DateTime.Now, '|') + obj);
        b := false;
      except
      end;
    
  end)).Start;
end;

procedure Log(params data: array of object) := WTF('Log.txt', data);

procedure Log2(params data: array of object) := WTF('Log2.txt', data);

procedure Log3(params data: array of object) := WTF('Log3.txt', data);

{$endregion}

{$region Dop}

type
  ST3 = (Single, Single, Single);

var
  ST30: ST3 := (Single(0), Single(0), Single(0));

function operator+(a, b: ST3): ST3; extensionmethod;
begin
  Result := (a.Item1 + b.Item1, a.Item2 + b.Item2, a.Item3 + b.Item3);
end;

function operator-(a, b: ST3): ST3; extensionmethod;
begin
  Result := (a.Item1 - b.Item1, a.Item2 - b.Item2, a.Item3 - b.Item3);
end;

function operator*(a: ST3; b: Single): ST3; extensionmethod;
begin
  Result := (a.Item1 * b, a.Item2 * b, a.Item3 * b);
end;

{$endregion}

var
  WW, WH: word;
  _hdc: HDC;
  MF: System.windows.forms.Form;

{$region Types} type
  
  {$region vec}
  
  vec2i = record
    
    private class _Empty := default(vec2i);
    public class property Empty: vec2i read _Empty;
    
    public X, Y: System.Int32;
    
    private function GetByIdx(i: byte): System.Int32;
    begin
      {$ifdef DEBUG}
      case i of
        0: Result := X;
        1: Result := Y;
      else raise new System.IndexOutOfRangeException(i + ' не принадлежит 0..1');
      end;
      {$else}
      Result := i = 0 ? X : Y;
      {$endif}
    end;
    
    private property ByIdx[i: byte]: System.Int32 read GetByIdx; default;
    
    public constructor create(X, Y: System.Int32);
    begin
      self.X := X;
      self.Y := Y;
    end;
    
    
    public class function operator+(v1, v2: vec2i) := new vec2i(v1.X + v2.X, v1.Y + v2.Y);
    public class procedure operator+=(var v1: vec2i; v2: vec2i);begin v1 := v1 + v2 end;
    
    public class function operator-(v1, v2: vec2i) := new vec2i(v1.X - v2.X, v1.Y - v2.Y);
    public class procedure operator-=(var v1: vec2i; v2: vec2i);begin v1 := v1 - v2 end;
    
    public class function operator*(v: vec2i; r: integer) := new vec2i(v.X * r, v.Y * r);
    public class procedure operator*=(var v: vec2i; r: integer);begin v := v * r end;
  
  end;
  vec3i = record
    
    private class _Empty := default(vec3i);
    public class property Empty: vec3i read _Empty;
    
    public X, Y, Z: integer;
    
    private function GetByIdx(i: byte): System.Int32;
    begin
      {$ifdef DEBUG}
      case i of
        0: Result := X;
        1: Result := Y;
        2: Result := Z;
      else raise new System.IndexOutOfRangeException(i + ' не принадлежит 0..2');
      end;
      {$else}
      Result := i = 0 ? X : i = 1 ? Y : Z;
      {$endif}
    end;
    
    private property ByIdx[i: byte]: System.Int32 read GetByIdx; default;
    
    public constructor create(X, Y, Z: integer);
    begin
      self.X := X;
      self.Y := Y;
      self.Z := Z;
    end;
    
    
    public class function operator+(v1, v2: vec3i) := new vec3i(v1.X + v2.X, v1.Y + v2.Y, v1.Z + v2.Z);
    public class procedure operator+=(var v1: vec3i; v2: vec3i);begin v1 := v1 + v2 end;
    
    public class function operator-(v1, v2: vec3i) := new vec3i(v1.X - v2.X, v1.Y - v2.Y, v1.Z - v2.Z);
    public class procedure operator-=(var v1: vec3i; v2: vec3i);begin v1 := v1 - v2 end;
    
    public class function operator*(v: vec3i; r: integer) := new vec3i(v.X * r, v.Y * r, v.Z * r);
    public class procedure operator*=(var v: vec3i; r: integer);begin v := v * r end;
    
    public class function operator implicit(v: vec2i): vec3i := new vec3i(v.X, v.Y, 0);
    
    public class function operator implicit(v: vec3i): vec2i := new vec2i(v.X, v.Y);
    
    
    public class function operator*(v1, v2: vec3i) := new vec3i(
    v1.Y * v2.Z - v1.Z * v2.Y,
    v1.Z * v2.X - v1.X * v2.Z,
    v1.X * v2.Y - v1.Y * v2.X);
  
  end;
  
  vec2f = record
    
    private class _Empty := default(vec2f);
    public class property Empty: vec2f read _Empty;
    
    public X, Y: Single;
    
    private function GetByIdx(i: byte): Single;
    begin
      {$ifdef DEBUG}
      case i of
        0: Result := X;
        1: Result := Y;
      else raise new System.IndexOutOfRangeException(i + ' не принадлежит 0..1');
      end;
      {$else}
      Result := i = 0 ? X : Y;
      {$endif}
    end;
    
    private property ByIdx[i: byte]: Single read GetByIdx; default;
    
    public constructor create(X, Y: Single);
    begin
      self.X := X;
      self.Y := Y;
    end;
    
    public function Norma := sqrt(sqr(X) + sqr(Y));
    
    public function Normalize: vec2f;
    begin
      var r := Norma;
      Result := new vec2f(X / r, Y / r);
    end;
    
    
    public class function operator+(v1, v2: vec2f) := new vec2f(v1.X + v2.X, v1.Y + v2.Y);
    public class procedure operator+=(var v1: vec2f; v2: vec2f);begin v1 := v1 + v2 end;
    
    public class function operator-(v1, v2: vec2f) := new vec2f(v1.X - v2.X, v1.Y - v2.Y);
    public class procedure operator-=(var v1: vec2f; v2: vec2f);begin v1 := v1 - v2 end;
    
    public class function operator*(v: vec2f; r: Single) := new vec2f(v.X * r, v.Y * r);
    public class procedure operator*=(var v1: vec2f; r: Single);begin v1 := v1 * r end;
    
    public class function operator/(v: vec2f; r: Single) := new vec2f(v.X / r, v.Y / r);
    public class procedure operator/=(var v: vec2f; r: Single);begin v := v / r end;
    
    
    public class function operator implicit(v: vec2i): vec2f := new vec2f(v.X, v.Y);
    public class function operator implicit(v: vec3i): vec2f := new vec2f(v.X, v.Y);
    
    public class function operator explicit(v: vec2f): vec2i := new vec2i(System.Convert.ToInt32(v.X), System.Convert.ToInt32(v.Y));
    public class function operator explicit(v: vec2f): vec3i := new vec3i(System.Convert.ToInt32(v.X), System.Convert.ToInt32(v.Y), 0);
  
  end;
  vec3f = record
    
    private class _Empty := default(vec3f);
    public class property Empty: vec3f read _Empty;
    
    public X, Y, Z: Single;
    
    private function GetByIdx(i: byte): Single;
    begin
      {$ifdef DEBUG}
      case i of
        0: Result := X;
        1: Result := Y;
        2: Result := Z;
      else raise new System.IndexOutOfRangeException(i + ' не принадлежит 0..2');
      end;
      {$else}
      Result := i = 0 ? X : i = 1 ? Y : Z;
      {$endif}
    end;
    
    private property ByIdx[i: byte]: Single read GetByIdx; default;
    
    public constructor create(X, Y, Z: Single);
    begin
      self.X := X;
      self.Y := Y;
      self.Z := Z;
    end;
    
    public function Norma := sqrt(sqr(X) + sqr(Y) + sqr(Z));
    
    public function Normalized: vec3f;
    begin
      var r := Norma;
      Result := new vec3f(X / r, Y / r, Z / r);
    end;
    
    
    public class function operator+(v1, v2: vec3f) := new vec3f(v1.X + v2.X, v1.Y + v2.Y, v1.Z + v2.Z);
    public class procedure operator+=(var v1: vec3f; v2: vec3f);begin v1 := v1 + v2 end;
    
    public class function operator-(v1, v2: vec3f) := new vec3f(v1.X - v2.X, v1.Y - v2.Y, v1.Z - v2.Z);
    public class procedure operator-=(var v1: vec3f; v2: vec3f);begin v1 := v1 - v2 end;
    
    public class function operator*(v: vec3f; r: Single) := new vec3f(v.X * r, v.Y * r, v.Z * r);
    public class procedure operator*=(var v: vec3f; r: Single);begin v := v * r end;
    
    public class function operator/(p: vec3f; r: Single) := new vec3f(p.X / r, p.Y / r, p.Z / r);
    public class procedure operator/=(var v: vec3f; r: Single);begin v := v / r end;
    
    
    public class function operator implicit(v: vec2f): vec3f := new vec3f(v.X, v.Y, 0);
    public class function operator implicit(v: vec2i): vec3f := new vec3f(v.X, v.Y, 0);
    public class function operator implicit(v: vec3i): vec3f := new vec3f(v.X, v.Y, v.Z);
    
    public class function operator implicit(v: vec3f): vec2f := new vec2f(v.X, v.Y);
    public class function operator explicit(v: vec3f): vec2i := new vec2i(System.Convert.ToInt32(v.X), System.Convert.ToInt32(v.Y));
    public class function operator explicit(v: vec3f): vec3i := new vec3i(System.Convert.ToInt32(v.X), System.Convert.ToInt32(v.Y), System.Convert.ToInt32(v.Z));
    
    
    public class function operator*(v1, v2: vec3f) := new vec3f(
    v1.Y * v2.Z - v1.Z * v2.Y,
    v1.Z * v2.X - v1.X * v2.Z,
    v1.X * v2.Y - v1.Y * v2.X);
  
  end;
  
  vec2d = record
    
    private class _Empty := default(vec2d);
    public class property Empty: vec2d read _Empty;
    
    public X, Y: real;
    
    private function GetByIdx(i: byte): real;
    begin
      {$ifdef DEBUG}
      case i of
        0: Result := X;
        1: Result := Y;
      else raise new System.IndexOutOfRangeException(i + ' не принадлежит 0..1');
      end;
      {$else}
      Result := i = 0 ? X : Y;
      {$endif}
    end;
    
    private property ByIdx[i: byte]: real read GetByIdx; default;
    
    public constructor create(X, Y: real);
    begin
      self.X := X;
      self.Y := Y;
    end;
    
    public function Norma := sqrt(sqr(X) + sqr(Y));
    
    public function Normalize: vec2d;
    begin
      var r := Norma;
      Result := new vec2d(X / r, Y / r);
    end;
    
    
    public class function operator+(v1, v2: vec2d) := new vec2d(v1.X + v2.X, v1.Y + v2.Y);
    public class procedure operator+=(var v1: vec2d; v2: vec2d);begin v1 := v1 + v2 end;
    
    public class function operator-(v1, v2: vec2d) := new vec2d(v1.X - v2.X, v1.Y - v2.Y);
    public class procedure operator-=(var v1: vec2d; v2: vec2d);begin v1 := v1 - v2 end;
    
    public class function operator*(v: vec2d; r: real) := new vec2d(v.X * r, v.Y * r);
    public class procedure operator*=(var v1: vec2d; r: real);begin v1 := v1 * r end;
    
    public class function operator/(v: vec2d; r: real) := new vec2d(v.X / r, v.Y / r);
    public class procedure operator/=(var v: vec2d; r: real);begin v := v / r end;
    
    
    public class function operator implicit(v: vec2i): vec2d := new vec2d(v.X, v.Y);
    public class function operator implicit(v: vec3i): vec2d := new vec2d(v.X, v.Y);
    public class function operator implicit(v: vec2f): vec2d := new vec2d(v.X, v.Y);
    public class function operator implicit(v: vec3f): vec2d := new vec2d(v.X, v.Y);
    
    public class function operator implicit(v: vec2d): vec2f := new vec2f(v.X, v.Y);
    public class function operator implicit(v: vec2d): vec3f := new vec3f(v.X, v.Y, 0);
    public class function operator explicit(v: vec2d): vec2i := new vec2i(System.Convert.ToInt32(v.X), System.Convert.ToInt32(v.Y));
    public class function operator explicit(v: vec2d): vec3i := new vec3i(System.Convert.ToInt32(v.X), System.Convert.ToInt32(v.Y), 0);
  
  end;
  vec3d = record
    
    private class _Empty := default(vec3d);
    public class property Empty: vec3d read _Empty;
    
    public X, Y, Z: real;
    
    private function GetByIdx(i: byte): real;
    begin
      {$ifdef DEBUG}
      case i of
        0: Result := X;
        1: Result := Y;
        2: Result := Z;
      else raise new System.IndexOutOfRangeException(i + ' не принадлежит 0..2');
      end;
      {$else}
      Result := i = 0 ? X : i = 1 ? Y : Z;
      {$endif}
    end;
    
    private property ByIdx[i: byte]: real read GetByIdx; default;
    
    public constructor create(X, Y, Z: real);
    begin
      self.X := X;
      self.Y := Y;
      self.Z := Z;
    end;
    
    public function Norma := sqrt(sqr(X) + sqr(Y) + sqr(Z));
    
    public function Normalized: vec3d;
    begin
      var r := Norma;
      Result := new vec3d(X / r, Y / r, Z / r);
    end;
    
    
    public class function operator+(v1, v2: vec3d) := new vec3d(v1.X + v2.X, v1.Y + v2.Y, v1.Z + v2.Z);
    public class procedure operator+=(var v1: vec3d; v2: vec3d);begin v1 := v1 + v2 end;
    
    public class function operator-(v1, v2: vec3d) := new vec3d(v1.X - v2.X, v1.Y - v2.Y, v1.Z - v2.Z);
    public class procedure operator-=(var v1: vec3d; v2: vec3d);begin v1 := v1 - v2 end;
    
    public class function operator*(v: vec3d; r: real) := new vec3d(v.X * r, v.Y * r, v.Z * r);
    public class procedure operator*=(var v: vec3d; r: real);begin v := v * r end;
    
    public class function operator/(p: vec3d; r: real) := new vec3d(p.X / r, p.Y / r, p.Z / r);
    public class procedure operator/=(var v: vec3d; r: real);begin v := v / r end;
    
    
    public class function operator implicit(v: vec2i): vec3d := new vec3d(v.X, v.Y, 0);
    public class function operator implicit(v: vec3i): vec3d := new vec3d(v.X, v.Y, v.Z);
    public class function operator implicit(v: vec2f): vec3d := new vec3d(v.X, v.Y, 0);
    public class function operator implicit(v: vec3f): vec3d := new vec3d(v.X, v.Y, v.Z);
    public class function operator implicit(v: vec2d): vec3d := new vec3d(v.X, v.Y, 0);
    
    public class function operator implicit(v: vec3d): vec2f := new vec2f(v.X, v.Y);
    public class function operator implicit(v: vec3d): vec3f := new vec3f(v.X, v.Y, v.Z);
    public class function operator implicit(v: vec3d): vec2d := new vec2d(v.X, v.Y);
    public class function operator explicit(v: vec3d): vec2i := new vec2i(System.Convert.ToInt32(v.X), System.Convert.ToInt32(v.Y));
    public class function operator explicit(v: vec3d): vec3i := new vec3i(System.Convert.ToInt32(v.X), System.Convert.ToInt32(v.Y), System.Convert.ToInt32(v.Z));
    
    
    public class function operator*(v1, v2: vec3d) := new vec3d(
    v1.Y * v2.Z - v1.Z * v2.Y,
    v1.Z * v2.X - v1.X * v2.Z,
    v1.X * v2.Y - v1.Y * v2.X);
  
  end;
  
  Tvec2d = record
    
    private class _Empty := default(Tvec2d);
    public class property Empty: Tvec2d read _Empty;
    
    public X, Y: real;
    public TX, TY: Single;
    
    private function GetByIdx(i: byte): object;
    begin
      {$ifdef DEBUG}
      case i of
        0: Result := X;
        1: Result := Y;
        2: Result := TX;
        3: Result := TY;
      else raise new System.IndexOutOfRangeException(i + ' не принадлежит 0..3');
      end;
      {$else}
      Result := i < 2 ?
       (i = 0 ? X : Y) :
       (i = 2 ? TX : TY);
      {$endif}
    end;
    
    private property ByIdx[i: byte]: object read GetByIdx; default;
    
    public constructor create(X, Y: real; TX, TY: Single);
    begin
      self.X := X;
      self.Y := Y;
      self.TX := TX;
      self.TY := TY;
    end;
    
    public function Norma := sqrt(sqr(X) + sqr(Y));
    
    public function Normalize: Tvec2d;
    begin
      var r := Norma;
      Result := new Tvec2d(X / r, Y / r, TX, TY);
    end;
    
    
    public class function operator explicit(v: vec2i): Tvec2d := new Tvec2d(v.X, v.Y,   0, 0);
    public class function operator explicit(v: vec3i): Tvec2d := new Tvec2d(v.X, v.Y,   0, 0);
    public class function operator explicit(v: vec2f): Tvec2d := new Tvec2d(v.X, v.Y,   0, 0);
    public class function operator explicit(v: vec3f): Tvec2d := new Tvec2d(v.X, v.Y,   0, 0);
    public class function operator explicit(v: vec2d): Tvec2d := new Tvec2d(v.X, v.Y,   0, 0);
    public class function operator explicit(v: vec3d): Tvec2d := new Tvec2d(v.X, v.Y,   0, 0);
    
    public class function operator implicit(v: Tvec2d): vec2f := new vec2f(v.X, v.Y);
    public class function operator implicit(v: Tvec2d): vec3f := new vec3f(v.X, v.Y, 0);
    public class function operator implicit(v: Tvec2d): vec2d := new vec2f(v.X, v.Y);
    public class function operator implicit(v: Tvec2d): vec3d := new vec3f(v.X, v.Y, 0);
    public class function operator explicit(v: Tvec2d): vec2i := new vec2i(System.Convert.ToInt32(v.X), System.Convert.ToInt32(v.Y));
    public class function operator explicit(v: Tvec2d): vec3i := new vec3i(System.Convert.ToInt32(v.X), System.Convert.ToInt32(v.Y), 0);
  
  
  end;
  Tvec3d = record
    
    private class _Empty := default(Tvec3d);
    public class property Empty: Tvec3d read _Empty;
    
    public X, Y, Z: real;
    public TX, TY: Single;
    
    private function GetByIdx(i: byte): object;
    begin
      {$ifdef DEBUG}
      case i of
        0: Result := X;
        1: Result := Y;
        2: Result := Z;
        3: Result := TX;
        4: Result := TY;
      else raise new System.IndexOutOfRangeException(i + ' не принадлежит 0..4');
      end;
      {$else}
      Result := i < 3 ?
       (i = 0 ? X : i = 1 ? Y : Z) :
       (i = 3 ? TX : TY);
      {$endif}
    end;
    
    private property ByIdx[i: byte]: object read GetByIdx; default;
    
    public constructor create(X, Y, Z: real; TX, TY: Single);
    begin
      self.X := X;
      self.Y := Y;
      self.Z := Z;
      self.TX := TX;
      self.TY := TY;
    end;
    
    public function Norma := sqrt(sqr(X) + sqr(Y) + sqr(Z));
    
    public function Normalize: Tvec3d;
    begin
      var r := Norma;
      Result := new Tvec3d(X / r, Y / r, Z / r, TX, TY);
    end;
    
    
    public class function operator implicit(v: Tvec2d): Tvec3d := new Tvec3d(v.X, v.Y, 0,         v.TX, v.TY);
    public class function operator explicit(v: vec2i): Tvec3d := new Tvec3d(v.X, v.Y, 0,         0,    0);
    public class function operator explicit(v: vec3i): Tvec3d := new Tvec3d(v.X, v.Y, v.Z,       0,    0);
    public class function operator explicit(v: vec2f): Tvec3d := new Tvec3d(v.X, v.Y, 0,         0,    0);
    public class function operator explicit(v: vec3f): Tvec3d := new Tvec3d(v.X, v.Y, v.Z,       0,    0);
    public class function operator explicit(v: vec2d): Tvec3d := new Tvec3d(v.X, v.Y, 0,         0,    0);
    public class function operator explicit(v: vec3d): Tvec3d := new Tvec3d(v.X, v.Y, v.Z,       0,    0);
    
    public class function operator implicit(v: Tvec3d): vec2f := new vec2f(v.X, v.Y);
    public class function operator implicit(v: Tvec3d): vec3f := new vec3f(v.X, v.Y, v.Z);
    public class function operator implicit(v: Tvec3d): vec2d := new vec2d(v.X, v.Y);
    public class function operator implicit(v: Tvec3d): vec3d := new vec3d(v.X, v.Y, v.Z);
    public class function operator implicit(v: Tvec3d): Tvec2d := new Tvec2d(v.X, v.Y, v.TX, v.TY);
    public class function operator explicit(v: Tvec3d): vec2i := new vec2i(System.Convert.ToInt32(v.X), System.Convert.ToInt32(v.Y));
    public class function operator explicit(v: Tvec3d): vec3i := new vec3i(System.Convert.ToInt32(v.X), System.Convert.ToInt32(v.Y), System.Convert.ToInt32(v.Z));
  
  end;
  
  Cvec3d = record
    
    private class _Empty := default(Cvec3d);
    public class property Empty: Cvec3d read _Empty;
    
    public X, Y, Z: real;
    public cr, cg, cb, ca: Single;
    
    private function GetByIdx(i: byte): object;
    begin
      {$ifdef DEBUG}
      case i of
        0: Result := X;
        1: Result := Y;
        2: Result := Z;
        3: Result := cr;
        4: Result := cg;
        5: Result := cb;
        6: Result := ca;
      else raise new System.IndexOutOfRangeException(i + ' не принадлежит 0..6');
      end;
      {$else}
      Result := i < 4 ?
       (i < 2 ?
        (i = 0 ?  X :  Y)  :
        (i = 2 ?  Z : cr) ) :
       (i = 4 ?
        cg                 :
        (i = 5) ? cb : ca  );
      {$endif}
    end;
    
    private property ByIdx[i: byte]: object read GetByIdx; default;
    
    public constructor create(X, Y, Z: real; cr, cg, cb, ca: Single);
    begin
      self.X := X;
      self.Y := Y;
      self.Z := Z;
      self.cr := cr;
      self.cg := cg;
      self.cb := cb;
      self.ca := ca;
    end;
    
    public function Norma := sqrt(sqr(X) + sqr(Y) + sqr(Z));
    
    public function Normalize: Cvec3d;
    begin
      var r := Norma;
      Result := new Cvec3d(X / r, Y / r, Z / r, cr, cg, cb, ca);
    end;
    
    
    public class function operator explicit(v: vec2i): Cvec3d := new Cvec3d(v.X, v.Y, 0,         0, 0, 0, 0);
    public class function operator explicit(v: vec3i): Cvec3d := new Cvec3d(v.X, v.Y, v.Z,       0, 0, 0, 0);
    public class function operator explicit(v: vec2f): Cvec3d := new Cvec3d(v.X, v.Y, 0,         0, 0, 0, 0);
    public class function operator explicit(v: vec3f): Cvec3d := new Cvec3d(v.X, v.Y, v.Z,       0, 0, 0, 0);
    public class function operator explicit(v: vec2d): Cvec3d := new Cvec3d(v.X, v.Y, 0,         0, 0, 0, 0);
    public class function operator explicit(v: vec3d): Cvec3d := new Cvec3d(v.X, v.Y, v.Z,       0, 0, 0, 0);
    
    public class function operator implicit(v: Cvec3d): vec2f := new vec2f(v.X, v.Y);
    public class function operator implicit(v: Cvec3d): vec3f := new vec3f(v.X, v.Y, v.Z);
    public class function operator implicit(v: Cvec3d): vec2d := new vec2d(v.X, v.Y);
    public class function operator implicit(v: Cvec3d): vec3d := new vec3d(v.X, v.Y, v.Z);
    public class function operator explicit(v: Cvec3d): vec2i := new vec2i(System.Convert.ToInt32(v.X), System.Convert.ToInt32(v.Y));
    public class function operator explicit(v: Cvec3d): vec3i := new vec3i(System.Convert.ToInt32(v.X), System.Convert.ToInt32(v.Y), System.Convert.ToInt32(v.Z));
  
  end;
  
  {$endregion}
  
  {$region rect}
  
  rect2f = record
    
    public X, Y, W, H: Single;
    
    public constructor(X, Y, W, H: Single);
    begin
      self.X := X;
      self.Y := Y;
      self.W := W;
      self.H := H;
    end;
    
    public function Contains(p: vec2i) := (p.X >= X) and (p.Y >= Y) and (p.X <= X + W) and (p.Y <= Y + H);
  
  end;
  
  {$endregion}
  
  {$region mtx}
  
  mtx3x3f = record
    
    public a00 := Single(1);
    public a10, a20, a01: Single;
    public a11 := Single(1);
    public a21, a02, a12: Single;
    public a22 := Single(1);
    
    
    public procedure SetCol0(v: vec3f);begin a00 := v.X; a10 := v.Y; a20 := v.Z; end;
    
    public procedure SetCol1(v: vec3f);begin a01 := v.X; a11 := v.Y; a21 := v.Z; end;
    
    public procedure SetCol2(v: vec3f);begin a02 := v.X; a12 := v.Y; a22 := v.Z; end;
    
    public procedure SetRow0(v: vec3f);begin a00 := v.X; a01 := v.Y; a02 := v.Z; end;
    
    public procedure SetRow1(v: vec3f);begin a10 := v.X; a11 := v.Y; a12 := v.Z; end;
    
    public procedure SetRow2(v: vec3f);begin a20 := v.X; a21 := v.Y; a22 := v.Z; end;
    
    public constructor;
    begin
      a00 := 1;
      a11 := 1;
      a22 := 1;
    end;
    
    public constructor(v0, v1, v2: vec3f);
    begin
      SetRow0(v0);
      SetRow1(v1);
      SetRow2(v2);
    end;
    
    public class function operator*(mtx1, mtx2: mtx3x3f): mtx3x3f;
    begin
      
      Result.a00 := mtx1.a00 * mtx2.a00 + mtx1.a01 * mtx2.a10 + mtx1.a02 * mtx2.a20;
      Result.a01 := mtx1.a00 * mtx2.a01 + mtx1.a01 * mtx2.a11 + mtx1.a02 * mtx2.a21;
      Result.a02 := mtx1.a00 * mtx2.a02 + mtx1.a01 * mtx2.a12 + mtx1.a02 * mtx2.a22;
      
      Result.a10 := mtx1.a10 * mtx2.a00 + mtx1.a11 * mtx2.a10 + mtx1.a12 * mtx2.a20;
      Result.a11 := mtx1.a10 * mtx2.a01 + mtx1.a11 * mtx2.a11 + mtx1.a12 * mtx2.a21;
      Result.a12 := mtx1.a10 * mtx2.a02 + mtx1.a11 * mtx2.a12 + mtx1.a12 * mtx2.a22;
      
      Result.a20 := mtx1.a20 * mtx2.a00 + mtx1.a21 * mtx2.a10 + mtx1.a22 * mtx2.a20;
      Result.a21 := mtx1.a20 * mtx2.a01 + mtx1.a21 * mtx2.a11 + mtx1.a22 * mtx2.a21;
      Result.a22 := mtx1.a20 * mtx2.a02 + mtx1.a21 * mtx2.a12 + mtx1.a22 * mtx2.a22;
      
    end;
    
    public class function operator*(vec: vec3f; mtx: mtx3x3f) := new vec3f(
     mtx.a00 * vec.X + mtx.a01 * vec.Y + mtx.a02 * vec.Z,
     mtx.a10 * vec.X + mtx.a11 * vec.Y + mtx.a12 * vec.Z,
     mtx.a20 * vec.X + mtx.a21 * vec.Y + mtx.a22 * vec.Z);
    
    public function det :=
     a00 * (a11 * a22 - a12 * a21) +
     a01 * (a12 * a20 - a10 * a22) +
     a02 * (a10 * a21 - a11 * a20);
    
    public function Inverse: mtx3x3f;
    begin
      
      var M: mtx3x3f;
      var d := det;
      
      
      M.a00 := a00;
      M.a01 := a10;
      M.a02 := a20;
      
      M.a10 := a01;
      M.a11 := a11;
      M.a12 := a21;
      
      M.a20 := a02;
      M.a21 := a12;
      M.a22 := a22;
      
      
      Result.a00 := (M.a11 * M.a22 - M.a12 * M.a21) / d;
      Result.a01 := (M.a12 * M.a20 - M.a10 * M.a22) / d;
      Result.a02 := (M.a10 * M.a21 - M.a11 * M.a20) / d;
      
      Result.a10 := (M.a21 * M.a02 - M.a22 * M.a01) / d;
      Result.a11 := (M.a22 * M.a00 - M.a20 * M.a02) / d;
      Result.a12 := (M.a20 * M.a01 - M.a21 * M.a00) / d;
      
      Result.a20 := (M.a01 * M.a12 - M.a02 * M.a11) / d;
      Result.a21 := (M.a02 * M.a10 - M.a00 * M.a12) / d;
      Result.a22 := (M.a00 * M.a11 - M.a01 * M.a10) / d;
      
    end;
  
  end;

  {$endregion}

{$endregion}

{$region external}

function GetDesktopWindow: system.IntPtr;
external 'User32.dll' name 'GetDesktopWindow';

procedure GetWindowRect(hWnd: system.IntPtr; var lpRect: system.Drawing.Rectangle);
external 'User32.dll' name 'GetWindowRect';

function GetKeyState(KeyId: byte): byte;
external 'User32.dll' name 'GetKeyState';

procedure SetCursorPos(x, y: integer);
external 'User32.dll' name 'SetCursorPos';

procedure GetCursorPos(p: ^vec2i);
external 'User32.dll' name 'GetCursorPos';

function GetCursorPos: vec2i;
begin
  GetCursorPos(@Result);
end;

procedure glGenTextures(n: integer; textures: Pointer);
external 'OpenGL32.dll' name 'glGenTextures';

procedure glBindTexture(target: GLenum; texture: GLuint);
external 'OpenGL32.dll' name 'glBindTexture';

{$endregion}

{$region 2D functions}{

function ArcTg(dx, dy: real): real := (dx = 0 ? dy > 0 ? Pi / 2 : -Pi / 2 : ArcTan(dy / dx)) + (dx < 0 ? Pi : 0);

function Rotate(a, b, rot: real): vec2f;
begin
  with Result do
  begin
    var r := sqrt(sqr(a) + sqr(b));
    var ang := ArcTg(a, b) + rot;
    X := Cos(ang) * r;
    Y := Sin(ang) * r;
  end;
end;

function Rotate(a: array of vec2f; rot: real): array of vec2f;
begin
  Result := new vec2f[a.Length];
  for i: integer := 0 to a.Length - 1 do
    a[i] := Rotate(a[i].X, a[i].Y, rot);
  Result := a;
end;

function Rotate(p: vec2f; rot: real) := Rotate(p.X, p.Y, rot);

procedure ChAngDif(var nCh: Single; tCh, ante: Single);
begin
  var dif := tCh - nCh;
  while dif < -Pi do dif += Pi * 2;
  while dif > Pi do dif -= Pi * 2;
  if abs(dif) < 0.03 then
    nCh := tCh else
    nCh += dif * ante;
end;

function Add(p: array of vec2f; dX, dY: real): array of vec2f;
begin
  for i: integer := 0 to p.Length - 1 do
  begin
    p[i].X += dX;
    p[i].Y += dY;
  end;
  Result := p;
end;

function Mlt(p: array of vec2f; r: real): array of vec2f;
begin
  for i: integer := 0 to p.Length - 1 do
  begin
    p[i].X *= r;
    p[i].Y *= r;
  end;
  Result := p;
end;

function Rand(r: real) := (Random * 2 - 1) * r;

{$endregion}

type
  Texture = class
    
    private class TexCrProcs := new List<procedure>;
    
    protected class procedure AddTexCrProc(p: procedure);
    begin
      var nTexCrProcs := TexCrProcs.ToList;
      nTexCrProcs.Add(p);
      TexCrProcs := nTexCrProcs;
    end;
    
    public class procedure CreateWaitTextures(n: cardinal);
    begin
      loop n do
        if TexCrProcs.Count = 0 then exit else
        begin
          var p := TexCrProcs[0];
          if p <> nil then p();
          TexCrProcs.Remove(p);
        end;
    end;
    
    public class procedure CreateWaitTextures := CreateWaitTextures(TexCrProcs.Count);
    
    public class WaitToCreateTexture := true;
  
  public 
    id: cardinal;
    w, h: word;
    clrs: array of byte;
    FiltersNearest, NoMipmaps, alpha: boolean;
    
    
    procedure Redraw(FiltersNearest: boolean := false; NoMipmaps: boolean := false);
    begin
      glBindTexture(GL_TEXTURE_2D, id);
      if NoMipmaps then
        if alpha then
          glTexImage2D(GL_TEXTURE_2D, 0, 4, w, h, 0, GL_RGBA, GL_UNSIGNED_BYTE, @clrs[0]) else
          glTexImage2D(GL_TEXTURE_2D, 0, 3, w, h, 0, GL_RGB, GL_UNSIGNED_BYTE, @clrs[0]) else
      if alpha then
        gluBuild2DMipmaps(GL_TEXTURE_2D, 4, w, h, GL_RGBA, GL_UNSIGNED_BYTE, @clrs[0]) else
        gluBuild2DMipmaps(GL_TEXTURE_2D, 3, w, h, GL_RGB, GL_UNSIGNED_BYTE, @clrs[0]);
      if FiltersNearest then
      begin
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
      end;
      glBindTexture(GL_TEXTURE_2D, 0);
    end;
    
    procedure SetVal(w, h: word; clrs: array of byte; alpha: boolean := false; DoRedraw: boolean := false; FiltersNearest: boolean := false; NoMipmaps: boolean := false);
    begin
      self.w := w;
      self.h := h;
      self.clrs := clrs;
      self.alpha := alpha;
      self.FiltersNearest := FiltersNearest;
      self.NoMipmaps := NoMipmaps;
      
      if DoRedraw then
        if WaitToCreateTexture then
          TexCrProcs.Add(()->begin self.Redraw(FiltersNearest, NoMipmaps) end) else
          Redraw(FiltersNearest, NoMipmaps);
    end;
    
    constructor create(w, h: word; clrs: array of byte; alpha: boolean := false; DoRedraw: boolean := false; FiltersNearest: boolean := false; NoMipmaps: boolean := false);
    begin
      self.w := w;
      self.h := h;
      self.clrs := clrs;
      self.alpha := alpha;
      self.FiltersNearest := FiltersNearest;
      self.NoMipmaps := NoMipmaps;
      
      if WaitToCreateTexture then
        if DoRedraw then
          
          AddTexCrProc(()->begin
            glGenTextures(1, @id);
            self.Redraw(FiltersNearest, NoMipmaps);
          end) else
        
          AddTexCrProc(()->begin
            glGenTextures(1, @id);
          end) else
      
      begin
        glGenTextures(1, @id);
        if DoRedraw then
          Redraw(FiltersNearest, NoMipmaps);
      end;
    end;
    
    constructor create(re: System.IO.BinaryReader; alpha: boolean := false; DoRedraw: boolean := false; FiltersNearest: boolean := false; NoMipmaps: boolean := false);
    begin
      w := re.ReadUInt16;
      h := re.ReadUInt16;
      if alpha then
        clrs := new byte[w * h * 4] else
        clrs := new byte[w * h * 3];
      re.Read(clrs, 0, clrs.Length);
      
      self.alpha := alpha;
      self.FiltersNearest := FiltersNearest;
      self.NoMipmaps := NoMipmaps;
      
      if Texture.WaitToCreateTexture then
        if DoRedraw then
          
          AddTexCrProc(()->begin
                      glGenTextures(1, @id);
                      self.Redraw(FiltersNearest, NoMipmaps);
            end) else
        
          AddTexCrProc(()->begin
                      glGenTextures(1, @id);
            end) else
      
      begin
        glGenTextures(1, @id);
        if DoRedraw then
          Redraw(FiltersNearest, NoMipmaps);
      end;
    end;
    
    constructor create(str: System.IO.Stream; CloseStream: boolean := false; alpha: boolean := false; Redraw: boolean := false; RQ: boolean := false);
    begin
      create(new System.IO.BinaryReader(str), alpha, Redraw, RQ);
      if CloseStream then
        str.Close;
    end;
    
    constructor create(f: string; alpha: boolean := false; Redraw: boolean := false; RQ: boolean := false);
    begin
      create(System.IO.File.OpenRead(f), true, alpha, Redraw, RQ);
    end;
    
    procedure Save(wr: System.IO.BinaryWriter; CloseStream: boolean := false);
    begin
      wr.Write(w);
      wr.Write(h);
      wr.Write(clrs);
      if CloseStream then
        wr.BaseStream.Close;
    end;
    
    procedure Save(str: System.IO.Stream; CloseStream: boolean := false) := Save(new System.IO.BinaryWriter(str), CloseStream) ;
    
    procedure Save(f: string) := Save(System.IO.File.Exists(f) ? System.IO.File.OpenRead(f) : System.IO.File.Create(f), true);
    
    class function GetPaternBytes(c: cardinal; func: integer->byte): array of byte;
    begin
      Result := new byte[c];
      Result.Fill(func);
    end;
    
    class function GetPaternBytes(w, h: cardinal; BPP: byte; func: (cardinal,cardinal,byte)->byte): array of byte;
    begin
      Result := new byte[w * h * BPP];
      for y: cardinal := 0 to h - 1 do
        for x: cardinal := 0 to w - 1 do
          for b: byte := 0 to BPP - 1 do
            Result[b + BPP * (x + w * y)] := func(x, y, b);
    end;
    
    class procedure CharOnBitMap(ch: char; x, y: cardinal; BitMap: array[,] of byte);
    begin
      var b := Leters[ch];
      for dx: byte := 0 to 7 do
        for dy: byte := 0 to 11 do
          try
            BitMap[x + dx, y + dy] := b[dx, dy];
          except
          end;
    end;
    
    class function GetTextTexture(s: string; cr, cg, cb, ca: byte; bcr, bcg, bcb, bca: byte): Texture;
    begin
      
      var w := 8 * s.Length + 4;
      var h := 12;
      var BitMap := new byte[w, h];
      var clrs := new byte[w * h * 4];
      var chs := s.ToCharArray;
      
      for i: integer := 0 to chs.Length - 1 do
        if Leters.ContainsKey(chs[i]) then
          CharOnBitMap(chs[i], i * 8 + 2, 0, BitMap) else
          WTF('Log.txt', 'No such leter as ', chs[i], ' ', ord(chs[i]));
      
      begin
        var i: cardinal := 0;
        for y: byte := 0 to h - 1 do
          for x: cardinal := 0 to w - 1 do
          begin
            var f := BitMap[x, y] = 1;
            clrs[i + 0] := f ? cr : bcr;
            clrs[i + 1] := f ? cg : bcg;
            clrs[i + 2] := f ? cb : bcb;
            clrs[i + 3] := f ? ca : bca;
            i += 4;
          end;
      end;
      
      Result := new Texture(w, h, clrs, true, true, true, true);
    end;
    
    procedure Draw(mode: GLenum; pts: sequence of Tvec3d; r, g, b, a: Single);
    begin
      glColor4f(r, g, b, a);
      glBindTexture(GL_TEXTURE_2D, id);
      glBegin(mode);
      foreach var pt in pts do
      begin
        glTexCoord2f(pt.TX, pt.TY);
        glVertex3d(pt.X, pt.Y, pt.Z);
      end;
      glEnd;
      glBindTexture(GL_TEXTURE_2D, 0);
    end;
    
    procedure Draw(mode: GLenum; pts: sequence of Tvec3d) := Draw(mode, pts, 1, 1, 1, 1);
  
  end;

type
  MyFormType = class(System.Windows.Forms.Form)
    
    timer: System.Windows.Forms.Timer;
    components: System.ComponentModel.IContainer;
    
    RedrawProc: procedure;
    
    procedure TimerTick(sender: Object; e: system.EventArgs) := RedrawProc;
    
    constructor(x, y, w, h, I: integer; Init, Redraw: procedure);
    begin
      self.Left := x;
      self.top := y;
      self.Width := w;
      self.Height := h;
      self.RedrawProc := Redraw;
      components := new System.ComponentModel.Container;
      timer := new System.Windows.Forms.Timer(self.components);
      SuspendLayout;
      timer.Enabled := true;
      timer.Interval := I;
      _hdc := GetDC(self.Handle.ToInt32());
      OpenGLInit(self.Handle);
      
      glShadeModel(GL_SMOOTH);
      
      glEnable(GL_DEPTH_TEST);
      glDepthFunc(GL_LEQUAL);
      glClearDepth(1.0);
      glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);
      
      glEnable(GL_BLEND);
      glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
      
      glEnable(GL_TEXTURE_2D);
      Init;
      
      glMatrixMode(GL_PROJECTION);
      glLoadIdentity;
      glViewport(0, 0, Width, Height);
      gluPerspective(45.0, Width / Height, 0.1, real.MaxValue);
      glClearColor(0.0, 0.0, 0.0, 1.0);
      
      glMatrixMode(GL_MODELVIEW);
      
      Cursor.Dispose;
      timer.Tick += TimerTick;
    end;
  
  end;

//ToDo delete
type

  gr = {static} class
    
    {$region 2D}
    
    public class procedure Polygon(Fill: boolean; cr, cg, cb, ca: Single; pts: array of vec2f);
    begin
      if Fill then
        glBegin(GL_POLYGON) else
        glBegin(GL_LINE_LOOP);
      glColor4f(cr, cg, cb, ca);
      for i: integer := 0 to pts.Length - 1 do
        glVertex2f(pts[i].X, pts[i].Y);
      glEnd;
    end;
    
    public class procedure Lines(cr, cg, cb, ca: Single; pts: array of vec2f);
    begin
      glBegin(GL_LINE_STRIP);
      glColor4f(cr, cg, cb, ca);
      for i: integer := 0 to pts.Length - 1 do
        glVertex2f(pts[i].X, pts[i].Y);
      glEnd;
    end;
    
    public class procedure Rectangle(Fill: boolean; cr, cg, cb, ca: Single; X, Y, W, H: Single);
    begin
      if Fill then
        glBegin(GL_QUADS) else
        glBegin(GL_LINE_LOOP);
      //glBindTexture(GL_TEXTURE_2D, TempTex);
      //gluBuild2DMipmaps(GL_TEXTURE_2D, 3, 1, 1, GL_RGB, GL_UNSIGNED_BYTE, @(new byte[3](0,0,0))[0]);
      glColor4f(cr, cg, cb, ca);
      glVertex2f(X, Y);
      glVertex2f(X + W, Y);
      glVertex2f(X + W, Y + H);
      glVertex2f(X, Y + H);
      glEnd;
    end;
    
    public class function Ellipse(X, Y, W, H: Single; pc: integer): array of vec2f;
    begin
      Result := new vec2f[pc];
      var dang := Pi * 2 / pc;
      for i: integer := 0 to pc - 1 do
        Result[i] := new vec2f(X + W * Cos(dang * i), Y + H * Sin(dang * i));
    end;
    
    public class procedure Ellipse(Fill: boolean; cr, cg, cb, ca: Single; X, Y, W, H: Single; pc: integer) := Polygon(Fill, cr, cg, cb, ca, Ellipse(X, Y, W, H, pc));
    
    //ToDo
    public class procedure Donut(ec1, ec2, ec3, ec4, ic1, ic2, ic3, ic4: byte; X, Y, eW, eH, iW, iH: Single);
    const
      EllipseQuality = 255;
    begin
      var DonPts: array[0..1] of array[1..EllipseQuality] of vec2f;
      
      var dang := Pi * 2 / EllipseQuality;
      for i: byte := 1 to EllipseQuality do
      begin
        DonPts[0, i] := new vec2f(X + iW * Cos(dang * i), Y + iH * Sin(dang * i));
        DonPts[1, i] := new vec2f(X + eW * Cos(dang * i), Y + eH * Sin(dang * i));
      end;
      
      glBegin(GL_QUAD_STRIP);
      for i: integer := 1 to EllipseQuality do
      begin
        glColor4ub(ic1, ic2, ic3, ic4);
        glVertex2f(DonPts[0, i].X, DonPts[0, i].Y);
        glColor4ub(ec1, ec2, ec3, ec4);
        glVertex2f(DonPts[1, i].X, DonPts[1, i].Y);
      end;
      glColor4ub(ic1, ic2, ic3, ic4);
      glVertex2f(DonPts[0, 1].X, DonPts[0, 1].Y);
      glColor4ub(ec1, ec2, ec3, ec4);
      glVertex2f(DonPts[1, 1].X, DonPts[1, 1].Y);
      glEnd;
    end;
    
    private class LastCurrsorPoss := new vec2i[0];
    private class ArrN: byte := 0;
    
    private class procedure CT2p1top2(var p1: vec2f; p2: vec2i);
    begin
      var Sh := new vec2f(p2.X - p1.X, p2.Y - p1.Y);
      var r := Power(sqr(Sh.X) + sqr(Sh.Y), -0.3);
      if real.IsNaN(r) or (r > 1) then r := 1;
      p1.X += Sh.X * r;
      p1.Y += Sh.Y * r;
    end;
    
    public class procedure DrawCurrsor(CT: byte; var CAct: byte; MP: vec2i);
    
    const
      CT2PetalCount: byte = 8;
      CT2PursueCount: byte = 12;
      l1 = 20;
      l2 = 120;
    
    begin
      if CT = 0 then exit;
      
      if CT = 1 then begin
        
        if LastCurrsorPoss.Length <> 0 then
          LastCurrsorPoss := new vec2i[0];
        
        var ang := CAct / 256 * Pi * 3;
        var ext := 30 - abs(Sin(ang * 2)) * 10;
        
        glBegin(GL_TRIANGLE_FAN);
        
        glColor4f(0.5, 0.5, 0.5, 0.3 + abs(sin(ang * 2)) * 0.2);
        glVertex2f(MP.X, MP.Y);
        
        glColor4f(0.5, 0.5, 0.5, 1);
        glVertex2f(MP.X + Cos(ang + Pi / 4 * 0) * ext, MP.Y + Sin(ang + Pi / 4 * 0) * ext);
        glVertex2f(MP.X + Cos(ang + Pi / 4 * 1) * 10, MP.Y + Sin(ang + Pi / 4 * 1) * 10);
        glVertex2f(MP.X + Cos(ang + Pi / 4 * 2) * ext, MP.Y + Sin(ang + Pi / 4 * 2) * ext);
        glVertex2f(MP.X + Cos(ang + Pi / 4 * 3) * 10, MP.Y + Sin(ang + Pi / 4 * 3) * 10);
        glVertex2f(MP.X + Cos(ang + Pi / 4 * 4) * ext, MP.Y + Sin(ang + Pi / 4 * 4) * ext);
        glVertex2f(MP.X + Cos(ang + Pi / 4 * 5) * 10, MP.Y + Sin(ang + Pi / 4 * 5) * 10);
        glVertex2f(MP.X + Cos(ang + Pi / 4 * 6) * ext, MP.Y + Sin(ang + Pi / 4 * 6) * ext);
        glVertex2f(MP.X + Cos(ang + Pi / 4 * 7) * 10, MP.Y + Sin(ang + Pi / 4 * 7) * 10);
        glVertex2f(MP.X + Cos(ang + Pi / 4 * 0) * ext, MP.Y + Sin(ang + Pi / 4 * 0) * ext);
        
        glEnd;
        
        CAct += 1;
        
      end else if CT = 2 then begin
        
        if LastCurrsorPoss.Length <> 256 then
        begin
          LastCurrsorPoss := new vec2i[256];
          LastCurrsorPoss.Fill(i -> MP);
        end else
          LastCurrsorPoss[ArrN] := MP;
        
        gr.Ellipse(true, 0, 0, 0, 1, MP.X, MP.Y, 7, 7, 16);
        gr.Ellipse(true, 1, 1, 1, 1, MP.X, MP.Y, 6, 6, 16);
        
        var sang := CAct / 256 * Pi * 5;
        glColor4f(0, 0, 0, 1);
        glBegin(GL_LINES);
        
        for i: byte := 1 to CT2PetalCount do
        begin
          
          var ang := sang + i / CT2PetalCount * Pi * 2;
          
          var p1 := new vec2f(MP.X + Cos(ang) * l1, MP.Y + Sin(ang) * l1);
          var p2 := new vec2f(MP.X + Cos(ang) * l2, MP.Y + Sin(ang) * l2);
          
          for i2: byte := 0 to CT2PursueCount do
          begin
            //CT2p1top2(p1,LastCurrsorPoss[byte(ArrN-i2)]);
            CT2p1top2(p2, LastCurrsorPoss[byte(ArrN - i2)]);
          end;
          
          if false then
          begin
            var r := 45;
            var nr := sqrt(sqr(p2.X - MP.X) + sqr(p2.Y - MP.Y));
            p2.X := (p2.X - MP.X) / nr * r + MP.X;
            p2.Y := (p2.Y - MP.Y) / nr * r + MP.Y;
          end;
          
          glVertex2f(p1.X, p1.Y);
          glVertex2f(p2.X, p2.Y);
          
        end;
        
        glEnd;
        
        ArrN += 1;
        CAct += 1;
        
      end else;
    end;
    
    {$endregion}
    
    {$region 3D}
    
    public class procedure Polygon(Fill: boolean; cr, cg, cb, ca: Single; pts: array of vec3d);
    begin
      if Fill then
        glBegin(GL_POLYGON) else
        glBegin(GL_LINE_LOOP);
      glColor4f(cr, cg, cb, ca);
      for i: integer := 0 to pts.Length - 1 do
        glVertex3d(pts[i].X, pts[i].Y, pts[i].Z);
      glEnd;
    end;
    
    public class procedure Lines(cr, cg, cb, ca: Single; pts: array of vec3d);
    begin
      glBegin(GL_LINE_STRIP);
      glColor4f(cr, cg, cb, ca);
      for i: integer := 0 to pts.Length - 1 do
        glVertex3d(pts[i].X, pts[i].Y, pts[i].Z);
      glEnd;
    end;
    
    public class procedure Cube(cr, cg, cb, ca: Single; X, Y, Z, dX, dY, dZ: real);
    begin
      
      glBegin(GL_QUADS);
      glColor4f(cr, cg, cb, ca);
      
      glVertex3d(X + 00, Y + 00, Z + 00);
      glVertex3d(X + dX, Y + 00, Z + 00);
      glVertex3d(X + dX, Y + dY, Z + 00);
      glVertex3d(X + 00, Y + dY, Z + 00);
      
      glVertex3d(X + 00, Y + 00, Z + dZ);
      glVertex3d(X + dX, Y + 00, Z + dZ);
      glVertex3d(X + dX, Y + dY, Z + dZ);
      glVertex3d(X + 00, Y + dY, Z + dZ);
      
      glVertex3d(X + 00, Y + 00, Z + 00);
      glVertex3d(X + dX, Y + 00, Z + 00);
      glVertex3d(X + dX, Y + 00, Z + dZ);
      glVertex3d(X + 00, Y + 00, Z + dZ);
      
      glVertex3d(X + 00, Y + dY, Z + 00);
      glVertex3d(X + dX, Y + dY, Z + 00);
      glVertex3d(X + dX, Y + dY, Z + dZ);
      glVertex3d(X + 00, Y + dY, Z + dZ);
      
      glVertex3d(X + 00, Y + 00, Z + 00);
      glVertex3d(X + 00, Y + 00, Z + dZ);
      glVertex3d(X + 00, Y + dY, Z + dZ);
      glVertex3d(X + 00, Y + dY, Z + 00);
      
      glVertex3d(X + dX, Y + 00, Z + 00);
      glVertex3d(X + dX, Y + 00, Z + dZ);
      glVertex3d(X + dX, Y + dY, Z + dZ);
      glVertex3d(X + dX, Y + dY, Z + 00);
      glEnd;
      
    end;
    
    public class procedure Sphere(Fill: boolean; cr, cg, cb, ca, X, Y, Z, dX, dY, dZ: Single; pc: integer) := Sphere(Fill, cr, cg, cb, ca, Sphere(X, Y, Z, dX, dY, dZ, pc));
    
    public class procedure Sphere(Fill: boolean; cr, cg, cb, ca: Single; pts: array[,] of vec3d);
    begin
      var w := pts.RowCount;
      var h := pts.ColCount;
      glColor4f(cr, cg, cb, ca);
      if Fill then
      begin
        glBegin(GL_QUADS);
        var lx := w - 1;
        for ix: integer := 0 to w - 1 do
        begin
          for iy: integer := 0 to h - 2 do
          begin
            with pts[ix, iy + 0] do glVertex3d(X, Y, Z);
            with pts[lx, iy + 0] do glVertex3d(X, Y, Z);
            with pts[lx, iy + 1] do glVertex3d(X, Y, Z);
            with pts[ix, iy + 1] do glVertex3d(X, Y, Z);
          end;
          lx := ix;
        end;
      end else
      begin
        glBegin(GL_LINES);
        for ix: integer := 0 to w - 1 do
          for iy: integer := 0 to h - 2 do
          begin
            with pts[ix, iy + 0] do glVertex3d(X, Y, Z);
            with pts[ix, iy + 1] do glVertex3d(X, Y, Z);
          end;
        for iy: integer := 1 to h - 2 do
        begin
          var lx := w - 1;
          for ix: integer := 0 to w - 1 do
          begin
            with pts[lx, iy] do glVertex3d(X, Y, Z);
            with pts[ix, iy] do glVertex3d(X, Y, Z);
            lx := ix;
          end;
        end;
      end;
      glEnd;
    end;
    
    public class function Sphere(X, Y, Z, dX, dY, dZ: Single; pc: integer): array[,] of vec3d;
    begin
      var w := pc * 2;
      var h := pc + 1;
      Result := new vec3d[w, h];
      var dangx := Pi / pc;
      var dangy := Pi / pc;
      for ix: integer := 0 to w - 1 do
      begin
        Result[ix, 0] := new vec3d(X, Y + dY, Z);
        for iy: integer := 1 to h - 2 do
        begin
          var AX := ix * dangx;
          var AY := iy * dangy;
          Result[ix, iy] := new vec3d(X + dX * Cos(AX) * Sin(AY), Y + dY * Cos(AY), Z + dZ * Sin(AX) * Sin(AY));
        end;
        Result[ix, h - 1] := new vec3d(X, Y - dY, Z);
      end;
    end;
  
    {$endregion}
  
  end;

begin
  var a: system.Drawing.Rectangle;
  GetWindowRect(GetDesktopWindow, a);
  WW := a.Width;
  WH := a.Height;
end.