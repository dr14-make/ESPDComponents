# Clutch Component Specification

## Overview

The Clutch component models a friction clutch that couples or decouples the engine from the transmission. It can transmit torque with slip or lock rigidly when engaged.

---

## Physical Model

### Your Task

Model a clutch that:

- Has input and output rotational flanges (engine side and gearbox side)
- Receives an engagement command signal (0 = disengaged, 1 = fully engaged)
- Transmits torque when engaged, with or without slip
- Decouples shafts when disengaged (freewheeling)
- Models friction torque during slip
- Dissipates energy as heat during slip

### Key Physical Phenomena

1. **Three Operating Modes:**
   - **Disengaged (clutch_cmd = 0):** No torque transmission, shafts rotate independently
   - **Slipping (0 < clutch_cmd < 1 or high torque):** Partial torque transmission with speed difference
   - **Locked (clutch_cmd = 1, low slip):** Rigid connection, no relative motion

2. **Friction Torque:**
   - Proportional to engagement command and normal force
   - Opposes relative motion during slip
   - Maximum torque = clutch_cmd × tau_max
   - Direction depends on relative velocity

3. **Slip Dynamics:**
   - Relative velocity: ω_slip = ω_in - ω_out
   - Friction torque: τ_friction = clutch_cmd × tau_max × sign(ω_slip)
   - Power dissipation: P_loss = τ_friction × ω_slip (always ≥ 0)

4. **Lock-up Condition:**
   - When clutch fully engaged AND slip velocity ≈ 0, transition to rigid connection
   - Prevents numerical issues at zero slip

### Simplifications for Phase 1

- **No thermal model:** Heat dissipation not tracked
- **Instant engagement:** No gradual engagement dynamics
- **Simple friction model:** Constant friction coefficient
- **No wear:** Friction characteristics don't change over time

---

## Implementation Guidelines

### Interface Requirements

**Required Connectors:**

- Two `Spline()` connections (input from engine, output to gearbox)
  - Use standard `Spline` connector: `potential phi::Angle`, `flow tau::Torque`
- Control input for clutch engagement (signal 0-1)
  - Use `RealInput()` from `Connectors`

**Suggested Parameters:**

- Maximum transmissible torque [N⋅m]
- Lock-up tolerance for slip velocity [rad/s]
- Optional: Inertia of clutch disc

### Important Considerations

- **Sign conventions:** Friction torque opposes relative motion
- **Smooth transition:** Use smooth approximation of sign() near zero (tanh recommended)
- **Lock-up logic:** When engaged and ω_slip ≈ 0, enforce phi_in = phi_out
- **Energy check:** Dissipated power must always be positive
- **Mode switching:** Handle transitions between slip and lock smoothly

### Physics Equations

**Disengaged Mode (clutch_cmd = 0):**

```
tau_in = 0
tau_out = 0
```

**Slipping Mode (0 < clutch_cmd ≤ 1):**

```
omega_in = der(phi_in)
omega_out = der(phi_out)
omega_slip = omega_in - omega_out
tau_friction = clutch_cmd * tau_max * tanh(omega_slip / omega_eps)
tau_in = -tau_friction
tau_out = tau_friction
P_dissipated = tau_friction * omega_slip
```

**Locked Mode (clutch_cmd = 1 AND |omega_slip| < omega_lock):**

```
phi_in = phi_out  (rigid connection)
tau_in + tau_out = 0  (torque balance)
```

---

## Test Harness Requirements

### Test 1: Engagement with Load

**Objective:** Verify clutch can engage under load and transmit torque

**Suggested Test Configuration:**

- Input: Constant speed source (engine side)
- Clutch with step engagement: 0 → 1 at t = 1s
- Output: Inertia load (gearbox side)
- Verify slip → lock transition

**What to Validate:**

- Initial slip when engaged (ω_in > ω_out)
- Friction torque accelerates output shaft
- Lock-up occurs when speeds equalize
- No torque when disengaged

**Expected Results:**

- 0 < t < 1s: Clutch disengaged, ω_out = 0
- t = 1s: Engagement, friction torque applied
- 1s < t < t_lock: Slipping, output accelerates
- t > t_lock: Locked, ω_in = ω_out

**Validation:**

```julia
@assert sol(0.5, idxs=sys.clutch.tau_friction) ≈ 0.0  # Disengaged
@assert sol(1.5, idxs=sys.clutch.omega_slip) > 0.0    # Slipping
@assert abs(sol(5.0, idxs=sys.clutch.omega_slip)) < 0.1  # Locked
@assert sol(5.0, idxs=sys.load.omega) ≈ 100.0         # Output matches input
```

