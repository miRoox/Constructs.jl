
# deduceArrayType(::Type{TA}, ::Type{T}, N::Integer) where {T, TA<:AbstractArray} = deducetype(Base.similar, TA, Type{T}, Dims{N})

struct SizedArray{T, N, TA<:AbstractArray{T,N}, TSubCon<:Construct{T}} <: Wrapper{T, TA}
    subcon::TSubCon
    size::NTuple{N, UInt}

    function SizedArray{T, N, TA, TSubCon}(subcon::TSubCon, size::NTuple{N, UInt}) where {T, N, TA<:AbstractArray{T,N}, TSubCon<:Construct{T}}
        # CTA = deduceArrayType(TA, T, N)
        # CTA::Type{<:TA}
        new{T, N, TA, TSubCon}(subcon, size)
    end
end

# pass deduced array type is not friendly to type deduction
# function createSizedArray(TA::UnionAll, subcon::TSubCon, size::Vararg{Integer, N}) where {T, N, TSubCon<:Construct{T}}
#     CTA = deduceArrayType(TA::Type{<:AbstractArray}, T, N)
#     SizedArray(CTA::Type{<:TA}, subcon, convert(NTuple{N, UInt}, size))
# end
"""
    SizedArray([TA], T|element, size...) -> Construct{TA}

Defines an array with specific size and element.

# Arguments

- `TA<:AbstractArray{T}`: the target array type, the default is `Array{T, N}`.
- `T`: the type of elements.
- `element::Construct{T}`: the construct of elements.
- `size`: the size of the array.
"""
function SizedArray(::Type{TA}, subcon::TSubCon, size::NTuple{N, Integer}) where {T, N, TA<:AbstractArray, TSubCon<:Construct{T}}
    SizedArray{T, N, TA, TSubCon}(subcon, convert(NTuple{N, UInt}, size))
end
SizedArray(::Type{TA}, subcon::TSubCon, size::Vararg{Integer, N}) where {T, N, TA<:AbstractArray, TSubCon<:Construct{T}} = SizedArray(TA, subcon, tuple(size...))
SizedArray(::Type{TA}, ::Type{T}, size::Vararg{Integer, N}) where {T, N, TA<:AbstractArray} = SizedArray(TA, Construct(T), size...)
SizedArray(::Type{TA}, ::Type{T}, size::NTuple{N, Integer}) where {T, N, TA<:AbstractArray} = SizedArray(TA, Construct(T), size)

SizedArray(subcon::Union{Construct{T}, Type{T}}, size::Vararg{Integer, N}) where {T, N} = SizedArray(Array{T, N}, Construct(subcon), size...)
SizedArray(subcon::Union{Construct{T}, Type{T}}, size::NTuple{N, Integer}) where {T, N} = SizedArray(Array{T, N}, Construct(subcon), size)

function deserialize(array::SizedArray{T, N, TA, TSubCon}, s::IO; contextkw...) where {T, N, TA, TSubCon}
    result = similar(TA, array.size)
    for i in eachindex(result)
        result[i] = deserialize(array.subcon, s; with_property(contextkw, i)...)
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
        bytecount += serialize(array.subcon, s, obj[i]; with_property(contextkw, i)...)
    end
    bytecount
end
estimatesize(array::SizedArray; contextkw...) = prod(array.size) * estimatesize(array.subcon; contextkw...)

"""
    PrefixedArray([TA], S|size, T|element) -> Construct{TA}

Defines an array with its size in the header.

# Arguments

- `TA<:AbstractArray{T, N}`: the target array type, the default is `Array{T, N}`.
- `S<:Union{Integer, NTuple{N, Integer}}`: the type of the size in the header.
- `T`: the type of elements.
- `size::Construct{S}`: the construct of size.
- `element::Construct{T}`: the construct of elements.
"""
PrefixedArray(size::Union{Type, Construct}, el::Union{Type, Construct}) = PrefixedArray(Construct(size), Construct(el))
PrefixedArray(::Type{TA}, size::Union{Type, Construct}, el::Union{Type, Construct}) where {TA} = PrefixedArray(TA, Construct(size), Construct(el))

PrefixedArray(sizecon::Construct{S}, subcon::Construct{T}) where {S<:Integer, T} = PrefixedArray(Vector{T}, sizecon, subcon)
PrefixedArray(sizecon::Construct{S}, subcon::Construct{T}) where {N, S<:NTuple{N, Integer}, T} = PrefixedArray(Array{T, N}, sizecon, subcon)

function PrefixedArray(::Type{TA}, sizecon::Construct{S}, subcon::Construct{T}) where {S<:Integer, T, TA<:AbstractVector{T}}
    Prefixed{S, TA, typeof(sizecon), SizedArray{T, 1, TA, typeof(subcon)}}(
        sizecon,
        length,
        (n::S) -> SizedArray(TA, subcon, n)
    )
end

function PrefixedArray(::Type{TA}, sizecon::Construct{S}, subcon::Construct{T}) where {N, S<:NTuple{N, Integer}, T, TA<:AbstractArray{T, N}}
    Prefixed{S, TA, typeof(sizecon), SizedArray{T, N, TA, typeof(subcon)}}(
        sizecon,
        size,
        (n::S) -> SizedArray(TA, subcon, n)
    )
end

struct GreedyVector{T, TSubCon<:Construct{T}} <: Wrapper{T, Vector{T}}
    subcon::TSubCon
end

"""
    GreedyVector(T|element) -> Construct{Vector{T}}

Defines an unknown-sized vector, which will deserialize elements as much as possible.

# Arguments

- `T`: the type of elements.
- `element::Construct{T}`: the construct of elements.
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
            push!(result, deserialize(array.subcon, s; with_property(contextkw, i)...))
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
    for i in eachindex(obj)
        bytecount += serialize(array.subcon, s, obj[i]; with_property(contextkw, i)...)
    end
    bytecount
end

# only when the data can be discarded.
function serialize(array::GreedyVector{T, TSubCon}, s::IO, ::UndefProperty; contextkw...) where {T, TSubCon}
    serialize(array, s, Vector{T}(); contextkw...)
end
