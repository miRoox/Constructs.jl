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

[`@construct`](@ref) defines the `struct` type and the corresponding deserialize/serialize methods.
The following `Bitmap` has a `BMP` header, width and height in `UInt16` little-endian format,
and pixel which is a 2-dimensional byte array with the specified width and height.

```@repr
using Constructs
@construct struct Bitmap
    ::Const(b"BMP")
    width::UInt16le
    height::UInt16le
    pixel::SizedArray(UInt8, this.width, this.height)
end
deserialize(Bitmap, b"BMP\x03\x00\x02\x00\x01\x02\x03\x04\x05\x06")
serialize(Bitmap(2, 3, UInt8[1 2 3; 7 8 9]))
```
