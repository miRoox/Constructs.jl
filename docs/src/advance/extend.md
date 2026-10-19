```@meta
CurrentModule = Constructs
DocTestSetup = :(using Constructs)
```
# Extending Constructs

## Implementing a construct

Subtype [`Construct{T}`](@ref Construct) when a new binary representation needs
custom IO. `T` is the Julia value returned on reading and accepted on writing.
The stream methods are the extension points; existing filename and byte-vector
convenience methods delegate to them.

| Method | Contract |
|:-------|:---------|
| `Constructs.deserialize(cons::C, io::IO; contextkw...)` | Read one value and return a `T` |
| `Constructs.serialize(cons::C, io::IO, value::T; contextkw...)` | Write one value and return the number of bytes written |
| `Constructs.estimatesize(cons::C; contextkw...)` | Optional; return a `ConstructSize` (fallback: `UnboundedSize(0)`) |
| `Constructs.default(cons::C; contextkw...)` | Supply a value if the construct will be used in hidden or anonymous fields |

Accept context keywords even if unused. Forward them to sub-constructs so
validators, adapters, and options such as `max_iter` work inside nested layouts.
Methods extending package functions should be qualified with `Constructs.` or
explicitly imported first.

This example defines an unsigned 24-bit little-endian field. It checks the range
before writing, and reads exactly three bytes through the existing array layout.

```jldoctest custom_construct
julia> struct UInt24LE <: Construct{UInt32} end

julia> function Constructs.deserialize(::UInt24LE, io::IO; contextkw...)
           bytes = deserialize(SizedArray(UInt8, 3), io; contextkw...)
           UInt32(bytes[1]) | (UInt32(bytes[2]) << 8) | (UInt32(bytes[3]) << 16)
       end;

julia> function Constructs.serialize(::UInt24LE, io::IO, value::UInt32; contextkw...)
           value <= 0x00ffffff || throw(ValidationError("value exceeds 24 bits"))
           bytes = UInt8[value & 0xff, (value >> 8) & 0xff, (value >> 16) & 0xff]
           write(io, bytes)
       end;

julia> Constructs.estimatesize(::UInt24LE; contextkw...) = ExactSize(3);

julia> Constructs.default(::UInt24LE; contextkw...) = UInt32(0);

julia> deserialize(UInt24LE(), b"\x56\x34\x12") == 0x00123456
true

julia> serialize(UInt24LE(), 0x00123456) == b"\x56\x34\x12"
true

julia> estimatesize(Sequence(UInt8, UInt24LE())) == ExactSize(4)
true
```

Returning a byte count is necessary because sequences, arrays, and macro-generated
records add their members' counts. The generic serializer converts values to `T`
when needed; the concrete method should accept `value::T` to avoid recursion or
ambiguity with that fallback. Reject malformed input with an appropriate exception
instead of silently returning a partially decoded value.

To make a construct the default for a type you own, define
`Constructs.Construct(::Type{YourType}) = YourLayout()`. Avoid changing the default
of a built-in type such as `UInt32`; pass `UInt24LE()` explicitly for that layout.

## Adapters

Subtype [`Adapter{TSub,T}`](@ref Adapter) when the byte representation already
exists and only the value conversion changes. Provide a sub-construct producing
`TSub`, [`encode`](@ref) from `T` to `TSub`, and [`decode`](@ref) in the opposite
direction. The inherited stream methods do the IO and the size estimate delegates
to the sub-construct.

```jldoctest custom_adapter
julia> struct CelsiusField <: Adapter{Int16, Float64}
           subcon::typeof(Int16le)
       end

julia> Constructs.encode(::CelsiusField, value::Float64; contextkw...) = round(Int16, 10 * value);

julia> Constructs.decode(::CelsiusField, value::Int16; contextkw...) = Float64(value) / 10;

julia> temperature = CelsiusField(Int16le);

julia> deserialize(temperature, b"\xeb\x00")
23.5

julia> serialize(temperature, 23.5) == b"\xeb\x00"
true

julia> estimatesize(temperature) == ExactSize(2)
true
```

The default [`subcon`](@ref) implementation reads a field named `subcon`.
Override it if the layout stores its child elsewhere. This example quantizes to
tenths of a degree; describe any rounding or loss of information in your own
adapter's contract.

For conversion with Julia's `convert`, use `Adapter(layout, OutputType)` directly.
For an involution that preserves the value type, use
[`SymmetricAdapter`](@ref), whose decode operation is the same as encode:

```jldoctest
julia> deserialize(Adapter(UInt8, Int), b"\x2a") === 42
true

julia> inverted = SymmetricAdapter(UInt8, ~);

julia> deserialize(inverted, serialize(inverted, 0x35)) == 0x35
true
```

A function passed as the second argument to `Adapter` also creates a symmetric
adapter. It must implement `f(f(x)) == x` for a lossless round trip; it is not
a constructor for separate arbitrary encode and decode functions. Use a subtype
as above when those functions differ.

## Validators and wrappers

[`Validator{T}`](@ref Validator) is a symmetric adapter that preserves values and
checks [`validate`](@ref) before serialization and after deserialization. For
a simple predicate, use `Validator(layout, predicate)`:

```jldoctest
julia> positive = Validator(Int16le, x -> x > 0);

julia> deserialize(positive, b"\x01\x00")
1

julia> try
           deserialize(positive, b"\x00\x00")
       catch err
           err isa ValidationError
       end
true
```

A custom validator subtype needs `subcon` and
`Constructs.validate(cons, value::T; contextkw...)`. Return `true` for success;
any other return value causes `ValidationError`. Throwing a `ValidationError`
directly lets you supply a more specific message.

[`Wrapper{TSub,T}`](@ref Wrapper) is the more general parent for a construct
containing a sub-construct. It provides `subcon` access, but does not supply IO
or size-estimation methods by itself. Use it when a wrapper changes framing or
control flow, as `Padded` and `Optional` do; implement those operations explicitly.

## Context, errors, and verification

Function-based validators, symmetric adapters, and overwrite getters may accept
either just the value or the value plus context keywords. When a callback uses
context, give its keywords defaults and accept `kw...`, for example
`(value; limit=100, kw...) -> value <= limit`.

Constructs tracks nested field names and array indices through [`PropertyPath`](@ref)
in an internal context keyword. Preserve context when delegating. That tracking
does not automatically add a path to every exception message, so provide useful
messages for custom validation failures.

Check both directions of a new layout, its boundary values, truncated input,
and byte counts returned by stream serialization. Include its use inside a
`Sequence` or macro-generated record to check composition. If it will be used
inside `Try`, `Optional`, or `GreedyVector`, remember that those constructs may
rewind input and recover from its exceptions; avoid irreversible callback side
effects during speculative parsing.
