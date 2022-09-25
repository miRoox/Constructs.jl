# multi-bytes numeric types:
const mbntypes = Union{Int16, UInt16, Int32, UInt32, Int64, UInt64, Int128, UInt128, Float16, Float32, Float64}

"""
    LittleEndian{T, TSubCon<:Construct{T}} <: Adapter{T, T}

Little endian data adapter for serializing and deserializing.
"""
struct LittleEndian{T<:mbntypes, TSubCon<:Construct{T}} <: Adapter{T, T}
    subcon::TSubCon
end

LittleEndian(::Type{T}) where {T<:mbntypes} = LittleEndian(Construct(T))

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

encode(::BigEndian{T, TSubCon}, obj::T; contextkw...) where {T, TSubCon} = hton(obj)
decode(::BigEndian{T, TSubCon}, obj::T; contextkw...) where {T, TSubCon} = ntoh(obj)
