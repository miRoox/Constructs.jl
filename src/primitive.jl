# Nothing
deserialize(::Type{Nothing}, ::IO) = nothing
serialize(::Nothing, ::IO) = nothing
estimatesize(::Type{Nothing}) = 0

# Missing
deserialize(::Type{Missing}, ::IO) = missing
serialize(::Missing, ::IO) = nothing
estimatesize(::Type{Missing}) = 0

# primitive numbers
for type in (Bool, UInt8, UInt16, UInt32, UInt64, UInt128, Int8, Int16, Int32, Int64, Int128, Float16, Float32, Float64)
    @eval begin
        Construct.deserialize(::Type{$type}, s::IO) = Base.read(s, $type)
        Construct.serialize(value::$type, s::IO) = Base.write(s, value)
        Construct.estimatesize(::Type{$type}) = $(Base.sizeof(type))
    end
end

deserialize(::Type{Char}, s::IO) = read(s, Char)
serialize(c::Char, s::IO) = write(s ,c)
estimatesize(::Type{Char}) = Interval{UInt}(1, 4)

# enum
deserialize(::Type{E}, s::IO) where {T<:Integer, E<:Base.Enum{T}} = E(deserialize(T, s))
serialize(obj::Base.Enum{<:Integer}, s::IO) = serialize(Integer(obj), s)
estimatesize(::Type{E}) where {T<:Integer, E<:Base.Enum{T}} = estimatesize(T)
