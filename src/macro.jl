"""
    this

Placeholder to access properties of the current object in [`@construct`](@ref) context.
"""
const this = :this

"""
    @construct [ConstructName] structdefinition

Generate a [`Construct{T}`](@ref) subtype with `ConstructName` for the given struct.
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
    name::Union{Symbol, Nothing}
    rawtype::Any # raw expression for type
    line::Union{LineNumberNode, Missing}
    tfunc::Function
    constype::DataType
    type::DataType
end

gentfunc(m::Module, rawtype::Any, line::Union{LineNumberNode, Missing})=Core.eval(m, Expr(:(->),
  this,
  Expr(:block, skipmissing([line])..., rawtype)
))

FieldInfo(m::Module, name::Union{Symbol, Nothing}, rawtype, line::Union{LineNumberNode, Missing}) = FieldInfo(name, rawtype, line, gentfunc(m, rawtype, line), Any, Any)

struct OtherStructInfo
    expr::Any
    line::Union{LineNumberNode, Missing}
end

function construct_impl(m::Module, source::LineNumberNode, constructname::Symbol, structdef::Expr)
    if structdef.head == :struct
        infos = dumpstructinfo(m, structdef)
        fields = filter(info -> info isa FieldInfo, infos)
        deducefieldtypes(fields)
        typedstructdef = replacestructdef(structdef, infos)
        constructdef = generateconstructdef(constructname, getdefname(structdef))
        Expr(:block,
            source, typedstructdef,
            source, constructdef)
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
                if length(node.args) == 2 # x::Int
                    push!(infos, FieldInfo(m ,node.args[1], rawtype, line))
                elseif length(node.args) == 1 # ::Padding(4)
                    push!(infos, FieldInfo(m, nothing, rawtype, line))
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

const max_deduction_iteration = 100

function deducefieldtypes(fields::Vector{>:FieldInfo})
    namedfields = filter(field -> field.name isa Symbol, fields)
    lasttypes = map(field -> (field.constype, field.type), fields)
    for i in 1:max_deduction_iteration
        if i == max_deduction_iteration
            error("Reach max iteration $max_deduction_iteration when trying to deduce field types.")
        end
        for field in fields
            if !isabstracttype(field.type)
                continue
            end
            thistype = NamedTuple{tuple(map(field -> field.name, namedfields)...), Tuple{map(field -> field.type, namedfields)...}}
            fieldconstype = deducetype(field.tfunc, thistype)
            if fieldconstype isa DataType
                field.constype = fieldconstype
                if hasmethod(constructtype2, Tuple{Type{field.constype}})
                    field.type = constructtype2(field.constype)
                end
            end
        end
        currenttypes = map(field -> (field.constype, field.type), fields)
        if currenttypes == lasttypes
            break # fix point
        else
            lasttypes = currenttypes
        end
    end
    fields
end

function replacestructdef(structdef::Expr, infos::Vector{Union{FieldInfo, OtherStructInfo}})
    @assert structdef.head == :struct
    stnodes = Vector()
    sizehint!(stnodes, length(structdef.args[3].args))
    for info in infos
        if info isa FieldInfo
            if isnothing(info.name) # omit field without name
                continue
            else
                if !ismissing(info.line)
                    push!(stnodes, info.line)
                end
                push!(stnodes, Expr(:(::), info.name, info.type))
            end
        else
            if !ismissing(info.line)
                push!(stnodes, info.line)
            end
            push!(stnodes, info.expr)
        end
    end
    Expr(:struct, structdef.args[1], structdef.args[2], Expr(:block, stnodes...))
end

function generateconstructdef(constructname::Symbol, structname)
    Expr(:block,
        Expr(:struct,
            false,
            Expr(:(<:), esc(constructname), Expr(:curly, GlobalRef(Constructs, :Construct), esc(structname))),
            Expr(:block),
        ),
        Expr(:function,
            Expr(:call,
                GlobalRef(Constructs, :Construct),
                Expr(:(::), Expr(:curly, GlobalRef(Core, :Type), esc(structname)))
            ),
            Expr(:block,
                Expr(:call, esc(constructname))
            ),
        )
    )
end

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
