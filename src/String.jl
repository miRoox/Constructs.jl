

# Indicates the string can use the default encoding of the type.
struct RawEncoding end


struct PaddedString{S<:AbstractString, Enc<:Union{Encoding, RawEncoding}} <: Construct{S}
    size::UInt
end

"""
    PaddedString([T], n, [encoding]) -> Construct{T}

String padded to `n` bytes.

# Arguments

- `T<:AbstractString`: the underlying string type.
- `n::Integer`: the size of the string in bytes.
- `encoding::Union{Encoding, String}`: the string encoding.
"""
PaddedString(size::Integer)=PaddedString(String, size)
PaddedString(::Type{S}, size::Integer, ::Enc) where {S<:AbstractString, Enc<:Union{Encoding, RawEncoding}} = PaddedString{S, Enc}(convert(UInt, size))
PaddedString(::Type{S}, size::Integer, enc::AbstractString) where {S<:AbstractString} = PaddedString(S, size, Encoding(enc))
PaddedString(::Type{S}, size::Integer) where {S<:AbstractString} = PaddedString(S, size, RawEncoding())
PaddedString(size::Integer, enc::Union{Encoding, AbstractString}) = PaddedString(String, size, enc)

swrite(::RawEncoding, s::IO, obj::S) where {S<:AbstractString} = write(s, obj)
function swrite(enc::Encoding, s::IO, obj::S) where {S<:AbstractString}
    p = StringEncoder(s, enc, encoding(S))
    write(p, obj)
    close(p)
end

# FIXME: HERE it assumes the null in the target string encoding is single-byte.
trim_end(b::AbstractVector{UInt8}) = @inbounds view(b, 1:findlast(!iszero, b))

function serialize(cons::PaddedString{S, Enc}, s::IO, obj::S; contextkw...) where {S<:AbstractString, Enc}
    start = position(s)
    swrite(Enc(), s, obj)
    stop = position(s)
    if stop > start + cons.size
        throw(PaddedError("string writes $(stop - start) bytes but was only allowed $(cons.size)."))
    end
    write(s, zeros(UInt8, cons.size - (stop - start)))
    cons.size
end

deserialize(cons::PaddedString{S, RawEncoding}, s::IO; contextkw...) where {S<:AbstractString} = S(trim_end(read(s, cons.size)))
function deserialize(cons::PaddedString{S, Enc}, s::IO; contextkw...) where {S<:AbstractString, Enc<:Encoding}
    b = IOBuffer(read(s, cons.size); read=true)
    S(trim_end(read(StringDecoder(b, Enc(), encoding(S)))))
end

estimatesize(cons::PaddedString; contextkw...) = ExactSize(cons.size)

struct PrefixedString{S<:AbstractString, Enc<:Union{Encoding, RawEncoding}, I<:Integer, TSizeCon<:Construct{I}} <: Construct{S}
    sizecon::TSizeCon
end

"""
    PrefixedString([T], S|size, [encoding]) -> Construct{T}

String with the size in the header.

# Arguments

- `T<:AbstractString`: the underlying string type.
- `S<:Integer`: the typeof the string size.
- `size::Construct{S}`: the construct of the string size (in bytes).
- `encoding::Union{Encoding, String}`: the string encoding.
"""
PrefixedString(size::Union{Type{I}, Construct{I}}) where {I<:Integer} = PrefixedString(String, Construct(size))
PrefixedString(size::Union{Type{I}, Construct{I}}, enc::Union{Encoding, AbstractString}) where {I<:Integer} = PrefixedString(String, Construct(size), enc)

PrefixedString(::Type{S}, size::Union{Type{I}, Construct{I}}) where {S<:AbstractString, I<:Integer} = PrefixedString(S, Construct(size), RawEncoding())
PrefixedString(::Type{S}, size::Union{Type{I}, Construct{I}}, enc::AbstractString) where {S<:AbstractString, I<:Integer} = PrefixedString(S, Construct(size), Encoding(enc))
PrefixedString(::Type{S}, ::Type{I}, enc::Union{Encoding, RawEncoding}) where {S<:AbstractString, I<:Integer} = PrefixedString(S, Construct(I), enc)

PrefixedString(::Type{S}, sizecon::Construct{I}, enc::Enc) where {S<:AbstractString, I<:Integer, Enc<:Union{Encoding, RawEncoding}} = PrefixedString{S, Enc, I, typeof(sizecon)}(sizecon)

function serialize(cons::PrefixedString{S, RawEncoding, I, TSizeCon}, s::IO, obj::S; contextkw...) where {S<:AbstractString, I, TSizeCon}
    serialize(cons.sizecon, s, sizeof(obj); contextkw...) + write(s, obj)
end
function serialize(cons::PrefixedString{S, Enc, I, TSizeCon}, s::IO, obj::S; contextkw...) where {S<:AbstractString, Enc<:Encoding, I, TSizeCon}
    b = IOBuffer()
    p = StringEncoder(b, Enc(), encoding(S))
    write(p, obj)
    close(p)
    seekstart(b)
    bs = take!(b)
    serialize(cons.sizecon, s, length(bs); contextkw...) + write(s, bs)
end

function deserialize(cons::PrefixedString{S, RawEncoding, I, TSizeCon}, s::IO; contextkw...) where {S<:AbstractString, I, TSizeCon}
    size = deserialize(cons.sizecon, s; contextkw...)
    S(read(s, size))
end
function deserialize(cons::PrefixedString{S, Enc, I, TSizeCon}, s::IO; contextkw...) where {S<:AbstractString, Enc<:Encoding, I, TSizeCon}
    size = deserialize(cons.sizecon, s; contextkw...)
    b = IOBuffer(read(s, size); read=true)
    S(read(StringDecoder(b, Enc(), encoding(S))))
end

estimatesize(cons::PrefixedString; contextkw...) = estimatesize(cons.sizecon; contextkw...) + UnboundedSize(0)

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
