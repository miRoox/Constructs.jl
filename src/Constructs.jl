"""
A declarative de-ser for binary data.
Inspired by [Construct](https://construct.readthedocs.io/).
"""
module Constructs

using Intervals
using MacroTools

export
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
    @cons,
    Padding,
    LittleEndian,
    BigEndian,
    IntEnum,
    Const,
    Repeat,
    RepeatGreedily

include("base.jl")
include("macro.jl")
include("primitive.jl")
include("adapters.jl")
include("collections.jl")

end
