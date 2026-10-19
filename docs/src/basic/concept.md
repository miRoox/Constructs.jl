```@meta
CurrentModule = Constructs
DocTestSetup = :(using Constructs)
```

# Concepts

## Constructs and Julia types

A [`Construct{T}`](@ref Construct) describes how to read and write a Julia value of
type `T`. A construct is a layout object, whereas `T` is the value type. For
example, [`UInt16le`](@ref) and [`UInt16be`](@ref) both produce `UInt16` values,
but use different byte orders.

[`Construct(T)`](@ref Construct) selects the default layout for a type.
`Construct(cons)` returns an existing construct unchanged. Most combinators accept
either a type or a construct, so `Sequence(UInt8, UInt16le)` combines a default
one-byte layout with an explicit little-endian layout.

```jldoctest
julia> Construct(UInt8) isa Construct{UInt8}
true

julia> Construct(UInt16le) === UInt16le
true

julia> deserialize(UInt16le, b"\x34\x12")
0x1234

julia> serialize(UInt16be, 0x1234) == b"\x12\x34"
true
```

Defaults exist for primitive values, strings, enums, tuples, `Nothing`, `Missing`,
and types declared with [`@construct`](@ref). An arbitrary Julia `struct` does
not automatically have a binary layout; define one with the macro or implement
`Construct(::Type{YourType})` as described in [Extending Constructs](@ref).

## Reading and writing

[`deserialize`](@ref) accepts an `IO` stream, a byte vector, or a filename.
[`serialize`](@ref) writes to an `IO` stream or a filename; without a destination,
it returns a `Vector{UInt8}`. Omitting the construct when serializing selects the
default construct for the object's type.

```jldoctest
julia> serialize(0x07) == b"\x07"
true

julia> io = IOBuffer(b"\x01\x02\x03");

julia> deserialize(UInt16be, io)
0x0102

julia> position(io)
2

julia> deserialize(UInt8, io)
0x03
```

Reading one value does not require the stream to be exhausted. When a protocol
requires an exact payload length, check `eof(io)` or `position(io)` yourself.
The filename forms are `deserialize(cons, filename)` and
`serialize(cons, filename, value)`; the latter opens the file for writing.

Values supplied to serialization are converted to the construct's value type
when necessary. Conversion can fail, for example when an integer does not fit
in the selected field width.

## Composition and context

Constructs compose into larger layouts: [`Sequence`](@ref) produces tuples,
[`SizedArray`](@ref) and [`PrefixedArray`](@ref) produce arrays, and
[`@construct`](@ref) produces named records. A [`Wrapper`](@ref) contains a
sub-construct accessible through [`subcon`](@ref). [`Adapter`](@ref) transforms
values and [`Validator`](@ref) checks them.

Keyword arguments on `serialize`, `deserialize`, and [`estimatesize`](@ref) are
passed down as context. Function-based adapters and validators can read them:

```jldoctest
julia> bounded = Validator(UInt8, (x; limit=10, kw...) -> x <= limit);

julia> deserialize(bounded, b"\x08"; limit=9)
0x08
```

Accept `kw...` in callbacks that use context so they also accept keywords passed
by enclosing constructs. Within a macro definition, [`this`](@ref) is a separate
mechanism for accessing fields of the current record; see
[The `@construct` Macro](@ref).

## Size estimates and defaults

`estimatesize` describes possible byte lengths for a layout, without reading a
stream or serializing a particular value:

| Result | Meaning |
|:-------|:--------|
| [`ExactSize(n)`](@ref ExactSize) | Exactly `n` bytes |
| [`RangedSize(lo, hi)`](@ref RangedSize) | Between `lo` and `hi` bytes, inclusive |
| [`UnboundedSize(lo)`](@ref UnboundedSize) | At least `lo` bytes, with no finite upper estimate |

```jldoctest
julia> estimatesize(Sequence(UInt8, UInt16le)) == ExactSize(3)
true

julia> 0 in estimatesize(Optional(UInt16le))
true

julia> estimatesize(PrefixedArray(UInt8, UInt16le)) == UnboundedSize(1)
true
```

Estimates are conservative: they can be unbounded even when a length prefix has
a finite integer range. The fallback for an unknown layout is `UnboundedSize(0)`.
Add or multiply estimates to combine layouts, and use `union` to combine
alternatives. `Constructs.lower(size)` and `Constructs.upper(size)` inspect the
bounds; [`UnboundedUpper`](@ref) represents an infinite upper bound.

[`Constructs.default`](@ref) supplies values for anonymous and hidden fields during
serialization. For example, `Const` supplies its constant, `Optional` supplies
its fallback, and numbers default to zero. Not every construct has a default;
this matters when omitting fields with `@construct`.
