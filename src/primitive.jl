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

# primitive numbers
for type in (Bool, UInt8, UInt16, UInt32, UInt64, UInt128, Int8, Int16, Int32, Int64, Int128, Float16, Float32, Float64)
    @eval begin
        Constructs.deserialize(::Default{$type}, s::IO; contextkw...) = Base.read(s, $type)
        Constructs.serialize(::Default{$type}, s::IO, value::$type; contextkw...) = Base.write(s, value)
        Constructs.estimatesize(::Default{$type}; contextkw...) = $(Base.sizeof(type))
    end
end

deserialize(::Default{Char}, s::IO; contextkw...) = read(s, Char)
serialize(::Default{Char}, s::IO, c::Char; contextkw...) = write(s ,c)
estimatesize(::Default{Char}; contextkw...) = Interval{UInt}(1, 4)

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
