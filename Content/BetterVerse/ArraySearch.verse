# ~1.1x faster than Arr.Find[V]. Linear search with early break (wrapping
# the for in a loop so we can break out).
(Arr:[]t).FastFind<public>(Value:t where t:subtype(comparable))<transacts><decides>:int =
    var Ret:?int = false
    loop:
        for (Index -> Val : Arr):
            if (Val = Value):
                set Ret = option{Index}
                break
        break
    Ret?

FastFind<public>(Arr:[]t, Value:t where t:subtype(comparable))<transacts><decides>:int =
    var Ret:?int = false
    loop:
        for (Index -> Val : Arr):
            if (Val = Value):
                set Ret = option{Index}
                break
        break
    Ret?

# ~5.5x faster than Arr.Slice[Start, Stop]. Same failable semantics as native.
(Arr:[]t).FastSlice<public>(Start:int, Stop:int where t:type)<computes><decides>:[]t =
    0 <= Start
    Start <= Stop
    Stop <= Arr.Length
    for (J := Start..Stop - 1, X := Arr[J]) { X }

FastSlice<public>(Arr:[]t, Start:int, Stop:int where t:type)<computes><decides>:[]t =
    0 <= Start
    Start <= Stop
    Stop <= Arr.Length
    for (J := Start..Stop - 1, X := Arr[J]) { X }

# ~3.1x faster than Arr.RemoveElement[Idx].
(Arr:[]t).FastRemoveElement<public>(IdxToRemove:int where t:type)<computes><decides>:[]t =
    0 <= IdxToRemove
    IdxToRemove < Arr.Length
    for (J -> X : Arr, J <> IdxToRemove) { X }

FastRemoveElement<public>(Arr:[]t, IdxToRemove:int where t:type)<computes><decides>:[]t =
    0 <= IdxToRemove
    IdxToRemove < Arr.Length
    for (J -> X : Arr, J <> IdxToRemove) { X }

# ~3.2x faster than Arr.ReplaceElement[Idx, Val].
(Arr:[]t).FastReplaceElement<public>(IdxToReplace:int, NewValue:t where t:type)<computes><decides>:[]t =
    0 <= IdxToReplace
    IdxToReplace < Arr.Length
    for (J -> X : Arr) { if (J = IdxToReplace) { NewValue } else { X } }

FastReplaceElement<public>(Arr:[]t, IdxToReplace:int, NewValue:t where t:type)<computes><decides>:[]t =
    0 <= IdxToReplace
    IdxToReplace < Arr.Length
    for (J -> X : Arr) { if (J = IdxToReplace) { NewValue } else { X } }

# ~2.4x faster than Arr.RemoveAllElements(Val).
(Arr:[]t).FastRemoveAllElements<public>(Val:t where t:subtype(comparable))<computes>:[]t =
    for (X : Arr, X <> Val) { X }

FastRemoveAllElements<public>(Arr:[]t, Val:t where t:subtype(comparable))<computes>:[]t =
    for (X : Arr, X <> Val) { X }

# ~3.9x faster than Arr.RemoveFirstElement[Val]. Same failable semantics.
(Arr:[]t).FastRemoveFirstElement<public>(Val:t where t:subtype(comparable))<transacts><decides>:[]t =
    var FoundIdx:int = -1
    loop:
        for (J -> X : Arr):
            if (X = Val):
                set FoundIdx = J
                break
        break
    FoundIdx >= 0
    for (J -> X : Arr, J <> FoundIdx) { X }

FastRemoveFirstElement<public>(Arr:[]t, Val:t where t:subtype(comparable))<transacts><decides>:[]t =
    var FoundIdx:int = -1
    loop:
        for (J -> X : Arr):
            if (X = Val):
                set FoundIdx = J
                break
        break
    FoundIdx >= 0
    for (J -> X : Arr, J <> FoundIdx) { X }

# ~4.1x faster than Arr.ReplaceFirstElement[Old, New]. Same failable semantics.
(Arr:[]t).FastReplaceFirstElement<public>(Old:t, New:t where t:subtype(comparable))<transacts><decides>:[]t =
    var FoundIdx:int = -1
    loop:
        for (J -> X : Arr):
            if (X = Old):
                set FoundIdx = J
                break
        break
    FoundIdx >= 0
    for (J -> X : Arr) { if (J = FoundIdx) { New } else { X } }

FastReplaceFirstElement<public>(Arr:[]t, Old:t, New:t where t:subtype(comparable))<transacts><decides>:[]t =
    var FoundIdx:int = -1
    loop:
        for (J -> X : Arr):
            if (X = Old):
                set FoundIdx = J
                break
        break
    FoundIdx >= 0
    for (J -> X : Arr) { if (J = FoundIdx) { New } else { X } }

# ~2.2x faster than Arr.ReplaceAllElements(Old, New).
(Arr:[]t).FastReplaceAllElements<public>(Old:t, New:t where t:subtype(comparable))<computes>:[]t =
    for (X : Arr) { if (X = Old) { New } else { X } }

FastReplaceAllElements<public>(Arr:[]t, Old:t, New:t where t:subtype(comparable))<computes>:[]t =
    for (X : Arr) { if (X = Old) { New } else { X } }
