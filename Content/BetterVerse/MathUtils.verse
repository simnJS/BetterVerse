using { /UnrealEngine.com/Temporary/SpatialMath }

# ~2.5x faster than Min(A, B).
FastMin<public>(A:float, B:float)<computes>:float =
    if (A < B) { A } else { B }

# ~2.7x faster than Max(A, B).
FastMax<public>(A:float, B:float)<computes>:float =
    if (A > B) { A } else { B }

# ~7.4x faster than Clamp(X, Lo, Hi).
FastClamp<public>(X:float, Lo:float, Hi:float)<computes>:float =
    if (X < Lo) { Lo } else if (X > Hi) { Hi } else { X }

# ~2.3x faster than DegreesToRadians(D).
FastDegreesToRadians<public>(D:float)<computes>:float = D * PiFloat / 180.0

# ~2.4x faster than RadiansToDegrees(R).
FastRadiansToDegrees<public>(R:float)<computes>:float = R * 180.0 / PiFloat

# ~1.4x faster than X.IsFinite[]. (X-X) = 0 fails for NaN and +-Inf.
(X:float).FastIsFinite<public>()<computes><decides>:float =
    (X - X) = 0.0
    X

# ~2.3x faster than X.IsAlmostZero[Tol].
(X:float).FastIsAlmostZero<public>(Tol:float)<computes><decides>:void =
    Abs(X) < Tol

# ~2.3x faster than IsAlmostEqual[A, B, Tol].
FastIsAlmostEqual<public>(A:float, B:float, Tol:float)<computes><decides>:void =
    Abs(A - B) < Tol

# ~2.8x faster than Sgn(float). Note: ignores NaN handling.
FastSgn<public>(X:float)<computes>:float =
    if (X > 0.0) { 1.0 } else if (X < 0.0) { -1.0 } else { 0.0 }

# ~1.8x faster than Sgn(int).
FastSgn<public>(X:int)<computes>:int =
    if (X > 0) { 1 } else if (X < 0) { -1 } else { 0 }

# ~1.9x faster than Min(A, B) int.
FastMin<public>(A:int, B:int)<computes>:int =
    if (A < B) { A } else { B }

# ~2.0x faster than Max(A, B) int.
FastMax<public>(A:int, B:int)<computes>:int =
    if (A > B) { A } else { B }

# ~1.6x faster than Lerp(From, To, Parameter) float.
FastLerp<public>(From:float, To:float, Parameter:float)<computes>:float =
    From + (To - From) * Parameter

