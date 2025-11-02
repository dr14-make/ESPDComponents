# Gearbox Component Specification

## Overview

The Gearbox component models a multi-ratio transmission with discrete gear ratios, mechanical efficiency losses, and smooth gear shifting transitions.

---

## Physical Model

### Kinematic Relationships

**Gear Ratio:**
```
ω_out = ω_in / ratio[gear]
```

**Torque Multiplication:**
```
τ_out = -τ_in × ratio[gear] × η
```

Where:
- `ratio[gear]` = speed ratio for selected gear
  - Example: [3.5, 2.0, 1.3, 1.0, 0.8] for 5-speed
  - 1st gear: highest ratio (low speed, high torque)
  - 5th gear: lowest ratio (high speed, low torque, overdrive)
- `η` = mechanical efficiency (typical: 0.95-0.98)

**Efficiency Direction Dependence:**
```
Forward power flow (engine driving):
  τ_out = -τ_in × ratio × η

Reverse power flow (engine braking):
  τ_out = -τ_in × ratio / η
```

---

## Dyad Implementation (Simplified - Phase 1)

```dyad
component GearboxSimple
  # Mechanical interfaces
  flange_in = RotationalComponents.Flange()    # Input (from engine/clutch)
  flange_out = RotationalComponents.Flange()   # Output (to driveline)
  
  # Control input
  gear_cmd = BlockComponents.IntegerInput()    # Gear number: 1, 2, 3, ...
  
  # Parameters
  parameter ratios::Vector{Real} = [3.5, 2.0, 1.3, 1.0, 0.8]  # Gear ratios
  parameter efficiencies::Vector{Real} = [0.96, 0.97, 0.97, 0.97, 0.97]
  parameter J_in::Inertia = 0.05               # Input shaft inertia [kg⋅m²]
  parameter tau_loss::Torque = 5.0             # Constant loss torque [N⋅m]
  
  # Variables
  variable gear::Integer                        # Current gear number
  variable ratio::Real                          # Current ratio
  variable eta::Real                            # Current efficiency
  variable omega_in::AngularVelocity
  variable omega_out::AngularVelocity
  variable tau_in::Torque
  variable tau_out::Torque
  variable tau_loss_actual::Torque
  
relations
  # Gear selection
  gear = gear_cmd.u
  
  # Lookup ratio and efficiency (with bounds checking)
  ratio = if 1 <= gear <= length(ratios) then ratios[gear] else ratios[1]
  eta = if 1 <= gear <= length(efficiencies) then efficiencies[gear] else efficiencies[1]
  
  # Speeds
  omega_in = der(flange_in.phi)
  omega_out = der(flange_out.phi)
  
  # Kinematic constraint
  omega_out = omega_in / ratio
  
  # Torques
  tau_in = flange_in.tau
  tau_out = flange_out.tau
  
  # Loss torque (opposes motion)
  tau_loss_actual = tau_loss * sign(omega_in)
  
  # Torque balance with efficiency
  tau_out = -(tau_in - tau_loss_actual) * ratio * eta
  
  # Input inertia dynamics (optional)
  J_in * der(omega_in) = tau_in - tau_loss_actual - (-tau_out / (ratio * eta))
  
end
```

**Note:** Smooth gear shifting (non-integer gear values) is Phase 4 feature.

---

## Test Harness

### Test 1: Fixed Gear Ratio Verification

```dyad
test component TestGearbox_FixedGear
  gearbox = GearboxSimple(
    ratios = [3.0, 2.0, 1.5, 1.0, 0.75],
    efficiencies = [0.95, 0.96, 0.97, 0.97, 0.97],
    tau_loss = 5.0
  )
  
  # Fixed gear 3 (ratio = 1.5)
  gear_select = BlockComponents.IntegerConstant(k = 3)
  
  # Input: constant speed
  speed_source = RotationalComponents.Speed()
  speed_cmd = BlockComponents.Constant(k = 100.0)  # 100 rad/s
  
  # Output: load
  load = RotationalComponents.Inertia(J = 2.0)
  
relations
  connect(gear_select.y, gearbox.gear_cmd)
  connect(speed_cmd.y, speed_source.w)
  connect(speed_source.flange, gearbox.flange_in)
  connect(gearbox.flange_out, load.flange)
  
  initial load.phi = 0.0
  initial der(load.phi) = 0.0
end
```

**Expected Results:**
- Gear 3: ratio = 1.5, η = 0.97
- Input speed: ω_in = 100 rad/s
- Output speed: ω_out = 100/1.5 = 66.67 rad/s
- At equilibrium (zero acceleration):
  - τ_in ≈ τ_loss / (1 - ratio×η) (complex, verify numerically)

**Validation:**
```julia
@assert gearbox.gear == 3
@assert abs(gearbox.ratio - 1.5) < 1e-6
@assert abs(sol(5.0, idxs=sys.gearbox.omega_out) - 66.67) < 0.5
```

