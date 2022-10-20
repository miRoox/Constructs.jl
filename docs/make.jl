using Constructs
using Documenter
using JSON

DocMeta.setdocmeta!(Constructs, :DocTestSetup, :(using Constructs); recursive=true)

# check if there is "push_preview" label
# see https://github.com/JuliaDocs/Documenter.jl/issues/1225#issuecomment-578604184
function should_push_preview(event_path = get(ENV, "GITHUB_EVENT_PATH", nothing))
    event_path === nothing && return false
    event = JSON.parsefile(event_path)
    labels = [x["name"] for x in event["pull_request"]["labels"]]
    return "push_preview" in labels
end

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
        "References" => "reference.md",
    ],
)

deploydocs(;
    repo="github.com/miRoox/Constructs.jl",
    push_preview = should_push_preview(),
)
