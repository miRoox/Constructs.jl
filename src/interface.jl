
"""
    Construct{T}

Construct is used for serializing and deserializing objects.

## Methods

- [`deserialize(cons::Construct{T}, s::IO; contextkw...)`](@ref deserialize)
- [`serialize(cons::Construct{T}, s::IO, obj::T; contextkw...)`](@ref serialize)
- [`estimatesize(cons::Construct{T}; contextkw...)`](@ref estimatesize) - optional
"""
abstract type Construct{T} end

"""
    Construct(T) -> Construct{T}

Get default construct for type `T`.
"""
Construct(cons::Construct) = cons

constructtype(::Construct{T}) where {T} = T
constructtype(type::Type) = type

"""
    deserialize(cons::Construct{T}, s::IO; contextkw...) -> T
    deserialize(T, s::IO; contextkw...) -> T

Deserialize a stream to an object.
"""
function deserialize end

"""
    deserialize(cons::Construct{T}, filename::AbstractString; contextkw...) -> T
    deserialize(T, filename::AbstractString; contextkw...) -> T

Deserialize a file to an object.
"""
deserialize(cons::Construct, filename::AbstractString; contextkw...) = open(filename, "r") do fs
    deserialize(cons, fs; contextkw...)
end

"""
    deserialize(cons::Construct{T}, bytes::AbstractVector{UInt8}; contextkw...) -> T
    deserialize(T, bytes::AbstractVector{UInt8}; contextkw...) -> T

Deserialize a byte array to an object.
"""
deserialize(cons::Construct, bytes::AbstractVector{UInt8}; contextkw...) = deserialize(cons, IOBuffer(bytes); contextkw...)

deserialize(t::Type, s::IO; contextkw...) = deserialize(Construct(t), s; contextkw...)
deserialize(t::Type, filename::AbstractString; contextkw...) = deserialize(Construct(t), filename; contextkw...)
deserialize(t::Type, bytes::AbstractVector{UInt8}; contextkw...) = deserialize(Construct(t), IOBuffer(bytes); contextkw...)

"""
    serialize(cons::Construct, s::IO, obj; contextkw...)
    serialize(T, s::IO, obj; contextkw...)
    serialize(s::IO, obj; contextkw...)

Serialize an object into a stream.
"""
function serialize end

function serialize(cons::Construct{T}, s::IO, obj::U; contextkw...) where {T, U}
    if !(U <: T)
        serialize(cons, s, convert(T, obj); contextkw...)
    else # avoid infinity recursive calls
        throw(MethodError(serialize, (NamedTuple(contextkw), cons, s, obj)))
    end
end

function serialize(cons::Construct, s::IO, ::UndefProperty; contextkw...)
    serialize(cons, s, default(cons; contextkw...); contextkw...)
end

"""
    serialize(cons::Construct, filename::AbstractString, obj; contextkw...)
    serialize(T, filename::AbstractString, obj; contextkw...)
    serialize(filename::AbstractString, obj; contextkw...)

Serialize an object to the file.
"""
serialize(cons::Construct{T}, filename::AbstractString, obj; contextkw...) where {T} = open(filename, "w") do fs
    serialize(cons, fs, obj; contextkw...)
end

"""
    serialize(cons::Construct, obj; contextkw...) -> Vector{UInt8}
    serialize(T, obj; contextkw...) -> Vector{UInt8}
    serialize(obj; contextkw...) -> Vector{UInt8}

Serialize an object in memory (a byte array).
"""
function serialize(cons::Construct{T}, obj; contextkw...) where {T}
    io = IOBuffer()
    serialize(cons, io, obj; contextkw...)
    return take!(io)
end

serialize(type::Type, s::IO, obj; contextkw...) = serialize(Construct(type), s, obj; contextkw...)
serialize(type::Type, filename::AbstractString, obj; contextkw...) = serialize(Construct(type), filename, obj; contextkw...)
serialize(type::Type, obj; contextkw...) = serialize(Construct(type), obj; contextkw...)

