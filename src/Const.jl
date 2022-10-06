"""
    Const{T, TSubCon<:Construct{T}, VT} <: Validator{T}

Field enforcing a constant.
"""
struct Const{T, TSubCon<:Construct{T}, VT} <: Validator{T}
    subcon::TSubCon
    value::VT
end

Const(::Type{T}, value::VT) where {T, VT} = Const(Construct(T), value)
Const(value::T) where {T} = Const(Construct(T), value)
Const(value::AbstractArray{V, N}) where {V, N} = Const(SizedArray(typeof(similar(value, size(value))), V, size(value)...), value)

function validate(cons::Const{T, TSubCon, VT}, obj::T; contextkw...) where {T, TSubCon, VT}
    (cons.value == obj) === true ? ValidationOK : ValidationError("$obj mismatch the const value $(cons.value).")
end
