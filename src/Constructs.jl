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
    JuliaSerializer,
    Padded,
    LittleEndian,
    BigEndian,
    IntEnum,
    Const,
    Sequence,
    SizedArray,
    GreedyVector

include("errors.jl")
include("size.jl")
include("base.jl")
include("container.jl")
include("macro.jl")

include("PrimitiveIO.jl")
include("Singleton.jl")
include("JuliaSerializer.jl")
include("Padded.jl")
include("Endians.jl")
include("IntEnum.jl")
include("Const.jl")
include("Sequence.jl")
include("Array.jl")

end
