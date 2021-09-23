using Constructs
using Documenter

DocMeta.setdocmeta!(Constructs, :DocTestSetup, :(using Constructs); recursive=true)

makedocs(;
    modules=[Constructs],
    authors="Yong-an Lu <miroox@outlook.com>",
    repo="https://github.com/miRoox/Constructs.jl/blob/{commit}{path}#{line}",
    sitename="Constructs.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://miRoox.github.io/Constructs.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/miRoox/Constructs.jl",
)
