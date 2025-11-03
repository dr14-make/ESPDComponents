ENV["JULIA_PKG_SERVER"] = "juliahub.com"

using Pkg
Pkg.Registry.add()
Pkg.activate(; temp=true)

Pkg.add(name="JuliaHub", version="0.1.11")
using JuliaHub 
JuliaHub.authenticate()
dataset = JuliaHub.dataset(
    ("ashutosh-bharambe", "dyad-agent"),
)
JuliaHub.download_dataset(
    dataset, "dyad-agent.zip"
)
run(`unzip dyad-agent.zip`)
run(`./dyad-agent-distribution/setup.sh`)
# run(`rm dyad-agent.zip`)
@info "Setup `ANTHROPIC_API_KEY` inside $(pwd())/dyad-agent-distribution/.env"
@info "You can now run `cd $(pwd())/dyad-agent-distribution/` in your terminal,\nthen run `./dyad-agent`"