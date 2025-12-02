# ...existing code...
try
  using CSV, DataFrames, Plots
catch
  import Pkg
  Pkg.add.(["CSV","DataFrames","Plots"])
  using CSV, DataFrames, Plots
end

function simulate_aero(; dt::Float64 = 0.02, t_stop::Float64 = 60.0, F_thrust::Float64 = 1000.0)
  # Parameters (match TestVehicleBody_AeroDrag)
  m = 1500.0
  Cd = 0.32
  A = 2.2
  rho = 1.225
  Crr = 0.0
  g = 9.81
  theta = 0.0
  v_eps = 1e-6

  nsteps = Int(round(t_stop/dt)) + 1

  times = Vector{Float64}(undef, nsteps)
  vel = Vector{Float64}(undef, nsteps)
  acc = Vector{Float64}(undef, nsteps)
  F_drag = Vector{Float64}(undef, nsteps)
  v_terminal = sqrt(2.0 * F_thrust / (rho * Cd * A))

  local v = 0.0
  local s = 0.0
  local idx = 1

  for k in 0:nsteps-1
    t = k * dt
    Fd = 0.5 * rho * Cd * A * v * abs(v)
    Frr_front = 0.0
    Frr_rear = 0.0
    Fgrade = m * g * sin(theta)
    a = (F_thrust - Fd - Frr_front - Frr_rear - Fgrade) / m

    times[idx] = t
    vel[idx] = v
    acc[idx] = a
    F_drag[idx] = Fd

    v = max(0.0, v + a * dt)
    s += v * dt

    idx += 1
  end

  results_dir = joinpath(@__DIR__,"..","results")
  mkpath(results_dir)
  csv_path = joinpath(results_dir, "TestVehicleBody_AeroDrag.csv")
  df = DataFrame(time=times, v=vel, a=acc, F_drag=F_drag, v_terminal=fill(v_terminal, length(times)))
  CSV.write(csv_path, df)
  println("Saved CSV: ", csv_path)

  plt = plot(times, vel, label="v (m/s)", xlabel="time (s)", ylabel="velocity (m/s)", title="TestVehicleBody_AeroDrag")
  hline!([v_terminal], color=:red, linestyle=:dash, label="v_terminal")
  outpng = joinpath(results_dir, "TestVehicleBody_AeroDrag.png")
  savefig(plt, outpng)
  println("Saved plot: ", outpng)

  println("Final v = $(round(vel[end], digits=3)) m/s, analytic v_terminal = $(round(v_terminal, digits=3)) m/s")
end

# run with default settings
simulate_aero()
# ...existing code...