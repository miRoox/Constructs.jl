# Nothing
deserialize(::Default{Nothing}, ::IO) = nothing
serialize(::Default{Nothing}, ::IO, ::Nothing) = 0
estimatesize(::Default{Nothing}) = 0

# Missing
deserialize(::Default{Missing}, ::IO) = missing
serialize(::Default{Missing}, ::IO, ::Missing) = 0
estimatesize(::Default{Missing}) = 0

# primitive numbers
for type in (Bool, UInt8, UInt16, UInt32, UInt64, UInt128, Int8, Int16, Int32, Int64, Int128, Float16, Float32, Float64)
    @eval begin
        Constructs.deserialize(::Default{$type}, s::IO) = Base.read(s, $type)
        Constructs.serialize(::Default{$type}, s::IO, value::$type) = Base.write(s, value)
        Constructs.estimatesize(::Default{$type}) = $(Base.sizeof(type))
    end
end

deserialize(::Default{Char}, s::IO) = read(s, Char)
serialize(::Default{Char}, s::IO, c::Char) = write(s ,c)
estimatesize(::Default{Char}) = Interval{UInt}(1, 4)

# enum
deserialize(::Default{E}, s::IO) where {T<:Integer, E<:Base.Enum{T}} = E(deserialize(T, s))
serialize(::Default{E}, s::IO, obj::E) where {T<:Integer, E<:Base.Enum{T}} = serialize(Integer(obj), s)
estimatesize(::Default{E}) where {T<:Integer, E<:Base.Enum{T}} = estimatesize(T)

"""
    JuliaSerializer <: Construct{Any}

Standard Julia serialization.
"""
struct JuliaSerializer <: Construct{Any} end

deserialize(::JuliaSerializer, s::IO) = Serialization.deserialize(s)
serialize(::JuliaSerializer, s::IO, obj) = Serialization.serialize(s, obj)

"""
    Padding <: Construct{Nothing}

Represents padding data.
"""
struct Padding <: Construct{Nothing}
    size::UInt

    Padding(size::Integer = 0) = new(convert(UInt, size))
end

function deserialize(cons::Padding, s::IO)
    skip(s, cons.size)
    nothing
end
serialize(cons::Padding, s::IO, ::Nothing) = write(s, zeros(UInt8, cons.size))
estimatesize(cons::Padding) = cons.size
