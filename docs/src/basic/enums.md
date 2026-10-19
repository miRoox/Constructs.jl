```@meta
CurrentModule = Constructs
DocTestSetup = :(using Constructs)
```

# Enums

[`IntEnum`](@ref) maps an integer representation to a Julia `@enum` type.
`Construct(E)` selects `IntEnum(E)` for an enum type `E`. By default the wire
integer type is the enum's base type.

## Exhaustive enums

The default, [`EnumExhaustive`](@ref), accepts only declared enum members.
Pass an integer construct explicitly to choose the field width and byte order
independently of the enum's base type.

```jldoctest enums
julia> @enum Command::UInt8 ping=1 pong=2

julia> deserialize(Command, b"\x02") === pong
true

julia> serialize(IntEnum(UInt16be, Command), ping) == b"\x00\x01"
true

julia> try
           deserialize(Command, b"\x03")
       catch err
           err isa ArgumentError
       end
true
```

`IntEnum{EnumExhaustive}(UInt16be, Command)` is the explicit form of
`IntEnum(UInt16be, Command)`. Conversion to the enum's base type must still
succeed: using a wider wire integer does not extend the enum's representable range.

## Non-exhaustive enums

Use [`EnumNonExhaustive`](@ref) when a format allows values that are not yet
declared in the Julia enum. This mode reinterprets the integer as an enum value
without checking membership. The result still has type `E`, even for unknown
values; use `Integer(value)` to inspect its numeric representation.

```jldoctest enums
julia> open_command = IntEnum{EnumNonExhaustive}(Command);

julia> unknown = deserialize(open_command, b"\x03");

julia> unknown isa Command
true

julia> Integer(unknown) == 3
true

julia> serialize(open_command, unknown) == b"\x03"
true
```

Non-exhaustive mode still converts to the enum's base integer type and can fail
if that conversion is out of range. If callers should receive a plain integer
for unknown members, use `Try(Command, UInt8)` instead; see
[Conditional Constructs](@ref).
