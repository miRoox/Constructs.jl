# multi-bytes numeric types:
const mbntypes = (Int16, UInt16, Int32, UInt32, Int64, UInt64, Int128, UInt128, Float16, Float32, Float64)
const mbnunion = Union{mbntypes...}

struct LittleEndian{T<:mbnunion, TSubCon<:Construct{T}} <: Adapter{T, T}
    subcon::TSubCon
end

"""
    LittleEndian(T) -> Construct{T}

Defines the little endian format `T`.

# Examples

```jldoctest
julia> deserialize(LittleEndian(UInt16), b"\\x12\\x34")
0x3412
```
"""
LittleEndian(::Type{T}) where {T} = LittleEndian(Construct(T))

encode(::LittleEndian{T, TSubCon}, obj::T; contextkw...) where {T, TSubCon} = htol(obj)
decode(::LittleEndian{T, TSubCon}, obj::T; contextkw...) where {T, TSubCon} = ltoh(obj)

struct BigEndian{T<:mbnunion, TSubCon<:Construct{T}} <: Adapter{T, T}
    subcon::TSubCon
end

"""
    BigEndian(T) -> Construct{T}

Defines the big endian format `T`.

# Examples

```jldoctest
julia> deserialize(BigEndian(UInt16), b"\\x12\\x34")
0x1234
```
"""
BigEndian(::Type{T}) where {T} = BigEndian(Construct(T))

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
