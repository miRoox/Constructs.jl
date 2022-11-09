struct Const{T, TSubCon<:Construct{T}} <: Validator{T}
    subcon::TSubCon
    value::T
end

"""
    Const([T|subcon], value::T) -> Construct{T}

Defines a constant `value`, usually used for file headers.

# Arguments

- `subcon::Construct{T}`: the underlying construct.
- `value::T`: the expected value.

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
Const(value::S) where {S<:AbstractString} = Const(PaddedString(S, sizeof(value)), value)

function validate(cons::Const{T, TSubCon}, obj::T; contextkw...) where {T, TSubCon}
    (cons.value == obj) === true || throw(ValidationError("$obj mismatch the const value $(cons.value)."))
end

default(cons::Const{T, TSubCon}; contextkw...) where {T, TSubCon} = cons.value
