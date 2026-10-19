```@meta
CurrentModule = Constructs
DocTestSetup = :(using Constructs)
```

# Repeaters

Repeaters apply one element layout to an array. Select the construct according
to how the binary format determines the number of elements:

| Construct | Shape source | Result by default |
|:----------|:-------------|:------------------|
| [`SizedArray`](@ref) | Dimensions in the layout | `Array{T,N}` |
| [`PrefixedArray`](@ref) | Dimensions read from a prefix | `Vector{T}` or `Array{T,N}` |
| [`GreedyVector`](@ref) | Read until EOF or an element fails | `Vector{T}` |

## SizedArray

`SizedArray(element, dims...)` uses a fixed shape, without storing dimensions
in the stream. A tuple of dimensions is also accepted. Serialization checks the
entire shape, not just the total number of elements, and raises
`DimensionMismatch` on a mismatch.

```jldoctest
julia> layout = SizedArray(UInt8, 2, 3);

julia> deserialize(layout, b"\x01\x02\x03\x04\x05\x06") == UInt8[1 3 5; 2 4 6]
true

julia> serialize(layout, UInt8[1 2 3; 4 5 6]) == b"\x01\x04\x02\x05\x03\x06"
true

julia> estimatesize(SizedArray(UInt16be, (2, 3))) == ExactSize(12)
true
```

Elements follow the array's `eachindex` order. Standard Julia arrays are column
major, so the first dimension varies fastest. A zero-length dimension produces
an empty payload; an empty dimension tuple `()` describes a zero-dimensional
array containing one element.

An optional leading array type, such as `SizedArray(BitMatrix, Bool, 2, 3)`,
selects the output container. It must have compatible element type and rank and
support allocation through `similar(TA, dims)` followed by indexed assignment.
When StaticArrays is loaded, the package extension also provides default
constructs for its mutable `MArray` types.

## PrefixedArray

`PrefixedArray(size, element)` reads the shape before the elements. An integer
prefix gives a vector length, measured in **elements**, not bytes. Serialization
computes the prefix from the array itself.

```jldoctest
julia> layout = PrefixedArray(UInt16le, Int8);

julia> deserialize(layout, b"\x02\x00\x12\xfe") == Int8[18, -2]
true

julia> serialize(layout, Int8[-3, 1, 7]) == b"\x03\x00\xfd\x01\x07"
true

julia> matrix_layout = PrefixedArray(Sequence(UInt8, UInt16le), Int8);

julia> deserialize(matrix_layout, b"\x03\x02\x00\xff\xfe\xfd\x01\x02\x03") == Int8[-1 1; -2 2; -3 3]
true
```

A prefix producing an `NTuple{N,<:Integer}`, such as a `Sequence` of dimension
fields, gives an `N`-dimensional array. The optional leading array type is
`PrefixedArray(TA, size, element)`.

Dimensions must fit the prefix's integer type when serializing; an out-of-range
length raises `InexactError`. Deserialization allocates according to the prefix,
so choose bounds appropriate to the input format when accepting external data.
The size estimate is the prefix estimate plus `UnboundedSize(0)`.

## GreedyVector

`GreedyVector(element)` repeatedly reads the element layout. It stops at EOF or
on an exception from an element, and rewinds to the beginning of the failed
element. It therefore requires an input supporting `position` and `seek`.

```jldoctest
julia> io = IOBuffer(b"\x01\xff\x02\xab\xcc");

julia> deserialize(GreedyVector(UInt16be), io) == UInt16[0x01ff, 0x02ab]
true

julia> position(io)
4

julia> read(io) == b"\xcc"
true
```

In this example, the final byte cannot form another `UInt16`; it remains unread.
Failures other than [`ExceedMaxIterations`](@ref) are treated as the end of the
vector, including validation failures. Use `SizedArray` or `PrefixedArray` when
a malformed element must cause the entire array to fail.

Deserialization accepts the `max_iter` context keyword (default `65535`) and
raises `ExceedMaxIterations` when the successful iteration count exceeds it.
This also bounds layouts such as `Nothing` that consume no bytes on nonempty
input. Serialization writes all supplied elements without a prefix; `max_iter`
does not limit writing. The size estimate is `UnboundedSize(0)` and the default
value is an empty vector.
