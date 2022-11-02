
function apply_optional_contextkw(f::Function, obj::T, contextkw) where {T}
    if hasmethod(f, Tuple{T}, keys(contextkw))
        f(obj; contextkw...)
    else
        f(obj)
    end
end

struct FunctionValidator{T, TSubCon<:Construct{T}} <: Validator{T}
    subcon::TSubCon
    validate::Function

    function FunctionValidator{T, TSubCon}(subcon::TSubCon, validate::Function) where {T, TSubCon<:Construct{T}}
        if !hasmethod(validate, Tuple{T}, ())
            throw(ArgumentError("$validate doesn't have a method for (::$T)."))
        end
        new{T, TSubCon}(subcon, validate)
    end
end

FunctionValidator(subcon::TSubCon, validate::Function) where {T, TSubCon<:Construct{T}} = FunctionValidator{T, TSubCon}(subcon, validate)
FunctionValidator(::Type{T}, validate::Function) where {T} = FunctionValidator(Construct(T), validate)

"""
    Validator(T|subcon, validate) -> Validator{T}

Create a validator based on the `validate` function.

# Arguments

- `subcon::Construct{T}`: the underlying construct.
- `validate`: the validate function. the function should have signature like `(::T; contextkw...)->Bool`.
"""
Validator(subcon::Union{Type, Construct}, validate::Function) = FunctionValidator(subcon, validate)

function validate(cons::FunctionValidator{T, TSubCon}, obj::T; contextkw...) where {T, TSubCon}
    apply_optional_contextkw(cons.validate, obj, contextkw)
end

struct FunctionSymmetricAdapter{T, TSubCon<:Construct{T}} <: SymmetricAdapter{T}
    subcon::TSubCon
    encode::Function
    
    function FunctionSymmetricAdapter{T, TSubCon}(subcon::TSubCon, encode::Function) where {T, TSubCon<:Construct{T}}
        if !hasmethod(encode, Tuple{T}, ())
            throw(ArgumentError("$encode doesn't have a method for (::$T)."))
        end
        new{T, TSubCon}(subcon, encode)
    end
end

FunctionSymmetricAdapter(subcon::TSubCon, encode::Function) where {T, TSubCon<:Construct{T}} = FunctionSymmetricAdapter{T, TSubCon}(subcon, encode)
FunctionSymmetricAdapter(::Type{T}, encode::Function) where {T} = FunctionSymmetricAdapter(Construct(T), encode)

"""
    Adapter(T|subcon, encode) -> SymmetricAdapter{T}
    SymmetricAdapter(T|subcon, encode) -> SymmetricAdapter{T}

Create a symmetric adapter based on the `encode` function.

# Arguments

- `subcon::Construct{T}`: the underlying construct.
- `encode`: the encoding function. the function should have signature like `(::T; contextkw...)->T` and satisfies involution (`encode(encode(x)) == x`).
"""
SymmetricAdapter(subcon::Union{Type, Construct}, encode::Function) = FunctionSymmetricAdapter(subcon, encode)
Adapter(subcon::Union{Type, Construct}, encode::Function) = FunctionSymmetricAdapter(subcon, encode)

function encode(cons::FunctionSymmetricAdapter{T, TSubCon}, obj::T; contextkw...) where {T, TSubCon}
    convert(T, apply_optional_contextkw(cons.encode, obj, contextkw))
end

# internal template
struct Prefixed{S, T, TSizeCon<:Construct{S}, TSubCon<:Construct{T}} <: Construct{T}
    sizecon::TSizeCon
    sizegetter::Function # obj::T -> S
    fsubcon::Function # size::S -> TSubCon
end

function deserialize(cons::Prefixed{S, T, TSizeCon, TSubCon}, s::IO; contextkw...) where {S, T, TSizeCon<:Construct{S}, TSubCon<:Construct{T}}
    size::S = deserialize(cons.sizecon, s; contextkw...)
    subcon::TSubCon = cons.fsubcon(size)
    deserialize(subcon, s; contextkw...)
end

function serialize(cons::Prefixed{S, T, TSizeCon, TSubCon}, s::IO, obj::T; contextkw...) where {S, T, TSizeCon<:Construct{S}, TSubCon<:Construct{T}}
    size::S = cons.sizegetter(obj)
    subcon::TSubCon = cons.fsubcon(size)
    serialize(cons.sizecon, s, size; contextkw...) + serialize(subcon, s, obj; contextkw...)
end

estimatesize(cons::Prefixed; contextkw...) = estimatesize(cons.sizecon; contextkw...) + UnboundedSize(0) # assume the size of subcon is unbounded.
