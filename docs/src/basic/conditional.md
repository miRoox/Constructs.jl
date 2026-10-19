```@meta
CurrentModule = Constructs
DocTestSetup = :(using Constructs)
```

# Conditional Constructs

[`Try`](@ref) chooses among alternative layouts and [`Optional`](@ref) supplies
a fallback when a layout cannot be read. Neither writes a discriminator or a
presence flag automatically. Both restore the input position before recovering
from a parsing failure, so use streams supporting `position` and `seek`.

## `Try`

`Try(first, second, rest...)` attempts deserialization in declaration order.
When a branch throws, the next branch starts from the same position. If the last
branch fails, its exception propagates. The default result type is the union
of the branch value types.

```jldoctest
julia> @enum Reply::UInt8 accepted=1 rejected=2

julia> reply = Try(Reply, UInt8);

julia> deserialize(reply, b"\x01") === accepted
true

julia> deserialize(reply, b"\x03")
0x03

julia> serialize(reply, rejected) == b"\x02"
true

julia> serialize(reply, 0x03) == b"\x03"
true
```

Order matters: `Try(UInt8, Reply)` always reads the byte as `UInt8`, because the
first branch already succeeds. The choice is based on success, including
validation, rather than on consuming the most bytes.

Serialization uses the value's Julia type to select a branch. When the first
branch's type is a subtype of the second's, it tries the first branch and rewinds
on failure before using the second. Otherwise, a failure in the selected branch
propagates; writing does not unconditionally try every alternative.

```jldoctest
julia> alternatives = Try(Const(0x01), UInt8);

julia> serialize(alternatives, 0x02) == b"\x02"
true
```

`Try{TU}(...)` sets an explicit common result type, for example
`Try{Integer}(Int8, UInt8)`. Every branch's value type must be a subtype of `TU`.
Size estimates take the union of the branch estimates; default-value lookup
tries the branches in order.

## `Optional`

`Optional(element, fallback=nothing)` tries to read `element`. On any parsing
exception it restores the input position and returns the fallback. Its result
type is normally `Union{T,typeof(fallback)}`.

```jldoctest
julia> io = IOBuffer(b"\x01");

julia> deserialize(Optional(UInt16be), io) === nothing
true

julia> position(io)
0

julia> deserialize(UInt8, io)
0x01

julia> serialize(Optional(UInt16be), nothing)
UInt8[]

julia> serialize(Optional(UInt16be), 0x0102) == b"\x01\x02"
true
```

When serializing, a value of the element type is written using that construct;
a value belonging only to the fallback type writes zero bytes. If the element
type is a subtype of the fallback type (including when both types are equal),
serialization attempts the element and suppresses a failure after rewinding.
This is a type-based rule, not an equality test against the fallback:

```jldoctest
julia> serialize(Optional(UInt8, 0xff), 0xff) == b"\xff"
true

julia> serialize(Optional(Const(0x01), 0xff), 0x02)
UInt8[]
```

`Optional{TU}(element, fallback)` selects an explicit common type. The default
value is the fallback, and the size estimate includes zero bytes as well as
the element estimate.

## Recovery boundaries

Recovery catches parsing exceptions broadly, including validation errors and
errors from custom constructs. Choose a strict layout when such failures must
reach the caller. A missing optional field also cannot be distinguished from a
present field whose bytes happen to parse successfully; protocols with a
presence flag need to model that flag explicitly.

Rewinding restores the stream position, but does not undo callback side effects.
During serialization it also does not truncate bytes already written by a failed
branch. A custom branch that writes and then throws can therefore leave trailing
data behind. Validate before writing, or serialize such a branch into a temporary
buffer before copying it to the destination.
