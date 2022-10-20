"""
    Overwrite{T, TSubCon<:Construct{T}, GT<:Union{Function, UndefProperty}} <: Adapter{T, T}

Overwrite the value when serializing. Deserialization simply passes down.
"""
struct Overwrite{T, TSubCon<:Construct{T}, GT<:Union{Function, UndefProperty}} <: Adapter{T, T}
    subcon::TSubCon
    getter::GT
end

"""
    Overwrite(base, getter)

Overwrite the value when serializing from `getter`.

# Arguments

- `base::Union{Type, Construct}`: the underlying type/construct.
- `getter`: the function/value to overwrite when serializing. the function should have signature like `(::T; contextkw...)`.

# Examples

```jldoctest
julia> serialize(Overwrite(UInt8, 0x01), 2)
1-element Vector{UInt8}:
 0x01

julia> serialize(Overwrite(Int8, abs), -2)
1-element Vector{UInt8}:
 0x02

julia> deserialize(Overwrite(UInt8, 0x01), b"\\x05")
0x05
```
"""
Overwrite(subcon::Construct{T}, value::T) where {T} = Overwrite(subcon, ((obj; contextkw...) -> value))
Overwrite(::Type{T}, getter) where {T} = Overwrite(Construct(T), getter)

encode(cons::Overwrite{T, TSubCon, GT}, obj::T; contextkw...) where {T, TSubCon, GT<:Function} = convert(T, cons.getter(obj; contextkw...))
# getter could be undefined when deserializing
decode(::Overwrite{T, TSubCon, GT}, obj::T; contextkw...) where {T, TSubCon, GT} = obj

function serialize(cons::Overwrite, s::IO, v::UndefProperty; contextkw...)
    serialize(cons, s, cons.getter(v; contextkw...); contextkw...)
end
