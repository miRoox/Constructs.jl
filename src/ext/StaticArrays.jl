
Constructs.Construct(::Type{TA}) where {S<:Tuple, T, N, TA<:StaticArrays.StaticArray{S, T, N}} = Constructs.SizedArray(TA, T, fieldtypes(S))
