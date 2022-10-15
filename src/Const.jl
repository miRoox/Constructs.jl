"""
    Const{T, TSubCon<:Construct{T}} <: Validator{T}

Field enforcing a constant.
"""
struct Const{T, TSubCon<:Construct{T}} <: Validator{T}
    subcon::TSubCon
    value::T
end

"""
    Const([base,] value)

Defines a constant `value`, usually used for file headers.

# Arguments

- `base::Union{Type, Construct}`: the underlying type/construct.
- `value`: the expected value.

# Examples

```jldoctest
julia> serialize(Const(0x01), 0x01)
1-element Vector{UInt8}:
 0x01

julia> deserialize(Const(0x01), b"\\x01")
0x01
```

```jldoctest
julia> serialize(Const(0x01), 0x03)
ERROR: ValidationError: 3 mismatch the const value 1.
[...]

julia> deserialize(Const(0x01), b"\\x02")
ERROR: ValidationError: 2 mismatch the const value 1.
[...]
```
"""
Const(subcon::Construct{T}, value) where {T} = Const(subcon, convert(T, value))
Const(::Type{T}, value) where {T} = Const(Construct(T), value)
Const(value::T) where {T} = Const(Construct(T), value)
Const(value::AbstractArray{V, N}) where {V, N} = Const(SizedArray(typeof(similar(value, size(value))), V, size(value)...), value)

function validate(cons::Const{T, TSubCon}, obj::T; contextkw...) where {T, TSubCon}
    (cons.value == obj) === true || throw(ValidationError("$obj mismatch the const value $(cons.value)."))
end

function serialize(cons::Const{T, TSubCon}, s::IO, ::UndefProperty; contextkw...) where {T, TSubCon}
    serialize(cons, s, cons.value; contextkw...)
end
