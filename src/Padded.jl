"""
    Padded{T, TSubCon<:Construct{T}} <: Wrapper{T, T}

Represents Padded data.
"""
struct Padded{T, TSubCon<:Construct{T}} <: Wrapper{T, T}
    subcon::TSubCon
    size::UInt
    # TODO: [warn] check size
end

"""
    Padded([base = Nothing,] n)

Create `n`-bytes padded data from `base`.

# Arguments

- `base::Union{Type, Construct}`: the type/construct to be padded.
- `n::Integer`: the size in bytes after padded.

# Examples

```jldoctest
julia> deserialize(Padded(Int8, 2), b"\\x01\\xfc")
1

julia> serialize(Padded(Int8, 2), Int8(1))
2-element Vector{UInt8}:
 0x01
 0x00
```
"""
Padded(subcon::TSubCon, size::Integer) where {TSubCon<:Construct} = Padded(subcon, convert(UInt, size))
Padded(t::Type, size::Integer) = Padded(Construct(t), size)
Padded(size::Integer) = Padded(Nothing, size)

function deserialize(cons::Padded, s::IO; contextkw...)
    start = position(s)
    val = deserialize(cons.subcon, s; contextkw...)
    stop = position(s)
    if stop > start + cons.size
        throw(PaddedError("subcon deserialized $(stop - start) bytes but was only allowed $(cons.size)."))
    end
    skip(s, cons.size - (stop - start))
    val
end
function serialize(cons::Padded{T}, s::IO, val::T; contextkw...) where {T}
    start = position(s)
    serialize(cons.subcon, s, val; contextkw...)
    stop = position(s)
    if stop > start + cons.size
        throw(PaddedError("subcon serialized $(stop - start) bytes but was only allowed $(cons.size)."))
    end
    write(s, zeros(UInt8, cons.size - (stop - start)))
    cons.size
end
estimatesize(cons::Padded; contextkw...) = ExactSize(cons.size)
