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
