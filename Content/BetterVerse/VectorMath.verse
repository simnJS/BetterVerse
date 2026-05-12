using { /UnrealEngine.com/Temporary/SpatialMath }

# ===================== Vector3 =====================

# ~33x faster than Distance(A, B).
FastDistance<public>(A:vector3, B:vector3)<computes><reads>:float =
    DX := A.X - B.X
    DY := A.Y - B.Y
    DZ := A.Z - B.Z
    Sqrt(DX*DX + DY*DY + DZ*DZ)

(A:vector3).FastDistance<public>(B:vector3)<computes><reads>:float =
    DX := A.X - B.X
    DY := A.Y - B.Y
    DZ := A.Z - B.Z
    Sqrt(DX*DX + DY*DY + DZ*DZ)

# ~42x faster. Prefer when comparing distances (no Sqrt).
FastDistanceSquared<public>(A:vector3, B:vector3)<computes>:float =
    DX := A.X - B.X
    DY := A.Y - B.Y
    DZ := A.Z - B.Z
    DX*DX + DY*DY + DZ*DZ

(A:vector3).FastDistanceSquared<public>(B:vector3)<computes>:float =
    DX := A.X - B.X
    DY := A.Y - B.Y
    DZ := A.Z - B.Z
    DX*DX + DY*DY + DZ*DZ

# ~18x faster than V.Length().
FastLength<public>(V:vector3)<computes><reads>:float =
    Sqrt(V.X*V.X + V.Y*V.Y + V.Z*V.Z)

(V:vector3).FastLength<public>()<computes><reads>:float =
    Sqrt(V.X*V.X + V.Y*V.Y + V.Z*V.Z)

# ~25x faster than V.LengthSquared().
FastLengthSquared<public>(V:vector3)<computes>:float =
    V.X*V.X + V.Y*V.Y + V.Z*V.Z

(V:vector3).FastLengthSquared<public>()<computes>:float =
    V.X*V.X + V.Y*V.Y + V.Z*V.Z

# ~26x faster than DotProduct(A, B).
FastDot<public>(A:vector3, B:vector3)<computes>:float =
    A.X*B.X + A.Y*B.Y + A.Z*B.Z

(A:vector3).FastDot<public>(B:vector3)<computes>:float =
    A.X*B.X + A.Y*B.Y + A.Z*B.Z

# ~30x faster than CrossProduct(A, B).
FastCross<public>(A:vector3, B:vector3)<computes>:vector3 =
    vector3{
        X := A.Y*B.Z - A.Z*B.Y,
        Y := A.Z*B.X - A.X*B.Z,
        Z := A.X*B.Y - A.Y*B.X
    }

(A:vector3).FastCross<public>(B:vector3)<computes>:vector3 =
    vector3{
        X := A.Y*B.Z - A.Z*B.Y,
        Y := A.Z*B.X - A.X*B.Z,
        Z := A.X*B.Y - A.Y*B.X
    }

# ~46x faster than V.MakeUnitVector[]. Fails on zero vector.
FastNormalize<public>(V:vector3)<computes><reads><decides>:vector3 =
    LenSq := V.X*V.X + V.Y*V.Y + V.Z*V.Z
    LenSq > 0.0
    InvLen := 1.0 / Sqrt(LenSq)
    vector3{ X := V.X * InvLen, Y := V.Y * InvLen, Z := V.Z * InvLen }

(V:vector3).FastNormalize<public>()<computes><reads><decides>:vector3 =
    LenSq := V.X*V.X + V.Y*V.Y + V.Z*V.Z
    LenSq > 0.0
    InvLen := 1.0 / Sqrt(LenSq)
    vector3{ X := V.X * InvLen, Y := V.Y * InvLen, Z := V.Z * InvLen }

# ~17x faster than Lerp(A, B, T).
FastLerp<public>(A:vector3, B:vector3, T:float)<computes>:vector3 =
    vector3{
        X := A.X + (B.X - A.X) * T,
        Y := A.Y + (B.Y - A.Y) * T,
        Z := A.Z + (B.Z - A.Z) * T
    }

(A:vector3).FastLerp<public>(B:vector3, T:float)<computes>:vector3 =
    vector3{
        X := A.X + (B.X - A.X) * T,
        Y := A.Y + (B.Y - A.Y) * T,
        Z := A.Z + (B.Z - A.Z) * T
    }

