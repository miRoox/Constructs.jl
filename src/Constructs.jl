"""
A declarative de-ser for binary data.
Inspired by [Construct](https://construct.readthedocs.io/).
"""
module Constructs

using Intervals

export
    @construct,
    this,
    Construct,
    Wrapper,
    Adapter,
    SymmetricAdapter,
    Validator,
    ValidationOK,
    ValidationError,
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
    Padding,
    LittleEndian,
    BigEndian,
    IntEnum,
    Const,
    SizedArray,
    GreedyVector

include("base.jl")
include("macro.jl")

include("PrimitiveIO.jl")
include("Singleton.jl")
include("JuliaSerializer.jl")
include("Padding.jl")
include("Endians.jl")
include("IntEnum.jl")
include("Const.jl")
include("Array.jl")
include("GreedyVector.jl")

end
