```@meta
CurrentModule = Constructs
DocTestSetup = :(using Constructs)
```

# The `@construct` Macro

[`@construct`](@ref) defines both a Julia record type and its binary layout.
Field annotations may be types or construct expressions. The macro infers each
field's Julia value type from its construct, so `value::UInt16le` becomes a real
`value::UInt16` field.

## Named records and dependent fields

Fields are processed in declaration order. During deserialization, [`this`](@ref)
provides access to fields already read. During serialization, it starts with
the stored fields of the supplied object.

```jldoctest macro_fields
julia> @construct PacketLayout struct Packet
           ::Const(b"PK")
           count::UInt8
           payload::SizedArray(UInt16be, this.count)
       end

julia> fieldnames(Packet)
(:count, :payload)

julia> fieldtype(Packet, :payload) == Vector{UInt16}
true

julia> Construct(Packet) isa PacketLayout
true

julia> packet = deserialize(Packet, b"PK\x02\x00\x01\x00\x02");

julia> packet.payload == UInt16[1, 2]
true

julia> serialize(Packet(2, UInt16[1, 2])) == b"PK\x02\x00\x01\x00\x02"
true
```

`PacketLayout` is an optional name for the generated construct type. If omitted,
the macro chooses an internal name; `Construct(Packet)` still retrieves an
instance. Use `PacketLayout()` when passing the named layout explicitly.

An ordinary stored length field is not recomputed on serialization. In this
example the payload must have the shape specified by `count`, otherwise
`SizedArray` raises `DimensionMismatch`.

## Hidden fields and derived lengths

There are three field forms:

| Declaration | Stored in the Julia record? | Available by name through `this`? |
|:------------|:----------------------------|:----------------------------------|
| `name::layout` | Yes | Yes |
| `[name]::layout` | No | Yes |
| `::layout` | No | No user-chosen name |

Hidden and anonymous fields are still read and written. On serialization the
macro obtains their values through [`Constructs.default`](@ref). `Const` and
`Padded` are common anonymous fields. To calculate a hidden length from the
payload, use [`Overwrite`](@ref):

```jldoctest
julia> @construct struct Message
           ::Const(b"M")
           [count]::Overwrite(UInt8, _ -> length(this.payload))
           payload::SizedArray(UInt8, this.count)
       end

julia> fieldnames(Message)
(:payload,)

julia> serialize(Message(UInt8[10, 20, 30])) == b"M\x03\x0a\x14\x1e"
true

julia> deserialize(Message, b"M\x02\x0a\x14").payload == UInt8[10, 20]
true
```

While reading, `count` comes from the input and is available before `payload`.
While writing, the getter can see the stored payload before it is written and
the computed default is stored in `this.count` for the later array layout.
The getter ignores its argument because default lookup passes an
[`UndefProperty`](@ref), rather than a stored length value. A hidden field without
an appropriate default can parse successfully but fail to serialize.

## Expand `@construct`

Use Julia's `@macroexpand` to inspect the generated definitions:

```julia
@macroexpand @construct SampleLayout struct Sample
    tag::UInt8
    value::UInt16be
end
```

The expansion contains the following pieces (internal names are generated):

1. The record type, containing the inferred types of visible fields.
2. A subtype of `Construct{Sample}` and a `Construct(::Type{Sample})` method.
3. An intermediate container type and `Container{Sample}()` constructor.
4. Stream methods for `serialize` and `deserialize`, plus `estimatesize`.

Serialization creates `Container(value)`, writes each field in order, and sums
the byte counts. Deserialization starts from an empty container, assigns each
decoded field, and calls the record constructor with the visible fields in
declaration order. Keep a constructor accepting those values if adding custom
inner constructors.

## Containers and undefined properties

[`Container{T}`](@ref Container) is the intermediate representation used while
a record is being processed. It can hold both visible and hidden fields.
`Container(obj)` copies an object's stored properties, whereas `Container{T}()`
starts with undefined properties represented by `UndefProperty{FieldType}()`.

```jldoctest macro_fields
julia> pending = Container{Packet}();

julia> pending.count isa UndefProperty{UInt8}
true

julia> ready = Container(Packet(2, UInt16[1, 2]));

julia> ready.count == 2
true
```

Do not treat `UndefProperty` as a normal field value. For example, a length
expression cannot use a later field that has not yet been read. Containers are
intended for inspection and generated processing; direct assignment through
`container.field = value` is not part of their public interface.

## Inference and size estimates

The macro infers constructs and field types when expanding the definition.
Use expressions with inferable result types, and define helper functions and
constructs before the record declaration. A missing annotation or an expression
whose construct type cannot be inferred causes a macro-expansion error.

`estimatesize(Record)` runs with an initially empty container, without a particular
record instance. Static fields contribute their estimates. A dependent layout
that raises `MethodError` when given an undefined field contributes
`UnboundedSize(0)`; other exceptions propagate.

```jldoctest macro_fields
julia> estimatesize(Packet) == UnboundedSize(3)
true
```

The three known bytes are the two-byte magic and the one-byte count. The payload
length is unknown during estimation. This estimate does not read data or predict
the length of a specific packet.
