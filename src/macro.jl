macro sym(names...)
    Expr(:block,
        map(name -> Expr(:(=), esc(name), Expr(:call, GlobalRef(Core, :Symbol), QuoteNode(name))), names)...,
        :nothing
    )
end

"""
    this

Placeholder to access properties of the current object in [`@construct`](@ref) context.
"""
const this = :this

"""
    @construct [ConstructName] structdefinition

Generate a [`Construct`](@ref) subtype with `ConstructName` for the given `struct`.

# Examples

```jldoctest
julia> @construct struct Bitmap
           ::Const(b"BMP")
           width::UInt16le
           height::UInt16le
           pixel::SizedArray(UInt8, this.height, this.width)
       end

julia> deserialize(Bitmap, b"BMP\\x03\\x00\\x02\\x00\\x01\\x02\\x03\\x04\\x05\\x06")
Bitmap(0x0003, 0x0002, UInt8[0x01 0x03 0x05; 0x02 0x04 0x06])

julia> serialize(Bitmap(2, 3, UInt8[1 2; 4 6; 8 9]))
13-element Vector{UInt8}:
 0x42
 0x4d
 0x50
 0x02
 0x00
 0x03
 0x00
 0x01
 0x04
 0x08
 0x02
 0x06
 0x09

julia> estimatesize(Bitmap)
UnboundedSize(0x0000000000000007)
```
"""
macro construct(structdef::Expr)
    construct_impl(__module__, __source__, gensym("CustomConstruct"), structdef)
end

macro construct(constructname::Symbol, structdef::Expr)
    construct_impl(__module__, __source__, constructname, structdef)
end

deducetype(f::Function, ts...) = Union{Base.return_types(f, Tuple{ts...})...}

constructtype2(::Type{<:Construct{T}}) where {T} = T
constructtype2(::Type{<:Type{T}}) where {T} = T

mutable struct FieldInfo
    name::Symbol # name or generated name
    rawtype::Any # raw expression for type
    line::Union{LineNumberNode, Missing}
    hidden::Bool
    tfunc::Function
    constype::Type
    type::Type
    cons::Any # Expr/Construct
end

gentfunc(m::Module, rawtype::Any, line::Union{LineNumberNode, Missing})=Core.eval(m, Expr(:(->),
  this,
  Expr(:block, skipmissing([line])..., rawtype)
))

function FieldInfo(m::Module, name::Symbol, rawtype, line::Union{LineNumberNode, Missing}; hidden::Bool = false)
    erawtype = macroexpand(m, rawtype)
    FieldInfo(
        name,
        erawtype,
        line,
        hidden,
        gentfunc(m, erawtype, line),
        Any,
        Any, # type deduction should start from the top type (Any)
        erawtype
    )
end

struct OtherStructInfo
    expr::Any
    line::Union{LineNumberNode, Missing}
end

function construct_impl(m::Module, source::LineNumberNode, constructname::Symbol, structdef::Expr)
    if structdef.head == :struct
        infos = dumpstructinfo(m, structdef)
        fields = filter(info -> info isa FieldInfo, infos)
        deducefieldtypes!(fields)
        structname = getdefname(structdef)
        defs = Vector()
        push!(defs, Expr(:macrocall,
            GlobalRef(Core, Symbol("@__doc__")),
            source,
            replacestructdef(structdef, infos)
        ))
        append!(defs, generateconstructdef(constructname, structname))
        append!(defs, generatecontainerdef(structname, fields))
        push!(defs, generateserializemethod(constructname, structname, fields))
        push!(defs, generatedeserializemethod(constructname, structname, fields))
        push!(defs, generateestimatesizemethod(constructname, structname, fields))
        expr = Expr(:block)
        for def in defs
            push!(expr.args, source)
            push!(expr.args, def)
        end
        expr
    else
        error("invalid syntax: @construct must be used with a struct type definition.")
    end
end

function dumpstructinfo(m::Module, structdef::Expr)
    @assert structdef.head == :struct
    stnodes = structdef.args[3].args
    infos = Vector{Union{FieldInfo, OtherStructInfo}}()
    sizehint!(infos, length(stnodes))
    for i in eachindex(stnodes)
        node = stnodes[i]
        if node isa LineNumberNode
            continue
        else
            line = stnodes[i-1] isa LineNumberNode ? stnodes[i-1] : missing
            if node isa Symbol
                error("invalid syntax: please specify a type/construct for $(node).")
            elseif node isa Expr && node.head == :(::)
                rawtype = node.args[end]
                if length(node.args) == 2
                    name = node.args[1]
                    if name isa Symbol # x::Int
                        push!(infos, FieldInfo(m, name, rawtype, line))
                    elseif name isa Expr && name.head == :vect  # [x]::Int
                        push!(infos, FieldInfo(m, only(name.args), rawtype, line; hidden=true))
                    else
                        error("invalid syntax: invalid field $(name).")
                    end
                elseif length(node.args) == 1 # ::Padded(4)
                    push!(infos, FieldInfo(m, gensym("(anonymous)"), rawtype, line; hidden=true))
                else
                    push!(infos, OtherStructInfo(node, line))
                end
            else
                push!(infos, OtherStructInfo(node, line))
            end
        end
    end
    infos
