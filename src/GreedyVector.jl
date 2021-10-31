"""
    GreedyVector{T, TSubCon<:Construct{T}} <: Wrapper{T, Vector{T}}

Homogenous array of elements for unknown count of elements by parsing until end of stream.
"""
struct GreedyVector{T, TSubCon<:Construct{T}} <: Wrapper{T, Vector{T}}
    subcon::TSubCon
end

GreedyVector(type::Type) = GreedyVector(Construct(type))

subcon(wrapper::GreedyVector) = wrapper.subcon
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
