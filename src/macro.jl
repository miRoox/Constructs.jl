

macro construct(structdef::Expr)
    construct_impl(__module__, __source__, gensym("CustomConstruct"), structdef)
end

macro construct(constructname::Symbol, structdef::Expr)
    construct_impl(__module__, __source__, constructname, structdef)
end

struct FieldInfo
    name::Union{Symbol, Nothing}
    constype::Union{Construct, DataType}
    line::Union{LineNumberNode, Missing}
end

struct OtherFieldInfo
    expr::Any
    line::Union{LineNumberNode, Missing}
end

function construct_impl(mod::Module, source::LineNumberNode, constructname::Symbol, structdef::Expr)
    if structdef.head == :struct
        fields = dumpfields(mod, structdef)
        typedstructdef = replacestructdef(structdef, fields)
        constructdef = generateconstructdef(constructname, getdefname(structdef))
        Expr(:block,
            source, typedstructdef,
            source, constructdef)
    else
        error("invalid syntax: @construct must be used with a struct type definition.")
    end
end

function dumpfields(mod::Module, structdef::Expr)
    @assert structdef.head == :struct
    stfields = structdef.args[3].args
    fields = Vector{Union{FieldInfo, OtherFieldInfo}}()
    sizehint!(fields, length(stfields))
    for i in eachindex(stfields)
        field = stfields[i]
        if field isa LineNumberNode
            continue
        else
            line = stfields[i-1] isa LineNumberNode ? stfields[i-1] : missing
            if field isa Symbol
                push!(fields, FieldInfo(field, Any, line))
            elseif field isa Expr && field.head == :(::)
                constype = Core.eval(mod, field.args[end])
                if length(field.args) == 2 # x::Int
                    push!(fields, FieldInfo(field.args[1], constype, line))
                elseif length(field.args) == 1 # ::Padding(4)
                    push!(fields, FieldInfo(nothing, constype, line))
                else
                    push!(fields, OtherFieldInfo(field, line))
                end
            else
                push!(fields, OtherFieldInfo(field, line))
            end
        end
    end 
    fields
end

function replacestructdef(structdef::Expr, fields::Vector{Union{FieldInfo, OtherFieldInfo}})
    @assert structdef.head == :struct
    stfields = Vector()
    sizehint!(stfields, length(structdef.args[3].args))
    for field in fields
        if field isa FieldInfo
            if isnothing(field.name) # omit field without name
                continue
            else
                if !ismissing(field.line)
                    push!(stfields, field.line)
                end
                push!(stfields, Expr(:(::), field.name, constructtype(field.constype)))
            end
        else
            if !ismissing(field.line)
                push!(stfields, field.line)
            end
            push!(stfields, field.expr)
        end
    end
    Expr(:struct, structdef.args[1], structdef.args[2], Expr(:block, stfields...))
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

hasthis(sym::Symbol) = sym == :this
hasthis(sym::GlobalRef) = hasthis(sym.name)
hasthis(ex::Expr) = any(hasthis, ex.args)
hasthis(arr::AbstractArray) = any(hasthis, arr)
hasthis(tuple::Tuple) = any(hasthis, tuple)
hasthis(_) = false

iscontextfree(ex) = !hasthis(ex)
