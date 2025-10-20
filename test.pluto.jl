### A Pluto.jl notebook ###
# v0.20.10

using Markdown
using InteractiveUtils

# ╔═╡ 7c56a60f-1403-4ffa-90aa-55e87cb4ba5d
# ╠═╡ show_logs = false
# ╠═╡ disabled = false
# ╠═╡ show_logs = false
# ╠═╡ skip_as_script = false
begin
    using Pkg
    Pkg.activate(temp=true)
    Pkg.add("Revise")
    Pkg.add("DyadInterface")
    Pkg.add("PlutoUI")
    Pkg.add("PlutoLinks")
    Pkg.develop(path="/home/dr14/Projects/CVUT/ESPDComponents")

end

# ╔═╡ 85426ea1-758a-438e-a3cc-3b52249d0072
# ╠═╡ show_logs = false
# ╠═╡ disabled = false
# ╠═╡ show_logs = false
# ╠═╡ skip_as_script = false
   begin 
    using PlutoLinks
    using ModelingToolkit
import Markdown
using ModelingToolkit: t_nounits as t
using OrdinaryDiffEqDefault
using RuntimeGeneratedFunctions


import BlockComponents
import DyadExampleComponents
import DyadInterface
import RotationalComponents
import TranslationalComponents
   end

# ╔═╡ 461b570b-6712-4942-9d0f-bc2011e4756f
# ╠═╡ show_logs = false
# ╠═╡ disabled = false
# ╠═╡ show_logs = false
# ╠═╡ skip_as_script = false
begin
 M = PlutoLinks.@ingredients("/home/dr14/Projects/CVUT/ESPDComponents/src/ESPDComponents.jl")
end

# ╔═╡ 1b2ce5df-3681-47f7-8d07-6d6d605045d7
# ╠═╡ show_logs = false
# ╠═╡ disabled = false
# ╠═╡ show_logs = false
# ╠═╡ skip_as_script = false
@doc M.ActiveSuspension

# ╔═╡ Cell order:
# ╠═7c56a60f-1403-4ffa-90aa-55e87cb4ba5d
# ╠═85426ea1-758a-438e-a3cc-3b52249d0072
# ╠═461b570b-6712-4942-9d0f-bc2011e4756f
# ╠═1b2ce5df-3681-47f7-8d07-6d6d605045d7
