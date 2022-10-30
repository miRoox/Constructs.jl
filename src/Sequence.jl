
const sequence_subcons_threshold = 9

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

for n in 1:sequence_subcons_threshold
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
struct SequenceN{N, TT<:NTuple{N, Any}, TSubCons<:NTuple{N, Construct}} <: Sequence{TT}
    subcons::TSubCons
end

function SequenceN(subcons::Vararg{Union{Type, Construct}, N}) where {N}
    CTT = Tuple{map(constructtype, subcons)...}
    csubcons = tuple(map(Construct, subcons)...)
    SequenceN{N, CTT, typeof(csubcons)}(csubcons)
end

"""
    Sequence(elements...) -> Construct{Tuple{Ts...}}

Defines the sequence of construct data based on `elements`.

This is the default constructor for `Tuple{Ts...}`.

# Examples

```jldoctest
julia> serialize((true, 0x23))
2-element Vector{UInt8}:
 0x01
 0x23

julia> deserialize(Sequence(Bool, UInt8), b"\\xab\\xcd")
(true, 0xcd)
```

# Known problems

In Julia 1.6, if the number of `Sequence` elements is greater than $sequence_subcons_threshold, [`@construct`](@ref) cannot deduce the field type correctly.
"""
Sequence(ts::Vararg{Union{Type, Construct}}) = SequenceN(ts...)
Construct(t::Type{<:Tuple}) = SequenceN(fieldtypes(t)...)

Base.getindex(seq::SequenceN, i::Integer) = seq.subcons[i]

deserialize(seq::SequenceN, s::IO; contextkw...) = tuple(map(((i, sub),) -> deserialize(sub, s; with_property(contextkw, i)...), enumerate(seq.subcons))...)
function serialize(seq::SequenceN{N, TT, TSubCons}, s::IO, t::TT; contextkw...) where {N, TT, TSubCons}
    sum(((i, sub, v),) -> serialize(sub, s, v; with_property(contextkw, i)...), zip(1:length(t), seq.subcons, t); init=0)
end
estimatesize(seq::SequenceN; contextkw...) = sum(((i, sub),) -> estimatesize(sub; with_property(contextkw, i)...), enumerate(seq.subcons); init=ExactSize(0))
