
struct FunctionValidator{T, TSubCon<:Construct{T}} <: Validator{T}
    subcon::TSubCon
    validate::Function
end

FunctionValidator(::Type{T}, validate::Function) where {T} = FunctionValidator(Construct(T), validate)

"""
    Validator(subcon, validate)

Create a validator based on the function.

# Arguments

- `subcon::Union{Type, Construct}`: the underlying type/construct.
- `validate`: the validate function. the function should have signature like `(::T; contextkw...)->Bool`.
"""
Validator(subcon::Union{Type, Construct}, validate::Function) = FunctionValidator(subcon, validate)

function validate(cons::FunctionValidator{T, TSubCon}, obj::T; contextkw...) where {T, TSubCon}
    cons.validate(obj; contextkw...)
end

struct FunctionSymmetricAdapter{T, TSubCon<:Construct{T}} <: SymmetricAdapter{T}
    subcon::TSubCon
    encode::Function
end

FunctionSymmetricAdapter(::Type{T}, encode::Function) where {T} = FunctionSymmetricAdapter(Construct(T), encode)

"""
    Adapter(subcon, encode)
    SymmetricAdapter(subcon, encode)

Create a symmetric adapter based on the `encode` function.

# Arguments

- `subcon::Union{Type, Construct}`: the underlying type/construct.
- `encode`: the encoding function. the function should have signature like `(::T; contextkw...)->T` and satisfies `encode(encode(x)) == x`
"""
SymmetricAdapter(subcon::Union{Type, Construct}, encode::Function) = FunctionSymmetricAdapter(subcon, encode)
Adapter(subcon::Union{Type, Construct}, encode::Function) = FunctionSymmetricAdapter(subcon, encode)

function encode(cons::FunctionSymmetricAdapter{T, TSubCon}, obj::T; contextkw...) where {T, TSubCon}
    convert(T, cons.encode(obj; contextkw...))
end
