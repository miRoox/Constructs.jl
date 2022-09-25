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

"""
    GreedyVector{T, TSubCon<:Construct{T}} <: BaseArray{T, 1}

Homogenous array of elements for unknown count of elements by parsing until end of stream.
"""
struct GreedyVector{T, TSubCon<:Construct{T}} <: BaseArray{T, 1}
    subcon::TSubCon
end

GreedyVector(type::Type) = GreedyVector(Construct(type))

function deserialize(array::GreedyVector{T, TSubCon}, s::IO; contextkw...) where {T, TSubCon}
    result = Vector{T}()
    fallback = 0
    try
        while !eof(s)
            fallback = position(s)
            push!(result, deserialize(array.subcon, s; contextkw...))
        end
    catch
        seek(s, fallback)
        # rethrow()
    end
    result
end
function serialize(array::GreedyVector{T, TSubCon}, s::IO, obj::Vector{T}; contextkw...) where {T, TSubCon}
    bytecount = 0
    for v in obj
        bytecount += serialize(array.subcon, s, v; contextkw...)
    end
    bytecount
end
estimatesize(::GreedyVector; contextkw...) = Interval(UInt(0), nothing)
