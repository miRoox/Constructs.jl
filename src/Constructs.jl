"""
A declarative de-ser for binary data.
Inspired by [Construct](https://construct.readthedocs.io/).
"""
module Constructs

using Intervals
using MacroTools

export
    Construct,
    deserialize,
    serialize,
    estimatesize,
    Wrapper,
    subcon,
    Adapter,
    encode,
    decode,
    LittleEndian,
    BigEndian

include("base.jl")
include("primitive.jl")
include("adapters.jl")

end
