# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

ESPDComponents is a Julia library for modeling physical systems (thermal, mechanical, electrical) using the **Dyad modeling language**. Dyad is a domain-specific language that compiles to Julia code using ModelingToolkit.jl for symbolic equation handling and simulation.

**Critical**: The `generated/` directory contains auto-generated Julia code from Dyad source files. **Never edit files in the `generated/` directory directly** - they will be overwritten by the Dyad compiler. Always modify the `.dyad` source files in the `dyad/` directory instead.

## Architecture

### Source-to-Code Pipeline

1. **Dyad Models** (`dyad/*.dyad`) - Source of truth for component definitions
   - Written in declarative Dyad language
   - Define components with parameters, variables, and relations (equations)
   - Include metadata for tests, visualizations, and UI placement
   - Organized into subdirectories (e.g., `dyad/TestModule/`, `dyad/Lectures/`)

2. **Generated Julia Code** (`generated/*.jl`) - Auto-generated, do not edit
   - `generated/definitions.jl` - ModelingToolkit component definitions
   - `generated/experiments.jl` - Analysis/simulation definitions
   - `generated/types.jl` - Type definitions
   - `generated/tests.jl` - Test cases from Dyad metadata
   - `generated/precompilation.jl` - Precompilation directives
   - `generated/module.jl` - Entry point that includes all generated files
   - Subdirectories mirror `dyad/` structure (e.g., `generated/Lectures/`, `generated/TestModule/`)

3. **Module Entry** (`src/ESPDComponents.jl`)
   - Thin wrapper that includes `generated/module.jl`
   - The actual module logic lives in generated code

### Dyad Component Structure

A typical Dyad component includes:

- **Parameters**: Configurable inputs with types and defaults (e.g., `parameter T_inf::Temperature = 300`)
- **Variables**: State variables that evolve over time (e.g., `variable T::Temperature`)
- **Relations**: Differential equations and constraints (e.g., `m * c_p * der(T) = h * A * (T_inf - T)`)
- **Initial conditions**: Set in relations block (e.g., `initial T = T0`)
- **Metadata**: JSON-formatted test cases, placement info, visualization specs

### Analysis Definitions

Analysis blocks define simulation experiments:

```dyad
analysis World
  extends TransientAnalysis(stop = 10)
  model = Hello(T_inf = T_inf, h = h)
  parameter T_inf::Temperature = 300
  parameter h::CoefficientOfHeatTransfer = 0.7
end
```

These become callable Julia functions returning simulation results.

## Development Commands

### Initial Setup

```bash
# Start Julia REPL (in VS Code: "Julia: Start REPL" from command palette)
julia

# In Julia REPL, enter package mode
]

# Install dependencies (first time only, may take a while)
pkg> instantiate

# Exit package mode
<Backspace>
```

### Running Tests

```bash
# In Julia package mode
pkg> test

# Or from Julia REPL
julia> using Pkg; Pkg.test()
```

Tests are defined in Dyad metadata and auto-generated to `generated/tests.jl`. The test harness is in `test/runtests.jl`.

### Running Simulations

```julia
# Load the module
using ESPDComponents

# Run a simulation (analysis name becomes a function)
result = World()

# Run with custom parameters
result = World(stop=20, k=4)

# Visualize results
using Plots
plot(result)

# Plot specific analysis with parameters
plot(World(stop=20, k=4))
```

### Inspecting Results

```julia
# List available signals/artifacts
using DyadInterface
Dict(string(s) => DyadInterface.artifacts(result, s) for s in DyadInterface.artifacts(result))

# Get metadata about result
res_meta = AnalysisSolutionMetadata(result)
println(res_meta.allowed_symbols)
```

### Custom Visualizations

```julia
# Create custom Plotly visualization
vizdef = PlotlyVisualizationSpec(
    res_meta.allowed_symbols[[2, 1]],
    (;),
    [Attribute("tstart", "start time", 0.0)]
)
customizable_visualization(result, vizdef)
```

See: <https://help.juliahub.com/dyad/dev/manual/advanced/custom_analysis.html#Customizable-Visualizations>

## Key Dependencies

- **ModelingToolkit.jl**: Symbolic equation system for physical modeling
- **DyadInterface.jl**: Interface between Dyad and Julia
- **DyadExampleComponents.jl**: Pre-built components (MassSpringDamper, RoadData, etc.)
- **BlockComponents.jl**: Signal processing blocks (Gain, Add, Derivative, Integrator, etc.)
- **TranslationalComponents.jl**: Linear mechanical components (Force, PositionSensor, etc.)
- **RotationalComponents.jl**: Rotational mechanical components
- **OrdinaryDiffEqDefault.jl**: ODE solver
- **Plots.jl**: Visualization

## Workflow for Modifying Components

1. Edit the `.dyad` file in the `dyad/` directory
2. The Dyad Studio VS Code extension automatically recompiles to `generated/`
3. Reload the Julia module:

   ```julia
   # In Julia REPL
   using Pkg; Pkg.activate(".")
   using ESPDComponents
   ```

4. Run tests or simulations to verify changes

## Analysis with Pluto Notebooks

The `analysis/` directory contains Pluto.jl notebooks for interactive exploration:

- `analysis/active-suspension.pluto.jl` - ActiveSuspension model analysis

To use:

utilize pluto notebook MCP server for cell and code manipulation, for validation use `execute_code` tool, to learn how to use Pluto use `learn_pluto_basic` tool

## Common Issues

- **"Method not found" errors**: The generated code may be stale. Check that Dyad Studio has recompiled after your changes to `.dyad` files.
- **Precompilation is slow**: First-time compilation of ModelingToolkit and differential equation solvers can take several minutes.
- **Simulation is slow on first run**: Julia uses JIT compilation, so the first simulation run compiles the specific numerical code. Subsequent runs will be fast.
