
"""
    UnboundedUpper

Unsigned infinity.
"""
struct UnboundedUpper <: Unsigned end

const unboundedupper = UnboundedUpper()

Base.:+(::UnboundedUpper, ::UnboundedUpper) = unboundedupper
Base.:+(::Integer, ::UnboundedUpper) = unboundedupper
Base.:+(x::UnboundedUpper, y::Integer) = y + x
Base.:*(::UnboundedUpper, ::UnboundedUpper) = unboundedupper
Base.:*(x::Unsigned, ::UnboundedUpper) = x > 0 ? unboundedupper : 0
Base.:*(x::UnboundedUpper, y::Unsigned) = y * x
Base.max(::UnboundedUpper, ::UnboundedUpper) = unboundedupper
Base.max(::Integer, ::UnboundedUpper) = unboundedupper
Base.max(x::UnboundedUpper, y::Integer) = max(y, x)
Base.min(::UnboundedUpper, ::UnboundedUpper) = unboundedupper
Base.min(x::Integer, ::UnboundedUpper) = x
Base.min(x::UnboundedUpper, y::Integer) = min(y, x)
Base.show(io::IO, ::UnboundedUpper) = print(io, "+∞")

"""
    ConstructSize

Abstract super type of construct size.
"""
abstract type ConstructSize end

ConstructSize(sz::ConstructSize) = sz
ConstructSize(x::Integer) = ExactSize(x)
ConstructSize(lower::Integer, upper::Integer) = lower == upper ? ExactSize(lower) : RangedSize(lower, upper)
ConstructSize(lower::Integer, ::UnboundedUpper) = UnboundedSize(lower)

Base.promote_rule(::Type{<:ConstructSize}, ::Type{<:Integer}) = ConstructSize
Base.convert(::Type{ConstructSize}, x::Integer) = convert(ExactSize, x)

Base.:+(x::ConstructSize, y::ConstructSize) = ConstructSize(lower(x) + lower(y), upper(x) + upper(y))
Base.:*(x::ConstructSize, y::ConstructSize) = ConstructSize(lower(x) * lower(y), upper(x) * upper(y))
Base.union(x::ConstructSize, y::ConstructSize) = ConstructSize(min(lower(x), lower(y)), max(upper(x), upper(y)))
Base.:+(x::Union{ConstructSize, Integer}, y::Union{ConstructSize, Integer}) = +(promote(x, y)...)
Base.:*(x::Union{ConstructSize, Integer}, y::Union{ConstructSize, Integer}) = *(promote(x, y)...)
Base.union(x::Union{ConstructSize, Integer}, y::Union{ConstructSize, Integer}) = union(promote(x, y)...)
Base.union(x::Union{ConstructSize, Integer}, rest::Vararg{Union{ConstructSize, Integer}}) = reduce(union, rest; init=x)

Base.:(==)(::ConstructSize, ::Integer) = false
Base.:(==)(::Integer, ::ConstructSize) = false

"""
    ExactSize(value)

Exact construct size (upper bound and lower bound are same).
"""
struct ExactSize <: ConstructSize
    value::UInt64
end

ExactSize(x::Integer) = ExactSize(convert(UInt64, x))

Base.convert(::Type{T}, x::ExactSize) where {T<:Number} = convert(T, x.value)
Base.convert(::Type{ExactSize}, x::Integer) = ExactSize(x)

Base.:(==)(x::Integer, y::ExactSize) = x == y.value
Base.:(==)(x::ExactSize, y::Integer) = y == x

lower(sz::ExactSize) = sz.value
upper(sz::ExactSize) = sz.value

Base.in(v::Integer, sz::ConstructSize) = v == sz.value

"""
    RangedSize(lower, upper)

Ranged construct size.
"""
struct RangedSize <: ConstructSize
    lower::UInt64
    upper::UInt64

    function RangedSize(lower::UInt64, upper::UInt64)
        if upper <= lower
            throw(ArgumentError("lower bound $lower should be less than upper bound $upper."))
        end
        new(lower, upper)
    end
end

RangedSize(lower::Integer, upper::Integer) = RangedSize(convert(UInt64, lower), convert(UInt64, upper))

lower(sz::RangedSize) = sz.lower
upper(sz::RangedSize) = sz.upper

Base.in(v::Integer, sz::RangedSize) = lower(sz) <= v <= upper(sz)

"""
    UnboundedSize(lower)

Unbounded ranged size.
"""
struct UnboundedSize <: ConstructSize
    lower::UInt64
end

UnboundedSize(lower::Integer) = UnboundedSize(convert(UInt64, lower))

lower(sz::UnboundedSize) = sz.lower
upper(::UnboundedSize) = unboundedupper

Base.in(v::Integer, sz::UnboundedSize) = lower(sz) <= v
