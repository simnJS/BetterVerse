
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /Verse.org/Random }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { BetterVerse }

math_unittest_device := class(creative_device):

    @editable Tol:float = 0.0001

    OnBegin<override>()<suspends>:void=
        Print("=== Unit Tests: Native vs Custom ===")
        Print("Tolerance: {Tol}")
        Sleep(0.1)

        A3 := vector3{ X := 3.0, Y := 4.0, Z := 12.0 }
        B3 := vector3{ X := 1.0, Y := 2.0, Z := 2.0 }
        A2 := vector2{ X := 3.0, Y := 4.0 }
        B2 := vector2{ X := 1.0, Y := 2.0 }
        Axis := vector3{ X := 0.0, Y := 0.0, Z := 1.0 }
        Angle := 1.5707963
        Normal3 := vector3{ X := 0.0, Y := 0.0, Z := 1.0 }
        Normal2 := vector2{ X := 1.0, Y := 0.0 }
        Scalar := 2.5

        # ===== Vec3 distance/length =====
        AssertCloseFloat("FastDistance(vec3)", Distance(A3, B3), A3.FastDistance(B3))
        AssertCloseFloat("FastDistanceSquared(vec3)", DistanceSquared(A3, B3), A3.FastDistanceSquared(B3))
        AssertCloseFloat("FastLength(vec3)", A3.Length(), A3.FastLength())
        AssertCloseFloat("FastLengthSquared(vec3)", A3.LengthSquared(), A3.FastLengthSquared())
        AssertCloseFloat("FastDot(vec3)", DotProduct(A3, B3), A3.FastDot(B3))
        AssertCloseVec3("FastCross(vec3)", CrossProduct(A3, B3), A3.FastCross(B3))

        # Normalize (both failable)
        if (NN3 := A3.MakeUnitVector[], NC3 := A3.FastNormalize[]):
            AssertCloseVec3("FastNormalize(vec3)", NN3, NC3)
        else:
            Print("[FAIL] FastNormalize(vec3) one or both failed")

        # Lerp -- type-annotate to disambiguate from float Lerp
        var NL3:vector3 = Lerp(A3, B3, 0.3)
        AssertCloseVec3("FastLerp(vec3)", NL3, A3.FastLerp(B3, 0.3))

        # ===== Vec3 rotation =====
        R := MakeRotation(Axis, Angle)
        AssertCloseVec3("FastRotateVector", R.RotateVector(A3), FastRotateVector(Axis, Angle, A3))
        AssertCloseVec3("FastUnrotateVector", R.UnrotateVector(A3), FastUnrotateVector(Axis, Angle, A3))

        # Reflect (native is failable; ours assumes Normal is unit)
        if (RefN3 := ReflectVector[A3, Normal3]):
            AssertCloseVec3("FastReflectVector(vec3)", RefN3, A3.FastReflectVector(Normal3))
        else:
            Print("[FAIL] FastReflectVector(vec3) native failed")

        # ===== Vec3 operators (extension method form) =====
        AssertCloseVec3("FastAdd(vec3)", A3 + B3, A3.FastAdd(B3))
        AssertCloseVec3("FastSub(vec3)", A3 - B3, A3.FastSub(B3))
        AssertCloseVec3("FastMul(vec3)", A3 * B3, A3.FastMul(B3))
        AssertCloseVec3("FastMulScalar(vec3)", A3 * Scalar, A3.FastMulScalar(Scalar))
        AssertCloseVec3("FastDivScalar(vec3)", A3 / Scalar, A3.FastDivScalar(Scalar))
        AssertCloseVec3("FastDivVec3", A3 / B3, A3.FastDivVec3(B3))
        AssertCloseVec3("FastNeg(vec3)", -A3, A3.FastNeg())

        # ===== Vec3 failables =====
        VClose3 := vector3{ X := 0.001, Y := 0.001, Z := 0.001 }
        VFar3 := vector3{ X := 1.0, Y := 1.0, Z := 1.0 }
        AssertLogicEq("FastIsAlmostZero(close)",
            logic{VClose3.IsAlmostZero[0.01]},
            logic{VClose3.FastIsAlmostZero[0.01]})
        AssertLogicEq("FastIsAlmostZero(far)",
            logic{VFar3.IsAlmostZero[0.01]},
            logic{VFar3.FastIsAlmostZero[0.01]})
        AssertLogicEq("FastIsAlmostEqual(vec3 eq)",
            logic{IsAlmostEqual[A3, A3, 0.01]},
            logic{FastIsAlmostEqual[A3, A3, 0.01]})
        AssertLogicEq("FastIsAlmostEqual(vec3 diff)",
            logic{IsAlmostEqual[A3, B3, 0.01]},
            logic{FastIsAlmostEqual[A3, B3, 0.01]})

        # IsFinite (A3 is finite, both should succeed)
        if (NF3 := A3.IsFinite[], CF3 := A3.FastIsFinite[]):
            AssertCloseVec3("FastIsFinite(vec3)", NF3, CF3)
        else:
            Print("[FAIL] FastIsFinite(vec3) one or both failed")

        Sleep(0.1)

        # ===== Vec2 distance/length =====
        AssertCloseFloat("FastDistance(vec2)", Distance(A2, B2), A2.FastDistance(B2))
        AssertCloseFloat("FastDistanceSquared(vec2)", DistanceSquared(A2, B2), A2.FastDistanceSquared(B2))
        AssertCloseFloat("FastLength(vec2)", A2.Length(), A2.FastLength())
        AssertCloseFloat("FastLengthSquared(vec2)", A2.LengthSquared(), A2.FastLengthSquared())
        AssertCloseFloat("FastDot(vec2)", DotProduct(A2, B2), A2.FastDot(B2))

        if (NN2 := A2.MakeUnitVector[], NC2 := A2.FastNormalize[]):
            AssertCloseVec2("FastNormalize(vec2)", NN2, NC2)
        else:
            Print("[FAIL] FastNormalize(vec2) one or both failed")

        var NL2:vector2 = Lerp(A2, B2, 0.3)
        AssertCloseVec2("FastLerp(vec2)", NL2, A2.FastLerp(B2, 0.3))

        if (RefN2 := ReflectVector[A2, Normal2]):
            AssertCloseVec2("FastReflectVector(vec2)", RefN2, A2.FastReflectVector(Normal2))
        else:
            Print("[FAIL] FastReflectVector(vec2) native failed")

        # ===== Vec2 operators =====
        AssertCloseVec2("FastAdd(vec2)", A2 + B2, A2.FastAdd(B2))
        AssertCloseVec2("FastSub(vec2)", A2 - B2, A2.FastSub(B2))
        AssertCloseVec2("FastMulScalar(vec2)", A2 * Scalar, A2.FastMulScalar(Scalar))
        AssertCloseVec2("FastDivScalar(vec2)", A2 / Scalar, A2.FastDivScalar(Scalar))
        AssertCloseVec2("FastDivVec2", A2 / B2, A2.FastDivVec2(B2))
        AssertCloseVec2("FastNeg(vec2)", -A2, A2.FastNeg())

        # ===== Vec2 failables =====
        VClose2 := vector2{ X := 0.001, Y := 0.001 }
        VFar2 := vector2{ X := 1.0, Y := 1.0 }
        AssertLogicEq("FastIsAlmostZero(vec2 close)",
            logic{VClose2.IsAlmostZero[0.01]},
            logic{VClose2.FastIsAlmostZero[0.01]})
        AssertLogicEq("FastIsAlmostZero(vec2 far)",
            logic{VFar2.IsAlmostZero[0.01]},
            logic{VFar2.FastIsAlmostZero[0.01]})
        AssertLogicEq("FastIsAlmostEqual(vec2 eq)",
            logic{IsAlmostEqual[A2, A2, 0.01]},
            logic{FastIsAlmostEqual[A2, A2, 0.01]})
        AssertLogicEq("FastIsAlmostEqual(vec2 diff)",
            logic{IsAlmostEqual[A2, B2, 0.01]},
            logic{FastIsAlmostEqual[A2, B2, 0.01]})

        if (NF2 := A2.IsFinite[], CF2 := A2.FastIsFinite[]):
            AssertCloseVec2("FastIsFinite(vec2)", NF2, CF2)
        else:
            Print("[FAIL] FastIsFinite(vec2) one or both failed")

        Sleep(0.1)

        # ===== Array tests =====
        Arr := for (X := 0..9) { X }                           # [0..9]
        ArrDup := for (X := 0..19) { Mod[X, 5] or 0 }          # [0..4 repeated]

        AssertOptIntEq("FastFind(present)",
            option{Arr.Find[5]}, option{Arr.FastFind[5]})
        AssertOptIntEq("FastFind(absent)",
            option{Arr.Find[99]}, option{Arr.FastFind[99]})

        if (SN := Arr.Slice[2, 7], SC := Arr.FastSlice[2, 7]):
            AssertIntArrayEq("FastSlice", SN, SC)
        else:
            Print("[FAIL] FastSlice one or both failed")

        if (RN := Arr.RemoveElement[3], RC := Arr.FastRemoveElement[3]):
            AssertIntArrayEq("FastRemoveElement", RN, RC)
        else:
            Print("[FAIL] FastRemoveElement one or both failed")

        if (RpN := Arr.ReplaceElement[3, 999], RpC := Arr.FastReplaceElement[3, 999]):
            AssertIntArrayEq("FastReplaceElement", RpN, RpC)
        else:
            Print("[FAIL] FastReplaceElement one or both failed")

        AssertIntArrayEq("FastRemoveAllElements",
            ArrDup.RemoveAllElements(2), ArrDup.FastRemoveAllElements(2))

        if (RfN := ArrDup.RemoveFirstElement[3], RfC := ArrDup.FastRemoveFirstElement[3]):
            AssertIntArrayEq("FastRemoveFirstElement", RfN, RfC)
        else:
            Print("[FAIL] FastRemoveFirstElement one or both failed")

        if (RpfN := ArrDup.ReplaceFirstElement[3, 999], RpfC := ArrDup.FastReplaceFirstElement[3, 999]):
            AssertIntArrayEq("FastReplaceFirstElement", RpfN, RpfC)
        else:
            Print("[FAIL] FastReplaceFirstElement one or both failed")

        AssertIntArrayEq("FastReplaceAllElements",
            ArrDup.ReplaceAllElements(2, 99), ArrDup.FastReplaceAllElements(2, 99))

        Sleep(0.1)

        # ===== MathUtils =====
        AssertCloseFloat("FastMin", Min(3.5, 7.2), FastMin(3.5, 7.2))
        AssertCloseFloat("FastMin(neg)", Min(-3.5, 7.2), FastMin(-3.5, 7.2))
        AssertCloseFloat("FastMax", Max(3.5, 7.2), FastMax(3.5, 7.2))
        AssertCloseFloat("FastClamp(in)", Clamp(5.0, 0.0, 10.0), FastClamp(5.0, 0.0, 10.0))
        AssertCloseFloat("FastClamp(low)", Clamp(-5.0, 0.0, 10.0), FastClamp(-5.0, 0.0, 10.0))
        AssertCloseFloat("FastClamp(high)", Clamp(15.0, 0.0, 10.0), FastClamp(15.0, 0.0, 10.0))
        AssertCloseFloat("FastDegreesToRadians(90)", DegreesToRadians(90.0), FastDegreesToRadians(90.0))
        AssertCloseFloat("FastDegreesToRadians(180)", DegreesToRadians(180.0), FastDegreesToRadians(180.0))
        AssertCloseFloat("FastRadiansToDegrees(PI)", RadiansToDegrees(3.1415927), FastRadiansToDegrees(3.1415927))

        # Float failables
        TestF1 := 3.14
        TestF2 := 0.001
        TestF3 := 1.0
        AssertLogicEq("FastFloatIsFinite",
            logic{TestF1.IsFinite[]}, logic{TestF1.FastIsFinite[]})
        AssertLogicEq("FastFloatIsAlmostZero(small)",
            logic{TestF2.IsAlmostZero[0.01]}, logic{TestF2.FastIsAlmostZero[0.01]})
        AssertLogicEq("FastFloatIsAlmostZero(big)",
            logic{TestF3.IsAlmostZero[0.01]}, logic{TestF3.FastIsAlmostZero[0.01]})
        AssertLogicEq("FastFloatIsAlmostEqual(eq)",
            logic{IsAlmostEqual[3.14, 3.14001, 0.01]}, logic{FastIsAlmostEqual[3.14, 3.14001, 0.01]})
        AssertLogicEq("FastFloatIsAlmostEqual(diff)",
            logic{IsAlmostEqual[3.14, 5.0, 0.01]}, logic{FastIsAlmostEqual[3.14, 5.0, 0.01]})

        Print("=== Unit Tests Complete ===")

    # =====================================================
    # Assert helpers
    # =====================================================
    AssertCloseFloat<private>(Name:string, Native:float, Custom:float)<transacts>:void=
        Diff := Abs(Native - Custom)
        if (Diff < Tol):
            Print("[PASS] {Name}: {Native} ~= {Custom} (diff={Diff})")
        else:
            Print("[FAIL] {Name}: native={Native} custom={Custom} diff={Diff}")

    AssertCloseVec3<private>(Name:string, Native:vector3, Custom:vector3)<transacts>:void=
        DX := Abs(Native.X - Custom.X)
        DY := Abs(Native.Y - Custom.Y)
        DZ := Abs(Native.Z - Custom.Z)
        if (DX < Tol and DY < Tol and DZ < Tol):
            Print("[PASS] {Name}: ({Native.X},{Native.Y},{Native.Z}) ~= ({Custom.X},{Custom.Y},{Custom.Z})")
        else:
            Print("[FAIL] {Name}: native=({Native.X},{Native.Y},{Native.Z}) custom=({Custom.X},{Custom.Y},{Custom.Z}) diff=({DX},{DY},{DZ})")

    AssertCloseVec2<private>(Name:string, Native:vector2, Custom:vector2)<transacts>:void=
        DX := Abs(Native.X - Custom.X)
        DY := Abs(Native.Y - Custom.Y)
        if (DX < Tol and DY < Tol):
            Print("[PASS] {Name}: ({Native.X},{Native.Y}) ~= ({Custom.X},{Custom.Y})")
        else:
            Print("[FAIL] {Name}: native=({Native.X},{Native.Y}) custom=({Custom.X},{Custom.Y}) diff=({DX},{DY})")

    AssertLogicEq<private>(Name:string, Native:logic, Custom:logic)<transacts>:void=
        N := if (Native?) { 1 } else { 0 }
        C := if (Custom?) { 1 } else { 0 }
        NStr := if (Native?) { "true" } else { "false" }
        CStr := if (Custom?) { "true" } else { "false" }
        if (N = C):
            Print("[PASS] {Name}: both {NStr}")
        else:
            Print("[FAIL] {Name}: native={NStr} custom={CStr}")

    AssertOptIntEq<private>(Name:string, Native:?int, Custom:?int)<transacts>:void=
        NV := Native? or -999999
        CV := Custom? or -999999
        if (NV = CV):
            Print("[PASS] {Name}: both {NV}")
        else:
            Print("[FAIL] {Name}: native={NV} custom={CV}")

    AssertIntArrayEq<private>(Name:string, Native:[]int, Custom:[]int)<transacts>:void=
        if (Native.Length = Custom.Length):
            var Mismatches:int = 0
            for (I -> X : Native):
                if (Y := Custom[I], X <> Y):
                    set Mismatches += 1
            if (Mismatches = 0):
                Print("[PASS] {Name}: arrays equal (len={Native.Length})")
            else:
                Print("[FAIL] {Name}: {Mismatches} mismatches in {Native.Length} elements")
        else:
            Print("[FAIL] {Name}: length mismatch native={Native.Length} custom={Custom.Length}")