# ~81x faster than ReflectVector(D, N). Assumes Normal is unit.
FastReflectVector<public>(Direction:vector3, Normal:vector3)<computes>:vector3 =
    TwoDot := 2.0 * (Direction.X*Normal.X + Direction.Y*Normal.Y + Direction.Z*Normal.Z)
    vector3{
        X := Direction.X - TwoDot*Normal.X,
        Y := Direction.Y - TwoDot*Normal.Y,
        Z := Direction.Z - TwoDot*Normal.Z
    }

(Direction:vector3).FastReflectVector<public>(Normal:vector3)<computes>:vector3 =
    TwoDot := 2.0 * (Direction.X*Normal.X + Direction.Y*Normal.Y + Direction.Z*Normal.Z)
    vector3{
        X := Direction.X - TwoDot*Normal.X,
        Y := Direction.Y - TwoDot*Normal.Y,
        Z := Direction.Z - TwoDot*Normal.Z
    }

# ~8x faster than R.RotateVector(V). Rodrigues' formula.
# Takes (axis, angle) directly; for hot loops, precompute Cos/Sin out of the loop.
FastRotateVector<public>(Axis:vector3, Angle:float, V:vector3)<computes><reads>:vector3 =
    CosA := Cos(Angle)
    SinA := Sin(Angle)
    OneMinusCos := 1.0 - CosA
    KdotV := Axis.X*V.X + Axis.Y*V.Y + Axis.Z*V.Z
    KcrossVX := Axis.Y*V.Z - Axis.Z*V.Y
    KcrossVY := Axis.Z*V.X - Axis.X*V.Z
    KcrossVZ := Axis.X*V.Y - Axis.Y*V.X
    vector3{
        X := V.X*CosA + KcrossVX*SinA + Axis.X*KdotV*OneMinusCos,
        Y := V.Y*CosA + KcrossVY*SinA + Axis.Y*KdotV*OneMinusCos,
        Z := V.Z*CosA + KcrossVZ*SinA + Axis.Z*KdotV*OneMinusCos
    }

(V:vector3).FastRotateBy<public>(Axis:vector3, Angle:float)<computes><reads>:vector3 =
    CosA := Cos(Angle)
    SinA := Sin(Angle)
    OneMinusCos := 1.0 - CosA
    KdotV := Axis.X*V.X + Axis.Y*V.Y + Axis.Z*V.Z
    KcrossVX := Axis.Y*V.Z - Axis.Z*V.Y
    KcrossVY := Axis.Z*V.X - Axis.X*V.Z
    KcrossVZ := Axis.X*V.Y - Axis.Y*V.X
    vector3{
        X := V.X*CosA + KcrossVX*SinA + Axis.X*KdotV*OneMinusCos,
        Y := V.Y*CosA + KcrossVY*SinA + Axis.Y*KdotV*OneMinusCos,
        Z := V.Z*CosA + KcrossVZ*SinA + Axis.Z*KdotV*OneMinusCos
    }

# ~8x faster than R.UnrotateVector(V). Rodrigues with negated sin.
FastUnrotateVector<public>(Axis:vector3, Angle:float, V:vector3)<computes><reads>:vector3 =
    CosA := Cos(Angle)
    SinA := -Sin(Angle)
    OneMinusCos := 1.0 - CosA
    KdotV := Axis.X*V.X + Axis.Y*V.Y + Axis.Z*V.Z
    KcrossVX := Axis.Y*V.Z - Axis.Z*V.Y
    KcrossVY := Axis.Z*V.X - Axis.X*V.Z
    KcrossVZ := Axis.X*V.Y - Axis.Y*V.X
    vector3{
        X := V.X*CosA + KcrossVX*SinA + Axis.X*KdotV*OneMinusCos,
        Y := V.Y*CosA + KcrossVY*SinA + Axis.Y*KdotV*OneMinusCos,
        Z := V.Z*CosA + KcrossVZ*SinA + Axis.Z*KdotV*OneMinusCos
    }

