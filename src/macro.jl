
macro construct(structtype)
    if structtype isa Expr && structtype.head == :struct
        _, structdecl = collectconvertfields(__module__ , structtype)
        structdecl
    else
        error("invalid syntax: @construct must be used with a struct type definition.")
    end
end

# collect and convert struct fields.
function collectconvertfields(mod::Module, structtype)
    @assert structtype isa Expr && structtype.head == :struct
    stfields = structtype.args[3].args
    fieldpairs = Vector()
    sstfields = Vector()
    sizehint!(fieldpairs, length(stfields))
    sizehint!(sstfields, length(stfields))
    for field in stfields
        if field isa LineNumberNode
            push!(sstfields, field)
            continue
        elseif field isa Expr
            if field.head == :(::)
                constructortype = Core.eval(mod, field.args[end])
                type=constructtype(constructortype)
                if length(field.args) == 2 # x::Int
                    name = field.args[1]
                    sstfield = Expr(:(::), name, type)
                    push!(sstfields, sstfield)
                    push!(fieldpairs, name => constructortype)
                elseif length(field.args) == 1 # ::Padding(4)
                    if sstfields[end] isa LineNumberNode
                        pop!(sstfields)
                    end
                    push!(fieldpairs, nothing => constructortype)
                end
            else
                push!(sstfields, field)
            end
        elseif field isa Symbol
            push!(sstfields, field)
            push!(fieldpairs, field => Any)
        end
    end
    fieldpairs, Expr(:struct, structtype.args[1], structtype.args[2], Expr(:block, sstfields...))
end

hasthis(sym::Symbol) = sym == :this
hasthis(sym::GlobalRef) = hasthis(sym.name)
hasthis(ex::Expr) = any(hasthis, ex.args)
hasthis(arr::AbstractArray) = any(hasthis, arr)
hasthis(tuple::Tuple) = any(hasthis, tuple)
hasthis(_) = false

iscontextfree(ex) = !hasthis(ex)
