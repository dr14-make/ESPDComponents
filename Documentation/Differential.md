# Differential Component Specification

## Overview

The Differential component splits input torque equally between two output shafts (left/right wheels) while allowing speed differences (differential action). Includes final drive ratio.

---

## Physical Model

### Your Task

Model an open differential that:
- Has one input shaft (from transmission/propshaft)
- Has two output shafts (to left and right wheels)
- Splits torque equally between outputs
- Allows outputs to rotate at different speeds (enables turning)
- Includes a final drive gear ratio
- Maintains kinematic relationship between input and output speeds

### Key Physical Phenomena

1. **Torque Distribution:**
   - Input torque is split equally to left and right outputs
   - Gear ratio amplifies torque at outputs
   - Equal torque split regardless of speed difference

2. **Speed Averaging:**
   - Input speed is related to average of output speeds
   - Final drive ratio relates input speed to output speed
   - During straight line motion: both outputs same speed
   - During turning: speeds differ but average is maintained

3. **Differential Action:**
   - **Straight line:** Both wheels turn at same speed
   - **Cornering:** Outer wheel faster than inner wheel
   - **One wheel lifted:** Lifted wheel spins at double speed, grounded wheel stops

4. **Power Conservation:**
   - Power in = Power out (ideal differential, no losses)
   - Input power = sum of left and right output powers

### Simplifications for Phase 1
- **Open differential:** Equal torque split (no limited-slip or locking)
- **No efficiency losses:** Ideal gearing
- **No inertia:** Massless gears
- **No backlash:** Instant torque transmission

---

## Implementation Guidelines

### Interface Requirements

**Required Connectors:**
- One `RotationalComponents.Flange()` for input (propshaft)
- Two `RotationalComponents.Flange()` for outputs (left and right axles)

**Suggested Parameters:**
- Final drive ratio [-] (typical: 3.0-5.0 for cars)

### Important Considerations

- **Kinematic constraint:** Input speed must be related to average output speed by ratio
- **Torque signs:** Pay attention to sign conventions for power flow
- **Power conservation:** Verify input power equals sum of output powers
- **Symmetric vs asymmetric loads:** Should handle both cases

---

## Test Harness Requirements

### Test 1: Symmetric Load (Straight Line Driving)

**Objective:** Verify torque split and speed ratio with equal loads

**Suggested Test Configuration:**
- Differential with known ratio
- Apply input torque
- Connect identical inertias to both outputs
- Observe accelerations and speeds

**What to Validate:**
- Both outputs have equal torque (measure or infer from equal accelerations)
- Both outputs have equal speed
- Input-output speed ratio matches final drive ratio
- Power conservation holds

### Test 2: Asymmetric Load (Turning or One Wheel on Ice)

**Objective:** Verify differential action with unequal loads

**Suggested Test Configuration:**
- Differential with known ratio
- Apply input torque
- Connect different loads to left and right outputs (e.g., one inertia, one damper)
- Observe speed difference

**What to Validate:**
- Torques remain equal on both sides despite different loads
- Speeds differ between left and right
- Average of output speeds maintains kinematic relationship with input
- Lower resistance side spins faster (differential behavior)
- Power conservation still holds
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
