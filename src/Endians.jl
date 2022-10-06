# multi-bytes numeric types:
const mbntypes = (Int16, UInt16, Int32, UInt32, Int64, UInt64, Int128, UInt128, Float16, Float32, Float64)
const mbnunion = Union{mbntypes...}

"""
    LittleEndian{T, TSubCon<:Construct{T}} <: Adapter{T, T}

Little endian data adapter for serializing and deserializing.
"""
struct LittleEndian{T<:mbnunion, TSubCon<:Construct{T}} <: Adapter{T, T}
    subcon::TSubCon
end

LittleEndian(::Type{T}) where {T<:mbnunion} = LittleEndian(Construct(T))

encode(::LittleEndian{T, TSubCon}, obj::T; contextkw...) where {T, TSubCon} = htol(obj)
decode(::LittleEndian{T, TSubCon}, obj::T; contextkw...) where {T, TSubCon} = ltoh(obj)

"""
    BigEndian{T, TSubCon<:Construct{T}} <: Adapter{T, T}

Big endian data adapter for serializing and deserializing.
"""
struct BigEndian{T<:mbnunion, TSubCon<:Construct{T}} <: Adapter{T, T}
    subcon::TSubCon
end

BigEndian(::Type{T}) where {T<:mbnunion} = BigEndian(Construct(T))

encode(::BigEndian{T, TSubCon}, obj::T; contextkw...) where {T, TSubCon} = hton(obj)
decode(::BigEndian{T, TSubCon}, obj::T; contextkw...) where {T, TSubCon} = ntoh(obj)

for ntype in mbntypes
    let le = "$(ntype)le", be = "$(ntype)be"
        @eval begin
            @doc """
                $($le) = LittleEndian($($ntype))
            """ const $(Symbol(le)) = LittleEndian($ntype)
        end
        @eval begin
            @doc """
                $($be) = BigEndian($($ntype))
            """ const $(Symbol(be)) = BigEndian($ntype)
        end
    end
end
