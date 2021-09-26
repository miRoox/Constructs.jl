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
    deserialize,
    serialize,
    estimatesize,
    subcon,
    encode,
    decode,
    @cons,
    Padding,
    LittleEndian,
    BigEndian

include("base.jl")
include("macro.jl")
include("primitive.jl")
include("adapters.jl")

end
