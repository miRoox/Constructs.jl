"""
    Const{T, TSubCon<:Construct{T}} <: Validator{T}

Field enforcing a constant.
"""
struct Const{T, TSubCon<:Construct{T}} <: Validator{T}
    subcon::TSubCon
    value::T
end

Const(value::T) where {T} = Const(Construct(T), value)
Const(value::AbstractVector{V}) where {V} = Const(SizedArray(V, length(value)), value)
Const(::Type{T}, value::T) where {T} = Const(Construct(T), value)
Const(::Type{T}, value::U) where {T, U} = Const(Construct(T), convert(T, value))
Const(subcon::Construct{T}, value::U) where {T, U} = Const(subcon, convert(T, value))

subcon(wrapper::Const) = wrapper.subcon
function validate(cons::Const{T, TSubCon}, obj::T; contextkw...) where {T, TSubCon}
    cons.value == obj ? ValidationOK : ValidationError("$obj mismatch the const value $(cons.value).")
end
