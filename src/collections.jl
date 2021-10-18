
"""
    SizedArray{T, TSubCon<:Construct{T}} <: Wrapper{T, AbstractVector{T}}

Homogenous array of elements.
"""
struct SizedArray{T, TSubCon<:Construct{T}} <: Wrapper{T, AbstractVector{T}}
    subcon::TSubCon
    count::UInt
end

SizedArray(subcon::Construct, count::Integer) = SizedArray(subcon, convert(UInt, count))
SizedArray(type::Type, count::Integer) = SizedArray(Construct(type), convert(UInt, count))

subcon(wrapper::SizedArray) = wrapper.subcon
function deserialize(array::SizedArray{T, TSubCon}, s::IO; contextkw...) where {T, TSubCon}
    count = array.count
    result = Vector{T}(undef, count)
    for i in eachindex(result)
        result[i] = deserialize(array.subcon, s; contextkw...)
    end
    result
end
function serialize(array::SizedArray{T, TSubCon}, s::IO, obj::AbstractVector{T}; contextkw...) where {T, TSubCon}
    actualcount = length(obj)
    if actualcount != array.count
        throw(ValidationError("expected $(array.count) elements, found $actualcount"))
    end
    bytecount = 0
    for v in obj
        bytecount += serialize(array.subcon, s, v; contextkw...)
    end
    bytecount
end
estimatesize(array::SizedArray; contextkw...) = array.count * estimatesize(array.subcon; contextkw...)

"""
    GreedyArray{T, TSubCon<:Construct{T}} <: Wrapper{T, AbstractVector{T}}

Homogenous array of elements for unknown count of elements by parsing until end of stream.
"""
struct GreedyArray{T, TSubCon<:Construct{T}} <: Wrapper{T, AbstractVector{T}}
    subcon::TSubCon
end

GreedyArray(type::Type) = GreedyArray(Construct(type))

subcon(wrapper::GreedyArray) = wrapper.subcon
function deserialize(array::GreedyArray{T, TSubCon}, s::IO; contextkw...) where {T, TSubCon}
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
function serialize(array::GreedyArray{T, TSubCon}, s::IO, obj::AbstractVector{T}; contextkw...) where {T, TSubCon}
    bytecount = 0
    for v in obj
        bytecount += serialize(array.subcon, s, v; contextkw...)
    end
    bytecount
end
estimatesize(::GreedyArray; contextkw...) = Interval(UInt(0), nothing)

Construct(::Type{Vector{T}}) where {T} = GreedyArray(T)
