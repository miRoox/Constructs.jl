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
    estimatesize

include("base.jl")
include("primitive.jl")
# include("wrapper.jl")

end
