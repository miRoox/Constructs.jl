
"""
    deserialize(T, s::IO; contextkw...)

Deserialize a stream to an object.
"""
function deserialize(t::Type, s::IO)
    if isbitstype(t)
        n = Base.sizeof(t)
        bytes = read(s, n)
        return reinterpret(t, bytes)[]
    end
    throw(ArgumentError("Invalid type $t."))
end

"""
    deserialize(T, filename::AbstractString; contextkw...)

Deserialize a file to an object.
"""
deserialize(t::Type, filename::AbstractString; contextkw...) = open(filename, "r") do fs
    deserialize(t, fs; contextkw...)
end

"""
    deserialize(T, bytes::AbstractVector{UInt8}; contextkw...)

Deserialize a byte array to an object.
"""
deserialize(t::Type, bytes::AbstractVector{UInt8}; contextkw...) = deserialize(t, IOBuffer(bytes), contextkw...)

"""
    serialize(obj, s::IO; contextkw...)

Serialize an object into a stream.
"""
function serialize(obj::T, s::IO) where {T}
    if isbits(obj)
        bytes = reinterpret(UInt8, [obj])
        write(s, bytes)
    end
    throw(ArgumentError("Invalid type $T."))
end

"""
    serialize(obj, filename::AbstractString; contextkw...)

Serialize an object to the file.
"""
serialize(obj, filename::AbstractString; contextkw...) = open(filename, "w") do fs
    serialize(obj, fs, contextkw...)
end

"""
    serialize(obj; contextkw...)

Serialize an object in memory (a byte array).
"""
function serialize(obj; contextkw...)
    io = IOBuffer()
    serialize(obj, io, contextkw...)
    return take!(io)
end

"""
    estimatesize(T; contextkw...)

Estimate the size of the type.
"""
estimatesize(::Type) = Interval(UInt(0), nothing)

"""
Base type of wrapper of `T`.
"""
abstract type Wrapper{T} end

Base.promote_rule(::Type{Wrapper{T}}, ::Type{T}) where {T} = T
Base.convert(wrap::Type{Wrapper{T}}, val::T) where {T} = wrap(val)
Base.convert(::Type{T}, wrapper::Wrapper{T}) where {T} = reinterpret(T, [wrapper])[]
