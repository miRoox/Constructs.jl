
"""
    UndefProperty

Placeholder for undefined properties in [`Container`](@ref).
"""
struct UndefProperty end

Base.show(io::IO, ::UndefProperty) = print(io, "#undef")

"""
    Container{T}

Intermediate container for a `struct` object when serializing/deserializing it.

    Container{T}()

Create an uninitialized container for `T`.

# Examples

```jldoctest
julia> Container{Complex{Int64}}()
Container{Complex{Int64}}:
  re: #undef
  im: #undef
```
"""
struct Container{T}
    _props::Dict{Symbol, Any}

    function Container{T}() where {T}
        if !isstructtype(T)
            throw(ArgumentError("$T is not a struct type."))
        end
        new{T}(Dict{Symbol, Any}())
    end
end

Base.getproperty(obj::Container{T}, name::Symbol) where {T} = get(getfield(obj, 1), name) do
    if name in fieldnames(T)
        UndefProperty()
    else
        error("type $T has no field $name")
    end
end
Base.setproperty!(::Container, name::Symbol, ::Any) = error("Container property $name cannot be set.")
function Base.propertynames(obj::Container{T}, private::Bool = false) where {T}
    tuple(union(private ? fieldnames(Container) : (), fieldnames(T), keys(getfield(obj, 1)))...)
end
setcontainerproperty!(obj::Container, name::Symbol, value::Any) = getfield(obj, 1)[name] = value

function Base.show(io::IO, obj::Container)
    show(io, typeof(obj))
    print(io, "(")
    for (i, prop) in enumerate(propertynames(obj))
        val = getproperty(obj, prop)
        if i > 1
            print(io, ", ")
        end
        print(io, prop)
        print(io, "=")
        show(io, val)
    end
    print(io, ")")
end

function Base.show(io::IO, mime::MIME"text/plain", obj::Container)
    show(io, typeof(obj))
    print(io, ":\n")
    for prop in propertynames(obj)
        val = getproperty(obj, prop)
        print(io, "  ")
        print(io, prop)
        print(io, ": ")
        if val isa UndefProperty
            show(io, val)
        else
            show(io, typeof(val))
            print(io, " = ")
            show(io, mime, val)
        end
        print(io, "\n")
    end
end

"""
    Container(object)

Create a container from `object`.

# Examples

```jldoctest
julia> Container(3+4im)
Container{Complex{Int64}}:
  re: Int64 = 3
  im: Int64 = 4
```
"""
function Container(obj::T) where {T}
    res = Container{T}()
    for prop in propertynames(obj)
        setcontainerproperty!(res, prop, getproperty(obj, prop))
    end
    res
end
