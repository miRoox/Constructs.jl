using Construct
using Documenter

DocMeta.setdocmeta!(Construct, :DocTestSetup, :(using Construct); recursive=true)

makedocs(;
    modules=[Construct],
    authors="Yong-an Lu <miroox@outlook.com>",
    repo="https://github.com/miRoox/Construct.jl/blob/{commit}{path}#{line}",
    sitename="Construct.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://miRoox.github.io/Construct.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/miRoox/Construct.jl",
)
