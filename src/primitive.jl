"""
    Singleton{T} <: Construct{T}

Singleton type empty construct.
"""
struct Singleton{T} <: Construct{T}
    function Singleton{T}() where {T}
        if !Base.issingletontype(T)
            throw(ArgumentError("$T is not a singleton type!"))
        end
        new()
    end
end
Singleton(::Type{T}) where {T} = Singleton{T}()
Singleton(::T) where {T} = Singleton{T}()

deserialize(::Singleton{T}, ::IO; contextkw...) where {T} = T.instance
serialize(::Singleton{T}, ::IO, ::T; contextkw...) where {T} = 0
estimatesize(::Singleton; contextkw...) = 0

Construct(::Type{Nothing}) = Singleton(nothing)
Construct(::Type{Missing}) = Singleton(missing)

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
estimatesize(::PrimitiveIO{T}; contextkw...) where {T} = sizeof(T)
estimatesize(::PrimitiveIO{Char}; contextkw...) = Interval{UInt}(1, 4)

"""
    JuliaSerializer <: Construct{Any}

Standard Julia serialization.
"""
struct JuliaSerializer <: Construct{Any} end

deserialize(::JuliaSerializer, s::IO; contextkw...) = Serialization.deserialize(s)
serialize(::JuliaSerializer, s::IO, obj; contextkw...) = Serialization.serialize(s, obj)

"""
    Padding <: Construct{Nothing}

Represents padding data.
"""
struct Padding <: Construct{Nothing}
    size::UInt

    Padding(size::Integer = 0) = new(convert(UInt, size))
end

function deserialize(cons::Padding, s::IO; contextkw...)
    skip(s, cons.size)
    nothing
end
serialize(cons::Padding, s::IO, ::Nothing; contextkw...) = write(s, zeros(UInt8, cons.size))
estimatesize(cons::Padding; contextkw...) = cons.size
