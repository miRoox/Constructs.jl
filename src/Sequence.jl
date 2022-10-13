
const sequence_max_subcons = 64

"""
    Sequence{Tuple{Ts...}} <: Construct{Tuple{Ts...}}

A sequence of construct data.

This is the default constructor for `Tuple{Ts...}`.
"""
abstract type Sequence{TT<:Tuple} <: Construct{TT} end

Base.getindex(seq::Sequence, i::Integer) = getfield(seq, convert(Int, i))
Base.getindex(seq::Sequence{Tuple{T1}}) where {T1} = getfield(seq, 1)

struct Sequence_0 <: Sequence{Tuple{}} end

Sequence() = Sequence_0()
Construct(::Type{Tuple{}}) = Sequence_0()

deserialize(::Sequence_0, ::IO; contextkw...) = ()
serialize(::Sequence_0, ::IO, ::Tuple{}; contextkw...) = 0
estimatesize(::Sequence_0; contextkw...) = ExactSize(0)

## sample:
# struct Sequence_1{T1, TSubCon1<:Construct{T1}} <: Sequence{Tuple{T1}}
#     subcon1::TSubCon1
# end
#
# Sequence_1(::Type{T1}) where {T1} = Sequence_1(Construct(T1))
# Sequence(ct::Union{Type, Construct}) = Sequence_1(ct)
# Construct(::Type{Tuple{T1}}) where {T1} = Sequence_1(T1)
#
# function deserialize(seq::Sequence_1, s::IO; contextkw...)
#     (deserialize(seq.subcon1, s; contextkw...),)
# end
# function serialize(seq::Sequence_1{T1}, s::IO, val::Tuple{T1}; contextkw...) where {T1}
#     serialize(seq.subcon1, s, val[1]; contextkw...)
# end
# estimatesize(seq::Sequence_1; contextkw...) = estimatesize(seq.subcon1; contextkw...)

for n in 1:sequence_max_subcons
    ## temporary expressions/symbols should be excluded from the code coverage.
    # COV_EXCL_START
    seqname = Symbol("Sequence_$n")
    ts = map(i -> gensym("T$i"), 1:n)
    tsubs = map(i -> gensym("TSubCon$i"), 1:n)
    ttsubs = map((t, tsub)-> Expr(:(<:), tsub, Expr(:curly, Construct, t)), ts, tsubs) # TSubCon$i <: Construct{T$i}
    subs = map(i -> Symbol("subcon$i"), 1:n)
    subts = map((sub, tsub) -> Expr(:(::), sub, tsub), subs, tsubs) # subcon$i::TSubCon$i
    cts = map(i -> Symbol("t$i"), 1:n)
    pcts = map(ct -> Expr(:(::), ct, :(Union{Type, Construct})), cts) # t$i::Union{Type, Construct}
    ccts = map(ct -> Expr(:call, :Construct, ct), cts) # Construct(t$i)
    desers = map((sub, i) -> :(deserialize(seq.$sub, s; with_property(contextkw, $i)...)), subs, 1:n)
    sers = map((sub, i) -> :(serialize(seq.$sub, s, val[$i]; with_property(contextkw, $i)...)), subs, 1:n)
    szs = map((sub, i) -> :(estimatesize(seq.$sub; with_property(contextkw, $i)...)), subs, 1:n)
    # COV_EXCL_STOP

    @eval begin
        struct $seqname{$(ts...), $(ttsubs...)} <: Sequence{Tuple{$(ts...)}}
            $(subts...)
        end

        $seqname($(pcts...)) = $seqname($(ccts...))
        Sequence($(pcts...)) = $seqname($(cts...))
        Construct(::Type{Tuple{$(ts...)}}) where {$(ts...)} = $seqname($(ts...))

        function deserialize(seq::$seqname, s::IO; contextkw...)
            tuple($(desers...))
        end
        function serialize(seq::$seqname{$(ts...)}, s::IO, val::Tuple{$(ts...)}; contextkw...) where {$(ts...)}
            +($(sers...))
        end
        estimatesize(seq::$seqname; contextkw...) = +($(szs...))
    end
end

## Following implementation is simple but not friendly for type deducing
# struct Sequence{N, TT<:NTuple{N, Any}, TSubCons<:NTuple{N, Construct}} <: Construct{TT}
#     subcons::TSubCons
#
#     function Sequence{N, TT, TSubCons}(subcons::TSubCons) where {N, TT<:NTuple{N, Any}, TSubCons<:Tuple{N, Construct}}
#         CTT = Tuple{map(constructtype, subcons)...}
#         CTT::Type{TT}
#         new{N, TT, TSubCons}(subcons)
#     end
# end
#
# function Sequence(subcons::Vararg{Union{Type, Construct}, N}) where {N}
#     CTT = Tuple{map(constructtype, subcons)...}
#     csubcons = (map(Construct, subcons)...)
#     Sequence{N, CTT, typeof(csubcons)}(csubcons)
# end
