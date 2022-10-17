# API References

```@contents
Pages = ["reference.md"]
Depth = 3
```

```@docs
Constructs
```

## Basic Interfaces

### `Construct`

```@docs
Construct{T}
Construct(cons::Construct)
serialize
serialize(cons::Construct{T}, filename::AbstractString, obj; contextkw...) where {T}
serialize(cons::Construct{T}, obj; contextkw...) where {T}
serialize(cons::Construct{T}, s::IO, ::UndefProperty; contextkw...) where {T}
deserialize
deserialize(cons::Construct, filename::AbstractString; contextkw...)
deserialize(cons::Construct, bytes::AbstractVector{UInt8}; contextkw...)
estimatesize
```

### `Wrapper`

```@docs
Wrapper{TSub, T}
subcon(wrapper::Wrapper)
```

### `Adapter`

```@docs
Adapter{TSub, T}
SymmetricAdapter{T}
encode
decode
```

### `Validator`

```@docs
Validator{T}
Validator(subcon::Union{Type, Construct}, validate::Function)
validate
```

## Primitive Constructs

```@docs
PrimitiveIO{T}
PrimitiveIO(::Type{T}) where {T}
Singleton{T}
Singleton(::Type{T}) where {T}
JuliaSerializer{T}
JuliaSerializer(::Type{T} = Any) where {T}
RaiseError
RaiseError(msg::AbstractString)
```

## Endianness Adapters

```@docs
LittleEndian{T, TSubCon<:Construct{T}}
LittleEndian(::Type{T}) where {T}
BigEndian{T, TSubCon<:Construct{T}}
BigEndian(::Type{T}) where {T}
```

```@autodocs
Modules = [Constructs]
Filter = c -> c isa LittleEndian || c isa BigEndian
```

## Enums

```@docs
IntEnum{Ex<:EnumExhaustibility, T<:Integer, TSubCon<:Construct{T}, E<:Base.Enum}
IntEnum(subcon::Union{Type, Construct}, ::Type{E}) where {E<:Base.Enum}
IntEnum{Ex}(subcon::TSubCon, ::Type{E}) where {Ex, T<:Integer, TSubCon<:Construct{T}, E<:Base.Enum}
EnumNonExhaustive
EnumExhaustive
```

## Sequence

```@docs
Sequence{TT<:Tuple}
Sequence(ts::Vararg{Union{Type, Construct}})
```

## Repeaters

```@docs
Repeater{T, TA<:AbstractArray{T}}
SizedArray{T, N, TA<:AbstractArray{T,N}, TSubCon<:Construct{T}}
SizedArray(::Type{TA}, subcon::TSubCon, size::Vararg{Integer, N}) where {T, N, TA<:AbstractArray, TSubCon<:Construct{T}}
GreedyVector{T, TSubCon<:Construct{T}}
GreedyVector(type::Type)
```

## Conditional

```@docs
Try{TU}
Try(ct1::Union{Type, Construct}, ct2::Union{Type, Construct})
```

## Padded

```@docs
Padded{T, TSubCon<:Construct{T}}
Padded(subcon::TSubCon, size::Integer) where {TSubCon<:Construct}
```

## Others

```@docs
Const{T, TSubCon<:Construct{T}}
Const(subcon::Construct{T}, value) where {T}
Overwrite{T, TSubCon<:Construct{T}, GT<:Union{Function, UndefProperty}}
Overwrite(subcon::Construct{T}, value::T) where {T}
```

## `@construct` Macro

```@docs
@construct
this
Container{T}
Container(obj::T) where {T}
UndefProperty
PropertyPath
```

## Construct Sizes

```@docs
ConstructSize
ExactSize
RangedSize
UnboundedSize
UnboundedUpper
```

## Errors

```@docs
AbstractConstructError
ValidationError
ExceedMaxIterations
PaddedError
```
