```@meta
CurrentModule = Constructs
DocTestSetup = :(using Constructs)
```

# Integers & Floats

## Primitive types

[`PrimitiveIO`](@ref) delegates directly to Julia's `read(io, T)` and
`write(io, value)`. It is the default construct for `Bool`, `Char`, the signed
and unsigned integer types with widths from 8 to 128 bits, and `Float16`,
`Float32`, and `Float64`.

```jldoctest
julia> deserialize(Int8, b"\xff")
-1

julia> serialize(UInt8, 42) == b"\x2a"
true

julia> estimatesize(UInt32) == ExactSize(4)
true
```

`PrimitiveIO(T)` can also be used explicitly for another type supported by
Julia's `read` and `write`. It does not define an automatic field layout for
arbitrary structs. `Char` follows Julia's character IO representation and has
a size estimate of `RangedSize(1, 4)`; it is not a fixed four-byte protocol field.

## Endianness

For multibyte numbers, the default construct uses the host's native byte order.
Choose an explicit byte order when a file or protocol must work across systems.

[`LittleEndian`](@ref) and [`BigEndian`](@ref) adapt a numeric construct. The
exported shortcuts are construct instances, rather than Julia types:

| Value types | Little-endian shortcuts | Big-endian shortcuts |
|:------------|:------------------------|:---------------------|
| `Int16`, `Int32`, `Int64`, `Int128` | `Int16le`, `Int32le`, `Int64le`, `Int128le` | `Int16be`, `Int32be`, `Int64be`, `Int128be` |
| `UInt16`, `UInt32`, `UInt64`, `UInt128` | `UInt16le`, `UInt32le`, `UInt64le`, `UInt128le` | `UInt16be`, `UInt32be`, `UInt64be`, `UInt128be` |
| `Float16`, `Float32`, `Float64` | `Float16le`, `Float32le`, `Float64le` | `Float16be`, `Float32be`, `Float64be` |

```jldoctest
julia> UInt16le == LittleEndian(UInt16)
true

julia> deserialize(UInt16le, b"\x12\x34")
0x3412

julia> deserialize(UInt16be, b"\x12\x34")
0x1234

julia> serialize(Float32be, 1.0f0) == b"\x3f\x80\x00\x00"
true
```

Single-byte types do not need a byte-order adapter. For portable layouts, also
prefer fixed-width types such as `Int32` over platform-dependent `Int`.

## Range checks and validation

The conversion performed by serialization rejects values outside the destination
type's range. To impose a narrower application-level range, use [`Validator`](@ref):

```jldoctest
julia> percent = Validator(UInt8, x -> x <= 100);

julia> serialize(percent, 75) == b"\x4b"
true

julia> try
           deserialize(percent, b"\xff")
       catch err
           err isa ValidationError
       end
true
```

The same predicate runs before writing and after reading. A failed predicate
raises [`ValidationError`](@ref); numeric conversion can instead raise
`InexactError` before validation.
