
"""
    Repeat{T, TSubCon<:Construct{T}} <: Wrapper{T, AbstractVector{T}}

Homogenous array of elements.
"""
struct Repeat{T, TSubCon<:Construct{T}} <: Wrapper{T, AbstractVector{T}}
    subcon::TSubCon
    count::UInt
end

Repeat(subcon::Construct, count::Integer) = Repeat(subcon, convert(UInt, count))
Repeat(type::Type, count::Integer) = Repeat(Construct(type), convert(UInt, count))

subcon(wrapper::Repeat) = wrapper.subcon
function deserialize(array::Repeat{T, TSubCon}, s::IO; contextkw...) where {T, TSubCon}
    count = array.count
    result = Vector{T}(undef, count)
    for i in 1:count
        result[i] = deserialize(array.subcon, s; contextkw...)
    end
    result
end
function serialize(array::Repeat{T, TSubCon}, s::IO, obj::AbstractVector{T}; contextkw...) where {T, TSubCon}
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
estimatesize(array::Repeat; contextkw...) = array.count * estimatesize(array.subcon; contextkw...)

"""
    RepeatGreedily{T, TSubCon<:Construct{T}} <: Wrapper{T, AbstractVector{T}}

Homogenous array of elements for unknown count of elements by parsing until end of stream.
"""
struct RepeatGreedily{T, TSubCon<:Construct{T}} <: Wrapper{T, AbstractVector{T}}
    subcon::TSubCon
end

RepeatGreedily(type::Type) = RepeatGreedily(Construct(type))

subcon(wrapper::RepeatGreedily) = wrapper.subcon
function deserialize(array::RepeatGreedily{T, TSubCon}, s::IO; contextkw...) where {T, TSubCon}
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
function serialize(array::RepeatGreedily{T, TSubCon}, s::IO, obj::AbstractVector{T}; contextkw...) where {T, TSubCon}
    bytecount = 0
    for v in obj
        bytecount += serialize(array.subcon, s, v; contextkw...)
    end
    bytecount
end
estimatesize(::RepeatGreedily; contextkw...) = Interval(UInt(0), nothing)

Construct(::Type{Vector{T}}) where {T} = RepeatGreedily(T)
