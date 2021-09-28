# Nothing
deserialize(::Default{Nothing}, ::IO; contextkw...) = nothing
serialize(::Default{Nothing}, ::IO, ::Nothing; contextkw...) = 0
estimatesize(::Default{Nothing}; contextkw...) = 0

# Missing
deserialize(::Default{Missing}, ::IO; contextkw...) = missing
serialize(::Default{Missing}, ::IO, ::Missing; contextkw...) = 0
estimatesize(::Default{Missing}; contextkw...) = 0

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
