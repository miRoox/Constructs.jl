"""
A declarative de-ser for binary data.
Inspired by [Construct](https://construct.readthedocs.io/).
"""
module Construct

using Intervals
using MacroTools

export
    deserialize,
    serialize,
    estimatesize

include("base.jl")
include("primitive.jl")

end
