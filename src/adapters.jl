
const mbntypes = Union{Int16, UInt16, Int32, UInt32, Int64, UInt64, Int128, UInt128, Float16, Float32, Float64}

"""
    LittleEndian{T, TSubCon<:Construct{T}} <: Adapter{T, T}

Little endian data adapter for serializing and deserializing.
"""
struct LittleEndian{T<:mbntypes, TSubCon<:Construct{T}} <: Adapter{T, T}
    subcon::TSubCon
end

LittleEndian(::Type{T}) where {T<:mbntypes} = LittleEndian(Default(T))

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

BigEndian(::Type{T}) where {T<:mbntypes} = BigEndian(Default(T))

subcon(wrapper::BigEndian) = wrapper.subcon
encode(::BigEndian{T, TSubCon}, obj::T; contextkw...) where {T, TSubCon} = hton(obj)
decode(::BigEndian{T, TSubCon}, obj::T; contextkw...) where {T, TSubCon} = ntoh(obj)

"""
    Magic{T, TSubCon<:Construct{T}} <: Validator{T}

Field enforcing a constant.
"""
struct Magic{T, TSubCon<:Construct{T}} <: Validator{T}
    subcon::TSubCon
    value::T
end

Magic(value::T) where {T} = Magic(Default(T), value)
Magic(::Type{T}, value::T) where {T} = Magic(Default(T), value)
Magic(::Type{T}, value::U) where {T, U} = Magic(Default(T), convert(T, value))
Magic(subcon::Construct{T}, value::U) where {T, U} = Magic(subcon, convert(T, value))

subcon(wrapper::Magic) = wrapper.subcon
function validate(magic::Magic{T, TSubCon}, obj::T; contextkw...) where {T, TSubCon}
    magic.value == obj ? ValidationOK : ValidationError("$obj mismatch the magic value $(magic.value).")
end
