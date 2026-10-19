```@meta
CurrentModule = Constructs
DocTestSetup = :(using Constructs)
```

# Other Constructs

## Const

[`Const`](@ref) validates a fixed value on both reading and writing. It is useful
for magic bytes, version markers, and fields that must have one particular value.
Pass a construct explicitly to control its representation.

```jldoctest
julia> deserialize(Const(b"BMP"), b"BMP") == b"BMP"
true

julia> serialize(Const(UInt16be, 7), 7) == b"\x00\x07"
true

julia> try
           deserialize(Const(b"BMP"), b"PNG")
       catch err
           err isa ValidationError
       end
true
```

`Const(array)` uses a fixed-size array layout. `Const(string)` uses a
`PaddedString` with the string's byte length, so it does not add the null
terminator used by the default `String` construct. A mismatch raises
[`ValidationError`](@ref). `Constructs.default(cons)` returns the constant.

!!! tip "omit the property name"
    In [`@construct`](@ref), omit the property name when the constant should
    appear in the binary layout without being stored in the Julia object:

    ```jldoctest
    julia> @construct struct HeadedInt16
               ::Const(0x07)
               value::Int16le
           end

    julia> serialize(HeadedInt16(Int16(2))) == b"\x07\x02\x00"
    true
    ```

## Padded

[`Padded(element, n)`](@ref Constructs.Padded) reserves a total of `n` bytes for a field.
Deserialization reads the value and skips the remaining bytes without checking
their contents. Serialization writes the value followed by zero bytes.

```jldoctest
julia> deserialize(Padded(UInt16be, 4), b"\x01\x02\xaa\xff")
0x0102

julia> serialize(Padded(UInt16be, 4), 0x0102) == b"\x01\x02\x00\x00"
true

julia> deserialize(Padded(2), b"\xaa\xff") === nothing
true

julia> serialize(Padded(2), nothing) == b"\x00\x00"
true
```

`Padded(n)` is shorthand for `Padded(Nothing, n)` and represents reserved bytes.
If the sub-construct consumes more than `n` bytes, [`PaddedError`](@ref) is raised
after that operation. The wrapper does not bound the sub-construct's IO or undo
bytes already consumed or written. Skipping is delegated to the stream and does
not independently validate that all padding bytes exist. The size estimate is
`ExactSize(n)`; its default delegates to the sub-construct.

## Overwrite

[`Overwrite`](@ref) changes a value only when serializing. It accepts either a
replacement value or a function of the supplied value. Reading simply returns
the value from the sub-construct without checking the replacement.

```jldoctest
julia> serialize(Overwrite(UInt8, 0x07), 0x02) == b"\x07"
true

julia> serialize(Overwrite(Int8, abs), Int8(-2)) == b"\x02"
true

julia> deserialize(Overwrite(UInt8, 0x07), b"\x02")
0x02
```

Use `Const` to require a particular value in both directions. Use `Overwrite`
for derived fields such as a length computed from the payload. In a hidden
macro field, its getter receives `UndefProperty{T}()` during default lookup, so
ignore that argument when computing a value from `this`; see
[Hidden fields and derived lengths](@ref).

## Strings

String constructs return `String` by default and accept a leading string type
to select another supported `AbstractString` representation. An optional encoding
name uses StringEncodings; without it, the string type's raw IO representation
is used (`String` uses UTF-8).

| Construct | Wire representation |
|:----------|:--------------------|
| [`NullTerminatedString()`](@ref NullTerminatedString) | Text followed by a null character; default for `String` |
| [`PaddedString(n)`](@ref PaddedString) | Text in a fixed `n`-byte field, padded with zero bytes |
| [`PrefixedString(size)`](@ref PrefixedString) | Encoded byte length followed by the text |

```jldoctest
julia> serialize(String, "hi") == b"hi\0"
true

julia> deserialize(NullTerminatedString(), b"hi\0rest")
"hi"

julia> serialize(PaddedString(4), "hi") == b"hi\0\0"
true

julia> deserialize(PaddedString(4), b"hi\0\0")
"hi"

julia> serialize(PrefixedString(UInt16le), "é") == b"\x02\x00\xc3\xa9"
true

julia> serialize(PrefixedString(UInt8, "UTF-16LE"), "A") == b"\x02A\0"
true
```

Lengths count encoded **bytes**, not Julia characters. `PaddedString` raises
`PaddedError` when writing text that exceeds its field size, and strips trailing
nulls when reading. `PrefixedString` preserves embedded nulls and computes the
prefix on writing; the byte count must fit the prefix type. Their size estimates
are `ExactSize(n)` and the prefix estimate plus `UnboundedSize(0)`, respectively.
`NullTerminatedString` has the fallback estimate `UnboundedSize(0)`.

`NullTerminatedString` cannot preserve embedded null characters on a round trip.
Its reader uses `readuntil`, which can return text at EOF without a terminator.
Likewise, the other string readers use `read(io, n)` without a separate check for
a short payload. If strict framing is required, check the consumed byte count.
The current padded-string trimming implementation assumes a single-byte null
after decoding and does not handle an entirely zero-filled field; prefer a
length-prefixed representation when empty strings must be supported.

## Zero-byte values and Julia serialization

[`Singleton`](@ref) represents a singleton Julia value without consuming bytes.
It is the default for `Nothing` and `Missing` and can be constructed from a
singleton type or its instance.

```jldoctest
julia> deserialize(Nothing, UInt8[]) === nothing
true

julia> serialize(missing)
UInt8[]

julia> estimatesize(Singleton(nothing)) == ExactSize(0)
true
```

[`JuliaSerializer(T)`](@ref JuliaSerializer) delegates to Julia's `Serialization`
stdlib, with `Any` as the default output type. Reading asserts that the decoded
value has type `T`. This is useful for Julia object persistence; for a specified
binary protocol, describe the individual fields instead.

```jldoctest
julia> layout = JuliaSerializer(Vector{Int});

julia> deserialize(layout, serialize(layout, [1, 2, 3])) == [1, 2, 3]
true
```

Its stream serializer returns the result of `Serialization.serialize`, rather
than a byte count. Consequently, use it on its own instead of inside combinators
such as `Sequence` that sum the counts returned by their members.

[`RaiseError`](@ref) represents a failing branch. Deserializing it, or requesting
its default, throws the configured exception. For example,
`Try(Const(0x01), RaiseError("unsupported marker"))` accepts the marker and raises
the specified error if it does not match.
