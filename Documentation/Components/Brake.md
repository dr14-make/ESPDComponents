# Brake Component Specification

## Overview

The Brake component models friction braking by applying a torque that opposes rotation, controlled by a brake signal (0-1).

---

## Physical Model

### Your Task

Model a brake that:

- Connects between two rotational flanges (through component, not blocking)
- Receives a control signal (0 = no braking, 1 = full braking)
- Applies torque that opposes the direction of rotation
- Dissipates energy as heat (power = torque × angular velocity)

### Key Physical Phenomena

1. **Friction Torque:**
   - Proportional to brake command signal
   - Always opposes motion (acts as resistive torque)
   - Maximum torque when fully applied

2. **Energy Dissipation:**
   - All kinetic energy converted to heat
   - Power dissipation depends on torque and speed

### Important Considerations

- **Sign handling:** Brake torque must oppose rotation direction
- **Smooth behavior at zero velocity:** Avoid discontinuities
- **Through component:** Both flanges must have consistent kinematics

---

## Implementation Guidelines

### Interface Requirements

**Required Connectors:**

- Two `Dyad.Spline()` connections (input and output - through component, rotational with phi/tau)
- `Dyad.RealInput()` for brake command signal [0, 1]

**Suggested Parameters:**

- Maximum brake torque [N⋅m]

### Test Harness Requirements

**Objective:** Verify brake can decelerate a spinning mass

**Suggested Test Configuration:**

- Spinning inertia (use `RotationalComponents.Inertia()`)
- Brake component
- Step input for brake command (0 → 1 at some time)
- Fixed reference

**What to Validate:**

- Initial spin-down with no braking
- Application of brake causes deceleration
- Calculate expected deceleration from torque and inertia
- Verify energy dissipation matches kinetic energy loss

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
