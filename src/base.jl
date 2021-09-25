"""
    Construct{T}

Construct is used for serializing and deserializing objects.

## Methods

* `deserialize(cons::Construct{T}, s::IO; contextkw...)::T`
* `serialize(cons::Construct{T}, s::IO, obj::T; contextkw...)`
* `estimatesize(cons::Construct{T}; contextkw...)` - optional
"""
abstract type Construct{T} end

constructtype(::Construct{T}) where {T} = T

"""
    Default{T} <: Construct{T}

Default construct for type `T`.
"""
struct Default{T} <: Construct{T} end

Default(::Type{T}) where {T} = Default{T}()

"""
    deserialize(cons::Construct, s::IO; contextkw...)

Deserialize a stream to an object.
"""
function deserialize end

"""
    deserialize(cons::Construct, filename::AbstractString; contextkw...)

Deserialize a file to an object.
"""
deserialize(cons::Construct, filename::AbstractString; contextkw...) = open(filename, "r") do fs
    deserialize(cons, fs; contextkw...)
end

"""
    deserialize(cons::Construct, bytes::AbstractVector{UInt8}; contextkw...)

Deserialize a byte array to an object.
"""
deserialize(cons::Construct, bytes::AbstractVector{UInt8}; contextkw...) = deserialize(cons, IOBuffer(bytes); contextkw...)

"""
    deserialize(T, s::IO; contextkw...)

Deserialize a stream to an object.
"""
deserialize(t::Type, s::IO; contextkw...) = deserialize(Default(t), s; contextkw...)

"""
    deserialize(T, filename::AbstractString; contextkw...)

Deserialize a file to an object.
"""
deserialize(t::Type, filename::AbstractString; contextkw...) = deserialize(Default(t), filename; contextkw...)

"""
    deserialize(T, bytes::AbstractVector{UInt8}; contextkw...)

Deserialize a byte array to an object.
"""
deserialize(t::Type, bytes::AbstractVector{UInt8}; contextkw...) = deserialize(Default(t), IOBuffer(bytes); contextkw...)

"""
    serialize(cons::Construct, s::IO, obj; contextkw...)

Serialize an object into a stream.
"""
function serialize end

"""
    serialize(cons::Construct, filename::AbstractString, obj; contextkw...)

Serialize an object to the file.
"""
serialize(cons::Construct{T}, filename::AbstractString, obj::T; contextkw...) where {T} = open(filename, "w") do fs
    serialize(cons, fs, obj; contextkw...)
end

"""
    serialize(cons::Construct, obj; contextkw...)

Serialize an object in memory (a byte array).
"""
function serialize(cons::Construct{T}, obj::T; contextkw...) where {T}
    io = IOBuffer()
    serialize(cons, io, obj; contextkw...)
    return take!(io)
end

"""
    serialize(obj, s::IO; contextkw...)

Serialize an object into a stream.
"""
serialize(s::IO, obj; contextkw...) = serialize(Default(typeof(obj)), s, obj; contextkw...)

"""
    serialize(filename::AbstractString, obj; contextkw...)

Serialize an object to the file.
"""
serialize(filename::AbstractString, obj; contextkw...) = serialize(Default(typeof(obj)), filename, obj; contextkw...)

"""
    serialize(obj; contextkw...)

Serialize an object in memory (a byte array).
"""
serialize(obj; contextkw...) = serialize(Default(typeof(obj)), obj; contextkw...)

"""
    estimatesize(cons::Construct; contextkw...)

Estimate the size of the type.
"""
estimatesize(::Construct) = Interval(UInt(0), nothing)

"""
    estimatesize(T; contextkw...)

Estimate the size of the type.
"""
estimatesize(t::Type) = estimatesize(Default(t))

"""
    Wrapper{TSub, T} <: Construct{T}

Base type of wrapper of `TSub`.

## Methods

* `subcon(wrapper::Wrapper{TSub, T})::Construct{TSub}`
"""
abstract type Wrapper{TSub, T} <: Construct{T} end

"""
    subcon(wrapper::Wrapper{TSub, T})::Construct{TSub}

Get sub-construct of `wrapper`.
"""
function subcon end

estimatesize(wrapper::Wrapper) = estimatesize(subcon(wrapper))

"""
    Adapter{TSub, T} <: Wrapper{TSub, T}

Abstract adapter type.

## Methods

* `subcon(wrapper::Wrapper{TSub, T})::Construct{TSub}`
* `encode(adapter::Adapter{TSub, T}, obj::T; contextkw...)`
* `decode(adapter::Adapter{TSub, T}, obj::TSub; contextkw...)`
"""
abstract type Adapter{TSub, T} <: Wrapper{TSub, T} end

"""
    encode(adapter::Adapter{TSub, T}, obj::T; contextkw...) where {TSub, T}
"""
function encode end

"""
    decode(adapter::Adapter{TSub, T}, obj::TSub; contextkw...) where {TSub, T}
"""
function decode end

function serialize(adapter::Adapter{TSub, T}, s::IO, obj::T; contextkw...) where {TSub, T}
    objsub = encode(adapter, obj; contextkw...)
    serialize(subcon(adapter), s, objsub; contextkw...)
end

function deserialize(adapter::Adapter{TSub, T}, s::IO; contextkw...) where {TSub, T}
    obj = deserialize(subcon(adapter), s; contextkw...)
    decode(adapter, obj; contextkw...)
end

"""
    SymmetricAdapter{T} <: Adapter{T, T}

Abstract adapter type. `encode` both for serializing and deserializing.

## Methods

* `subcon(wrapper::Wrapper{T, T})::Construct{TSub}`
* `encode(adapter::Adapter{T, T}, obj::T; contextkw...)`
"""
abstract type SymmetricAdapter{T} <: Adapter{T, T} end

decode(adapter::SymmetricAdapter{T}, obj::T; contextkw...) where {T} = encode(adapter, obj; contextkw...)
