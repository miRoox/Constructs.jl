
"""
    Try{TU} <: Construct{TU}

Attempts to serialize/deserialize each of the subconstructs.
"""
abstract type Try{TU} <: Construct{TU} end

struct Try2{TU, T1, T2, TSubCon1<:Construct{T1}, TSubCon2<:Construct{T2}} <: Try{TU}
    subcon1::TSubCon1
    subcon2::TSubCon2

    # `T1<:TU, T2<:TU` cannot apply to type parameters
    Try2{TU, T1, T2, TSubCon1, TSubCon2}(c1::TSubCon1, c2::TSubCon2) where {TU, T1<:TU, T2<:TU, TSubCon1<:Construct{T1}, TSubCon2<:Construct{T2}} = new{TU, T1, T2, TSubCon1, TSubCon2}(c1, c2)
end

Try2{TU}(c1::TSubCon1, c2::TSubCon2) where {TU, T1<:TU, T2<:TU, TSubCon1<:Construct{T1}, TSubCon2<:Construct{T2}} = Try2{TU, T1, T2, TSubCon1, TSubCon2}(c1, c2)
Try2(c1::Construct{T1}, c2::Construct{T2}) where {T1, T2} = Try2{Union{T1, T2}}(c1, c2)

"""
    Try(subcon1, subcon2, ...)
    Try{TU}(subcon1, subcon2, ...)

Try each `subcon` and use the first successful one.

# Examples

Another non-exhaustive enum:

```jldoctest
julia> @enum Fruit::UInt8 apple=1 banana=2 orange=3

julia> deserialize(Try(Fruit, UInt8), b"\\x02")
banana::Fruit = 0x02

julia> deserialize(Try(Fruit, UInt8), b"\\x04")
0x04
```
"""
Try(ct1::Union{Type, Construct}, ct2::Union{Type, Construct}) = Try2(Construct(ct1), Construct(ct2))
Try{TU}(ct1::Union{Type, Construct}, ct2::Union{Type, Construct}) where {TU} = Try2{TU}(Construct(ct1), Construct(ct2))
Try(ct1::Union{Type, Construct}, ct2::Union{Type, Construct}, rest::Vararg{Union{Type, Construct}}) = Try2(Construct(ct1), Try(ct2, rest...))
Try{TU}(ct1::Union{Type, Construct}, ct2::Union{Type, Construct}, rest::Vararg{Union{Type, Construct}}) where {TU} = Try2{TU}(Construct(ct1), Try{TU}(ct2, rest...))

function deserialize(cons::Try2, s::IO; contextkw...)
    fallback = position(s)
    try
        deserialize(cons.subcon1, s; contextkw...)
    catch
        seek(s, fallback)
        deserialize(cons.subcon2, s; contextkw...)
    end
end

function serialize_try(cons::Try2, s::IO, v; contextkw...)
    fallback = position(s)
    try
        serialize(cons.subcon1, s, v; contextkw...)
    catch
        seek(s, fallback)
        serialize(cons.subcon2, s, v; contextkw...)
    end
end

function serialize(cons::Try2{TU, T1, T2, TSubCon1, TSubCon2}, s::IO, v::T1; contextkw...) where {TU, T2, T1<:T2, TSubCon1, TSubCon2}
    serialize_try(cons, s, v; contextkw...)
end

function serialize(cons::Try2{TU, T1, T2, TSubCon1, TSubCon2}, s::IO, v::T1; contextkw...) where {TU, T1, T2, TSubCon1, TSubCon2}
    serialize(cons.subcon1, s, v; contextkw...)
end

function serialize(cons::Try2{TU, T1, T2, TSubCon1, TSubCon2}, s::IO, v::T2; contextkw...) where {TU, T1, T2, TSubCon1, TSubCon2}
    serialize(cons.subcon2, s, v; contextkw...)
end

function serialize(cons::Try2{TU, T1, T2, TSubCon1, TSubCon2}, s::IO, v::UndefProperty; contextkw...) where {TU, T1, T2, TSubCon1, TSubCon2}
    serialize_try(cons, s, v; contextkw...)
end

estimatesize(cons::Try2; contextkw...) = union(estimatesize(cons.subcon1; contextkw...), estimatesize(cons.subcon2; contextkw...))
