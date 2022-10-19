"""
    JuliaSerializer{T} <: Construct{T}

Standard Julia serialization.

See also: [`Serialization`](https://docs.julialang.org/en/v1.6/stdlib/Serialization/)
"""
struct JuliaSerializer{T} <: Construct{T} end

"""
    JuliaSerializer([type])

Create the standard Julia serializer.
"""
JuliaSerializer(::Type{T} = Any) where {T} = JuliaSerializer{T}()

deserialize(::JuliaSerializer{T}, s::IO; contextkw...) where {T} = Serialization.deserialize(s)::T
serialize(::JuliaSerializer{T}, s::IO, obj::T; contextkw...) where {T} = Serialization.serialize(s, obj)
