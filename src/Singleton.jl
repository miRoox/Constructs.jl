"""
    Singleton{T} <: Construct{T}

Singleton type empty construct.

This is the default constructor for `Nothing` and `Missing`.
"""
struct Singleton{T} <: Construct{T}
    function Singleton{T}() where {T}
        if !Base.issingletontype(T)
            throw(ArgumentError("$T is not a singleton type!"))
        end
        new()
    end
end

Singleton(::Type{T}) where {T} = Singleton{T}()
Singleton(::T) where {T} = Singleton{T}()

deserialize(::Singleton{T}, ::IO; contextkw...) where {T} = T.instance
serialize(::Singleton{T}, ::IO, ::T; contextkw...) where {T} = 0
estimatesize(::Singleton; contextkw...) = ExactSize(0)

Construct(::Type{Nothing}) = Singleton(nothing)
Construct(::Type{Missing}) = Singleton(missing)
