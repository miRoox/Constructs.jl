
"""
    @Array(sub, size)

Homogenous array of elements.
"""
macro Array(sub, size...)
    if all(iscontextfree, size)
        Expr(:call, GlobalRef(Constructs, :SizedArray), sub, size...)
    else
        Expr(:call, GlobalRef(Constructs, :ContextualArray), sub, map(x -> iscontextfree(x) ? x : QuoteNode(x), size)...)
    end
end

"""
    BaseArray{T, N} <: Wrapper{T, Array{T, N}}

Abstract base type for Array wrapper.
"""
abstract type BaseArray{T, N} <: Wrapper{T, Array{T, N}} end

"""
    SizedArray{T, TSubCon<:Construct{T}, N} <: Wrapper{T, Array{T, N}}

Homogenous array of elements.
"""
struct SizedArray{T, TSubCon<:Construct{T}, N} <: BaseArray{T, N}
    subcon::TSubCon
    size::NTuple{N, UInt}
end

SizedArray(subcon::Construct, size::Vararg{Integer, N}) where {N} = SizedArray(subcon, convert(NTuple{N, UInt}, size))
SizedArray(type::Type, size::Vararg{Integer, N}) where {N} = SizedArray(Construct(type), size...)

subcon(wrapper::SizedArray) = wrapper.subcon
function deserialize(array::SizedArray{T, TSubCon, N}, s::IO; contextkw...) where {T, TSubCon, N}
    result = Array{T}(undef, array.size)
    for i in eachindex(result)
        result[i] = deserialize(array.subcon, s; contextkw...)
    end
    result
end
function serialize(array::SizedArray{T, TSubCon, N}, s::IO, obj::Array{T, N}; contextkw...) where {T, TSubCon, N}
    actualsize = size(obj)
    if actualsize != array.size
        throw(ValidationError("expected $(array.size) elements, found $actualsize."))
    end
    bytecount = 0
    for i in eachindex(obj)
        bytecount += serialize(array.subcon, s, obj[i]; contextkw...)
    end
    bytecount
end
estimatesize(array::SizedArray; contextkw...) = prod(array.size) * estimatesize(array.subcon; contextkw...)

struct ContextualArray{T, TSubCon<:Construct{T}, N} <: BaseArray{T, N}
    subcon::TSubCon
    size::NTuple{N, Any}
end

ContextualArray(subcon::Construct, size::Vararg{Any, N}) where {N} = ContextualArray(subcon, size)
ContextualArray(type::Type, size::Vararg{Any, N}) where {N} = ContextualArray(Construct(type), size...)

subcon(wrapper::ContextualArray) = wrapper.subcon
