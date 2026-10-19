```@meta
CurrentModule = Constructs
DocTestSetup = :(using Constructs)
```

# Sequences

[`Sequence`](@ref) combines layouts in order and returns a tuple. It accepts
types and constructs, so each position can have a different representation.

```jldoctest sequences
julia> layout = Sequence(UInt8, UInt16be, Padded(Int8, 2));

julia> deserialize(layout, b"\x07\x01\x02\xff\xaa")
(0x07, 0x0102, -1)

julia> serialize(layout, (0x07, 0x0102, Int8(-1))) == b"\x07\x01\x02\xff\x00"
true

julia> estimatesize(layout) == ExactSize(5)
true

julia> layout[2] == UInt16be
true
```

Serialization follows tuple order; deserialization consumes each member before
starting the next. There is no implicit alignment, delimiter, or length prefix.
Use [`Padded`](@ref) for reserved bytes or an explicitly padded field.

## Default tuple layouts

`Construct(Tuple{T1, T2, ...})` selects a sequence of the default constructs for
the member types. Thus serializing a tuple directly uses its members' default
layouts, including native byte order for multibyte numbers.

```jldoctest
julia> deserialize(Tuple{UInt8, Int8}, b"\x01\xff")
(0x01, -1)

julia> serialize((0x01, Int8(-1))) == b"\x01\xff"
true

julia> deserialize(Sequence(), UInt8[])
()

julia> serialize(())
UInt8[]
```

An empty sequence consumes zero bytes. A one-member sequence still returns a
one-element tuple, rather than the member itself.

## Choosing a composition

Use a sequence for a fixed collection of positions with potentially different
types. Use [repeaters](repeaters.md) for an array of one element layout,
and [`@construct`](@ref) for a record with named or dependent fields. A sequence
does not provide `this` references between positions.

Size estimates add the member estimates. A default tuple value is available
through `Constructs.default(sequence)` only when all member constructs provide
defaults. Failures while reading or writing a member propagate to the caller;
a sequence does not rewind earlier members.
