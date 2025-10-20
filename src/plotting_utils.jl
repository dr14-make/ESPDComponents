import PlotlyLight

"""
    get_all_signals(result)

Extract all available signal symbols from all symbol groups in the analysis result.

Returns a `Vector{Symbol}` containing all signals from both unknowns and observables.

# Example
```julia
result = DerivativeTestAnalysis(stop=2, T=0.01)
signals = get_all_signals(result)  # [:derivative₊x, :sine₊y, :derivative₊u, :derivative₊y]
```
"""
function get_all_signals(result::DyadInterface.TransientAnalysisSolution)::Vector{Symbol}
    meta = DyadInterface.AnalysisSolutionMetadata(result)
    # Flatten all symbol groups into a single array
    all_symbols = Symbol[]
    for (group_name, symbols) in meta.symbol_groups
        append!(all_symbols, symbols)
    end
    return all_symbols
end

"""
    get_signal_data(result, signal_symbol::Symbol) -> (Vector{Float64}, Vector{Float64})

Extract time and data vectors for a specific signal from the analysis result.

Automatically determines whether the signal is an unknown or observable and extracts
from the appropriate table.

# Arguments
- `result`: The analysis solution result
- `signal_symbol::Symbol`: The signal to extract (e.g., `:derivative₊x`, `:sine₊y`)

# Returns
A tuple `(t, y)` where:
- `t::Vector{Float64}`: Time vector
- `y::Vector{Float64}`: Signal values

# Example
```julia
result = DerivativeTestAnalysis(stop=2, T=0.01)
t, y = get_signal_data(result, :sine₊y)
```
"""
function get_signal_data(result::DyadInterface.TransientAnalysisSolution,
    signal_symbol::Symbol)::Tuple{Vector{Float64},Vector{Float64}}
    meta = DyadInterface.AnalysisSolutionMetadata(result)

    # Check if signal is in unknowns or observables
    if signal_symbol in meta.symbol_groups[:unknowns]
        df = DyadInterface.artifacts(result, :SimulationSolutionTable)
        signal_name = string(signal_symbol) * "(t)"
        return df.timestamp, df[!, signal_name]
    elseif signal_symbol in meta.symbol_groups[:observables]
        df = DyadInterface.artifacts(result, :ObservablesTable)
        signal_name = string(signal_symbol)
        return df.t, df[!, signal_name]
    else
        error("Signal $signal_symbol not found in symbol_groups")
    end
end

"""
    plot_signals(result, signals::Vector{Symbol}; title="Analysis Results",
                 xaxis_title="Time (s)", yaxis_title="Value")

Plot multiple signals from an analysis result on the same plot with time on the x-axis.

All signals are overlaid on a single plot, sharing the same time axis. This allows
easy comparison of multiple signals from the simulation.

# Arguments
- `result`: The analysis solution result
- `signals::Vector{Symbol}`: Array of signal symbols to plot (e.g., `[:derivative₊x, :sine₊y]`)
  All signals will be plotted on the same axes with time on the x-axis.
- `title::String`: Plot title (default: "Analysis Results")
- `xaxis_title::String`: X-axis label (default: "Time (s)")
- `yaxis_title::String`: Y-axis label (default: "Value")

# Returns
A `PlotlyLight.Plot` object with all signals overlaid on the same plot

# Example
```julia
using PlotlyLight
result = DerivativeTestAnalysis(stop=2, T=0.01)

# Plot all signals together
all_signals = get_all_signals(result)
plot_signals(result, all_signals)

# Plot specific signals on the same plot
plot_signals(result, [:sine₊y, :derivative₊y], title="Observables Comparison")
```
"""
function plot_signals(result::DyadInterface.TransientAnalysisSolution,
    signals::Vector{Symbol};
    title::String="Analysis Results",
    xaxis_title::String="Time (s)",
    yaxis_title::String="Value")
    if isempty(signals)
        return "No signals selected. Please provide a non-empty array of signal symbols."
    end

    # Create traces for each signal
    traces = [
        PlotlyLight.Config(
            x=get_signal_data(result, sig)[1],
            y=get_signal_data(result, sig)[2],
            type="scatter",
            mode="lines",
            name=string(sig)
        ) for sig in signals
    ]

    # Create and return the plot
    return PlotlyLight.Plot(
        traces,
        PlotlyLight.Config(
            layout=(
                title=title,
                xaxis_title=xaxis_title,
                yaxis_title=yaxis_title
            )
        )
    )
end
