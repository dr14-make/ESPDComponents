### A Pluto.jl notebook ###
# v0.20.10

using Markdown
using InteractiveUtils

# ╔═╡ 85426ea1-758a-438e-a3cc-3b52249d0072
# ╠═╡ show_logs = false
# ╠═╡ disabled = false
# ╠═╡ show_logs = false
# ╠═╡ skip_as_script = false
begin
    using Pkg
    # Read and activate the project environment
    Pkg.activate(".")
    Pkg.instantiate()
end

# ╔═╡ 461b570b-6712-4942-9d0f-bc2011e4756f
# ╠═╡ show_logs = false
# ╠═╡ disabled = false
# ╠═╡ show_logs = false
# ╠═╡ skip_as_script = false
module m
include("/home/dr14/Projects/CVUT/ESPDComponents/src/ESPDComponents.jl")
end

# ╔═╡ 1b2ce5df-3681-47f7-8d07-6d6d605045d7
# ╠═╡ show_logs = false
# ╠═╡ disabled = false
# ╠═╡ show_logs = false
# ╠═╡ skip_as_script = false
@doc m.ESPDComponents.ActiveSuspension

# ╔═╡ Cell order:
# ╠═85426ea1-758a-438e-a3cc-3b52249d0072
# ╠═461b570b-6712-4942-9d0f-bc2011e4756f
# ╠═1b2ce5df-3681-47f7-8d07-6d6d605045d7