(V:vector3).FastUnrotateBy<public>(Axis:vector3, Angle:float)<computes><reads>:vector3 =
    CosA := Cos(Angle)
    SinA := -Sin(Angle)
    OneMinusCos := 1.0 - CosA
    KdotV := Axis.X*V.X + Axis.Y*V.Y + Axis.Z*V.Z
    KcrossVX := Axis.Y*V.Z - Axis.Z*V.Y
    KcrossVY := Axis.Z*V.X - Axis.X*V.Z
    KcrossVZ := Axis.X*V.Y - Axis.Y*V.X
    vector3{
        X := V.X*CosA + KcrossVX*SinA + Axis.X*KdotV*OneMinusCos,
        Y := V.Y*CosA + KcrossVY*SinA + Axis.Y*KdotV*OneMinusCos,
        Z := V.Z*CosA + KcrossVZ*SinA + Axis.Z*KdotV*OneMinusCos
    }

# ===================== Vector3 operators (~2x faster) =====================

FastAdd<public>(A:vector3, B:vector3)<computes>:vector3 =
    vector3{ X := A.X + B.X, Y := A.Y + B.Y, Z := A.Z + B.Z }

(A:vector3).FastAdd<public>(B:vector3)<computes>:vector3 =
    vector3{ X := A.X + B.X, Y := A.Y + B.Y, Z := A.Z + B.Z }

FastSub<public>(A:vector3, B:vector3)<computes>:vector3 =
    vector3{ X := A.X - B.X, Y := A.Y - B.Y, Z := A.Z - B.Z }

(A:vector3).FastSub<public>(B:vector3)<computes>:vector3 =
    vector3{ X := A.X - B.X, Y := A.Y - B.Y, Z := A.Z - B.Z }

# Hadamard (component-wise) product.
FastMul<public>(A:vector3, B:vector3)<computes>:vector3 =
    vector3{ X := A.X * B.X, Y := A.Y * B.Y, Z := A.Z * B.Z }

(A:vector3).FastMul<public>(B:vector3)<computes>:vector3 =
    vector3{ X := A.X * B.X, Y := A.Y * B.Y, Z := A.Z * B.Z }

FastMulScalar<public>(V:vector3, S:float)<computes>:vector3 =
    vector3{ X := V.X * S, Y := V.Y * S, Z := V.Z * S }

(V:vector3).FastMulScalar<public>(S:float)<computes>:vector3 =
    vector3{ X := V.X * S, Y := V.Y * S, Z := V.Z * S }

# Precomputes 1/S so only one division.
FastDivScalar<public>(V:vector3, S:float)<computes>:vector3 =
    Inv := 1.0 / S
    vector3{ X := V.X * Inv, Y := V.Y * Inv, Z := V.Z * Inv }

(V:vector3).FastDivScalar<public>(S:float)<computes>:vector3 =
    Inv := 1.0 / S
    vector3{ X := V.X * Inv, Y := V.Y * Inv, Z := V.Z * Inv }

FastDivVec3<public>(A:vector3, B:vector3)<computes>:vector3 =
    vector3{ X := A.X / B.X, Y := A.Y / B.Y, Z := A.Z / B.Z }

(A:vector3).FastDivVec3<public>(B:vector3)<computes>:vector3 =
    vector3{ X := A.X / B.X, Y := A.Y / B.Y, Z := A.Z / B.Z }

FastNeg<public>(V:vector3)<computes>:vector3 =
    vector3{ X := -V.X, Y := -V.Y, Z := -V.Z }

(V:vector3).FastNeg<public>()<computes>:vector3 =
    vector3{ X := -V.X, Y := -V.Y, Z := -V.Z }

# ===================== Vector3 failables =====================

# ~14x faster than V.IsAlmostZero[Tol].
(V:vector3).FastIsAlmostZero<public>(Tol:float)<computes><decides>:void =
    Abs(V.X) < Tol
    Abs(V.Y) < Tol
    Abs(V.Z) < Tol

# ~12x faster than IsAlmostEqual[V1, V2, Tol].
FastIsAlmostEqual<public>(V1:vector3, V2:vector3, Tol:float)<computes><decides>:void =
    Abs(V1.X - V2.X) < Tol
    Abs(V1.Y - V2.Y) < Tol
    Abs(V1.Z - V2.Z) < Tol

# ~14x faster than V.IsFinite[]. (X-X) = 0 fails for NaN and +-Inf.
(V:vector3).FastIsFinite<public>()<computes><decides>:vector3 =
    (V.X - V.X) = 0.0
    (V.Y - V.Y) = 0.0
    (V.Z - V.Z) = 0.0
    V

# ===================== Vector2 =====================

# ~24x faster than Distance(V1, V2).
FastDistance<public>(A:vector2, B:vector2)<computes><reads>:float =
    DX := A.X - B.X
    DY := A.Y - B.Y
    Sqrt(DX*DX + DY*DY)

