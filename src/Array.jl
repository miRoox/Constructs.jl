"""
    SizedArray{T, TSubCon<:Construct{T}, N} <: Wrapper{T, Array{T, N}}

Homogenous array of elements.
"""
struct SizedArray{T, TSubCon<:Construct{T}, N} <: Wrapper{T, Array{T, N}}
    subcon::TSubCon
    size::NTuple{N, UInt}
end

SizedArray(subcon::Construct, size::NTuple{N, Integer}) where {N} = SizedArray(subcon, convert(NTuple{N, UInt}, size))
SizedArray(type::Type, size::NTuple{N, Integer}) where {N} = SizedArray(Construct(type), size)
SizedArray(subcon::Construct, count::Integer) = SizedArray(subcon, (convert(UInt, count),))
SizedArray(type::Type, count::Integer) = SizedArray(Construct(type), count)

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
