```@meta
CurrentModule = Constructs
```

# Constructs

A declarative deserialization-serialization for binary data.
Inspired by [Construct](https://construct.readthedocs.io/).

## Installation

`Constructs` can be installed with the Julia package manager.

```julia
using Pkg
Pkg.add("Constructs")
```

## Basic Usage

[`@construct`](@ref) defines the `struct` type and the corresponding [`deserialize`](@ref)/[`serialize`](@ref) methods.
The following `Bitmap` has a `BMP` header, width and height in `UInt16` little-endian format,
and pixel which is a 2-dimensional byte array with the specified width and height.

```jldoctest
julia> using Constructs

julia> @construct struct Bitmap
           ::Const(b"BMP")
           width::UInt16le
           height::UInt16le
           pixel::SizedArray(UInt8, this.height, this.width) # Julia arrays are column major
       end

julia> deserialize(Bitmap, b"BMP\x02\x00\x03\x00\x01\x02\x03\x04\x05\x06")
Bitmap(0x0002, 0x0003, UInt8[0x01 0x04; 0x02 0x05; 0x03 0x06])

julia> serialize(Bitmap(3, 2, UInt8[1 2 3; 7 8 9]))
13-element Vector{UInt8}:
 0x42
 0x4d
 0x50
 0x03
 0x00
 0x02
 0x00
 0x01
 0x07
 0x02
 0x08
 0x03
 0x09
```
