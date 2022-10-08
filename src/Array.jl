"""
    Repeater{T, N, TA<:AbstractArray{T,N}} <: Wrapper{T, TA}

Abstract base type for Array wrapper.
"""
abstract type Repeater{T, N, TA<:AbstractArray{T,N}} <: Wrapper{T, TA} end

deduceArrayType(::Type{TA}, ::Type{T}, N::Integer) where {T, TA<:AbstractArray} = deducetype(Base.similar, TA, Type{T}, Dims{N})

"""
    SizedArray{T, N, TA<:AbstractArray{T,N}, TSubCon<:Construct{T}} <: Repeater{T, N, TA}

Homogenous array of elements.
"""
struct SizedArray{T, N, TA<:AbstractArray{T,N}, TSubCon<:Construct{T}} <: Repeater{T, N, TA}
    subcon::TSubCon
    size::NTuple{N, UInt}

    function SizedArray{T, N, TA, TSubCon}(subcon::TSubCon, size::NTuple{N, UInt}) where {T, N, TA<:AbstractArray{T,N}, TSubCon<:Construct{T}}
        CTA = deduceArrayType(TA, T, N)
        CTA::Type{TA}
        new{T, N, TA, TSubCon}(subcon, size)
    end
end

# pass deduced array type is not friendly to type deduction
# function createSizedArray(TA::UnionAll, subcon::TSubCon, size::Vararg{Integer, N}) where {T, N, TSubCon<:Construct{T}}
#     CTA = deduceArrayType(TA::Type{<:AbstractArray}, T, N)
#     SizedArray(CTA::Type{<:TA}, subcon, convert(NTuple{N, UInt}, size))
# end
"""
    SizedArray([arraytype,] element, size...)

Defines an array with specific size and element.

# Arguments

- `arraytype::Type`: the target array type, the default is `Array{T, N}`.
- `element::Union{Type, Construct}`: the type/construct of elements.
- `size`: the size of the array.
"""
function SizedArray(::Type{TA}, subcon::TSubCon, size::Vararg{Integer, N}) where {T, N, TA<:AbstractArray, TSubCon<:Construct{T}}
    SizedArray{T, N, TA, TSubCon}(subcon, convert(NTuple{N, UInt}, size))
end
SizedArray(::Type{TA}, ::Type{T}, size::Vararg{Integer, N}) where {T, N, TA<:AbstractArray} = SizedArray(TA, Construct(T), size...)

SizedArray(subcon::Construct{T}, size::Vararg{Integer, N}) where {T, N} = SizedArray(Array{T, N}, subcon, size...)
SizedArray(::Type{T}, size::Vararg{Integer, N}) where {T, N} = SizedArray(Array{T, N}, Construct(T), size...)

function deserialize(array::SizedArray{T, N, TA, TSubCon}, s::IO; contextkw...) where {T, N, TA, TSubCon}
    result = similar(TA, array.size)
    for i in eachindex(result)
        result[i] = deserialize(array.subcon, s; contextkw...)
    end
    result
end
function serialize(array::SizedArray{T, N, TA, TSubCon}, s::IO, obj::TA; contextkw...) where {T, N, TA, TSubCon}
    actualsize = size(obj)
    if actualsize != array.size
        throw(DimensionMismatch("expected $(array.size) elements, found $actualsize."))
    end
    bytecount = 0
    for i in eachindex(obj)
        bytecount += serialize(array.subcon, s, obj[i]; contextkw...)
    end
    bytecount
end
estimatesize(array::SizedArray; contextkw...) = prod(array.size) * estimatesize(array.subcon; contextkw...)

"""
    GreedyVector{T, TSubCon<:Construct{T}} <: Repeater{T, 1, Vector{T}}

Homogenous array of elements for unknown count of elements by deserializing until end of stream.
"""
struct GreedyVector{T, TSubCon<:Construct{T}} <: Repeater{T, 1, Vector{T}}
    subcon::TSubCon
end

"""
    GreedyVector(element)

Defines an unknown-sized vector, which will deserialize elements as much as possible.

# Arguments

- `element::Union{Type, Construct}`: the type/construct of elements.

"""
GreedyVector(type::Type) = GreedyVector(Construct(type))

function deserialize(array::GreedyVector{T, TSubCon}, s::IO; contextkw...) where {T, TSubCon}
    result = Vector{T}()
    max_iter = convert(UInt, get(contextkw, :max_iter, default_max_iter))
    fallback = 0
    i = zero(max_iter)
    try
        while !eof(s)
            fallback = position(s)
            push!(result, deserialize(array.subcon, s; contextkw...))
            i += 1
            if i > max_iter
                throw(ExceedMaxIterations("Exceed max iterations $max_iter", max_iter))
            end
        end
    catch e
        seek(s, fallback)
        if e isa ExceedMaxIterations
            rethrow()
        end
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

# only when the data can be discarded.
function serialize(array::GreedyVector{T, TSubCon}, s::IO, ::UndefProperty; contextkw...) where {T, TSubCon}
    serialize(array, s, Vector{T}(); contextkw...)
end

estimatesize(::GreedyVector; contextkw...) = UnboundedSize(0)
