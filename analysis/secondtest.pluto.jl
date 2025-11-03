### A Pluto.jl notebook ###
# v0.20.10

using Markdown
using InteractiveUtils

# ╔═╡ 2bc53bfd-d283-42d3-ac98-b78905fb7d44
# ╠═╡ show_logs = false
# ╠═╡ disabled = false
# ╠═╡ show_logs = false
# ╠═╡ skip_as_script = false
begin
    import Pkg
    projectPath = "/home/dr14/Projects/CVUT/ESPDComponents"
    Pkg.activate(temp=true)
    Pkg.add("DyadInterface")
    Pkg.add("PlutoUI")
    Pkg.add("Plots")
    Pkg.develop(path=projectPath)
    using DyadInterface
    using Plots
    using PlutoUI
    const Layout=PlutoUI.ExperimentalLayout;
end

# ╔═╡ a11a86b6-7afa-436b-a3ec-f0793f3cbe12
# ╠═╡ show_logs = false
# ╠═╡ disabled = false
# ╠═╡ show_logs = false
# ╠═╡ skip_as_script = false
  begin
      using ESPDComponents
  end

# ╔═╡ 11a4fde2-b749-401f-a60a-a9d19b80efc1
# ╠═╡ show_logs = false
# ╠═╡ disabled = false
# ╠═╡ show_logs = false
# ╠═╡ skip_as_script = false
result = World()

# ╔═╡ 64a825eb-03a5-4aed-af70-00815f674cb6
# ╠═╡ show_logs = false
# ╠═╡ disabled = false
# ╠═╡ show_logs = false
# ╠═╡ skip_as_script = false
begin 
    plot(result)
end

# ╔═╡ Cell order:
# ╠═2bc53bfd-d283-42d3-ac98-b78905fb7d44
# ╠═a11a86b6-7afa-436b-a3ec-f0793f3cbe12
# ╠═11a4fde2-b749-401f-a60a-a9d19b80efc1
# ╠═64a825eb-03a5-4aed-af70-00815f674cb6