end

function deducefieldtypes!(fields::Vector{>:FieldInfo})
    for field in fields
        thistype = NamedTuple{tuple(map(field -> field.name, fields)...), Tuple{map(field -> field.type, fields)...}}
        fieldconstype = deducetype(field.tfunc, thistype)
        if fieldconstype !== Union{}
            field.constype = fieldconstype
            if hasmethod(constructtype2, Tuple{Type{field.constype}})
                field.type = constructtype2(field.constype)
                if field.type isa field.constype
                    field.cons = Construct(field.type)
                end
            else
                error("$(field.rawtype) is neither a constructor nor a type.")
            end
        else
            error("Cannot deduce type for $(field.rawtype).")
        end
    end
    fields
end

function replacestructdef(structdef::Expr, infos::Vector{Union{FieldInfo, OtherStructInfo}})
    @assert structdef.head == :struct
    bodyexpr = Expr(:block)
    sizehint!(bodyexpr.args, length(structdef.args[3].args))
    for info in infos
        if info isa FieldInfo
            if info.hidden # omit hidden field
                continue
            else
                if !ismissing(info.line)
                    push!(bodyexpr.args, info.line)
                end
                push!(bodyexpr.args, Expr(:(::), info.name, info.type))
            end
        else
            if !ismissing(info.line)
                push!(bodyexpr.args, info.line)
            end
            push!(bodyexpr.args, info.expr)
        end
    end
    Expr(:struct, structdef.args[1], esc(structdef.args[2]), bodyexpr)
end

function generateconstructdef(constructname::Symbol, structname::Symbol)
    tuple(
        Expr(:struct,
            false,
            Expr(:(<:), esc(constructname), Expr(:curly, GlobalRef(Constructs, :Construct), esc(structname))),
            Expr(:block),
        ),
        Expr(:function,
            Expr(:call,
                GlobalRef(Constructs, :Construct),
                Expr(:(::), Expr(:curly, Type, esc(structname)))
            ),
            Expr(:block,
                Expr(:call, esc(constructname))
            ),
        )
    )
end

function generatecontainerdef(structname::Symbol, fields::Vector{>:FieldInfo})
    containername = gensym("ShadowContainer")
    bodyexpr = Expr(:block)
    sizehint!(bodyexpr.args, 2 * length(fields))
    for field in fields
        if !ismissing(field.line)
            push!(bodyexpr.args, field.line)
        end
        push!(bodyexpr.args, Expr(:(::), field.name, Union{field.type, UndefProperty{field.type}}))
    end
    tuple(
        Expr(:struct,
            true,
            Expr(:(<:), esc(containername), Expr(:curly, GlobalRef(Constructs, :ShadowContainer), esc(structname))),
            bodyexpr,
        ),
        Expr(:function,
            Expr(:call,
                Expr(:curly, GlobalRef(Constructs, :Container), esc(structname)),
            ),
            Expr(:block,
                Expr(:call,
                    esc(containername),
                    Iterators.map(field -> UndefProperty{field.type}(), fields)...
                )
            )
        )
    )
end

function generateserializemethod(constructname::Symbol, structname::Symbol, fields::Vector{>:FieldInfo})
    @sym s val contextkw result
    sercalls = Vector{Any}()
    sizehint!(sercalls, 2 * length(fields))
    for field in fields
        if !ismissing(field.line)
            push!(sercalls, field.line)
        end
        fieldcons = escape_excludes(field.cons, [this])
        fielddata = Expr(:(.),
            this,
            QuoteNode(field.name)
        )
        if field.hidden
            fielddata = Expr(:block,
                Expr(:call,
                    GlobalRef(Constructs, :setcontainerproperty!),
                    this,
                    QuoteNode(field.name),
                    Expr(:call,
                        GlobalRef(Constructs, :default),
                        Expr(:parameters,
                            Expr(:(...),
                                Expr(:call,
                                    GlobalRef(Constructs, :with_property),
                                    contextkw,
                                    QuoteNode(field.name)
                                )
                            )
                        ),
                        fieldcons,
                    )
                ),
                fielddata
            )
        end
        sercall = Expr(:(+=),
            result,
            Expr(:call, 
                GlobalRef(Constructs, :serialize),
                Expr(:parameters,
                    Expr(:(...),
                        Expr(:call,
                            GlobalRef(Constructs, :with_property),
                            contextkw,
                            QuoteNode(field.name)
                        )
                    )
                ),
                fieldcons,
                s,
                fielddata
            )
        )
        push!(sercalls, sercall)
    end

    Expr(:function,
        Expr(:call,
            GlobalRef(Constructs, :serialize),
            Expr(:parameters,
                Expr(:(...), contextkw)
            ),
            Expr(:(::), esc(constructname)),
            Expr(:(::), s, IO),
            Expr(:(::), val, esc(structname))
        ),
        Expr(:block,
            Expr(:(=),
                this,
                Expr(:call,
                    GlobalRef(Constructs, :Container),
                    val
                )
            ),
            Expr(:(=), result, 0),
            sercalls...,
            result
        )
    )
