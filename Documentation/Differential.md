# Differential Component Specification

## Overview

The Differential component splits input torque equally between two output shafts (left/right wheels) while allowing speed differences (differential action). Includes final drive ratio.

---

## Physical Model

### Kinematic Constraints

**Open Differential (Equal Torque Split):**
```
ω_input = (ω_left + ω_right)/2 × ratio

τ_left = τ_right = -τ_input × ratio/2
```

Where:
- `ω_input` = input shaft (propshaft) speed [rad/s]
- `ω_left, ω_right` = output shaft (axle) speeds [rad/s]
- `ratio` = final drive ratio (typical: 3.0-5.0)
- `τ_input` = input torque [N⋅m]
- `τ_left, τ_right` = output torques [N⋅m]

**Power Conservation:**
```
P_in = P_out
τ_input × ω_input = τ_left × ω_left + τ_right × ω_right
```

### Differential Action Example
- Straight line: ω_left = ω_right = ω_input/ratio
- Turning: ω_left ≠ ω_right, but average maintained
- One wheel lifted: ω_lifted = 2×ω_input/ratio, ω_ground = 0

---

## Dyad Implementation

```dyad
component Differential
  # Mechanical interfaces
  flange_input = RotationalComponents.Flange()     # Propshaft input
  flange_left = RotationalComponents.Flange()      # Left axle output
  flange_right = RotationalComponents.Flange()     # Right axle output
  
  # Parameters
  parameter ratio::Real = 3.5               # Final drive ratio [-]
  
  # Variables
  variable omega_in::AngularVelocity        # Input speed
  variable omega_left::AngularVelocity      # Left output speed
  variable omega_right::AngularVelocity     # Right output speed
  variable tau_in::Torque                   # Input torque
  variable tau_left::Torque                 # Left output torque
  variable tau_right::Torque                # Right output torque
  
relations
  # Extract speeds
  omega_in = der(flange_input.phi)
  omega_left = der(flange_left.phi)
  omega_right = der(flange_right.phi)
  
  # Kinematic constraint (speed averaging)
  omega_in = (omega_left + omega_right) / 2 * ratio
  
  # Extract torques
  tau_in = flange_input.tau
  tau_left = flange_left.tau
  tau_right = flange_right.tau
  
  # Torque split (equal distribution)
  tau_left = -tau_in * ratio / 2
  tau_right = -tau_in * ratio / 2
  
end
```

---

## Test Harness

### Test 1: Symmetric Load (Straight Line)

```dyad
test component TestDifferential_Symmetric
  diff = Differential(ratio = 3.5)
  
  # Input torque
  input_torque = RotationalComponents.TorqueSource()
  torque_cmd = BlockComponents.Constant(k = 200.0)  # 200 N⋅m
  
  # Symmetric loads (both wheels same)
  load_left = RotationalComponents.Inertia(J = 1.0)
  load_right = RotationalComponents.Inertia(J = 1.0)
  
relations
  connect(torque_cmd.y, input_torque.tau)
  connect(input_torque.flange, diff.flange_input)
  connect(diff.flange_left, load_left.flange)
  connect(diff.flange_right, load_right.flange)
  
  initial diff.flange_input.phi = 0.0
  initial der(diff.flange_input.phi) = 0.0
  initial load_left.phi = 0.0
  initial der(load_left.phi) = 0.0
  initial load_right.phi = 0.0
  initial der(load_right.phi) = 0.0
end
```

**Expected Results:**
- Torque split: τ_left = τ_right = 200×3.5/2 = 350 N⋅m
- Symmetric acceleration: α_left = α_right = 350/1.0 = 350 rad/s²
- Input speed: ω_in = (ω_left + ω_right)/2 × 3.5 = ω_left × 3.5
- Speed ratio verified: ω_out/ω_in = 1/3.5

**Validation:**
```julia
@assert abs(sol(0.1, idxs=sys.diff.tau_left) - 350.0) < 1.0
@assert abs(sol(0.1, idxs=sys.diff.tau_right) - 350.0) < 1.0
@assert abs(sol(1.0, idxs=sys.load_left.omega) - sol(1.0, idxs=sys.load_right.omega)) < 0.1
@assert abs(sol(1.0, idxs=sys.diff.omega_in) * 3.5 - sol(1.0, idxs=sys.load_left.omega)) < 1.0
```

### Test 2: Asymmetric Load (Cornering Simulation)

```dyad
test component TestDifferential_Asymmetric
  diff = Differential(ratio = 3.5)
  
  input_torque = RotationalComponents.TorqueSource()
  torque_cmd = BlockComponents.Constant(k = 200.0)
  
  # Different loads (inside wheel lighter load in turn)
  load_left = RotationalComponents.Damper(d = 0.5)   # Outside wheel
  load_right = RotationalComponents.Damper(d = 0.3)  # Inside wheel
  fixed = RotationalComponents.Fixed()
  
relations
  connect(torque_cmd.y, input_torque.tau)
  connect(input_torque.flange, diff.flange_input)
  connect(diff.flange_left, load_left.flange_a)
  connect(diff.flange_right, load_right.flange_a)
  connect(load_left.flange_b, fixed.flange)
  connect(load_right.flange_b, fixed.flange)
  
  initial diff.flange_input.phi = 0.0
  initial der(diff.flange_input.phi) = 0.0
end
```

**Expected Results:**
- Equal torque: τ_left = τ_right = 350 N⋅m (open diff characteristic)
- Different speeds: ω_right > ω_left (less damping → faster)
- At equilibrium: d_left×ω_left = d_right×ω_right = 350 N⋅m
  - ω_left = 350/0.5 = 700 rad/s
  - ω_right = 350/0.3 = 1167 rad/s
- Input speed: ω_in = (700+1167)/2 × 3.5 ≈ 327 rad/s

---

## Parameter Ranges

| Vehicle Type | Final Drive Ratio |
|--------------|-------------------|
| Sports Car | 3.0-4.0 |
| Sedan (FWD) | 3.5-4.5 |
| Sedan (RWD) | 3.0-4.0 |
| Truck/SUV | 3.5-5.5 |
| Performance | 2.5-3.5 |

Higher ratio = better acceleration, lower top speed
Lower ratio = lower acceleration, higher top speed

---

## Advanced Topics (Phase 4)

### Limited-Slip Differential (LSD)
Add torque bias when speed difference exceeds threshold:
```
Δτ = k_LSD × (ω_left - ω_right)
τ_left = τ_base + Δτ
τ_right = τ_base - Δτ
```

### Torque Vectoring
Active control of left/right torque split for handling.

### Efficiency Losses
Add friction/gear losses:
```
η = 0.95-0.98 (typical)
P_out = η × P_in
```

---

## Validation Checklist

- [ ] Speed averaging: ω_in = (ω_L + ω_R)/2 × ratio (error < 0.1%)
- [ ] Equal torque split: τ_L = τ_R (error < 1%)
- [ ] Gear ratio: ω_out/ω_in = 1/ratio
- [ ] Power balance: P_in = P_out (ideal case)
- [ ] Differential action: works with ω_L ≠ ω_R

---

**Component Status:** 🔴 Not Started  
**Priority:** HIGH  
**Complexity:** Medium (kinematic constraints)  
**Prerequisites:** None

---

## Reference

- Modelica: `temp/modelica/ipowertrain/Gearsets/BasicDifferential.mo`
- Wong, J.Y. "Theory of Ground Vehicles" Chapter 4: Differentials
