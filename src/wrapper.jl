
const mbinttypes = Union{Int16, UInt16, Int32, UInt32, Int64, UInt64, Int128, UInt128}
const mbfloattypes = Union{Float16, Float32, Float64}
const mbntypes = Union{mbinttypes, mbfloattypes}

"""
    LittleEndian{T} <: Wrapper{T}

Little endian data wrapper for serializing and deserializing.
"""
struct LittleEndian{T<:Union{mbntypes, Base.Enum{<:mbinttypes}}} <: Wrapper{T}
    value::T
end

Base.convert(::Type{T}, le::LittleEndian{T}) where {T}  = le.value

deserialize(::Type{LittleEndian{T}}, s::IO) where {T<:mbntypes} = LittleEndian(ltoh(deserialize(T, s)))
deserialize(::Type{LittleEndian{E}}, s::IO) where {T<:mbinttypes, E<:Base.Enum{T}} = LittleEndian(E(ltoh(deserialize(T, s))))
serialize(le::LittleEndian{<:mbntypes}, s::IO)= serialize(htol(le.value), s)
serialize(le::LittleEndian{<:Base.Enum{<:mbinttypes}}, s::IO) = serialize(htol(Integer(le.value)), s)
estimatesize(::Type{LittleEndian{T}}) where {T} = estimatesize(T)

"""
    BigEndian{T} <: Wrapper{T}

Big endian data wrapper for serializing and deserializing.
"""
struct BigEndian{T<:Union{mbntypes, Base.Enum{<:mbinttypes}}} <: Wrapper{T}
    value::T
end

Base.convert(::Type{T}, be::BigEndian{T}) where {T}  = be.value

deserialize(::Type{BigEndian{T}}, s::IO) where {T<:mbntypes} = BigEndian(ntoh(deserialize(T, s)))
deserialize(::Type{BigEndian{E}}, s::IO) where {T<:mbinttypes, E<:Base.Enum{T}} = BigEndian(E(ntoh(deserialize(T, s))))
serialize(be::BigEndian{<:mbntypes}, s::IO)= serialize(hton(be.value), s)
serialize(be::BigEndian{<:Base.Enum{<:mbinttypes}}, s::IO) = serialize(hton(Integer(be.value)), s)
estimatesize(::Type{BigEndian{T}}) where {T} = estimatesize(T)
