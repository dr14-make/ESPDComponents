# Engine Component Specification

## Overview

The Engine component models an internal combustion engine as a torque source with speed-dependent characteristics, rotational inertia, and throttle control.

---

## Physical Model

### Governing Equations

**Torque Production:**
```
τ_engine = throttle × τ_max(ω)
```

Where:
- `throttle` ∈ [0, 1] = throttle position
- `τ_max(ω)` = maximum torque envelope as function of speed

**Typical Torque Curve (gasoline engine):**
```
τ_max(ω) = τ_peak × f(ω/ω_rated)

f(x) = 4x(1-x)  for 0 < x < 1  (simplified parabolic)
```

**Rotational Dynamics:**
```
J_engine × α = τ_engine - τ_load - τ_friction
```

**Friction Losses:**
```
τ_friction = c₀ + c₁×ω + c₂×ω²
```

---

## Dyad Implementation (Simplified - Phase 1)

```dyad
component EngineSimple
  # Mechanical interface
  flange = RotationalComponents.Flange()
  
  # Control input
  throttle_input = BlockComponents.RealInput()  # [0, 1]
  
  # Parameters
  parameter J::Inertia = 0.15               # Engine inertia [kg⋅m²]
  parameter tau_peak::Torque = 200.0        # Peak torque [N⋅m]
  parameter omega_peak::AngularVelocity = 420.0  # Speed at peak (≈4000 rpm)
  parameter omega_max::AngularVelocity = 630.0   # Max speed (≈6000 rpm)
  parameter tau_friction::Torque = 15.0     # Friction torque [N⋅m]
  
  # Variables
  variable omega::AngularVelocity
  variable alpha::AngularAcceleration
  variable throttle::Real
  variable tau_max::Torque                  # Max available torque at current speed
  variable tau_produced::Torque             # Actual torque produced
  variable tau_net::Torque                  # Net torque to shaft
  
relations
  # Speed
  omega = der(flange.phi)
  alpha = der(omega)
  
  # Throttle
  throttle = throttle_input.u
  
  # Torque curve (parabolic approximation)
  tau_max = if omega < omega_max then
    tau_peak * 4 * (omega/omega_max) * (1 - omega/omega_max)
  else
    0.0  # Fuel cut at redline
  end
  
  # Produced torque
  tau_produced = throttle * tau_max
  
  # Net torque (with friction)
  tau_net = tau_produced - tau_friction * sign(omega)
  
  # Dynamics
  J * alpha = tau_net + flange.tau
  
end
```

---

## Test Harness

### Test 1: No-Load Speed Sweep

```dyad
test component TestEngine_NoLoad
  engine = EngineSimple(
    tau_peak = 200.0,
    omega_peak = 420.0,  # 4000 rpm
    omega_max = 630.0    # 6000 rpm
  )
  
  throttle_cmd = BlockComponents.Ramp(
    height = 1.0,
    duration = 10.0,
    offset = 0.0,
    startTime = 1.0
  )
  
  # No load - just engine inertia
  
relations
  connect(throttle_cmd.y, engine.throttle_input)
  
  initial engine.flange.phi = 0.0
  initial der(engine.flange.phi) = 10.0  # Start at idle
end
```

**Expected Results:**
- Engine accelerates as throttle increases
- Peak torque at ω = ω_peak
- Speed plateaus near ω_max at full throttle
- Friction limits final speed

### Test 2: Load Torque Characteristic

```dyad
test component TestEngine_Load
  engine = EngineSimple()
  load = RotationalComponents.Damper(d = 0.5)  # Load torque = 0.5×ω
  fixed = RotationalComponents.Fixed()
  throttle_cmd = BlockComponents.Constant(k = 0.5)  # 50% throttle
  
relations
  connect(throttle_cmd.y, engine.throttle_input)
  connect(engine.flange, load.flange_a)
  connect(load.flange_b, fixed.flange)
  
  initial engine.flange.phi = 0.0
  initial der(engine.flange.phi) = 0.0
end
```

**Expected Results:**
- Equilibrium when τ_produced = τ_load + τ_friction
- At 50% throttle and some speed ω_eq:
  - τ_produced = 0.5 × τ_max(ω_eq)
  - τ_load = 0.5 × ω_eq
  - Solve numerically for ω_eq

---

## Parameter Ranges

| Engine Type | Displacement | Peak Torque | Peak Speed | Inertia |
|-------------|--------------|-------------|------------|---------|
| Small 4-cyl | 1.0-1.6 L | 100-140 N⋅m | 3500-4500 rpm | 0.10-0.15 kg⋅m² |
| Mid 4-cyl | 1.8-2.5 L | 150-220 N⋅m | 4000-5000 rpm | 0.15-0.25 kg⋅m² |
| V6 | 2.5-3.5 L | 220-320 N⋅m | 4000-5500 rpm | 0.25-0.40 kg⋅m² |
| V8 | 4.0-6.0 L | 350-600 N⋅m | 3500-5000 rpm | 0.40-0.70 kg⋅m² |

---

## Advanced Features (Phase 4)

### Map-Based Engine
Use 2D lookup table: `τ = f(ω, throttle)`
- Read from external data file
- More accurate for specific engines
- Include fuel consumption maps

### Thermal Effects
- Coolant temperature affects performance
- Thermal inertia and heat rejection
- Integration with cooling system

### Starter Motor
- Cranking torque to start engine
- Key-on logic

---

## Validation Checklist

- [ ] Torque curve shape matches theory
- [ ] Peak torque at specified speed
- [ ] Zero torque at throttle = 0
- [ ] Friction opposes motion
- [ ] Energy balance: P_in = P_out + P_friction
- [ ] Stable operation under load

---

**Component Status:** 🔴 Not Started  
**Priority:** HIGH - Core powertrain component  
**Complexity:** Medium  
**Prerequisites:** None (standalone test possible)

---

## Reference

- Modelica: `temp/modelica/ipowertrain/Engines/BasicEngine.mo`
- Heywood, J.B. "Internal Combustion Engine Fundamentals"
