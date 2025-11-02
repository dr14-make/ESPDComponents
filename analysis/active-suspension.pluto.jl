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

# ╔═╡ 1d2af386-c73c-4bcd-8dcf-4c42d321d478
# ╠═╡ show_logs = false
# ╠═╡ disabled = false
# ╠═╡ show_logs = false
# ╠═╡ skip_as_script = false
  begin
      using Revise
      using ESPDComponents
  end

# ╔═╡ a35413a7-ae28-4a3f-ba81-95235b5e3c75
# ╠═╡ show_logs = false
# ╠═╡ disabled = false
# ╠═╡ show_logs = false
# ╠═╡ skip_as_script = false
#VSCODE-MARKDOWN
md""""""

# ╔═╡ a13309de-c940-4f2c-b6fd-7990a2a3d225
# ╠═╡ show_logs = false
# ╠═╡ disabled = false
# ╠═╡ show_logs = false
# ╠═╡ skip_as_script = false
  @doc ActiveSuspension

# ╔═╡ 8821bfd4-31de-4cbb-ba02-78971038fcc9
# ╠═╡ show_logs = false
# ╠═╡ disabled = false
# ╠═╡ show_logs = false
# ╠═╡ skip_as_script = false

begin
    gui_kp = @bind Kp NumberField(0.0:10000,    default=20)
    gui_onoff = @bind On CheckBox(default=false)

	gui_ti =  @bind Ti     NumberField(0.0:1000, default=5 )
    gui_td =  @bind Td     NumberField(0.0:10000, default=1)
    gui_nd = @bind Nd NumberField(0.0:10000,    default=10)
	
	s = Layout.grid([
        md" $On$:" gui_onoff  md"" md""
	 	md" $K_p$:" gui_kp  md"" md""
		md" $T_d$:" gui_td 	md" $N_d$:" gui_nd 
		md" $T_i$::" gui_ti md"" md""
	])
	md""
	
end

# ╔═╡ 4a3f2577-9fe3-4b2a-956e-d038dad0035f
# ╠═╡ show_logs = false
# ╠═╡ disabled = false
# ╠═╡ show_logs = false
# ╠═╡ skip_as_script = false
begin
result = PIDTest(Ti=Ti, Kp =Kp, Td= Td, Nd=Nd, On = On)
md""
end

# ╔═╡ 8b8dcdfe-fbe6-4670-b72a-a478e51d2c07
# ╠═╡ show_logs = false
# ╠═╡ disabled = false
# ╠═╡ show_logs = false
# ╠═╡ skip_as_script = false

  md"""
  # Select Options
  $(selector = @bind selected PlutoUI.MultiSelect(sort(ESPDComponents.get_all_signals(result))))
  """

# ╔═╡ 9ce35e2d-10ef-4652-b56c-418fae13bc51
# ╠═╡ show_logs = false
# ╠═╡ disabled = false
# ╠═╡ show_logs = false
# ╠═╡ skip_as_script = false
md"""
## Selected
[$(join(selected, ","))]"""

# ╔═╡ 59a1b955-db0f-49d5-8317-153433d03ff1
# ╠═╡ show_logs = false
# ╠═╡ disabled = false
# ╠═╡ show_logs = false
# ╠═╡ skip_as_script = false
s

# ╔═╡ b15e8fae-b559-48e1-9a3a-ab7a4bf75a31
# ╠═╡ show_logs = false
# ╠═╡ disabled = false
# ╠═╡ show_logs = false
# ╠═╡ skip_as_script = false
#VSCODE-MARKDOWN
md"""|kp_parallel|ki_parallel|kd_parallel|	
|--|--|--|
|763.1047116174678	|5432.027424912485|	714.3128082724203|	"""

# ╔═╡ 6e8aed34-f617-4158-a5f1-effeed6c6166
# ╠═╡ show_logs = false
# ╠═╡ disabled = false
# ╠═╡ show_logs = false
# ╠═╡ skip_as_script = false
md"""


$(ESPDComponents.plot_signals(result, [:seat_pos₊s,:road_data₊y,:set_point₊y]))
$(ESPDComponents.plot_signals(result, [:force₊f]))
"""

# ╔═╡ 0da737ee-7a39-42ad-8491-56ae1347f147
# ╠═╡ show_logs = false
# ╠═╡ disabled = false
# ╠═╡ show_logs = false
# ╠═╡ skip_as_script = false
plot(x, y, 
    label="label",
    title="title",
    xlabel="x",
    ylabel="y"
)

# ╔═╡ Cell order:
# ╠═b3f11681-1433-45bb-9543-4f9acab6e335
# ╠═6c383bc5-5afc-4208-b05e-a9bd86b501ac
# ╠═1d2af386-c73c-4bcd-8dcf-4c42d321d478
# ╠═a35413a7-ae28-4a3f-ba81-95235b5e3c75
# ╠═a13309de-c940-4f2c-b6fd-7990a2a3d225
# ╠═8821bfd4-31de-4cbb-ba02-78971038fcc9
# ╠═4a3f2577-9fe3-4b2a-956e-d038dad0035f
# ╠═8b8dcdfe-fbe6-4670-b72a-a478e51d2c07
# ╠═9ce35e2d-10ef-4652-b56c-418fae13bc51
# ╠═59a1b955-db0f-49d5-8317-153433d03ff1
# ╠═b15e8fae-b559-48e1-9a3a-ab7a4bf75a31
# ╠═6e8aed34-f617-4158-a5f1-effeed6c6166
# ╠═0da737ee-7a39-42ad-8491-56ae1347f147
