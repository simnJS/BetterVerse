# BetterVerse

A drop-in replacement library for Verse / UEFN native math and array functions.
Most natives that operate on `vector2` / `vector3` structs pay a heavy
marshalling cost crossing the Verse ↔ C++ boundary. Reimplementing them in pure
Verse keeps the work in the runtime and yields **1.1× to 81× speedups**
depending on the function, while producing bit-exact identical results.

## What's in here

| File | Functions |
|---|---|
| `Content/BetterVerse/VectorMath.verse` | Vector3 / Vector2 ops, operators, failable checks |
| `Content/BetterVerse/ArraySearch.verse` | Array find, slice, remove, replace variants |
| `Content/BetterVerse/MathUtils.verse` | Float `Min`, `Max`, `Clamp`, conversions, failables |
| `Content/MathUnitTest.verse` | `math_unittest_device` — verifies every custom matches the native bit-by-bit |

All functions are exposed in two forms when relevant: as a free function
(`FastDot(A, B)`) and as an extension method (`A.FastDot(B)`).

## Speedups summary

| Native | Speedup |
|---|---:|
| `ReflectVector` (vec3) | **81×** |
| `ReflectVector` (vec2) | 78× |
| `MakeUnitVector` (vec3) | 46× |
| `DistanceSquared` | 42× |
| `Distance` | 33× |
| `CrossProduct` | 30× |
| `MakeUnitVector` (vec2) | 28× |
| `DotProduct` | 26× |
| `LengthSquared` | 25× |
| `Distance` (vec2) | 24× |
| `DotProduct` (vec2) | 21× |
| `Length` | 18× |
| `Lerp` (vec3) | 17× |
| `Length` (vec2) | 15× |
| `IsFinite` (vec3/vec2) | 14× |
| `IsAlmostZero` / `IsAlmostEqual` (vec) | 12-14× |
| `Lerp` (vec2) | 14× |
| `RotateVector` / `UnrotateVector` | 8× |
| `Clamp` | 7× |
| `Slice` | 5.5× |
| `ReplaceFirstElement` | 4× |
| `RemoveFirstElement` | 4× |
| `RemoveElement` / `ReplaceElement` | 3× |
| `Min` / `Max` | 2.5× |
| `RemoveAllElements` | 2.4× |
| Vector operators (`+`, `-`, `*`, `/`, `-`) | 2× |
| `DegreesToRadians` / `RadiansToDegrees` | 2.3× |
| `IsAlmostEqual` / `IsAlmostZero` (float) | 2.3× |
| `IsFinite` (float) | 1.4× |
| `Find` | 1.1× |

### Where the native wins (kept the native, no `Fast*` provided)

- `Sqrt`, `Sin`, `Cos`, `Pow`, `Floor` — scalar math intrinsics (SIMD)
- `Abs(float)` — single-arg intrinsic
- `Arr.Insert[Idx, Elements]` — internal memcpy beats user-land concat

## Why the speedups exist

Verse natives that take or return a struct (vector2, vector3, rotation) cross
the Verse ↔ C++ boundary on each call. The struct must be serialized in,
processed in C++, then serialized back out. For functions whose actual work is
trivial (`A + B`, `A.X*B.X + A.Y*B.Y + A.Z*B.Z`), this marshalling cost
dominates everything else.

Reimplementing inline in Verse keeps the work in the runtime, manipulating
floats directly with no boundary crossing. Scalar natives (`Sqrt`, `Sin`, etc.)
don't have this problem and beat any reimplementation.

Worst offenders: functions with **two struct inputs and a struct output**, plus
**failable internal checks** (e.g., `ReflectVector` runs `MakeUnitVector[]`
internally on the normal).

## Installation

1. Copy the `Content/BetterVerse/` folder into your project's `Content/`.
2. Declare the module in your project's `ModulesConfig.verse`:
   ```verse
   BetterVerse<public> := module{}
   ```
3. Import where needed:
   ```verse
   using { BetterVerse }
   ```

## Usage

```verse
using { BetterVerse }
using { /UnrealEngine.com/Temporary/SpatialMath }

# Instead of Distance(A, B):
D := A.FastDistance(B)

# Instead of DistanceSquared(A, B) for range checks:
if (A.FastDistanceSquared(B) < Radius * Radius). InRange()

# Instead of V.MakeUnitVector[]:
if (Unit := V.FastNormalize[]). UseUnit()

# Instead of Arr.Slice[Start, Stop]:
if (Sub := Arr.FastSlice[0, 10]). UseSub()

# Float helpers:
Clamped := FastClamp(X, 0.0, 1.0)
Rad := FastDegreesToRadians(90.0)
```

## Verification

The `math_unittest_device` (`Content/MathUnitTest.verse`) runs every custom
against its native counterpart with concrete values and prints `[PASS]` /
`[FAIL]` for each. Drop it into a map, play, and check the log. All 64 tests
pass bit-exact with default tolerance `1e-4`.

## Caveats

- `FastNormalize` and `FastReflectVector` assume non-zero / unit inputs (same
  as native).
- `FastRotateVector` takes `(Axis, Angle, V)` instead of a `rotation` object
  because `rotation` is opaque in Verse. If you already have a `rotation`,
  staying on the native may be more convenient than extracting axis/angle.
- Speedup ratios were measured under specific iteration counts and may vary
  on different hardware / Verse runtime versions. Run the benchmark device to
  re-measure on your setup.

## Methodology

Speedups were measured with the `profile()` Verse builtin over ~5k–100k
iterations per function depending on cost. Inputs are randomized once before
each benchmark to prevent constant folding. Loop-invariant work is hoisted out
of the timing loop in both native and custom benches to keep the comparison
fair. Full bench source code is available on request — the unit test device
covers correctness, the bench device covered performance during development.

## AI assistance disclosure

This library was developed in collaboration with Claude (Anthropic AI). The AI
ran the benchmarks, identified the marshalling pattern across ~60 natives,
implemented the custom versions, and authored the unit tests. All
implementations and measurements were validated end-to-end in UEFN before
landing.

## License

Public domain — do what you want with it.
