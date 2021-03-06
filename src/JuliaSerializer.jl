"""
    JuliaSerializer <: Construct{Any}

Standard Julia serialization.
"""
struct JuliaSerializer <: Construct{Any} end

deserialize(::JuliaSerializer, s::IO; contextkw...) = Serialization.deserialize(s)
serialize(::JuliaSerializer, s::IO, obj; contextkw...) = Serialization.serialize(s, obj)
