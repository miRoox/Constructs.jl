
abstract type EnumExhaustibility end

"""
    EnumExhaustive <: EnumExhaustibility

Indicates the enumeration is exhaustive.
"""
struct EnumExhaustive <: EnumExhaustibility end

"""
    EnumNonExhaustive <: EnumExhaustibility

Indicates the enumeration is non-exhaustive.
"""
struct EnumNonExhaustive <: EnumExhaustibility end

"""
    IntEnum{Ex<:EnumExhaustibility, T, TSubCon<:Construct{T}, E<:Base.Enum} <: Adapter{T, E}

Integer-based enum adapter for serializing and deserializing.
"""
struct IntEnum{Ex<:EnumExhaustibility, T<:Integer, TSubCon<:Construct{T}, E<:Base.Enum} <: Adapter{T, E}
    subcon::TSubCon
end

"""
    IntEnum{EnumNonExhaustive}([base,] enum)

Defines the non-exhaustive `enum`.

# Arguments

- `base::Union{Type, Construct}`: the base integer type/construct.
- `enum::Type`: the enum type.

# Examples

```jldoctest
julia> @enum Fruit::UInt8 apple=1 banana=2 orange=3

julia> deserialize(IntEnum{EnumNonExhaustive}(Fruit), b"\\x04")
<invalid #4>::Fruit = 0x04
```
"""
IntEnum{Ex}(subcon::TSubCon, ::Type{E}) where {Ex, T<:Integer, TSubCon<:Construct{T}, E<:Base.Enum} = IntEnum{Ex, T, TSubCon, E}(subcon)
IntEnum{Ex}(::Type{T}, ::Type{E}) where {Ex, T<:Integer, E<:Base.Enum} = IntEnum{Ex}(Construct(T), E)
IntEnum{Ex}(::Type{E}) where {Ex, T<:Integer, E<:Base.Enum{T}} = IntEnum{Ex}(Construct(T), E)

"""
    IntEnum([base,] enum)

Defines the (exhaustive) `enum`.

# Arguments

- `base::Union{Type, Construct}`: the base integer type/construct.
- `enum::Type`: the enum type.

# Examples

```jldoctest
julia> @enum Fruit::UInt8 apple=1 banana=2 orange=3

julia> deserialize(IntEnum(Fruit), b"\\x02")
banana::Fruit = 0x02

julia> deserialize(IntEnum(Fruit), b"\\x04")
ERROR: ArgumentError: invalid value for Enum Fruit: 4
[...]

julia> serialize(IntEnum(UInt16le, Fruit), orange)
2-element Vector{UInt8}:
 0x03
 0x00
```
"""
IntEnum(subcon::Union{Type, Construct}, ::Type{E}) where {E<:Base.Enum} = IntEnum{EnumExhaustive}(subcon, E)
IntEnum(::Type{E}) where {T<:Integer, E<:Base.Enum{T}} = IntEnum(Construct(T), E)

encode(::IntEnum{Ex, T, TSubCon, E}, obj::E; contextkw...) where {Ex, T, TSubCon, E} = convert(T, Integer(obj))
decode(::IntEnum{EnumExhaustive, T, TSubCon, E}, obj::T; contextkw...) where {T, TSubCon, EB, E<:Base.Enum{EB}} = E(convert(EB, obj))
decode(::IntEnum{EnumNonExhaustive, T, TSubCon, E}, obj::T; contextkw...) where {T, TSubCon, EB, E<:Base.Enum{EB}} = reinterpret(E, convert(EB, obj))

Construct(enum::Type{<:Base.Enum}) = IntEnum(enum)