serialize(s::IO, obj; contextkw...) = serialize(Construct(undeftypeof(obj)), s, obj; contextkw...)
serialize(filename::AbstractString, obj; contextkw...) = serialize(Construct(undeftypeof(obj)), filename, obj; contextkw...)
serialize(obj; contextkw...) = serialize(Construct(undeftypeof(obj)), obj; contextkw...)

"""
    estimatesize(cons::Construct; contextkw...) -> ConstructSize
    estimatesize(T; contextkw...) -> ConstructSize

Estimate the size of the type.
"""
estimatesize(::Construct; contextkw...) = UnboundedSize(0)
estimatesize(t::Type; contextkw...) = estimatesize(Construct(t); contextkw...)

"""
    default(cons::Construct{T}; contextkw...) -> T
    default(T; contextkw...) -> T

Get default value for the construct/type.

This method is usually called for anonymous fields in [`@construct`](@ref).
"""
function default(::Construct{T}; contextkw...) where {T}
    if Base.issingletontype(T)
        T()
    else
        default(T; contextkw...)
    end
end

default(t::Type{<:Number}; contextkw...) = zero(t)

"""
    Wrapper{TSub, T} <: Construct{T}

Abstract wrapper for `TSub`.

## Methods

- [`subcon(wrapper::Wrapper{TSub, T})`](@ref subcon)
"""
abstract type Wrapper{TSub, T} <: Construct{T} end

"""
    subcon(wrapper::Wrapper{TSub, T}) -> Construct{TSub}

Get sub-construct of `wrapper`.
"""
subcon(wrapper::Wrapper) = getproperty(wrapper, :subcon) # built-in sub-constructs always follow this convention

"""
    Adapter{TSub, T} <: Wrapper{TSub, T}

Abstract adapter type.

## Methods

- [`subcon(adapter::Adapter{TSub, T})`](@ref subcon)
- [`encode(adapter::Adapter{TSub, T}, obj::T; contextkw...)`](@ref encode)
- [`decode(adapter::Adapter{TSub, T}, obj::TSub; contextkw...)`](@ref decode)
"""
abstract type Adapter{TSub, T} <: Wrapper{TSub, T} end

"""
    encode(adapter::Adapter{TSub, T}, obj::T; contextkw...) -> TSub

Encode the input object when serializing.
"""
function encode end

"""
    decode(adapter::Adapter{TSub, T}, obj::TSub; contextkw...) -> T

Decode the output object when deserializing.
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

estimatesize(wrapper::Adapter; contextkw...) = estimatesize(subcon(wrapper); contextkw...)

"""
    SymmetricAdapter{T} <: Adapter{T, T}

Abstract adapter type. `encode` both for serializing and deserializing.

## Methods

- [`subcon(adapter::SymmetricAdapter{T})`](@ref subcon)
- [`encode(adapter::SymmetricAdapter{T}, obj::T; contextkw...)`](@ref encode)
"""
abstract type SymmetricAdapter{T} <: Adapter{T, T} end

decode(adapter::SymmetricAdapter{T}, obj::T; contextkw...) where {T} = encode(adapter, obj; contextkw...)

"""
    Validator{T} <: SymmetricAdapter{T}

Abstract validator type. Validates a condition on the encoded/decoded object..

## Methods

- [`subcon(validator::Validator{T})`](@ref subcon)
- [`validate(validator::Validator{T}, obj::T; contextkw...)`](@ref validate)
"""
abstract type Validator{T} <: SymmetricAdapter{T} end

"""
    validate(validator::Validator{T}, obj::T; contextkw...) -> Bool

Checks whether the given `obj` is a valid value for the `validator`.

Should return a `Bool` or throw a [`ValidationError`](@ref).
"""
function validate end

function encode(validator::Validator{T}, obj::T; contextkw...) where {T}
    result = validate(validator, obj; contextkw...)
    if result !== true
        throw(ValidationError("object failed validation: $obj"))
    end
    obj
end
