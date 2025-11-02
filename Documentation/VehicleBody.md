# Vehicle Body Component Specification

## Overview

The VehicleBody component models the translational dynamics of a vehicle as a point mass subject to longitudinal forces. This is the foundation component for the vehicle dynamics library.

---

## Physical Model

### Conceptual Diagram

```
        Ftraction →  [VEHICLE MASS]  ← Faero + Froll + Fgrade
                         (m)
                          ↓
                        m·g
```

### Your Task

Model a vehicle body experiencing:

- **Traction force** from wheels (input via flange)
- **Aerodynamic drag** (resistance increases with velocity squared)
- **Rolling resistance** (friction from tires on road)
- **Grade resistance** (force due to road slope)

The vehicle body should accelerate/decelerate according to Newton's laws based on these forces.

### Key Physical Phenomena

1. **Aerodynamic Drag:**
   - Depends on: air density, drag coefficient, frontal area, velocity
   - Increases with velocity squared
   - Always opposes motion

2. **Rolling Resistance:**
   - Depends on: vehicle weight, rolling resistance coefficient, road grade
   - Proportional to normal force on tires
   - Always opposes motion

3. **Grade Resistance:**
   - Component of weight parallel to road surface
   - Positive when going uphill, negative downhill

### Simplifications for Phase 1

- **Flat road:** No grade effects initially (can be extended later)
- **Zero-slip tires:** Perfect traction (wheel doesn't spin or lock)
- **No pitch dynamics:** Vehicle treated as point mass
- **No lateral forces:** Straight-line motion only

---

## Implementation Guidelines

### Interface Requirements

**Required Connector:**

- Use `TranslationalComponents.Flange()` for mechanical connection to wheels
- **ACTION:** Read the Flange source to understand the sign convention!

**Suggested Parameters:**

- Vehicle mass [kg]
- Drag coefficient [-]
- Frontal area [m²]
- Air density [kg/m³]
- Rolling resistance coefficient [-]
- Gravitational acceleration [m/s²]
- Road grade angle [rad] (start with 0 for flat road)

### Important Considerations

- **Sign Convention:** Forces must be applied with correct signs - check the Flange documentation
- **Discontinuity at v=0:** Drag and rolling resistance change direction - handle smoothly
- **Initial Conditions:** Differential equations need initial values

---

## Test Harness Requirements

### Test 1: Constant Force Acceleration

**Objective:** Verify Newton's second law with known force input

**Suggested Test Configuration:**

- Vehicle with known mass
- Disable aero drag and rolling resistance (set coefficients to 0)
- Apply constant force
- Simulate for sufficient time to observe motion

**Components You'll Need:**

- Your VehicleBody component
- `TranslationalComponents.Force()` for force input
- `BlockComponents.Constant()` for constant force value

**What to Validate:**

- Calculate expected acceleration from F=ma **before** running simulation
- Verify velocity increases linearly
- Verify position increases quadratically
- Compare simulation to hand calculations

### Test 2: Aerodynamic Drag

**Objective:** Verify drag force behavior and terminal velocity

**Suggested Test Configuration:**

- Vehicle with realistic parameters
- Enable aerodynamic drag, disable rolling resistance
- Apply constant thrust force
- Simulate until steady state reached

**Components You'll Need:**

- Your VehicleBody component with drag enabled
- `TranslationalComponents.Force()` for thrust
- `BlockComponents.Constant()` for thrust value

**What to Validate:**

- Calculate terminal velocity where thrust equals drag **before** running
- Verify velocity asymptotically approaches terminal velocity
- Check that acceleration goes to zero at steady state
- Verify power balance

### Test 3: Coast-Down

**Objective:** Verify combined resistance forces

**Suggested Test Configuration:**

- Realistic vehicle parameters
- Enable both aero drag and rolling resistance
- No applied force (coasting)
- Initial velocity (e.g., highway speed)
- Simulate until vehicle stops

**What to Validate:**

- Calculate initial deceleration **before** running
- Observe that drag dominates at high speed
- Observe that rolling resistance dominates at low speed
- Vehicle comes to complete stop
- Compare deceleration curve to physical reasoning

---

## Parameter Ranges

### Typical Values

| Parameter | Compact Car | Mid-Size Sedan | SUV/Truck |
|-----------|-------------|----------------|-----------|
| Mass (kg) | 1000-1300 | 1400-1700 | 2000-3000 |
| Cd [-] | 0.28-0.35 | 0.30-0.38 | 0.35-0.45 |
| A (m²) | 2.0-2.3 | 2.2-2.5 | 2.5-3.0 |
| Crr [-] | 0.010-0.015 | 0.012-0.018 | 0.015-0.025 |

### Physical Constraints

- `m > 0` (positive mass)
- `Cd > 0` (drag always opposes motion)
- `A > 0` (positive area)
- `rho > 0` (positive air density)
- `Crr >= 0` (non-negative resistance)
- `-π/4 < theta < π/4` (reasonable grade limits: ±45°)

---

## Validation Checklist

### Level 1: Compiles

- [ ] No syntax errors
- [ ] All parameters have units
- [ ] All variables declared with types

### Level 2: Runs

- [ ] `sol.retcode == ReturnCode.Success`
- [ ] No NaN or Inf values
- [ ] Simulation completes to stop time

### Level 3: Physics Validated

- [ ] Energy is conserved (power in = power out + losses)
- [ ] Force balance matches Newton's law (verify numerically)
- [ ] Steady-state matches hand calculations
- [ ] Transient behavior is physically reasonable

---

## Integration Notes

### Connection to Wheels

The VehicleBody component connects to wheels through the translational flange. The wheel component must convert rotational motion to translational motion - this is covered in the Wheel component specification.

---

## Next Steps

After VehicleBody is validated:

1. Proceed to **Wheel.md** - Convert rotational to translational motion
2. Then **Brake.md** - Add deceleration capability
3. Integration test: Wheel + Body + Brake in coast-down scenario

---

**Component Status:** 🔴 Not Started  
**Priority:** CRITICAL - Foundation for all other components  
**Estimated Complexity:** Low (pure translational dynamics)  
**Prerequisite Components:** None (standalone)