### Test 2: Partial Engagement (Slip Control)

**Objective:** Verify partial engagement maintains controlled slip

**Suggested Test Configuration:**

- Input: Constant torque source
- Clutch with partial engagement: clutch_cmd = 0.5
- Output: Damper load
- Verify continuous slip with partial torque transmission

**What to Validate:**

- Torque transmitted = clutch_cmd × tau_max (approximately)
- Continuous slip velocity (not locked)
- Power dissipation P_loss > 0
- Stable operation in slip mode

**Expected Results:**

- Steady-state with ω_slip ≠ 0
- τ_transmitted ≈ 0.5 × tau_max
- Output speed < input speed

### Test 3: Disengagement Under Load

**Objective:** Verify clutch can disengage and decouple shafts

**Suggested Test Configuration:**

- Start with locked clutch transmitting torque
- Disengage: clutch_cmd 1 → 0 at t = 2s
- Verify decoupling

**What to Validate:**

- Before disengagement: ω_in = ω_out
- After disengagement: τ_transmitted = 0
- Input and output shafts independent after t = 2s

---

## Parameter Ranges

### Maximum Torque Capacity

| Vehicle Type | Clutch Torque Capacity |
|--------------|------------------------|
| Small Car | 200-300 N⋅m |
| Sedan | 300-500 N⋅m |
| SUV/Truck | 500-800 N⋅m |
| Performance | 600-1000 N⋅m |
| Heavy Duty | 1000-2000 N⋅m |

### Typical Parameters

- Friction coefficient: μ = 0.25-0.45 (dry clutch)
- Lock-up tolerance: ω_lock = 0.1-1.0 rad/s
- Engagement time: 0.1-0.5 s (not modeled in Phase 1)
- Slip tolerance: ω_eps = 0.01 rad/s (for smooth sign function)

---

## Advanced Features (Phase 4)

### Gradual Engagement Dynamics

Model engagement as first-order lag:

```
der(engagement_actual) = (clutch_cmd - engagement_actual) / T_engage
T_engage = 0.1-0.3 s
```

### Temperature-Dependent Friction

```
mu_effective = mu_nominal * (1 - k_temp * (T - T_nominal))
```

### Wear Model

```
wear_rate = k_wear * P_dissipated
mu_effective = mu_nominal * (1 - k_mu_wear * wear_total)
```

### Self-Adjusting Clutch

Model automatic adjustment of air gap to compensate for wear.

---

## Validation Checklist

- [ ] Disengaged: τ_transmitted = 0
- [ ] Engaged + slip: τ = clutch_cmd × tau_max × sign(ω_slip)
- [ ] Locked: phi_in = phi_out (error < 0.001 rad)
- [ ] Friction opposes relative motion (always dissipative)
- [ ] Power dissipation P_loss ≥ 0 at all times
- [ ] Smooth transition near zero slip (no discontinuities)
- [ ] Lock-up occurs when engaged and ω_slip ≈ 0

---

## Common Issues

### Issue 1: Chattering at Lock-up

**Problem:** Oscillations near ω_slip = 0 due to discontinuous friction
**Solution:**

- Use smooth approximation: `tanh(omega_slip / omega_eps)` instead of `sign(omega_slip)`
- Phase 4: Implement proper lock-up mode with rigid constraint

### Issue 2: Negative Power Dissipation

**Problem:** Sign error causes energy creation
**Solution:** Verify `P_loss = tau_friction * omega_slip ≥ 0` always

### Issue 3: Solver Stiffness in Slip Mode

**Problem:** DAE system becomes stiff during engagement
**Solution:** Use DAE-compatible solver (Rodas5P), adjust tolerances

### Issue 4: Mode Switching Discontinuities

**Problem:** Instant switch between slip and lock causes solver issues
**Solution:**

- Phase 1: Accept with stiff solver
- Phase 4: Implement smooth state events for mode transitions

---

**Component Status:** 🔴 Not Started  
**Priority:** HIGH (Phase 4, but useful for Phase 2A integration)  
**Complexity:** Medium-High (mode switching, friction, slip dynamics)  
**Prerequisites:** None (can test standalone)

---

## Reference

- Modelica: `Modelica.Mechanics.Rotational.Components.Clutch`
- SAE J2452: Clutch Torque Capacity Measurement
- Textbook: "Vehicle Powertrain Systems" by Behrooz Mashadi
- Note: This is a simplified clutch model. Real clutches have complex engagement dynamics, thermal effects, and wear characteristics not captured in Phase 1.
