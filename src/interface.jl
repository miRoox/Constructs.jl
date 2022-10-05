
"""
    Construct{T}

Construct is used for serializing and deserializing objects.

## Methods

* `deserialize(cons::Construct{T}, s::IO; contextkw...)::T`
* `serialize(cons::Construct{T}, s::IO, obj::T; contextkw...)`
* `estimatesize(cons::Construct{T}; contextkw...)` - optional
"""
abstract type Construct{T} end

"""
    Construct(type)

Get default construct for type.
"""
Construct(cons::Construct) = cons

constructtype(::Construct{T}) where {T} = T
constructtype(type::Type) = type

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
deserialize(t::Type, s::IO; contextkw...) = deserialize(Construct(t), s; contextkw...)

"""
    deserialize(T, filename::AbstractString; contextkw...)

Deserialize a file to an object.
"""
deserialize(t::Type, filename::AbstractString; contextkw...) = deserialize(Construct(t), filename; contextkw...)

"""
    deserialize(T, bytes::AbstractVector{UInt8}; contextkw...)

Deserialize a byte array to an object.
"""
deserialize(t::Type, bytes::AbstractVector{UInt8}; contextkw...) = deserialize(Construct(t), IOBuffer(bytes); contextkw...)

"""
    serialize(cons::Construct, s::IO, obj; contextkw...)

Serialize an object into a stream.
"""
function serialize end

"""
    serialize(cons::Construct, s::IO, ::UndefProperty; contextkw...)

Serialize an insufficient object into a stream.

# Note

This method is usually called for anonymous fields in [`@construct`](@ref).

By default, only singleton types support this because they don't need to write anything.
"""
function serialize(cons::Construct{T}, s::IO, ::UndefProperty; contextkw...) where {T}
    if Base.issingletontype(T)
        serialize(cons, s, T.instance; contextkw...)
    else
        throw(MethodError(serialize, (NamedTuple(contextkw), cons, s, UndefProperty())))
    end
end

"""
    serialize(cons::Construct, filename::AbstractString, obj; contextkw...)

Serialize an object to the file.
"""
serialize(cons::Construct{T}, filename::AbstractString, obj; contextkw...) where {T} = open(filename, "w") do fs
    serialize(cons, fs, obj; contextkw...)
end

"""
    serialize(cons::Construct, obj; contextkw...)

Serialize an object in memory (a byte array).
"""
function serialize(cons::Construct{T}, obj; contextkw...) where {T}
    io = IOBuffer()
    serialize(cons, io, obj; contextkw...)
    return take!(io)
end

"""
    serialize(T, s::IO, obj; contextkw...)

Serialize an object into a stream.
"""
serialize(type::Type, s::IO, obj; contextkw...) = serialize(Construct(type), s, obj; contextkw...)

"""
    serialize(T, filename::AbstractString, obj; contextkw...)

Serialize an object to the file.
"""
serialize(type::Type, filename::AbstractString, obj; contextkw...) = serialize(Construct(type), filename, obj; contextkw...)

"""
    serialize(T, obj; contextkw...)

Serialize an object in memory (a byte array).
"""
serialize(type::Type, obj; contextkw...) = serialize(Construct(type), obj; contextkw...)

"""
    serialize(s::IO, obj; contextkw...)

Serialize an object into a stream.
"""
serialize(s::IO, obj; contextkw...) = serialize(Construct(typeof(obj)), s, obj; contextkw...)

"""
    serialize(filename::AbstractString, obj; contextkw...)

Serialize an object to the file.
"""
serialize(filename::AbstractString, obj; contextkw...) = serialize(Construct(typeof(obj)), filename, obj; contextkw...)

"""
    serialize(obj; contextkw...)

Serialize an object in memory (a byte array).
"""
serialize(obj; contextkw...) = serialize(Construct(typeof(obj)), obj; contextkw...)

"""
    estimatesize(cons::Construct; contextkw...)

Estimate the size of the type.
"""
estimatesize(::Construct; contextkw...) = UnboundedSize(0)

"""
    estimatesize(T; contextkw...)

Estimate the size of the type.
"""
estimatesize(t::Type; contextkw...) = estimatesize(Construct(t); contextkw...)

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
subcon(wrapper::Wrapper) = getproperty(wrapper, :subcon) # built-in sub-constructs always follow this convention

"""
    Adapter{TSub, T} <: Wrapper{TSub, T}

Abstract adapter type.

## Methods

* `subcon(adapter::Adapter{TSub, T})::Construct{TSub}`
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

estimatesize(wrapper::Adapter) = estimatesize(subcon(wrapper))

"""
    SymmetricAdapter{T} <: Adapter{T, T}

Abstract adapter type. `encode` both for serializing and deserializing.

## Methods

* `subcon(adapter::SymmetricAdapter{T})::Construct{T}`
* `encode(adapter::SymmetricAdapter{T}, obj::T; contextkw...)`
"""
abstract type SymmetricAdapter{T} <: Adapter{T, T} end

decode(adapter::SymmetricAdapter{T}, obj::T; contextkw...) where {T} = encode(adapter, obj; contextkw...)

"""
    Validator{T} <: SymmetricAdapter{T}

Abstract validator type. Validates a condition on the encoded/decoded object..

## Methods

* `subcon(validator::Validator{T})::Construct{T}`
* `validate(validator::Validator{T}, obj::T; contextkw...)::Union{ValidationOk, ValidationError}`
"""
abstract type Validator{T} <: SymmetricAdapter{T} end

"""
    validate(validator::Validator{T}, obj::T; contextkw...)::Union{ValidationOk, ValidationError}
"""
function validate end

function encode(validator::Validator{T}, obj::T; contextkw...) where {T}
    result = validate(validator, obj; contextkw...)
    if result isa ValidationError
        throw(result)
    end
    obj
end
