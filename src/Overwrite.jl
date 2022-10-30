struct Overwrite{T, TSubCon<:Construct{T}, GT<:Union{Function, UndefProperty}} <: Adapter{T, T}
    subcon::TSubCon
    getter::GT
    
    function Overwrite{T, TSubCon, GT}(subcon::TSubCon, getter::GT) where {T, TSubCon<:Construct{T}, GT<:Union{Function, UndefProperty}}
        if getter isa Function && !hasmethod(getter, Tuple{T}, ())
            throw(ArgumentError("$getter doesn't have a method for (::$T)."))
        end
        new{T, TSubCon, GT}(subcon, getter)
    end
end

Overwrite(subcon::TSubCon, getter::GT) where {T, TSubCon<:Construct{T}, GT<:Union{Function, UndefProperty}} = Overwrite{T, TSubCon, GT}(subcon, getter)

"""
    Overwrite(T, value::T) -> Construct{T}
    Overwrite(T, getter) -> Construct{T}
    Overwrite(subcon::Construct{T}, value::T) -> Construct{T}
    Overwrite(subcon::Construct{T}, getter) -> Construct{T}

Overwrite the value when serializing from `getter`/`value`. Deserialization simply passes down.

# Arguments

- `subcon::Construct{T}`: the underlying construct.
- `value::T`: the value to overwrite when serializing.
- `getter`: the function to overwrite when serializing. the function should have signature like `(::T; contextkw...)` and satisfies idempotence (`getter(getter(x)) == getter(x)`).

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

encode(cons::Overwrite{T, TSubCon, GT}, obj::T; contextkw...) where {T, TSubCon, GT<:Function} = convert(T, apply_optional_contextkw(cons.getter, obj, contextkw))
# getter could be undefined when deserializing
decode(::Overwrite{T, TSubCon, GT}, obj::T; contextkw...) where {T, TSubCon, GT} = obj

function serialize(cons::Overwrite, s::IO, v::UndefProperty; contextkw...)
    serialize(cons, s, apply_optional_contextkw(cons.getter, v, contextkw); contextkw...)
end
