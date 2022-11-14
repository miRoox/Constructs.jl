
struct Optional{TU, T, TV, TSubCon<:Construct{T}} <: Wrapper{T, TU}
    subcon::TSubCon
    default::TV

    Optional{TU, T, TV, TSubCon}(subcon::TSubCon, default::TV) where {TU, T<:TU, TV<:TU, TSubCon<:Construct{T}} = new{TU, T, TV, TSubCon}(subcon, default)
end

"""
    Optional(T|subcon, [default = nothing]) -> Construct{Union{T, TV}}
    Optional{TU}(T|subcon, [default = nothing]) -> Construct{TU}

Optional construct with a `default` value.

# Arguments

- `TU`: the common type of the construct and the default value.
- `T<:TU`: the type of the sub construct.
- `TV<:TU`: the type of the default value.
- `subcon::Construct{T}`: the sub construct.
- `default::TV`: the default value.
"""
Optional(sub::Union{Type{T}, Construct{T}}, default::TV = nothing) where {T, TV} = Optional{Union{T, TV}}(sub, default)
Optional{TU}(subcon::TSubCon, default::TV = nothing) where {TU, T<:TU, TV<:TU, TSubCon<:Construct{T}} = Optional{TU, T, TV, TSubCon}(subcon, default)
Optional{TU}(::Type{T}, default::TV = nothing) where {TU, T<:TU, TV<:TU} = Optional{TU}(Construct(T), default)

function deserialize(cons::Optional, s::IO; contextkw...)
    fallback = position(s)
    try
        deserialize(cons.subcon, s; contextkw...)
    catch
        seek(s, fallback)
        cons.default
    end
end

function serialize(cons::Optional{TU, T, TV, TSubCon}, s::IO, v::T; contextkw...) where {TU, TV, T<:TV, TSubCon}
    fallback = position(s)
    try
        serialize(cons.subcon, s, v; contextkw...)
    catch
        seek(s, fallback)
        0
    end
end

function serialize(cons::Optional{TU, T, TV, TSubCon}, s::IO, v::T; contextkw...) where {TU, T, TV, TSubCon}
    serialize(cons.subcon, s, v; contextkw...)
end

serialize(cons::Optional{TU, T, TV, TSubCon}, s::IO, v::TV; contextkw...) where {TU, T, TV, TSubCon} = 0

estimatesize(cons::Optional; contextkw...) = union(estimatesize(cons.subcon; contextkw...), ExactSize(0))

default(cons::Optional; contextkw...) = cons.default
