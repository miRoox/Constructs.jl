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
