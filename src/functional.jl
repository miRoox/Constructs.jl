
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
