"""
A declarative de-ser for binary data.
Inspired by [Construct](https://construct.readthedocs.io/).
"""
module Constructs

import Serialization

export
    @construct,
    this,
    Construct,
    Wrapper,
    Adapter,
    SymmetricAdapter,
    Validator,
    UnboundedUpper,
    ConstructSize,
    ExactSize,
    RangedSize,
    UnboundedSize,
    ConstructError,
    ValidationOK,
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
    Padded,
    LittleEndian,
    BigEndian,
    EnumExhaustive,
    EnumNonExhaustive,
    IntEnum,
    Const,
    Try,
    Sequence,
    SizedArray,
    GreedyVector

include("errors.jl")
include("size.jl")
include("container.jl")
include("base.jl")
include("macro.jl")

include("PrimitiveIO.jl")
include("Singleton.jl")
include("Error.jl")
include("JuliaSerializer.jl")
include("Padded.jl")
include("Endians.jl")
include("IntEnum.jl")
include("Const.jl")
include("Try.jl")
include("Sequence.jl")
include("Array.jl")

end
