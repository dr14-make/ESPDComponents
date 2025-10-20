module ESPDComponents

include("../generated/module.jl")

# Plotting utilities
include("plotting_utils.jl")
export get_all_signals, get_signal_data, plot_signals

end # module ESPDComponents