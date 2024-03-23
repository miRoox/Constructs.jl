"""
A declarative de-ser for binary data.
Inspired by [Construct](https://construct.readthedocs.io/).
"""
module Constructs

using Requires
using StringEncodings

import Serialization

export
    @construct,
    this,
    Construct,
    Wrapper,
    Adapter,
    SymmetricAdapter,
    Validator,
    PropertyPath,
    UnboundedUpper,
    ConstructSize,
    ExactSize,
    RangedSize,
    UnboundedSize,
    AbstractConstructError,
    ValidationError,
    ExceedMaxIterations,
    PaddedError,
    UndefProperty,
    Container,
    deserialize,
    serialize,
    estimatesize,
    subcon,
    encode,
    decode,
    validate,
    PrimitiveIO,
    Singleton,
    RaiseError,
    JuliaSerializer,
    NullTerminatedString,
    PaddedString,
    PrefixedString,
    Padded,
    LittleEndian,
    BigEndian,
    Int16le, UInt16le, Int32le, UInt32le, Int64le, UInt64le, Int128le, UInt128le,
    Float16le, Float32le, Float64le,
    Int16be, UInt16be, Int32be, UInt32be, Int64be, UInt64be, Int128be, UInt128be,
    Float16be, Float32be, Float64be,
    EnumExhaustive,
    EnumNonExhaustive,
    IntEnum,
    Const,
    Overwrite,
    Optional,
    Try,
    IfThenElse,
    Sequence,
    SizedArray,
    PrefixedArray,
    GreedyVector

include("context.jl")
include("errors.jl")
include("size.jl")
include("container.jl")
include("interface.jl")
include("macro.jl")
include("functional.jl")

include("PrimitiveIO.jl")
include("Singleton.jl")
include("String.jl")
include("Error.jl")
include("JuliaSerializer.jl")
include("Padded.jl")
include("Endians.jl")
include("IntEnum.jl")
include("Const.jl")
include("Overwrite.jl")
include("Optional.jl")
include("Try.jl")
include("Conditional.jl")
include("Sequence.jl")
include("Array.jl")

function __init__()
    @require StaticArrays="90137ffa-7385-5640-81b9-e52037218182" include("ext/StaticArrays.jl")
end

end
