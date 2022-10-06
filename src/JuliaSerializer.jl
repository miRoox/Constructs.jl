"""
    JuliaSerializer <: Construct{Any}

Standard Julia serialization.

See also: [`Serialization`](https://docs.julialang.org/en/v1.6/stdlib/Serialization/)
"""
struct JuliaSerializer <: Construct{Any} end

deserialize(::JuliaSerializer, s::IO; contextkw...) = Serialization.deserialize(s)
serialize(::JuliaSerializer, s::IO, obj; contextkw...) = Serialization.serialize(s, obj)
