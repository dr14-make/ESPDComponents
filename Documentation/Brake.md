# Brake Component Specification

## Overview

The Brake component models friction braking by applying a torque that opposes rotation, controlled by a brake signal (0-1).

---

## Physical Model

### Governing Equations

**Brake Torque:**
```
τ_brake = brake_signal × τ_max × sign(ω)
```

Where:
- `brake_signal` ∈ [0, 1] = brake pedal position (0=released, 1=full)
- `τ_max` = maximum brake torque [N⋅m]
- `ω` = angular velocity [rad/s]
- `sign(ω)` = ensures torque opposes rotation

**Power Dissipation:**
```
P_brake = τ_brake × ω
```
All power converted to heat (not modeled in Phase 1).

---

## Dyad Implementation

```dyad
component Brake
  # Rotational interfaces
  flange_a = RotationalComponents.Flange()  # Input (from driveline)
  flange_b = RotationalComponents.Flange()  # Output (to wheel)
  
  # Control input
  brake_input = BlockComponents.RealInput()  # Brake signal [0, 1]
  
  # Parameters
  parameter tau_max::Torque = 2000.0        # Maximum brake torque [N⋅m]
  parameter omega_cutoff::AngularVelocity = 0.1  # Smooth sign cutoff [rad/s]
  
  # Variables
  variable omega::AngularVelocity           # Shaft speed
  variable tau_brake::Torque                # Applied brake torque
  variable brake_signal::Real               # Brake command [0, 1]
  variable P_dissipated::Power              # Dissipated power
  
relations
  # Get brake command
  brake_signal = brake_input.u
  
  # Compute speed (same on both sides - rigid connection)
  omega = der(flange_a.phi)
  flange_a.phi = flange_b.phi
  
  # Brake torque with smooth sign
  tau_brake = brake_signal * tau_max * tanh(omega / omega_cutoff)
  
  # Torque balance
  flange_a.tau + tau_brake + flange_b.tau = 0
  
  # Power dissipation
  P_dissipated = tau_brake * omega
  
end
```

---

## Test Harness

### Test: Spinning Wheel Brake Application

```dyad
test component TestBrake
  brake = Brake(tau_max = 1000.0)
  inertia = RotationalComponents.Inertia(J = 2.0)
  brake_cmd = BlockComponents.Step(
    height = 1.0,          # Full brake
    offset = 0.0,
    startTime = 2.0        # Apply at t=2s
  )
  fixed = RotationalComponents.Fixed()
  
relations
  connect(brake_cmd.y, brake.brake_input)
  connect(inertia.flange_a, brake.flange_a)
  connect(brake.flange_b, fixed.flange)
  
  # Start spinning
  initial inertia.flange_a.phi = 0.0
  initial der(inertia.flange_a.phi) = 50.0  # 50 rad/s
end

analysis TestBrake_Analysis
  extends TransientAnalysis(stop = 10.0, alg = "Rodas5P")
  model = TestBrake()
end
```

**Expected Results:**
- 0 < t < 2s: Free spinning at ω = 50 rad/s
- t = 2s: Brake applied, deceleration begins
- Deceleration: α = -τ_brake/J = -1000/2 = -500 rad/s²
- Stop time: t_stop = 2 + ω₀/|α| = 2 + 50/500 = 2.1 s
- Total energy dissipated: E = ½Jω² = 0.5×2×50² = 2500 J

**Validation:**
```julia
@assert sol(2.01, idxs=sys.brake.tau_brake) ≈ 1000.0
@assert sol(2.01, idxs=sys.inertia.alpha) ≈ -500.0
@assert abs(sol(2.1, idxs=sys.inertia.omega)) < 0.5
```

---

## Parameter Ranges

| Vehicle Type | Max Brake Torque (per wheel) |
|--------------|------------------------------|
| Small Car | 1000-1500 N⋅m |
| Sedan | 1500-2500 N⋅m |
| SUV/Truck | 2500-4000 N⋅m |
| Performance | 3000-6000 N⋅m |

---

## Validation Checklist

- [ ] Torque opposes rotation direction
- [ ] Zero brake signal → zero torque
- [ ] Full brake → τ = τ_max
- [ ] Power always positive (dissipative)
- [ ] Smooth behavior near ω = 0

---

**Component Status:** 🔴 Not Started  
**Priority:** MEDIUM  
**Complexity:** Low  
**Prerequisites:** None