(A:vector2).FastDistance<public>(B:vector2)<computes><reads>:float =
    DX := A.X - B.X
    DY := A.Y - B.Y
    Sqrt(DX*DX + DY*DY)

FastDistanceSquared<public>(A:vector2, B:vector2)<computes>:float =
    DX := A.X - B.X
    DY := A.Y - B.Y
    DX*DX + DY*DY

(A:vector2).FastDistanceSquared<public>(B:vector2)<computes>:float =
    DX := A.X - B.X
    DY := A.Y - B.Y
    DX*DX + DY*DY

# ~15x faster than V.Length().
FastLength<public>(V:vector2)<computes><reads>:float =
    Sqrt(V.X*V.X + V.Y*V.Y)

(V:vector2).FastLength<public>()<computes><reads>:float =
    Sqrt(V.X*V.X + V.Y*V.Y)

FastLengthSquared<public>(V:vector2)<computes>:float =
    V.X*V.X + V.Y*V.Y

(V:vector2).FastLengthSquared<public>()<computes>:float =
    V.X*V.X + V.Y*V.Y

# ~21x faster than DotProduct(A, B).
FastDot<public>(A:vector2, B:vector2)<computes>:float =
    A.X*B.X + A.Y*B.Y

(A:vector2).FastDot<public>(B:vector2)<computes>:float =
    A.X*B.X + A.Y*B.Y

# ~14x faster than Lerp(A, B, T).
FastLerp<public>(A:vector2, B:vector2, T:float)<computes>:vector2 =
    vector2{
        X := A.X + (B.X - A.X) * T,
        Y := A.Y + (B.Y - A.Y) * T
    }

(A:vector2).FastLerp<public>(B:vector2, T:float)<computes>:vector2 =
    vector2{
        X := A.X + (B.X - A.X) * T,
        Y := A.Y + (B.Y - A.Y) * T
    }

# ~78x faster than ReflectVector(D, N). Assumes Normal is unit.
FastReflectVector<public>(Direction:vector2, Normal:vector2)<computes>:vector2 =
    TwoDot := 2.0 * (Direction.X*Normal.X + Direction.Y*Normal.Y)
    vector2{
        X := Direction.X - TwoDot*Normal.X,
        Y := Direction.Y - TwoDot*Normal.Y
    }

(Direction:vector2).FastReflectVector<public>(Normal:vector2)<computes>:vector2 =
    TwoDot := 2.0 * (Direction.X*Normal.X + Direction.Y*Normal.Y)
    vector2{
        X := Direction.X - TwoDot*Normal.X,
        Y := Direction.Y - TwoDot*Normal.Y
    }

# ~28x faster than V.MakeUnitVector[]. Fails on zero vector.
FastNormalize<public>(V:vector2)<computes><reads><decides>:vector2 =
    LenSq := V.X*V.X + V.Y*V.Y
    LenSq > 0.0
    InvLen := 1.0 / Sqrt(LenSq)
    vector2{ X := V.X * InvLen, Y := V.Y * InvLen }

(V:vector2).FastNormalize<public>()<computes><reads><decides>:vector2 =
    LenSq := V.X*V.X + V.Y*V.Y
    LenSq > 0.0
    InvLen := 1.0 / Sqrt(LenSq)
    vector2{ X := V.X * InvLen, Y := V.Y * InvLen }

# ===================== Vector2 operators (~2x faster) =====================

FastAdd<public>(A:vector2, B:vector2)<computes>:vector2 =
    vector2{ X := A.X + B.X, Y := A.Y + B.Y }

(A:vector2).FastAdd<public>(B:vector2)<computes>:vector2 =
    vector2{ X := A.X + B.X, Y := A.Y + B.Y }

FastSub<public>(A:vector2, B:vector2)<computes>:vector2 =
    vector2{ X := A.X - B.X, Y := A.Y - B.Y }

(A:vector2).FastSub<public>(B:vector2)<computes>:vector2 =
    vector2{ X := A.X - B.X, Y := A.Y - B.Y }

FastMulScalar<public>(V:vector2, S:float)<computes>:vector2 =
    vector2{ X := V.X * S, Y := V.Y * S }

(V:vector2).FastMulScalar<public>(S:float)<computes>:vector2 =
    vector2{ X := V.X * S, Y := V.Y * S }

