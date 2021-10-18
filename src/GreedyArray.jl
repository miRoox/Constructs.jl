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