end

function generatedeserializemethod(constructname::Symbol, structname::Symbol, fields::Vector{>:FieldInfo})
    @sym s contextkw
    desercalls = Vector{Any}()
    sizehint!(desercalls, 2 * length(fields))
    for field in fields
        if !ismissing(field.line)
            push!(desercalls, field.line)
        end
        desercall = Expr(:call,
            GlobalRef(Constructs, :setcontainerproperty!),
            this,
            QuoteNode(field.name),
            Expr(:call,
                GlobalRef(Constructs, :deserialize),
                Expr(:parameters,
                    Expr(:(...),
                        Expr(:call,
                            GlobalRef(Constructs, :with_property),
                            contextkw,
                            QuoteNode(field.name)
                        )
                    )
                ),
                escape_excludes(field.cons, [this]),
                s,
            )
        )
        push!(desercalls, desercall)
    end
    thisfields = map(filter(field -> !field.hidden, fields)) do field
        Expr(:(.),
            this,
            QuoteNode(field.name)
        )
    end

    Expr(:function,
        Expr(:call,
            GlobalRef(Constructs, :deserialize),
            Expr(:parameters,
                Expr(:(...), contextkw)
            ),
            Expr(:(::), esc(constructname)),
            Expr(:(::), s, IO)
        ),
        Expr(:block,
            Expr(:(=),
                this,
                Expr(:call,
                    Expr(:curly,
                        GlobalRef(Constructs, :Container),
                        esc(structname)
                    ),
                )
            ),
            desercalls...,
            Expr(:call,
                esc(structname),
                thisfields...
            )
        )
    )
end

function generateestimatesizemethod(constructname::Symbol, structname::Symbol, fields::Vector{>:FieldInfo})
    @sym contextkw result ex
    szcalls = Vector{Any}()
    sizehint!(szcalls, 2 * length(fields))
    for field in fields
        if !ismissing(field.line)
            push!(szcalls, field.line)
        end
        szcall = Expr(:call, 
            GlobalRef(Constructs, :estimatesize),
            Expr(:parameters,
                Expr(:(...),
                    Expr(:call,
                        GlobalRef(Constructs, :with_property),
                        contextkw,
                        QuoteNode(field.name)
                    )
                )
            ),
            escape_excludes(field.cons, [this])
        )
        # if the construct can't accept UndefProperty{T}() while the code has it,
        # the size is just UnboundedSize(0) (like any other unknown sized construct)
        szcall = Expr(:try,
            Expr(:block, szcall),
            ex,
            Expr(:block,
                Expr(:if,
                    Expr(:call, GlobalRef(Core, :isa), ex, GlobalRef(Core, :MethodError)),
                    UnboundedSize(0),
                    Expr(:call, GlobalRef(Base, :rethrow))
                )
            )
        )
        szcall = Expr(:(+=),
            result,
            szcall
        )
        push!(szcalls, szcall)
    end

    Expr(:function,
        Expr(:call,
            GlobalRef(Constructs, :estimatesize),
            Expr(:parameters,
                Expr(:(...), contextkw)
            ),
            Expr(:(::), esc(constructname))
        ),
        Expr(:block,
            Expr(:(=),
                this,
                Expr(:call,
                    Expr(:curly,
                        GlobalRef(Constructs, :Container),
                        esc(structname)
                    ),
                )
            ),
            Expr(:(=), result, ConstructSize(0)),
            szcalls...,
            result
        )
    )
end

function escape_excludes(expr::Expr, excludes::Vector{Symbol})
    if expr.head in [:meta, :quote, :macrocall]
        expr
    else
        Expr(expr.head, map(arg -> escape_excludes(arg, excludes), expr.args)...)
    end
end
function escape_excludes(sym::Symbol, excludes::Vector{Symbol})
    if sym in excludes
        sym
    else
        esc(sym)
    end
end
escape_excludes(other, ::Vector{Symbol}) = other

getdefname(name::Symbol) = name
getdefname(sym::GlobalRef) = sym.name
function getdefname(expr::Expr)
    if expr.head == :struct
        getdefname(expr.args[2])
    elseif expr.head in [:abstract, :(<:), :curly, :call, :function, :(=), :where]
        getdefname(expr.args[1])
    else
        error("syntax error: invalid definition $expr.")
    end
end
