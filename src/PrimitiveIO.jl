# COV_EXCL_START
const primitive_types = (Bool, Char, UInt8, UInt16, UInt32, UInt64, UInt128, Int8, Int16, Int32, Int64, Int128, Float16, Float32, Float64)
const primitive_types_indoc = join(map(t -> string("`", t, "`"), primitive_types), ", ", " and ")
# COV_EXCL_STOP

struct PrimitiveIO{T} <: Construct{T} end

"""
    PrimitiveIO(T) -> Construct{T}

Defines a primitive IO construct for `type` based on [`read`](https://docs.julialang.org/en/v1.6/base/io-network/#Base.read) and [`write`](https://docs.julialang.org/en/v1.6/base/io-network/#Base.write).

This is the default construct for $primitive_types_indoc.

# Examples

```jldoctest
julia> serialize(PrimitiveIO(Complex{Bool}), im)
2-element Vector{UInt8}:
 0x00
 0x01
```
"""
PrimitiveIO(::Type{T}) where {T} = PrimitiveIO{T}()

# primitive numbers
for type in primitive_types
    @eval Construct(::Type{$type}) = PrimitiveIO($type)
end

deserialize(::PrimitiveIO{T}, s::IO; contextkw...) where {T} = read(s, T)
serialize(::PrimitiveIO{T}, s::IO, c::T; contextkw...) where {T} = write(s ,c)
estimatesize(::PrimitiveIO{T}; contextkw...) where {T} = ExactSize(sizeof(T))
estimatesize(::PrimitiveIO{Char}; contextkw...) = RangedSize(1, 4)
