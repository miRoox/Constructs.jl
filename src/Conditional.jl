
"""
    IfThenElse(condition, TT|truecon, TF|falsecon) -> Construct{Union{TT, TF}}
    IfThenElse{TU}(condition, TT|truecon, TF|falsecon) -> Construct{TU}

Select the subconstructs based on the condition.

# Arguments

# Examples


"""
abstract type IfThenElse{TU} <: Construct{TU} end

serialize(cons::IfThenElse{TU}, obj::TU; contextkw...) where {TU} = serialize(subcon(cons), obj; contextkw...)
deserialize(cons::IfThenElse{TU}, s::IO; contextkw...) where {TU} = deserialize(subcon(cons), s; contextkw...)

struct IfThenElseSelect{TU, TT, TF, TSubConT<:Construct{TT}, TSubConF<:Construct{TF}} <: IfThenElse{TU}
    cond::Function
    truecon::TSubConT
    falsecon::TSubConF

    IfThenElseSelect{TU, TT, TF, TSubConT, TSubConF}(cond::Function, truecon::TSubConT, falsecon::TSubConF) where {TU, TT<:TU, TF<:TU, TSubConT<:Construct{TT}, TSubConF<:Construct{TF}} = new{TU, TT, TF, TSubConT, TSubConF}(cond, truecon, falsecon)
end

IfThenElseSelect{TU}(cond::Function, truecon::TSubConT, falsecon::TSubConF) where {TU, TT<:TU, TF<:TU, TSubConT<:Construct{TT}, TSubConF<:Construct{TF}} = IfThenElseSelect{TU, TT, TF, TSubConT, TSubConF}(cond, truecon, falsecon)

subcon(cons::IfThenElseSelect) = cons.cond() ? cons.truecon : cons.falsecon
estimatesize(cons::IfThenElseSelect; contextkw...) = union(estimatesize(cons.truecon; contextkw...), estimatesize(cons.falsecon; contextkw...))

# struct IfThenElseWrapper{TU, T, TSubCon<:Construct{T}} <: IfThenElse{TU}
#     subcon::TSubCon
# end

# IfThenElseWrapper{TU}(subcon::TSubCon) where {TU, T<:TU, TSubCon<:Construct{T}} = IfThenElseWrapper{TU, T, TSubCon}(subcon)
# IfThenElseWrapper{TU}(::Type{T}) where {TU, T<:TU} = IfThenElseWrapper{TU}(Construct(T))

# subcon(cons::IfThenElseWrapper) = cons.subcon
# estimatesize(cons::IfThenElseWrapper; contextkw...) = estimatesize(cons.subcon; contextkw...)

# IfThenElse{TU}(cond::Bool, truecon::Union{Type{TT}, Construct{TT}}, falsecon::Union{Type{TF}, Construct{TF}}) where {TU, TT<:TU, TF<:TU} = IfThenElseWrapper{TU}(cond ? truecon : falsecon)
IfThenElse{TU}(cond::Bool, truecon::Union{Type{TT}, Construct{TT}}, falsecon::Union{Type{TF}, Construct{TF}}) where {TU, TT<:TU, TF<:TU} = IfThenElse{TU}(()->cond, truecon, falsecon)
IfThenElse{TU}(cond::Function, truecon::Union{Type{TT}, Construct{TT}}, falsecon::Union{Type{TF}, Construct{TF}}) where {TU, TT<:TU, TF<:TU} = IfThenElseSelect{TU}(cond, Construct(truecon), Construct(falsecon))
IfThenElse(cond, truecon::Union{Type{TT}, Construct{TT}}, falsecon::Union{Type{TF}, Construct{TF}}) where {TT, TF} = IfThenElse{Union{TT, TF}}(cond, truecon, falsecon)
