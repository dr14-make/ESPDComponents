### A Pluto.jl notebook ###
# v0.20.10

using Markdown
using InteractiveUtils

# ╔═╡ 3b3d54c7-1c0c-4e00-b496-e5a593044540
# ╠═╡ show_logs = false
# ╠═╡ disabled = false
# ╠═╡ show_logs = false
# ╠═╡ skip_as_script = false
begin
    import Pkg
    projectPath = "/home/dr14/Projects/CVUT/ESPDComponents"
    Pkg.activate(temp=true)
    Pkg.add("Revise")
    Pkg.add("DyadInterface")
    Pkg.add("PlutoUI")
    Pkg.develop(path=projectPath)
    using DyadInterface
    using PlotlyLight
    using PlutoUI
    preset.template.plotly_dark!()  # Change template
    const Layout=PlutoUI.ExperimentalLayout;
end

# ╔═╡ 05d0065a-b435-48f3-bca7-4e03bf46e90f
# ╠═╡ show_logs = false
# ╠═╡ disabled = false
# ╠═╡ show_logs = false
# ╠═╡ skip_as_script = false
  begin
      using Revise
      using ESPDComponents
  end

# ╔═╡ 9a52a195-27d3-4538-ada8-8420e1fa1a51
# ╠═╡ show_logs = false
# ╠═╡ disabled = false
# ╠═╡ show_logs = false
# ╠═╡ skip_as_script = false
@doc SimpleCar

# ╔═╡ 4bbe91b1-ea40-4303-a2ed-d4fb53edb378
# ╠═╡ show_logs = false
# ╠═╡ disabled = false
# ╠═╡ show_logs = false
# ╠═╡ skip_as_script = false
begin
result = SimpleCarTest(stop=50)
end

# ╔═╡ Cell order:
# ╠═3b3d54c7-1c0c-4e00-b496-e5a593044540
# ╠═05d0065a-b435-48f3-bca7-4e03bf46e90f
# ╠═9a52a195-27d3-4538-ada8-8420e1fa1a51
# ╠═4bbe91b1-ea40-4303-a2ed-d4fb53edb378
