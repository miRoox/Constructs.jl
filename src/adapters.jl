
const mbntypes = Union{Int16, UInt16, Int32, UInt32, Int64, UInt64, Int128, UInt128, Float16, Float32, Float64}

"""
    LittleEndian{T, TSubCon<:Construct{T}} <: Adapter{T, T}

Little endian data adapter for serializing and deserializing.
"""
struct LittleEndian{T<:mbntypes, TSubCon<:Construct{T}} <: Adapter{T, T}
    subcon::TSubCon
end

LittleEndian(::Type{T}) where {T<:mbntypes} = LittleEndian(Construct(T))

subcon(wrapper::LittleEndian) = wrapper.subcon
encode(::LittleEndian{T, TSubCon}, obj::T; contextkw...) where {T, TSubCon} = htol(obj)
decode(::LittleEndian{T, TSubCon}, obj::T; contextkw...) where {T, TSubCon} = ltoh(obj)

"""
    BigEndian{T, TSubCon<:Construct{T}} <: Adapter{T, T}

Big endian data adapter for serializing and deserializing.
"""
struct BigEndian{T<:mbntypes, TSubCon<:Construct{T}} <: Adapter{T, T}
    subcon::TSubCon
end

BigEndian(::Type{T}) where {T<:mbntypes} = BigEndian(Construct(T))

subcon(wrapper::BigEndian) = wrapper.subcon
encode(::BigEndian{T, TSubCon}, obj::T; contextkw...) where {T, TSubCon} = hton(obj)
decode(::BigEndian{T, TSubCon}, obj::T; contextkw...) where {T, TSubCon} = ntoh(obj)

"""
    IntEnum{T, TSubCon<:Construct{T}, E<:Base.Enum} <: Adapter{T, E}

Integer-based enum adapter for serializing and deserializing.
"""
struct IntEnum{T<:Integer, TSubCon<:Construct{T}, E<:Base.Enum} <: Adapter{T, E}
    subcon::TSubCon
end

IntEnum(subcon::Construct{T}, ::Type{E}) where {T<:Integer, E<:Base.Enum} = IntEnum{T, typeof(subcon), E}(subcon)
IntEnum(::Type{T}, ::Type{E}) where {T<:Integer, E<:Base.Enum} = IntEnum(Construct(T), E)
IntEnum(::Type{E}) where {T<:Integer, E<:Base.Enum{T}} = IntEnum(Construct(T), E)

subcon(wrapper::IntEnum) = wrapper.subcon
encode(::IntEnum{T, TSubCon, E}, obj::E; contextkw...) where {T, TSubCon, E} = convert(T, Integer(obj))
decode(::IntEnum{T, TSubCon, E}, obj::T; contextkw...) where {T, TSubCon, EB, E<:Base.Enum{EB}} = E(convert(EB, obj))

Construct(enum::Type{<:Base.Enum}) = IntEnum(enum)

"""
    Magic{T, TSubCon<:Construct{T}} <: Validator{T}

Field enforcing a constant.
"""
struct Magic{T, TSubCon<:Construct{T}} <: Validator{T}
    subcon::TSubCon
    value::T
end

Magic(value::T) where {T} = Magic(Construct(T), value)
Magic(value::AbstractVector{V}) where {V} = Magic(Repeat(V, length(value)), value)
Magic(::Type{T}, value::T) where {T} = Magic(Construct(T), value)
Magic(::Type{T}, value::U) where {T, U} = Magic(Construct(T), convert(T, value))
Magic(subcon::Construct{T}, value::U) where {T, U} = Magic(subcon, convert(T, value))

subcon(wrapper::Magic) = wrapper.subcon
function validate(magic::Magic{T, TSubCon}, obj::T; contextkw...) where {T, TSubCon}
    magic.value == obj ? ValidationOK : ValidationError("$obj mismatch the magic value $(magic.value).")
end
