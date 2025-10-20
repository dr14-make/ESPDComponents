### A Pluto.jl notebook ###
# v0.19.40

using Markdown
using InteractiveUtils

# ╔═╡ b3f11681-1433-45bb-9543-4f9acab6e335
# ╠═╡ disabled = false
# ╠═╡ show_logs = true
# ╠═╡ skip_as_script = false
#VSCODE-MARKDOWN
md"""
# Pluto Notebook Demo
This is an example Pluto notebook demonstrating various features.
"""

# ╔═╡ 6c383bc5-5afc-4208-b05e-a9bd86b501ac
# ╠═╡ show_logs = false
# ╠═╡ disabled = false
# ╠═╡ show_logs = false
# ╠═╡ skip_as_script = false
begin
    import Pkg
    projectPath = "/home/dr14/Projects/CVUT/ESPDComponents"
    Pkg.activate(temp=true)
    Pkg.develop(path=projectPath)
    Pkg.instantiate() 
    Pkg.add("DyadInterface")
    using DyadInterface
    Pkg.add("PlutoUI")
end

# ╔═╡ Cell order:
# ╠═b3f11681-1433-45bb-9543-4f9acab6e335
# ╠═6c383bc5-5afc-4208-b05e-a9bd86b501ac
