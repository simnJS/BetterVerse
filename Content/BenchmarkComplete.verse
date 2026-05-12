
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /Verse.org/Random }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { BetterVerse }

# Complete benchmark device. Drop it in a map, hit play, read profile() times
# in the log. Flip @editable flags to skip sections if a single tick budget
# can't fit everything on your machine.
benchmark_complete_device := class(creative_device):

    @editable Iterations:int = 2000
    @editable VecIterations:int = 500
    @editable ArrayIterations:int = 100
    @editable ArraySize:int = 500

    @editable RunVec3Core:logic = true
    @editable RunVec3Rotation:logic = true
    @editable RunVec3Operators:logic = true
    @editable RunVec3Failables:logic = true
    @editable RunVec2Core:logic = true
    @editable RunVec2Operators:logic = true
    @editable RunVec2Failables:logic = true
    @editable RunVec2iOperators:logic = true
    @editable RunTransform:logic = true
    @editable RunArray:logic = true
    @editable RunMathScalar:logic = true

    OnBegin<override>()<suspends>:void=
        Print("=== BenchmarkComplete: Native vs BetterVerse ===")
        Print("Iter:{Iterations} VecIter:{VecIterations} ArrIter:{ArrayIterations} ArrSize:{ArraySize}")
        Sleep(0.1)

        if (RunVec3Core?). RunVec3CoreSection()
        if (RunVec3Rotation?). RunVec3RotationSection()
        if (RunVec3Operators?). RunVec3OperatorsSection()
        if (RunVec3Failables?). RunVec3FailablesSection()
        if (RunVec2Core?). RunVec2CoreSection()
        if (RunVec2Operators?). RunVec2OperatorsSection()
        if (RunVec2Failables?). RunVec2FailablesSection()
        if (RunVec2iOperators?). RunVec2iOperatorsSection()
        if (RunTransform?). RunTransformSection()
        if (RunArray?). RunArraySection()
        if (RunMathScalar?). RunMathScalarSection()

        Print("=== BenchmarkComplete done ===")

    # =====================================================
    # Helpers
    # =====================================================
    MakeRandomVec3<private>()<transacts>:vector3=
        vector3{ X := GetRandomFloat(-1000.0, 1000.0), Y := GetRandomFloat(-1000.0, 1000.0), Z := GetRandomFloat(-1000.0, 1000.0) }

    MakeRandomUnitVec3<private>()<transacts>:vector3=
        V := MakeRandomVec3()
        L := Sqrt(V.X*V.X + V.Y*V.Y + V.Z*V.Z)
        InvL := 1.0 / L
        vector3{ X := V.X*InvL, Y := V.Y*InvL, Z := V.Z*InvL }

    MakeRandomVec2<private>()<transacts>:vector2=
        vector2{ X := GetRandomFloat(-1000.0, 1000.0), Y := GetRandomFloat(-1000.0, 1000.0) }

    MakeRandomUnitVec2<private>()<transacts>:vector2=
        V := MakeRandomVec2()
        L := Sqrt(V.X*V.X + V.Y*V.Y)
        InvL := 1.0 / L
        vector2{ X := V.X*InvL, Y := V.Y*InvL }

    MakeRandomVec2i<private>()<transacts>:vector2i=
        vector2i{ X := GetRandomInt(-1000, 1000), Y := GetRandomInt(-1000, 1000) }

    MakeIntArray<private>(Size:int)<transacts>:[]int=
        for (X := 0..Size - 1) { X }

    MakeIntArrayWithDupes<private>(Size:int)<transacts>:[]int=
        for (X := 0..Size - 1) { Mod[X, 5] or 0 }

    # =====================================================
    # Vec3 core
    # =====================================================
    RunVec3CoreSection<private>()<suspends>:void=
        Print("--- Vec3 core ---")
        BenchPair_Vec3_Distance(); Sleep(0.1)
        BenchPair_Vec3_DistanceSquared(); Sleep(0.1)
        BenchPair_Vec3_Length(); Sleep(0.1)
        BenchPair_Vec3_LengthSquared(); Sleep(0.1)
        BenchPair_Vec3_Dot(); Sleep(0.1)
        BenchPair_Vec3_Cross(); Sleep(0.1)
        BenchPair_Vec3_Normalize(); Sleep(0.1)
        BenchPair_Vec3_Lerp(); Sleep(0.1)
        BenchPair_Vec3_Reflect(); Sleep(0.1)

    BenchPair_Vec3_Distance<private>()<transacts>:void=
        A := MakeRandomVec3(); B := MakeRandomVec3()
        var AccN:float = 0.0; var AccC:float = 0.0
        profile("Native_Vec3_Distance"):
            for (I := 1..Iterations):
                AP := vector3{ X := A.X + I * 0.001, Y := A.Y, Z := A.Z }
                set AccN += Distance(AP, B)
        profile("Custom_Vec3_Distance"):
            for (I := 1..Iterations):
                AP := vector3{ X := A.X + I * 0.001, Y := A.Y, Z := A.Z }
                set AccC += AP.FastDistance(B)
        Print("Vec3_Distance N={AccN} C={AccC}")

    BenchPair_Vec3_DistanceSquared<private>()<transacts>:void=
        A := MakeRandomVec3(); B := MakeRandomVec3()
        var AccN:float = 0.0; var AccC:float = 0.0
        profile("Native_Vec3_DistanceSquared"):
            for (I := 1..Iterations):
                AP := vector3{ X := A.X + I * 0.001, Y := A.Y, Z := A.Z }
                set AccN += DistanceSquared(AP, B)
        profile("Custom_Vec3_DistanceSquared"):
            for (I := 1..Iterations):
                AP := vector3{ X := A.X + I * 0.001, Y := A.Y, Z := A.Z }
                set AccC += AP.FastDistanceSquared(B)
        Print("Vec3_DistanceSquared N={AccN} C={AccC}")

    BenchPair_Vec3_Length<private>()<transacts>:void=
        V := MakeRandomVec3()
        var AccN:float = 0.0; var AccC:float = 0.0
        profile("Native_Vec3_Length"):
            for (I := 1..Iterations):
                VP := vector3{ X := V.X + I * 0.001, Y := V.Y, Z := V.Z }
                set AccN += VP.Length()
        profile("Custom_Vec3_Length"):
            for (I := 1..Iterations):
                VP := vector3{ X := V.X + I * 0.001, Y := V.Y, Z := V.Z }
                set AccC += VP.FastLength()
        Print("Vec3_Length N={AccN} C={AccC}")

    BenchPair_Vec3_LengthSquared<private>()<transacts>:void=
        V := MakeRandomVec3()
        var AccN:float = 0.0; var AccC:float = 0.0
        profile("Native_Vec3_LengthSquared"):
            for (I := 1..Iterations):
                VP := vector3{ X := V.X + I * 0.001, Y := V.Y, Z := V.Z }
                set AccN += VP.LengthSquared()
        profile("Custom_Vec3_LengthSquared"):
            for (I := 1..Iterations):
                VP := vector3{ X := V.X + I * 0.001, Y := V.Y, Z := V.Z }
                set AccC += VP.FastLengthSquared()
        Print("Vec3_LengthSquared N={AccN} C={AccC}")

    BenchPair_Vec3_Dot<private>()<transacts>:void=
        A := MakeRandomVec3(); B := MakeRandomVec3()
        var AccN:float = 0.0; var AccC:float = 0.0
        profile("Native_Vec3_Dot"):
            for (I := 1..Iterations):
                AP := vector3{ X := A.X + I * 0.001, Y := A.Y, Z := A.Z }
                set AccN += DotProduct(AP, B)
        profile("Custom_Vec3_Dot"):
            for (I := 1..Iterations):
                AP := vector3{ X := A.X + I * 0.001, Y := A.Y, Z := A.Z }
                set AccC += AP.FastDot(B)
        Print("Vec3_Dot N={AccN} C={AccC}")

    BenchPair_Vec3_Cross<private>()<transacts>:void=
        A := MakeRandomVec3(); B := MakeRandomVec3()
        var AccN:float = 0.0; var AccC:float = 0.0
        profile("Native_Vec3_Cross"):
            for (I := 1..VecIterations):
                AP := vector3{ X := A.X + I * 0.001, Y := A.Y, Z := A.Z }
                R := CrossProduct(AP, B)
                set AccN += R.X + R.Y + R.Z
        profile("Custom_Vec3_Cross"):
            for (I := 1..VecIterations):
                AP := vector3{ X := A.X + I * 0.001, Y := A.Y, Z := A.Z }
                R := AP.FastCross(B)
                set AccC += R.X + R.Y + R.Z
        Print("Vec3_Cross N={AccN} C={AccC}")

    BenchPair_Vec3_Normalize<private>()<transacts>:void=
        V := MakeRandomVec3()
        var AccN:float = 0.0; var AccC:float = 0.0
        profile("Native_Vec3_Normalize"):
            for (I := 1..VecIterations):
                VP := vector3{ X := V.X + I * 0.001, Y := V.Y, Z := V.Z }
                if (N := VP.MakeUnitVector[]). set AccN += N.X + N.Y + N.Z
        profile("Custom_Vec3_Normalize"):
            for (I := 1..VecIterations):
                VP := vector3{ X := V.X + I * 0.001, Y := V.Y, Z := V.Z }
                if (N := VP.FastNormalize[]). set AccC += N.X + N.Y + N.Z
        Print("Vec3_Normalize N={AccN} C={AccC}")

    BenchPair_Vec3_Lerp<private>()<transacts>:void=
        A := MakeRandomVec3(); B := MakeRandomVec3()
        var AccN:float = 0.0; var AccC:float = 0.0
        profile("Native_Vec3_Lerp"):
            for (I := 1..VecIterations):
                T := (I * 1.0) / (VecIterations * 1.0)
                L:vector3 = Lerp(A, B, T)
                set AccN += L.X + L.Y + L.Z
        profile("Custom_Vec3_Lerp"):
            for (I := 1..VecIterations):
                T := (I * 1.0) / (VecIterations * 1.0)
                L := A.FastLerp(B, T)
                set AccC += L.X + L.Y + L.Z
        Print("Vec3_Lerp N={AccN} C={AccC}")

    BenchPair_Vec3_Reflect<private>()<transacts>:void=
        Normal := MakeRandomUnitVec3(); V := MakeRandomVec3()
        var AccN:float = 0.0; var AccC:float = 0.0
        profile("Native_Vec3_Reflect"):
            for (I := 1..VecIterations):
                VP := vector3{ X := V.X + I * 0.001, Y := V.Y, Z := V.Z }
                if (R := ReflectVector[VP, Normal]). set AccN += R.X + R.Y + R.Z
        profile("Custom_Vec3_Reflect"):
            for (I := 1..VecIterations):
                VP := vector3{ X := V.X + I * 0.001, Y := V.Y, Z := V.Z }
                R := VP.FastReflectVector(Normal)
                set AccC += R.X + R.Y + R.Z
        Print("Vec3_Reflect N={AccN} C={AccC}")

    # =====================================================
    # Vec3 rotation
    # =====================================================
    RunVec3RotationSection<private>()<suspends>:void=
        Print("--- Vec3 rotation ---")
        BenchPair_Vec3_RotateVector(); Sleep(0.1)
        BenchPair_Vec3_UnrotateVector(); Sleep(0.1)

    BenchPair_Vec3_RotateVector<private>()<transacts>:void=
        Axis := MakeRandomUnitVec3(); Angle := GetRandomFloat(0.0, 6.28)
        R := MakeRotation(Axis, Angle); V := MakeRandomVec3()
        var AccN:float = 0.0; var AccC:float = 0.0
        profile("Native_Vec3_RotateVector"):
            for (I := 1..VecIterations):
                VP := vector3{ X := V.X + I * 0.001, Y := V.Y, Z := V.Z }
                Rot := R.RotateVector(VP)
                set AccN += Rot.X + Rot.Y + Rot.Z
        profile("Custom_Vec3_RotateVector"):
            for (I := 1..VecIterations):
                VP := vector3{ X := V.X + I * 0.001, Y := V.Y, Z := V.Z }
                Rot := FastRotateVector(Axis, Angle, VP)
                set AccC += Rot.X + Rot.Y + Rot.Z
        Print("Vec3_RotateVector N={AccN} C={AccC}")

    BenchPair_Vec3_UnrotateVector<private>()<transacts>:void=
        Axis := MakeRandomUnitVec3(); Angle := GetRandomFloat(0.0, 6.28)
        R := MakeRotation(Axis, Angle); V := MakeRandomVec3()
        var AccN:float = 0.0; var AccC:float = 0.0
        profile("Native_Vec3_UnrotateVector"):
            for (I := 1..VecIterations):
                VP := vector3{ X := V.X + I * 0.001, Y := V.Y, Z := V.Z }
                Rot := R.UnrotateVector(VP)
                set AccN += Rot.X + Rot.Y + Rot.Z
        profile("Custom_Vec3_UnrotateVector"):
            for (I := 1..VecIterations):
                VP := vector3{ X := V.X + I * 0.001, Y := V.Y, Z := V.Z }
                Rot := FastUnrotateVector(Axis, Angle, VP)
                set AccC += Rot.X + Rot.Y + Rot.Z
        Print("Vec3_UnrotateVector N={AccN} C={AccC}")

    # =====================================================
    # Vec3 operators
    # =====================================================
    RunVec3OperatorsSection<private>()<suspends>:void=
        Print("--- Vec3 operators ---")
        BenchPair_Vec3_Add(); Sleep(0.1)
        BenchPair_Vec3_Sub(); Sleep(0.1)
        BenchPair_Vec3_Mul(); Sleep(0.1)
        BenchPair_Vec3_MulScalar(); Sleep(0.1)
        BenchPair_Vec3_DivScalar(); Sleep(0.1)
        BenchPair_Vec3_DivVec3(); Sleep(0.1)
        BenchPair_Vec3_Neg(); Sleep(0.1)

    BenchPair_Vec3_Add<private>()<transacts>:void=
        A := MakeRandomVec3(); B := MakeRandomVec3()
        var AccN:float = 0.0; var AccC:float = 0.0
        profile("Native_Vec3_Add"):
            for (I := 1..VecIterations):
                AP := vector3{ X := A.X + I * 0.001, Y := A.Y, Z := A.Z }
                R := AP + B
                set AccN += R.X + R.Y + R.Z
        profile("Custom_Vec3_Add"):
            for (I := 1..VecIterations):
                AP := vector3{ X := A.X + I * 0.001, Y := A.Y, Z := A.Z }
                R := AP.FastAdd(B)
                set AccC += R.X + R.Y + R.Z
        Print("Vec3_Add N={AccN} C={AccC}")

    BenchPair_Vec3_Sub<private>()<transacts>:void=
        A := MakeRandomVec3(); B := MakeRandomVec3()
        var AccN:float = 0.0; var AccC:float = 0.0
        profile("Native_Vec3_Sub"):
            for (I := 1..VecIterations):
                AP := vector3{ X := A.X + I * 0.001, Y := A.Y, Z := A.Z }
                R := AP - B
                set AccN += R.X + R.Y + R.Z
        profile("Custom_Vec3_Sub"):
            for (I := 1..VecIterations):
                AP := vector3{ X := A.X + I * 0.001, Y := A.Y, Z := A.Z }
                R := AP.FastSub(B)
                set AccC += R.X + R.Y + R.Z
        Print("Vec3_Sub N={AccN} C={AccC}")

    BenchPair_Vec3_Mul<private>()<transacts>:void=
        A := MakeRandomVec3(); B := MakeRandomVec3()
        var AccN:float = 0.0; var AccC:float = 0.0
        profile("Native_Vec3_Mul"):
            for (I := 1..VecIterations):
                AP := vector3{ X := A.X + I * 0.001, Y := A.Y, Z := A.Z }
                R := AP * B
                set AccN += R.X + R.Y + R.Z
        profile("Custom_Vec3_Mul"):
            for (I := 1..VecIterations):
                AP := vector3{ X := A.X + I * 0.001, Y := A.Y, Z := A.Z }
                R := AP.FastMul(B)
                set AccC += R.X + R.Y + R.Z
        Print("Vec3_Mul N={AccN} C={AccC}")

    BenchPair_Vec3_MulScalar<private>()<transacts>:void=
        A := MakeRandomVec3(); S := GetRandomFloat(0.1, 10.0)
        var AccN:float = 0.0; var AccC:float = 0.0
        profile("Native_Vec3_MulScalar"):
            for (I := 1..VecIterations):
                AP := vector3{ X := A.X + I * 0.001, Y := A.Y, Z := A.Z }
                R := AP * S
                set AccN += R.X + R.Y + R.Z
        profile("Custom_Vec3_MulScalar"):
            for (I := 1..VecIterations):
                AP := vector3{ X := A.X + I * 0.001, Y := A.Y, Z := A.Z }
                R := AP.FastMulScalar(S)
                set AccC += R.X + R.Y + R.Z
        Print("Vec3_MulScalar N={AccN} C={AccC}")

    BenchPair_Vec3_DivScalar<private>()<transacts>:void=
        A := MakeRandomVec3(); S := GetRandomFloat(1.0, 10.0)
        var AccN:float = 0.0; var AccC:float = 0.0
        profile("Native_Vec3_DivScalar"):
            for (I := 1..VecIterations):
                AP := vector3{ X := A.X + I * 0.001, Y := A.Y, Z := A.Z }
                R := AP / S
                set AccN += R.X + R.Y + R.Z
        profile("Custom_Vec3_DivScalar"):
            for (I := 1..VecIterations):
                AP := vector3{ X := A.X + I * 0.001, Y := A.Y, Z := A.Z }
                R := AP.FastDivScalar(S)
                set AccC += R.X + R.Y + R.Z
        Print("Vec3_DivScalar N={AccN} C={AccC}")

    BenchPair_Vec3_DivVec3<private>()<transacts>:void=
        A := MakeRandomVec3()
        B := vector3{ X := GetRandomFloat(1.0, 10.0), Y := GetRandomFloat(1.0, 10.0), Z := GetRandomFloat(1.0, 10.0) }
        var AccN:float = 0.0; var AccC:float = 0.0
        profile("Native_Vec3_DivVec3"):
            for (I := 1..VecIterations):
                AP := vector3{ X := A.X + I * 0.001, Y := A.Y, Z := A.Z }
                R := AP / B
                set AccN += R.X + R.Y + R.Z
        profile("Custom_Vec3_DivVec3"):
            for (I := 1..VecIterations):
                AP := vector3{ X := A.X + I * 0.001, Y := A.Y, Z := A.Z }
                R := AP.FastDivVec3(B)
                set AccC += R.X + R.Y + R.Z
        Print("Vec3_DivVec3 N={AccN} C={AccC}")

    BenchPair_Vec3_Neg<private>()<transacts>:void=
        A := MakeRandomVec3()
        var AccN:float = 0.0; var AccC:float = 0.0
        profile("Native_Vec3_Neg"):
            for (I := 1..VecIterations):
                AP := vector3{ X := A.X + I * 0.001, Y := A.Y, Z := A.Z }
                R := -AP
                set AccN += R.X + R.Y + R.Z
        profile("Custom_Vec3_Neg"):
            for (I := 1..VecIterations):
                AP := vector3{ X := A.X + I * 0.001, Y := A.Y, Z := A.Z }
                R := AP.FastNeg()
                set AccC += R.X + R.Y + R.Z
        Print("Vec3_Neg N={AccN} C={AccC}")

    # =====================================================
    # Vec3 failables
    # =====================================================
    RunVec3FailablesSection<private>()<suspends>:void=
        Print("--- Vec3 failables ---")
        BenchPair_Vec3_IsAlmostZero(); Sleep(0.1)
        BenchPair_Vec3_IsAlmostEqual(); Sleep(0.1)
        BenchPair_Vec3_IsFinite(); Sleep(0.1)

    BenchPair_Vec3_IsAlmostZero<private>()<transacts>:void=
        V := vector3{ X := 0.005, Y := 0.005, Z := 0.005 }
        var AccN:int = 0; var AccC:int = 0
        profile("Native_Vec3_IsAlmostZero"):
            for (I := 1..Iterations):
                VP := vector3{ X := V.X + I * 0.0000001, Y := V.Y, Z := V.Z }
                if (VP.IsAlmostZero[0.01]). set AccN += 1
        profile("Custom_Vec3_IsAlmostZero"):
            for (I := 1..Iterations):
                VP := vector3{ X := V.X + I * 0.0000001, Y := V.Y, Z := V.Z }
                if (VP.FastIsAlmostZero[0.01]). set AccC += 1
        Print("Vec3_IsAlmostZero N={AccN} C={AccC}")

    BenchPair_Vec3_IsAlmostEqual<private>()<transacts>:void=
        V1 := vector3{ X := 10.0, Y := 20.0, Z := 30.0 }; V2 := V1
        var AccN:int = 0; var AccC:int = 0
        profile("Native_Vec3_IsAlmostEqual"):
            for (I := 1..Iterations):
                V1P := vector3{ X := V1.X + I * 0.0000001, Y := V1.Y, Z := V1.Z }
                if (IsAlmostEqual[V1P, V2, 0.01]). set AccN += 1
        profile("Custom_Vec3_IsAlmostEqual"):
            for (I := 1..Iterations):
                V1P := vector3{ X := V1.X + I * 0.0000001, Y := V1.Y, Z := V1.Z }
                if (FastIsAlmostEqual[V1P, V2, 0.01]). set AccC += 1
        Print("Vec3_IsAlmostEqual N={AccN} C={AccC}")

    BenchPair_Vec3_IsFinite<private>()<transacts>:void=
        V := MakeRandomVec3()
        var AccN:int = 0; var AccC:int = 0
        profile("Native_Vec3_IsFinite"):
            for (I := 1..VecIterations):
                VP := vector3{ X := V.X + I * 0.001, Y := V.Y, Z := V.Z }
                if (VP.IsFinite[]). set AccN += 1
        profile("Custom_Vec3_IsFinite"):
            for (I := 1..VecIterations):
                VP := vector3{ X := V.X + I * 0.001, Y := V.Y, Z := V.Z }
                if (VP.FastIsFinite[]). set AccC += 1
        Print("Vec3_IsFinite N={AccN} C={AccC}")

    # =====================================================
    # Vec2 core
    # =====================================================
    RunVec2CoreSection<private>()<suspends>:void=
        Print("--- Vec2 core ---")
        BenchPair_Vec2_Distance(); Sleep(0.1)
        BenchPair_Vec2_DistanceSquared(); Sleep(0.1)
        BenchPair_Vec2_Length(); Sleep(0.1)
        BenchPair_Vec2_LengthSquared(); Sleep(0.1)
        BenchPair_Vec2_Dot(); Sleep(0.1)
        BenchPair_Vec2_Normalize(); Sleep(0.1)
        BenchPair_Vec2_Lerp(); Sleep(0.1)
        BenchPair_Vec2_Reflect(); Sleep(0.1)

    BenchPair_Vec2_Distance<private>()<transacts>:void=
        A := MakeRandomVec2(); B := MakeRandomVec2()
        var AccN:float = 0.0; var AccC:float = 0.0
        profile("Native_Vec2_Distance"):
            for (I := 1..Iterations):
                AP := vector2{ X := A.X + I * 0.001, Y := A.Y }
                set AccN += Distance(AP, B)
        profile("Custom_Vec2_Distance"):
            for (I := 1..Iterations):
                AP := vector2{ X := A.X + I * 0.001, Y := A.Y }
                set AccC += AP.FastDistance(B)
        Print("Vec2_Distance N={AccN} C={AccC}")

    BenchPair_Vec2_DistanceSquared<private>()<transacts>:void=
        A := MakeRandomVec2(); B := MakeRandomVec2()
        var AccN:float = 0.0; var AccC:float = 0.0
        profile("Native_Vec2_DistanceSquared"):
            for (I := 1..Iterations):
                AP := vector2{ X := A.X + I * 0.001, Y := A.Y }
                set AccN += DistanceSquared(AP, B)
        profile("Custom_Vec2_DistanceSquared"):
            for (I := 1..Iterations):
                AP := vector2{ X := A.X + I * 0.001, Y := A.Y }
                set AccC += AP.FastDistanceSquared(B)
        Print("Vec2_DistanceSquared N={AccN} C={AccC}")

    BenchPair_Vec2_Length<private>()<transacts>:void=
        V := MakeRandomVec2()
        var AccN:float = 0.0; var AccC:float = 0.0
        profile("Native_Vec2_Length"):
            for (I := 1..Iterations):
                VP := vector2{ X := V.X + I * 0.001, Y := V.Y }
                set AccN += VP.Length()
        profile("Custom_Vec2_Length"):
            for (I := 1..Iterations):
                VP := vector2{ X := V.X + I * 0.001, Y := V.Y }
                set AccC += VP.FastLength()
        Print("Vec2_Length N={AccN} C={AccC}")

    BenchPair_Vec2_LengthSquared<private>()<transacts>:void=
        V := MakeRandomVec2()
        var AccN:float = 0.0; var AccC:float = 0.0
        profile("Native_Vec2_LengthSquared"):
            for (I := 1..Iterations):
                VP := vector2{ X := V.X + I * 0.001, Y := V.Y }
                set AccN += VP.LengthSquared()
        profile("Custom_Vec2_LengthSquared"):
            for (I := 1..Iterations):
                VP := vector2{ X := V.X + I * 0.001, Y := V.Y }
                set AccC += VP.FastLengthSquared()
        Print("Vec2_LengthSquared N={AccN} C={AccC}")

    BenchPair_Vec2_Dot<private>()<transacts>:void=
        A := MakeRandomVec2(); B := MakeRandomVec2()
        var AccN:float = 0.0; var AccC:float = 0.0
        profile("Native_Vec2_Dot"):
            for (I := 1..Iterations):
                AP := vector2{ X := A.X + I * 0.001, Y := A.Y }
                set AccN += DotProduct(AP, B)
        profile("Custom_Vec2_Dot"):
            for (I := 1..Iterations):
                AP := vector2{ X := A.X + I * 0.001, Y := A.Y }
                set AccC += AP.FastDot(B)
        Print("Vec2_Dot N={AccN} C={AccC}")

    BenchPair_Vec2_Normalize<private>()<transacts>:void=
        V := MakeRandomVec2()
        var AccN:float = 0.0; var AccC:float = 0.0
        profile("Native_Vec2_Normalize"):
            for (I := 1..VecIterations):
                VP := vector2{ X := V.X + I * 0.001, Y := V.Y }
                if (N := VP.MakeUnitVector[]). set AccN += N.X + N.Y
        profile("Custom_Vec2_Normalize"):
            for (I := 1..VecIterations):
                VP := vector2{ X := V.X + I * 0.001, Y := V.Y }
                if (N := VP.FastNormalize[]). set AccC += N.X + N.Y
        Print("Vec2_Normalize N={AccN} C={AccC}")

    BenchPair_Vec2_Lerp<private>()<transacts>:void=
        A := MakeRandomVec2(); B := MakeRandomVec2()
        var AccN:float = 0.0; var AccC:float = 0.0
        profile("Native_Vec2_Lerp"):
            for (I := 1..VecIterations):
                T := (I * 1.0) / (VecIterations * 1.0)
                L:vector2 = Lerp(A, B, T)
                set AccN += L.X + L.Y
        profile("Custom_Vec2_Lerp"):
            for (I := 1..VecIterations):
                T := (I * 1.0) / (VecIterations * 1.0)
                L := A.FastLerp(B, T)
                set AccC += L.X + L.Y
        Print("Vec2_Lerp N={AccN} C={AccC}")

    BenchPair_Vec2_Reflect<private>()<transacts>:void=
        Normal := MakeRandomUnitVec2(); V := MakeRandomVec2()
        var AccN:float = 0.0; var AccC:float = 0.0
        profile("Native_Vec2_Reflect"):
            for (I := 1..VecIterations):
                VP := vector2{ X := V.X + I * 0.001, Y := V.Y }
                if (R := ReflectVector[VP, Normal]). set AccN += R.X + R.Y
        profile("Custom_Vec2_Reflect"):
            for (I := 1..VecIterations):
                VP := vector2{ X := V.X + I * 0.001, Y := V.Y }
                R := VP.FastReflectVector(Normal)
                set AccC += R.X + R.Y
        Print("Vec2_Reflect N={AccN} C={AccC}")

    # =====================================================
    # Vec2 operators
    # =====================================================
    RunVec2OperatorsSection<private>()<suspends>:void=
        Print("--- Vec2 operators ---")
        BenchPair_Vec2_Add(); Sleep(0.1)
        BenchPair_Vec2_Sub(); Sleep(0.1)
        BenchPair_Vec2_MulScalar(); Sleep(0.1)
        BenchPair_Vec2_DivScalar(); Sleep(0.1)
        BenchPair_Vec2_DivVec2(); Sleep(0.1)
        BenchPair_Vec2_Neg(); Sleep(0.1)

    BenchPair_Vec2_Add<private>()<transacts>:void=
        A := MakeRandomVec2(); B := MakeRandomVec2()
        var AccN:float = 0.0; var AccC:float = 0.0
        profile("Native_Vec2_Add"):
            for (I := 1..VecIterations):
                AP := vector2{ X := A.X + I * 0.001, Y := A.Y }
                R := AP + B
                set AccN += R.X + R.Y
        profile("Custom_Vec2_Add"):
            for (I := 1..VecIterations):
                AP := vector2{ X := A.X + I * 0.001, Y := A.Y }
                R := AP.FastAdd(B)
                set AccC += R.X + R.Y
        Print("Vec2_Add N={AccN} C={AccC}")

    BenchPair_Vec2_Sub<private>()<transacts>:void=
        A := MakeRandomVec2(); B := MakeRandomVec2()
        var AccN:float = 0.0; var AccC:float = 0.0
        profile("Native_Vec2_Sub"):
            for (I := 1..VecIterations):
                AP := vector2{ X := A.X + I * 0.001, Y := A.Y }
                R := AP - B
                set AccN += R.X + R.Y
        profile("Custom_Vec2_Sub"):
            for (I := 1..VecIterations):
                AP := vector2{ X := A.X + I * 0.001, Y := A.Y }
                R := AP.FastSub(B)
                set AccC += R.X + R.Y
        Print("Vec2_Sub N={AccN} C={AccC}")

    BenchPair_Vec2_MulScalar<private>()<transacts>:void=
        A := MakeRandomVec2(); S := GetRandomFloat(0.1, 10.0)
        var AccN:float = 0.0; var AccC:float = 0.0
        profile("Native_Vec2_MulScalar"):
            for (I := 1..VecIterations):
                AP := vector2{ X := A.X + I * 0.001, Y := A.Y }
                R := AP * S
                set AccN += R.X + R.Y
        profile("Custom_Vec2_MulScalar"):
            for (I := 1..VecIterations):
                AP := vector2{ X := A.X + I * 0.001, Y := A.Y }
                R := AP.FastMulScalar(S)
                set AccC += R.X + R.Y
        Print("Vec2_MulScalar N={AccN} C={AccC}")

    BenchPair_Vec2_DivScalar<private>()<transacts>:void=
        A := MakeRandomVec2(); S := GetRandomFloat(1.0, 10.0)
        var AccN:float = 0.0; var AccC:float = 0.0
        profile("Native_Vec2_DivScalar"):
            for (I := 1..VecIterations):
                AP := vector2{ X := A.X + I * 0.001, Y := A.Y }
                R := AP / S
                set AccN += R.X + R.Y
        profile("Custom_Vec2_DivScalar"):
            for (I := 1..VecIterations):
                AP := vector2{ X := A.X + I * 0.001, Y := A.Y }
                R := AP.FastDivScalar(S)
                set AccC += R.X + R.Y
        Print("Vec2_DivScalar N={AccN} C={AccC}")

    BenchPair_Vec2_DivVec2<private>()<transacts>:void=
        A := MakeRandomVec2()
        B := vector2{ X := GetRandomFloat(1.0, 10.0), Y := GetRandomFloat(1.0, 10.0) }
        var AccN:float = 0.0; var AccC:float = 0.0
        profile("Native_Vec2_DivVec2"):
            for (I := 1..VecIterations):
                AP := vector2{ X := A.X + I * 0.001, Y := A.Y }
                R := AP / B
                set AccN += R.X + R.Y
        profile("Custom_Vec2_DivVec2"):
            for (I := 1..VecIterations):
                AP := vector2{ X := A.X + I * 0.001, Y := A.Y }
                R := AP.FastDivVec2(B)
                set AccC += R.X + R.Y
        Print("Vec2_DivVec2 N={AccN} C={AccC}")

    BenchPair_Vec2_Neg<private>()<transacts>:void=
        A := MakeRandomVec2()
        var AccN:float = 0.0; var AccC:float = 0.0
        profile("Native_Vec2_Neg"):
            for (I := 1..VecIterations):
                AP := vector2{ X := A.X + I * 0.001, Y := A.Y }
                R := -AP
                set AccN += R.X + R.Y
        profile("Custom_Vec2_Neg"):
            for (I := 1..VecIterations):
                AP := vector2{ X := A.X + I * 0.001, Y := A.Y }
                R := AP.FastNeg()
                set AccC += R.X + R.Y
        Print("Vec2_Neg N={AccN} C={AccC}")

    # =====================================================
    # Vec2 failables
    # =====================================================
    RunVec2FailablesSection<private>()<suspends>:void=
        Print("--- Vec2 failables ---")
        BenchPair_Vec2_IsAlmostZero(); Sleep(0.1)
        BenchPair_Vec2_IsAlmostEqual(); Sleep(0.1)
        BenchPair_Vec2_IsFinite(); Sleep(0.1)

    BenchPair_Vec2_IsAlmostZero<private>()<transacts>:void=
        V := vector2{ X := 0.005, Y := 0.005 }
        var AccN:int = 0; var AccC:int = 0
        profile("Native_Vec2_IsAlmostZero"):
            for (I := 1..Iterations):
                VP := vector2{ X := V.X + I * 0.0000001, Y := V.Y }
                if (VP.IsAlmostZero[0.01]). set AccN += 1
        profile("Custom_Vec2_IsAlmostZero"):
            for (I := 1..Iterations):
                VP := vector2{ X := V.X + I * 0.0000001, Y := V.Y }
                if (VP.FastIsAlmostZero[0.01]). set AccC += 1
        Print("Vec2_IsAlmostZero N={AccN} C={AccC}")

    BenchPair_Vec2_IsAlmostEqual<private>()<transacts>:void=
        V1 := vector2{ X := 10.0, Y := 20.0 }; V2 := V1
        var AccN:int = 0; var AccC:int = 0
        profile("Native_Vec2_IsAlmostEqual"):
            for (I := 1..Iterations):
                V1P := vector2{ X := V1.X + I * 0.0000001, Y := V1.Y }
                if (IsAlmostEqual[V1P, V2, 0.01]). set AccN += 1
        profile("Custom_Vec2_IsAlmostEqual"):
            for (I := 1..Iterations):
                V1P := vector2{ X := V1.X + I * 0.0000001, Y := V1.Y }
                if (FastIsAlmostEqual[V1P, V2, 0.01]). set AccC += 1
        Print("Vec2_IsAlmostEqual N={AccN} C={AccC}")

    BenchPair_Vec2_IsFinite<private>()<transacts>:void=
        V := MakeRandomVec2()
        var AccN:int = 0; var AccC:int = 0
        profile("Native_Vec2_IsFinite"):
            for (I := 1..VecIterations):
                VP := vector2{ X := V.X + I * 0.001, Y := V.Y }
                if (VP.IsFinite[]). set AccN += 1
        profile("Custom_Vec2_IsFinite"):
            for (I := 1..VecIterations):
                VP := vector2{ X := V.X + I * 0.001, Y := V.Y }
                if (VP.FastIsFinite[]). set AccC += 1
        Print("Vec2_IsFinite N={AccN} C={AccC}")

    # =====================================================
    # Vec2i operators
    # =====================================================
    RunVec2iOperatorsSection<private>()<suspends>:void=
        Print("--- Vec2i operators ---")
        BenchPair_Vec2i_Add(); Sleep(0.1)
        BenchPair_Vec2i_Sub(); Sleep(0.1)
        BenchPair_Vec2i_MulScalar(); Sleep(0.1)
        BenchPair_Vec2i_Neg(); Sleep(0.1)
        BenchPair_Vec2i_Dot(); Sleep(0.1)

    BenchPair_Vec2i_Add<private>()<transacts>:void=
        A := MakeRandomVec2i(); B := MakeRandomVec2i()
        var AccN:int = 0; var AccC:int = 0
        profile("Native_Vec2i_Add"):
            for (I := 1..VecIterations):
                AP := vector2i{ X := A.X + I, Y := A.Y }
                R := AP + B
                set AccN += R.X + R.Y
        profile("Custom_Vec2i_Add"):
            for (I := 1..VecIterations):
                AP := vector2i{ X := A.X + I, Y := A.Y }
                R := AP.FastAdd(B)
                set AccC += R.X + R.Y
        Print("Vec2i_Add N={AccN} C={AccC}")

    BenchPair_Vec2i_Sub<private>()<transacts>:void=
        A := MakeRandomVec2i(); B := MakeRandomVec2i()
        var AccN:int = 0; var AccC:int = 0
        profile("Native_Vec2i_Sub"):
            for (I := 1..VecIterations):
                AP := vector2i{ X := A.X + I, Y := A.Y }
                R := AP - B
                set AccN += R.X + R.Y
        profile("Custom_Vec2i_Sub"):
            for (I := 1..VecIterations):
                AP := vector2i{ X := A.X + I, Y := A.Y }
                R := AP.FastSub(B)
                set AccC += R.X + R.Y
        Print("Vec2i_Sub N={AccN} C={AccC}")

    BenchPair_Vec2i_MulScalar<private>()<transacts>:void=
        A := MakeRandomVec2i(); S := GetRandomInt(2, 10)
        var AccN:int = 0; var AccC:int = 0
        profile("Native_Vec2i_MulScalar"):
            for (I := 1..VecIterations):
                AP := vector2i{ X := A.X + I, Y := A.Y }
                R := AP * S
                set AccN += R.X + R.Y
        profile("Custom_Vec2i_MulScalar"):
            for (I := 1..VecIterations):
                AP := vector2i{ X := A.X + I, Y := A.Y }
                R := AP.FastMulScalar(S)
                set AccC += R.X + R.Y
        Print("Vec2i_MulScalar N={AccN} C={AccC}")

    BenchPair_Vec2i_Neg<private>()<transacts>:void=
        A := MakeRandomVec2i()
        var AccN:int = 0; var AccC:int = 0
        profile("Native_Vec2i_Neg"):
            for (I := 1..VecIterations):
                AP := vector2i{ X := A.X + I, Y := A.Y }
                R := -AP
                set AccN += R.X + R.Y
        profile("Custom_Vec2i_Neg"):
            for (I := 1..VecIterations):
                AP := vector2i{ X := A.X + I, Y := A.Y }
                R := AP.FastNeg()
                set AccC += R.X + R.Y
        Print("Vec2i_Neg N={AccN} C={AccC}")

    BenchPair_Vec2i_Dot<private>()<transacts>:void=
        A := MakeRandomVec2i(); B := MakeRandomVec2i()
        var AccN:int = 0; var AccC:int = 0
        profile("Native_Vec2i_Dot"):
            for (I := 1..VecIterations):
                AP := vector2i{ X := A.X + I, Y := A.Y }
                set AccN += DotProduct(AP, B)
        profile("Custom_Vec2i_Dot"):
            for (I := 1..VecIterations):
                AP := vector2i{ X := A.X + I, Y := A.Y }
                set AccC += AP.FastDot(B)
        Print("Vec2i_Dot N={AccN} C={AccC}")

    # =====================================================
    # Transform
    # =====================================================
    RunTransformSection<private>()<suspends>:void=
        Print("--- Transform ---")
        BenchPair_TransformVector(); Sleep(0.1)

    BenchPair_TransformVector<private>()<transacts>:void=
        Axis := vector3{ X := 0.0, Y := 0.0, Z := 1.0 }
        T := transform{
            Scale := vector3{ X := 2.0, Y := 1.5, Z := 0.5 },
            Rotation := MakeRotation(Axis, 0.7853),
            Translation := vector3{ X := 100.0, Y := 200.0, Z := 50.0 }
        }
        V := vector3{ X := 1.0, Y := 2.0, Z := 3.0 }
        var AccN:float = 0.0; var AccC:float = 0.0
        profile("Native_TransformVector"):
            for (I := 1..VecIterations):
                VP := vector3{ X := V.X + I * 0.001, Y := V.Y, Z := V.Z }
                R := TransformVector(T, VP)
                set AccN += R.X + R.Y + R.Z
        profile("Custom_TransformVector"):
            for (I := 1..VecIterations):
                VP := vector3{ X := V.X + I * 0.001, Y := V.Y, Z := V.Z }
                R := T.FastTransformVector(VP)
                set AccC += R.X + R.Y + R.Z
        Print("TransformVector N={AccN} C={AccC}")

    # =====================================================
    # Array
    # =====================================================
    RunArraySection<private>()<suspends>:void=
        Print("--- Array ---")
        BenchPair_Find(); Sleep(0.1)
        BenchPair_Slice(); Sleep(0.1)
        BenchPair_RemoveElement(); Sleep(0.1)
        BenchPair_ReplaceElement(); Sleep(0.1)
        BenchPair_RemoveAllElements(); Sleep(0.1)
        BenchPair_RemoveFirstElement(); Sleep(0.1)
        BenchPair_ReplaceFirstElement(); Sleep(0.1)
        BenchPair_ReplaceAllElements(); Sleep(0.1)

    BenchPair_Find<private>()<transacts>:void=
        Arr := MakeIntArray(ArraySize)
        var AccN:int = 0; var AccC:int = 0
        profile("Native_Find"):
            for (I := 1..ArrayIterations):
                Target := Mod[I * 7919, ArraySize] or 0
                if (Idx := Arr.Find[Target]). set AccN += Idx
        profile("Custom_Find"):
            for (I := 1..ArrayIterations):
                Target := Mod[I * 7919, ArraySize] or 0
                if (Idx := Arr.FastFind[Target]). set AccC += Idx
        Print("Find N={AccN} C={AccC}")

    @editable SliceStart:int = 125
    @editable SliceStop:int = 375

    BenchPair_Slice<private>()<transacts>:void=
        Arr := MakeIntArray(ArraySize)
        Start := SliceStart
        Stop := SliceStop
        var AccN:int = 0; var AccC:int = 0
        profile("Native_Slice"):
            for (I := 1..ArrayIterations):
                if (S := Arr.Slice[Start, Stop]). set AccN += S.Length
        profile("Custom_Slice"):
            for (I := 1..ArrayIterations):
                if (S := Arr.FastSlice[Start, Stop]). set AccC += S.Length
        Print("Slice N={AccN} C={AccC}")

    BenchPair_RemoveElement<private>()<transacts>:void=
        Arr := MakeIntArray(ArraySize)
        var AccN:int = 0; var AccC:int = 0
        profile("Native_RemoveElement"):
            for (I := 1..ArrayIterations):
                Idx := Mod[I * 7919, ArraySize] or 0
                if (R := Arr.RemoveElement[Idx]). set AccN += R.Length
        profile("Custom_RemoveElement"):
            for (I := 1..ArrayIterations):
                Idx := Mod[I * 7919, ArraySize] or 0
                if (R := Arr.FastRemoveElement[Idx]). set AccC += R.Length
        Print("RemoveElement N={AccN} C={AccC}")

    BenchPair_ReplaceElement<private>()<transacts>:void=
        Arr := MakeIntArray(ArraySize)
        var AccN:int = 0; var AccC:int = 0
        profile("Native_ReplaceElement"):
            for (I := 1..ArrayIterations):
                Idx := Mod[I * 7919, ArraySize] or 0
                if (R := Arr.ReplaceElement[Idx, I]). set AccN += R.Length
        profile("Custom_ReplaceElement"):
            for (I := 1..ArrayIterations):
                Idx := Mod[I * 7919, ArraySize] or 0
                if (R := Arr.FastReplaceElement[Idx, I]). set AccC += R.Length
        Print("ReplaceElement N={AccN} C={AccC}")

    BenchPair_RemoveAllElements<private>()<transacts>:void=
        Arr := MakeIntArrayWithDupes(ArraySize)
        var AccN:int = 0; var AccC:int = 0
        profile("Native_RemoveAllElements"):
            for (I := 1..ArrayIterations):
                Target := Mod[I, 5] or 0
                set AccN += Arr.RemoveAllElements(Target).Length
        profile("Custom_RemoveAllElements"):
            for (I := 1..ArrayIterations):
                Target := Mod[I, 5] or 0
                set AccC += Arr.FastRemoveAllElements(Target).Length
        Print("RemoveAllElements N={AccN} C={AccC}")

    BenchPair_RemoveFirstElement<private>()<transacts>:void=
        Arr := MakeIntArrayWithDupes(ArraySize)
        var AccN:int = 0; var AccC:int = 0
        profile("Native_RemoveFirstElement"):
            for (I := 1..ArrayIterations):
                Target := Mod[I, 5] or 0
                if (R := Arr.RemoveFirstElement[Target]). set AccN += R.Length
        profile("Custom_RemoveFirstElement"):
            for (I := 1..ArrayIterations):
                Target := Mod[I, 5] or 0
                if (R := Arr.FastRemoveFirstElement[Target]). set AccC += R.Length
        Print("RemoveFirstElement N={AccN} C={AccC}")

    BenchPair_ReplaceFirstElement<private>()<transacts>:void=
        Arr := MakeIntArrayWithDupes(ArraySize)
        var AccN:int = 0; var AccC:int = 0
        profile("Native_ReplaceFirstElement"):
            for (I := 1..ArrayIterations):
                Target := Mod[I, 5] or 0
                if (R := Arr.ReplaceFirstElement[Target, 99]). set AccN += R.Length
        profile("Custom_ReplaceFirstElement"):
            for (I := 1..ArrayIterations):
                Target := Mod[I, 5] or 0
                if (R := Arr.FastReplaceFirstElement[Target, 99]). set AccC += R.Length
        Print("ReplaceFirstElement N={AccN} C={AccC}")

    BenchPair_ReplaceAllElements<private>()<transacts>:void=
        Arr := MakeIntArrayWithDupes(ArraySize)
        var AccN:int = 0; var AccC:int = 0
        profile("Native_ReplaceAllElements"):
            for (I := 1..ArrayIterations):
                Target := Mod[I, 5] or 0
                set AccN += Arr.ReplaceAllElements(Target, 99).Length
        profile("Custom_ReplaceAllElements"):
            for (I := 1..ArrayIterations):
                Target := Mod[I, 5] or 0
                set AccC += Arr.FastReplaceAllElements(Target, 99).Length
        Print("ReplaceAllElements N={AccN} C={AccC}")

    # =====================================================
    # Math scalar
    # =====================================================
    RunMathScalarSection<private>()<suspends>:void=
        Print("--- Math scalar ---")
        BenchPair_MinFloat(); Sleep(0.1)
        BenchPair_MaxFloat(); Sleep(0.1)
        BenchPair_ClampFloat(); Sleep(0.1)
        BenchPair_MinInt(); Sleep(0.1)
        BenchPair_MaxInt(); Sleep(0.1)
        BenchPair_SgnFloat(); Sleep(0.1)
        BenchPair_SgnInt(); Sleep(0.1)
        BenchPair_LerpFloat(); Sleep(0.1)
        BenchPair_DegreesToRadians(); Sleep(0.1)
        BenchPair_RadiansToDegrees(); Sleep(0.1)
        BenchPair_FloatIsFinite(); Sleep(0.1)
        BenchPair_FloatIsAlmostZero(); Sleep(0.1)
        BenchPair_FloatIsAlmostEqual(); Sleep(0.1)

    BenchPair_MinFloat<private>()<transacts>:void=
        BaseA := GetRandomFloat(-100.0, 100.0); B := GetRandomFloat(-100.0, 100.0)
        var AccN:float = 0.0; var AccC:float = 0.0
        profile("Native_MinFloat"):
            for (I := 1..Iterations):
                A := BaseA + I * 0.001
                set AccN += Min(A, B)
        profile("Custom_MinFloat"):
            for (I := 1..Iterations):
                A := BaseA + I * 0.001
                set AccC += FastMin(A, B)
        Print("MinFloat N={AccN} C={AccC}")

    BenchPair_MaxFloat<private>()<transacts>:void=
        BaseA := GetRandomFloat(-100.0, 100.0); B := GetRandomFloat(-100.0, 100.0)
        var AccN:float = 0.0; var AccC:float = 0.0
        profile("Native_MaxFloat"):
            for (I := 1..Iterations):
                A := BaseA + I * 0.001
                set AccN += Max(A, B)
        profile("Custom_MaxFloat"):
            for (I := 1..Iterations):
                A := BaseA + I * 0.001
                set AccC += FastMax(A, B)
        Print("MaxFloat N={AccN} C={AccC}")

    BenchPair_ClampFloat<private>()<transacts>:void=
        Base := GetRandomFloat(-100.0, 100.0); Lo := -10.0; Hi := 10.0
        var AccN:float = 0.0; var AccC:float = 0.0
        profile("Native_ClampFloat"):
            for (I := 1..Iterations):
                X := Base + I * 0.001
                set AccN += Clamp(X, Lo, Hi)
        profile("Custom_ClampFloat"):
            for (I := 1..Iterations):
                X := Base + I * 0.001
                set AccC += FastClamp(X, Lo, Hi)
        Print("ClampFloat N={AccN} C={AccC}")

    BenchPair_MinInt<private>()<transacts>:void=
        BaseA := GetRandomInt(-1000, 1000); B := GetRandomInt(-1000, 1000)
        var AccN:int = 0; var AccC:int = 0
        profile("Native_MinInt"):
            for (I := 1..Iterations):
                A := BaseA + I
                set AccN += Min(A, B)
        profile("Custom_MinInt"):
            for (I := 1..Iterations):
                A := BaseA + I
                set AccC += FastMin(A, B)
        Print("MinInt N={AccN} C={AccC}")

    BenchPair_MaxInt<private>()<transacts>:void=
        BaseA := GetRandomInt(-1000, 1000); B := GetRandomInt(-1000, 1000)
        var AccN:int = 0; var AccC:int = 0
        profile("Native_MaxInt"):
            for (I := 1..Iterations):
                A := BaseA + I
                set AccN += Max(A, B)
        profile("Custom_MaxInt"):
            for (I := 1..Iterations):
                A := BaseA + I
                set AccC += FastMax(A, B)
        Print("MaxInt N={AccN} C={AccC}")

    BenchPair_SgnFloat<private>()<transacts>:void=
        Base := GetRandomFloat(-10.0, 10.0)
        var AccN:float = 0.0; var AccC:float = 0.0
        profile("Native_SgnFloat"):
            for (I := 1..Iterations):
                X := Base + I * 0.001
                set AccN += Sgn(X)
        profile("Custom_SgnFloat"):
            for (I := 1..Iterations):
                X := Base + I * 0.001
                set AccC += FastSgn(X)
        Print("SgnFloat N={AccN} C={AccC}")

    BenchPair_SgnInt<private>()<transacts>:void=
        Base := GetRandomInt(-1000, 1000)
        var AccN:int = 0; var AccC:int = 0
        profile("Native_SgnInt"):
            for (I := 1..Iterations):
                X := Base + I
                set AccN += Sgn(X)
        profile("Custom_SgnInt"):
            for (I := 1..Iterations):
                X := Base + I
                set AccC += FastSgn(X)
        Print("SgnInt N={AccN} C={AccC}")

    BenchPair_LerpFloat<private>()<transacts>:void=
        A := GetRandomFloat(0.0, 100.0); B := GetRandomFloat(0.0, 100.0)
        var AccN:float = 0.0; var AccC:float = 0.0
        profile("Native_LerpFloat"):
            for (I := 1..Iterations):
                T := (I * 1.0) / (Iterations * 1.0)
                L:float = Lerp(A, B, T)
                set AccN += L
        profile("Custom_LerpFloat"):
            for (I := 1..Iterations):
                T := (I * 1.0) / (Iterations * 1.0)
                set AccC += FastLerp(A, B, T)
        Print("LerpFloat N={AccN} C={AccC}")

    BenchPair_DegreesToRadians<private>()<transacts>:void=
        Base := GetRandomFloat(0.0, 360.0)
        var AccN:float = 0.0; var AccC:float = 0.0
        profile("Native_DegreesToRadians"):
            for (I := 1..Iterations):
                D := Base + I * 0.001
                set AccN += DegreesToRadians(D)
        profile("Custom_DegreesToRadians"):
            for (I := 1..Iterations):
                D := Base + I * 0.001
                set AccC += FastDegreesToRadians(D)
        Print("DegreesToRadians N={AccN} C={AccC}")

    BenchPair_RadiansToDegrees<private>()<transacts>:void=
        Base := GetRandomFloat(0.0, 6.28)
        var AccN:float = 0.0; var AccC:float = 0.0
        profile("Native_RadiansToDegrees"):
            for (I := 1..Iterations):
                R := Base + I * 0.001
                set AccN += RadiansToDegrees(R)
        profile("Custom_RadiansToDegrees"):
            for (I := 1..Iterations):
                R := Base + I * 0.001
                set AccC += FastRadiansToDegrees(R)
        Print("RadiansToDegrees N={AccN} C={AccC}")

    BenchPair_FloatIsFinite<private>()<transacts>:void=
        Base := GetRandomFloat(-100.0, 100.0)
        var AccN:int = 0; var AccC:int = 0
        profile("Native_FloatIsFinite"):
            for (I := 1..Iterations):
                X := Base + I * 0.001
                if (X.IsFinite[]). set AccN += 1
        profile("Custom_FloatIsFinite"):
            for (I := 1..Iterations):
                X := Base + I * 0.001
                if (X.FastIsFinite[]). set AccC += 1
        Print("FloatIsFinite N={AccN} C={AccC}")

    BenchPair_FloatIsAlmostZero<private>()<transacts>:void=
        Base := 0.005
        var AccN:int = 0; var AccC:int = 0
        profile("Native_FloatIsAlmostZero"):
            for (I := 1..Iterations):
                X := Base + I * 0.0000001
                if (X.IsAlmostZero[0.01]). set AccN += 1
        profile("Custom_FloatIsAlmostZero"):
            for (I := 1..Iterations):
                X := Base + I * 0.0000001
                if (X.FastIsAlmostZero[0.01]). set AccC += 1
        Print("FloatIsAlmostZero N={AccN} C={AccC}")

    BenchPair_FloatIsAlmostEqual<private>()<transacts>:void=
        A := 10.0; B := 10.0
        var AccN:int = 0; var AccC:int = 0
        profile("Native_FloatIsAlmostEqual"):
            for (I := 1..Iterations):
                AP := A + I * 0.0000001
                if (IsAlmostEqual[AP, B, 0.01]). set AccN += 1
        profile("Custom_FloatIsAlmostEqual"):
            for (I := 1..Iterations):
                AP := A + I * 0.0000001
                if (FastIsAlmostEqual[AP, B, 0.01]). set AccC += 1
        Print("FloatIsAlmostEqual N={AccN} C={AccC}")
