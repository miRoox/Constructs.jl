# API References

```@contents
Pages = ["reference.md"]
Depth = 3
```

## Basic Interfaces

Basic construct:

```@docs
Construct
serialize
deserialize
estimatesize
```

Construct wrapper:

```@docs
Wrapper
subcon
```

Construct adapter:

```@docs
Adapter
SymmetricAdapter
encode
decode
```

Construct validator:

```@docs
Validator
validate
ValidationError
```

## Primitive Constructs

```@docs
PrimitiveIO
Singleton
JuliaSerializer
RaiseError
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

# Enums

```@docs
IntEnum
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

## Validators

```@docs
Const
```

## `@construct` Macro

```@docs
@construct
this
Container
UndefProperty
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
ConstructError
ExceedMaxIterations
PaddedError
```
