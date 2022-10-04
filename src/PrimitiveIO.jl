"""
    PrimitiveIO{T} <: Construct{T}

Construct based on primitive read/write.
"""
struct PrimitiveIO{T} <: Construct{T} end

# primitive numbers
for type in (Bool, Char, UInt8, UInt16, UInt32, UInt64, UInt128, Int8, Int16, Int32, Int64, Int128, Float16, Float32, Float64)
    @eval Construct(::Type{$type}) = PrimitiveIO{$type}()
end

deserialize(::PrimitiveIO{T}, s::IO; contextkw...) where {T} = read(s, T)
serialize(::PrimitiveIO{T}, s::IO, c::T; contextkw...) where {T} = write(s ,c)
estimatesize(::PrimitiveIO{T}; contextkw...) where {T} = ExactSize(sizeof(T))
estimatesize(::PrimitiveIO{Char}; contextkw...) = RangedSize(1, 4)