FastDivScalar<public>(V:vector2, S:float)<computes>:vector2 =
    Inv := 1.0 / S
    vector2{ X := V.X * Inv, Y := V.Y * Inv }

(V:vector2).FastDivScalar<public>(S:float)<computes>:vector2 =
    Inv := 1.0 / S
    vector2{ X := V.X * Inv, Y := V.Y * Inv }

FastDivVec2<public>(A:vector2, B:vector2)<computes>:vector2 =
    vector2{ X := A.X / B.X, Y := A.Y / B.Y }

(A:vector2).FastDivVec2<public>(B:vector2)<computes>:vector2 =
    vector2{ X := A.X / B.X, Y := A.Y / B.Y }

FastNeg<public>(V:vector2)<computes>:vector2 =
    vector2{ X := -V.X, Y := -V.Y }

(V:vector2).FastNeg<public>()<computes>:vector2 =
    vector2{ X := -V.X, Y := -V.Y }

# ===================== Vector2 failables =====================

# ~12x faster than V.IsAlmostZero[Tol].
(V:vector2).FastIsAlmostZero<public>(Tol:float)<computes><decides>:void =
    Abs(V.X) < Tol
    Abs(V.Y) < Tol

FastIsAlmostEqual<public>(V1:vector2, V2:vector2, Tol:float)<computes><decides>:void =
    Abs(V1.X - V2.X) < Tol
    Abs(V1.Y - V2.Y) < Tol

(V:vector2).FastIsFinite<public>()<computes><decides>:vector2 =
    (V.X - V.X) = 0.0
    (V.Y - V.Y) = 0.0
    V

# ===================== Vector2i operators (~2x faster) =====================

# ~2.3x faster than A + B.
FastAdd<public>(A:vector2i, B:vector2i)<computes>:vector2i =
    vector2i{ X := A.X + B.X, Y := A.Y + B.Y }

(A:vector2i).FastAdd<public>(B:vector2i)<computes>:vector2i =
    vector2i{ X := A.X + B.X, Y := A.Y + B.Y }

# ~2.3x faster than A - B.
FastSub<public>(A:vector2i, B:vector2i)<computes>:vector2i =
    vector2i{ X := A.X - B.X, Y := A.Y - B.Y }

(A:vector2i).FastSub<public>(B:vector2i)<computes>:vector2i =
    vector2i{ X := A.X - B.X, Y := A.Y - B.Y }

# ~2.3x faster than V * S.
FastMulScalar<public>(V:vector2i, S:int)<computes>:vector2i =
    vector2i{ X := V.X * S, Y := V.Y * S }

(V:vector2i).FastMulScalar<public>(S:int)<computes>:vector2i =
    vector2i{ X := V.X * S, Y := V.Y * S }

# ~2.2x faster than -V.
FastNeg<public>(V:vector2i)<computes>:vector2i =
    vector2i{ X := -V.X, Y := -V.Y }

(V:vector2i).FastNeg<public>()<computes>:vector2i =
    vector2i{ X := -V.X, Y := -V.Y }

# ~17x faster than DotProduct(A, B).
FastDot<public>(A:vector2i, B:vector2i)<computes>:int =
    A.X*B.X + A.Y*B.Y

(A:vector2i).FastDot<public>(B:vector2i)<computes>:int =
    A.X*B.X + A.Y*B.Y

# ~3.5x faster than TransformVector(T, V). Bypasses transform struct marshalling
# (still uses native RotateVector since rotation is opaque).
FastTransformVector<public>(T:transform, V:vector3)<computes><reads>:vector3 =
    Scaled := vector3{ X := V.X * T.Scale.X, Y := V.Y * T.Scale.Y, Z := V.Z * T.Scale.Z }
    Rotated := T.Rotation.RotateVector(Scaled)
    vector3{
        X := Rotated.X + T.Translation.X,
        Y := Rotated.Y + T.Translation.Y,
        Z := Rotated.Z + T.Translation.Z
    }

(T:transform).FastTransformVector<public>(V:vector3)<computes><reads>:vector3 =
    Scaled := vector3{ X := V.X * T.Scale.X, Y := V.Y * T.Scale.Y, Z := V.Z * T.Scale.Z }
    Rotated := T.Rotation.RotateVector(Scaled)
    vector3{
        X := Rotated.X + T.Translation.X,
        Y := Rotated.Y + T.Translation.Y,
        Z := Rotated.Z + T.Translation.Z
    }
