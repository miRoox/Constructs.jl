struct JuliaSerializer{T} <: Construct{T} end

"""
    JuliaSerializer([T = Any]) -> Construct{T}

Create the standard Julia serializer.

See also: [`Serialization`](https://docs.julialang.org/en/v1.6/stdlib/Serialization/)
"""
JuliaSerializer(::Type{T} = Any) where {T} = JuliaSerializer{T}()

deserialize(::JuliaSerializer{T}, s::IO; contextkw...) where {T} = Serialization.deserialize(s)::T
serialize(::JuliaSerializer{T}, s::IO, obj::T; contextkw...) where {T} = Serialization.serialize(s, obj)
