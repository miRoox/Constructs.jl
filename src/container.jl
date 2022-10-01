
"""
    Container{T}

Intermediate container for a `struct` object when serializing/deserializing it.
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

Base.getproperty(obj::Container, name::Symbol) = getfield(obj, 1)[name]
Base.setproperty!(::Container, name::Symbol, ::Any) = error("Container property $name cannot be set.")
Base.propertynames(obj::Container, private::Bool = false) = ((private ? fieldnames(Container) : ())..., keys(getfield(obj, 1))...)
setcontainerproperty!(obj::Container, name::Symbol, value::Any) = getfield(obj, 1)[name] = value

function Container(obj::T) where {T}
    res = Container{T}()
    for prop in propertynames(obj)
        setcontainerproperty!(res, prop, getproperty(obj, prop))
    end
    res
end
