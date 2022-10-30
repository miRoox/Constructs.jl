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
subcon
```

### `Adapter`

```@docs
Adapter{TSub, T}
SymmetricAdapter{T}
SymmetricAdapter(subcon::Union{Type, Construct}, encode::Function)
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
PrimitiveIO
Singleton
JuliaSerializer
RaiseError
```

## String

```@docs
NullTerminatedString
```

## Endianness Adapters

```@docs
LittleEndian
BigEndian
```

```@autodocs
Modules = [Constructs]
Filter = c -> c isa LittleEndian || c isa BigEndian
```

## Enums

```@docs
IntEnum(subcon::Union{Type, Construct}, ::Type{E}) where {E<:Base.Enum}
IntEnum{Ex}(subcon::TSubCon, ::Type{E}) where {Ex, T<:Integer, TSubCon<:Construct{T}, E<:Base.Enum}
EnumNonExhaustive
EnumExhaustive
```

## Sequence

```@docs
Sequence
```

## Repeaters

```@docs
SizedArray
PrefixedArray
GreedyVector
```

## Conditional

```@docs
Try
```

## Padded

```@docs
Padded
```

## Others

```@docs
Const
Overwrite
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
