
const pathkw = gensym("path")

"""
    PropertyPath(segments)

Represents a property path.
"""
struct PropertyPath
    segments::Vector{Any} # could be property or index
end

PropertyPath() = PropertyPath([])
PropertyPath(path::PropertyPath, append) = PropertyPath([path.segments..., append])

Base.:(==)(x::PropertyPath, y::PropertyPath) = x.segments == y.segments

function Base.show(io::IO, path::PropertyPath)
    print(io, "(this)")
    for seg in path.segments
        print(io, " -> ")
        show(io, seg)
    end
end

with_property(contextkw, property) = (; contextkw..., pathkw => PropertyPath(get(PropertyPath, contextkw, pathkw), property))
