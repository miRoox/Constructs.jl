
"""
    PropertyPath(segments)

Represents a property path.
"""
struct PropertyPath
    segments::Vector{Any} # could be property or index
end

PropertyPath() = PropertyPath([])

Base.:(==)(x::PropertyPath, y::PropertyPath) = x.segments == y.segments

function Base.show(io::IO, path::PropertyPath)
    print(io, "(this)")
    for seg in path.segments
        print(io, " -> ")
        show(io, seg)
    end
end
