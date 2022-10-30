

# Indicates the string can use the default encoding of the type.
struct RawEncoding end

struct NullTerminatedString{S<:AbstractString, Enc<:Union{Encoding, RawEncoding}} <: Construct{S} end

"""
    NullTerminatedString([T], [encoding]) -> Construct{T}

String ending in a terminating null character.

This is the default construct for the subtypes of `AbstractString`.

# Arguments

- `T<:AbstractString`: the underlying string type.
- `encoding::Union{Encoding, String}`: the string encoding.
"""
NullTerminatedString()=NullTerminatedString(String)
NullTerminatedString(::Type{S}, ::Enc) where {S<:AbstractString, Enc<:Union{Encoding, RawEncoding}} = NullTerminatedString{S, Enc}()
NullTerminatedString(::Type{S}, enc::AbstractString) where {S<:AbstractString} = NullTerminatedString(S, Encoding(enc))
NullTerminatedString(::Type{S}) where {S<:AbstractString} = NullTerminatedString(S, RawEncoding())
NullTerminatedString(enc::Union{Encoding, AbstractString}) = NullTerminatedString(String, enc)

Construct(s::Type{<:AbstractString}) = NullTerminatedString(s)

serialize(cons::NullTerminatedString{S, RawEncoding}, s::IO, obj::S; contextkw...) where {S<:AbstractString} = write(s, obj, S("\0"))
deserialize(cons::NullTerminatedString{S, RawEncoding}, s::IO; contextkw...) where {S<:AbstractString} = convert(S, readuntil(s, S("\0")))

function serialize(cons::NullTerminatedString{S, Enc}, s::IO, obj::S; contextkw...) where {S<:AbstractString, Enc<:Encoding}
    p = StringEncoder(s, Enc(), encoding(S))
    write(p, obj, "\0")
    close(p)
end

function deserialize(cons::NullTerminatedString{S, Enc}, s::IO; contextkw...) where {S<:AbstractString, Enc<:Encoding}
    S(readuntil(StringDecoder(s, Enc(), encoding(S)), "\0"))
end