### Test 2: Gear Shift Sequence

```dyad
test component TestGearbox_Shifting
  gearbox = GearboxSimple(
    ratios = [3.5, 2.0, 1.3, 1.0],
    efficiencies = [0.96, 0.97, 0.97, 0.97]
  )
  
  # Gear sequence: 1 → 2 → 3 → 4
  gear_select = BlockComponents.IntegerStep([
    (time = 0.0, value = 1),
    (time = 2.0, value = 2),
    (time = 4.0, value = 3),
    (time = 6.0, value = 4)
  ])
  
  # Constant input torque
  torque_source = RotationalComponents.TorqueSource()
  torque_cmd = BlockComponents.Constant(k = 100.0)
  
  # Load
  load = RotationalComponents.Damper(d = 0.2)
  fixed = RotationalComponents.Fixed()
  
relations
  connect(gear_select.y, gearbox.gear_cmd)
  connect(torque_cmd.y, torque_source.tau)
  connect(torque_source.flange, gearbox.flange_in)
  connect(gearbox.flange_out, load.flange_a)
  connect(load.flange_b, fixed.flange)
  
  initial gearbox.flange_in.phi = 0.0
  initial der(gearbox.flange_in.phi) = 0.0
end
```

**Expected Results:**
- Each gear produces different output torque
- Gear 1 (ratio=3.5): τ_out ≈ 100×3.5×0.96 = 336 N⋅m
- Gear 4 (ratio=1.0): τ_out ≈ 100×1.0×0.97 = 97 N⋅m
- Output speed increases with higher gears (lower ratio)
- **Note:** Discrete shifts cause discontinuities (Phase 4: add smooth shifting)

---

## Parameter Ranges

### Typical Gear Ratios

**Manual Transmission (5-speed):**
```
1st: 3.5-4.5
2nd: 2.0-2.5
3rd: 1.3-1.7
4th: 1.0-1.2
5th: 0.7-0.9 (overdrive)
```

**Automatic Transmission (6-speed):**
```
1st: 4.0-5.0
2nd: 2.5-3.0
3rd: 1.5-2.0
4th: 1.0-1.5
5th: 0.8-1.0
6th: 0.6-0.8 (overdrive)
```

**Performance (close-ratio):**
- Smaller steps between gears (1.2-1.4× ratio change)
- Keeps engine in power band

**Economy (wide-ratio):**
- Larger steps (1.5-2.0× ratio change)
- Optimizes fuel efficiency

### Efficiency Values
- Manual transmission: η = 0.94-0.97
- Automatic (torque converter): η = 0.85-0.92
- Dual-clutch (DCT): η = 0.95-0.98
- CVT: η = 0.85-0.90

---

## Advanced Features (Phase 4)

### Smooth Gear Shifting
Interpolate ratio during shifts:
```
gear_actual = gear_cmd + shift_rate × dt
ratio = interpolate(ratios, gear_actual)
```
Prevents discontinuities, models synchronizer action.

### Shift Dynamics
Add shift time delay and torque interruption:
```
if shifting:
  tau_out = 0  # Torque interruption
  t_shift = 0.1-0.3 s  # Shift duration
```

### Neutral Gear
```
if gear == 0:
  flange_in and flange_out decoupled
  tau_out = 0
```

### Reverse Gear
Negative ratio: `ratio_reverse = -3.5`

---

## Validation Checklist

- [ ] Speed ratio: ω_out/ω_in = 1/ratio (error < 1%)
- [ ] Torque multiplication: τ_out = τ_in × ratio × η
- [ ] Power with losses: P_out = P_in × η - P_loss
- [ ] All gears selectable (1 to N)
- [ ] Efficiency < 1.0 (no energy creation)
- [ ] Higher gear → lower ratio → higher speed

---

## Common Issues

### Issue 1: Discontinuous Shifts
**Problem:** Instantaneous ratio change causes solver issues
**Solution:** 
- Phase 1: Accept small discontinuity, use stiff solver
- Phase 4: Implement smooth shifting with time constant

### Issue 2: Efficiency Direction
**Problem:** Efficiency should degrade in both directions
**Solution:** Check power flow direction, apply η correctly

### Issue 3: Invalid Gear Selection
**Problem:** gear_cmd outside valid range
**Solution:** Bounds checking with default to gear 1

---

**Component Status:** 🔴 Not Started  
**Priority:** HIGH  
**Complexity:** Medium-High (discrete states, efficiency)  
**Prerequisites:** None (can test standalone)

---

## Reference

- Modelica: `temp/modelica/ipowertrain/Gearsets/TransmissionGearbox.mo`
- Naunheimer, H. "Automotive Transmissions"
- SAE J2926: Transmission Efficiency Measurement
