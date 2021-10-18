"""
    IntEnum{T, TSubCon<:Construct{T}, E<:Base.Enum} <: Adapter{T, E}

Integer-based enum adapter for serializing and deserializing.
"""
struct IntEnum{T<:Integer, TSubCon<:Construct{T}, E<:Base.Enum} <: Adapter{T, E}
    subcon::TSubCon
end

IntEnum(subcon::Construct{T}, ::Type{E}) where {T<:Integer, E<:Base.Enum} = IntEnum{T, typeof(subcon), E}(subcon)
IntEnum(::Type{T}, ::Type{E}) where {T<:Integer, E<:Base.Enum} = IntEnum(Construct(T), E)
IntEnum(::Type{E}) where {T<:Integer, E<:Base.Enum{T}} = IntEnum(Construct(T), E)

subcon(wrapper::IntEnum) = wrapper.subcon
encode(::IntEnum{T, TSubCon, E}, obj::E; contextkw...) where {T, TSubCon, E} = convert(T, Integer(obj))
decode(::IntEnum{T, TSubCon, E}, obj::T; contextkw...) where {T, TSubCon, EB, E<:Base.Enum{EB}} = E(convert(EB, obj))

Construct(enum::Type{<:Base.Enum}) = IntEnum(enum)
