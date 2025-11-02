# Vehicle Body Component Specification

## Overview

The VehicleBody component models the longitudinal and pitch dynamics of a vehicle with separate front and rear axles. It includes load transfer effects during acceleration and braking, which are critical for understanding traction limits and vehicle stability.

---

## Physical Model

### Conceptual Diagram

```
                     CG (h_cg above ground)
                          ●
                         /|\
                        / | \
                       /  |  \
                  Fdrag|  |mg |Fgrade
                       |  ↓   |
    ┌─────────────────────────────────────┐
    │         VEHICLE BODY (m)             │
    └─────────────────────────────────────┘
         ↓                       ↓
       N_front                 N_rear
    [FRONT AXLE]            [REAR AXLE]
         ↑                       ↑
      F_front                 F_rear
    ═══════════             ═══════════
    |<---a--->|<-----b----->|
    |<--------L (wheelbase)-------->|
```

### Your Task

Model a vehicle body with:

- **Separate front and rear axles** for independent traction forces
- **Load transfer during acceleration/braking** (pitch dynamics)
- **Normal force distribution** to each axle (affects wheel traction limits)
- **Aerodynamic drag** (resistance increases with velocity squared)
- **Rolling resistance** (proportional to normal forces per axle)
- **Grade resistance** (force due to road slope)

The vehicle body should:

1. Accelerate/decelerate based on total traction forces from both axles
2. Calculate dynamic normal forces considering longitudinal acceleration
3. Provide normal forces to each wheel for traction limit calculations

### Key Physical Phenomena

1. **Load Transfer (NEW - Critical for Roll Behavior):**
   - During acceleration: weight shifts rearward → N_rear increases, N_front decreases
   - During braking: weight shifts forward → N_front increases, N_rear decreases
   - Magnitude: ΔN = m·a·h_cg / L
   - This affects maximum traction at each axle!

2. **Static Weight Distribution:**
   - Depends on CG position between axles
   - Front: N_static_front = m·g·(b/L) where b is CG to rear axle distance
   - Rear: N_static_rear = m·g·(a/L) where a is CG to front axle distance
   - Must satisfy: a + b = L (wheelbase)

3. **Aerodynamic Drag:**
   - Depends on: air density, drag coefficient, frontal area, velocity
   - Increases with velocity squared
   - Always opposes motion

4. **Rolling Resistance:**
   - **Per-axle basis:** F_roll = Crr × N (depends on actual normal force)
   - Front and rear calculated separately
   - Always opposes motion

5. **Grade Resistance:**
   - Component of weight parallel to road surface
   - Positive when going uphill, negative downhill

### Simplifications for Phase 1

- **Flat road:** Start with theta = 0 (can add grade later)
- **Zero-slip tires:** Perfect traction up to friction limit
- **Rigid body pitch:** Instant load transfer (no suspension dynamics)
- **No lateral forces:** Straight-line motion only
- **No yaw dynamics:** No turning (yet)

---

## Implementation Guidelines

### Interface Requirements

**Required Connectors:**

- `flange_front`: TranslationalComponents.Flange (front axle traction input)
- `flange_rear`: TranslationalComponents.Flange (rear axle traction input)
- `flange_normal_front`: TranslationalComponents.Flange (front normal force output)
- `flange_normal_rear`: TranslationalComponents.Flange (rear normal force output)
- **ACTION:** Read the Flange source to understand the sign convention!

**Suggested Parameters:**

- Vehicle mass [kg]
- Wheelbase L [m]
- CG height h_cg [m] (above ground, critical for load transfer!)
- Distance a [m] (CG to front axle)
- Distance b [m] (CG to rear axle, must satisfy L = a + b)
- Drag coefficient [-]
- Frontal area [m²]
- Air density [kg/m³]
- Rolling resistance coefficient [-]
- Gravitational acceleration [m/s²]
- Road grade angle [rad] (start with 0 for flat road)

### Important Considerations

- **Sign Convention:** Forces must be applied with correct signs - check the Flange documentation
- **Load Transfer:** This is THE key feature - affects traction limits, braking performance, acceleration
- **Moment Balance:** About CG must be satisfied for normal forces
- **Discontinuity at v=0:** Drag and rolling resistance change direction - handle smoothly
- **Initial Conditions:** Differential equations need initial values
- **Parameter Consistency:** Must have L = a + b exactly

---

## Test Harness Requirements

### Test 1: Static Weight Distribution

**Objective:** Verify correct normal force distribution at rest

**Suggested Test Configuration:**

- Vehicle with known mass and geometry (m, a, b, L, h_cg)
- Zero velocity, zero applied forces
- Flat road (theta = 0)
- Simulate or solve algebraically

**What to Validate:**

- Calculate expected static normal forces **before** running:
  - N_front_expected = m·g·(b/L)
  - N_rear_expected = m·g·(a/L)
  - N_front + N_rear = m·g (total weight)
- Verify simulation matches hand calculations (error < 0.1%)
- Check moment balance about CG: N_front·a - N_rear·b = 0

### Test 2: Load Transfer During Acceleration

**Objective:** Verify load transfer magnitude and direction

**Suggested Test Configuration:**

- Vehicle with known parameters
- Apply constant acceleration (e.g., 3 m/s²)
- Disable drag and rolling resistance for simplicity
- Flat road

**Components You'll Need:**

- Your VehicleBody component
- Two `TranslationalComponents.Force()` for front/rear traction
- `BlockComponents.Constant()` for force values
- Or connect to Wheel components with torque input

**What to Validate:**

- Calculate expected load transfer **before** running:
  - ΔN = m·a·h_cg / L
  - N_front = N_static_front - ΔN
  - N_rear = N_static_rear + ΔN
- Verify rear normal force increases during acceleration
- Verify front normal force decreases during acceleration
- Check total: N_front + N_rear = m·g (conserved!)
- Verify longitudinal force balance: F_front + F_rear = m·a

### Test 3: Load Transfer During Braking

**Objective:** Verify weight shift forward during deceleration

**Suggested Test Configuration:**

- Vehicle with initial velocity
- Apply braking force (negative acceleration)
- Observe normal force shift

**What to Validate:**

- Calculate expected load transfer **before** running:
  - For braking: a < 0 → ΔN < 0 → weight shifts forward
  - N_front = N_static_front + |ΔN|
  - N_rear = N_static_rear - |ΔN|
- Verify front normal force increases during braking
- Verify rear normal force decreases during braking
- Check for risk of rear wheel lockup (N_rear → 0)

### Test 4: Aerodynamic Drag

**Objective:** Verify drag force behavior and terminal velocity

**Suggested Test Configuration:**

- Vehicle with realistic parameters
- Enable aerodynamic drag, disable rolling resistance
- Apply constant thrust force (both axles or rear-only)
- Simulate until steady state reached

**What to Validate:**

- Calculate terminal velocity where thrust equals drag **before** running
- Verify velocity asymptotically approaches terminal velocity
- Check that acceleration goes to zero at steady state
- Verify power balance
- Normal forces should remain at static values (zero acceleration at steady state)

### Test 5: Combined Acceleration with Roll (Advanced)

**Objective:** Verify realistic acceleration scenario with load transfer

**Suggested Test Configuration:**

- Rear-wheel-drive vehicle (only rear axle provides traction)
- Apply high torque to rear wheels
- Observe if rear wheels can provide enough traction
- Enable all resistance forces

**What to Validate:**

- Calculate maximum rear traction **before** running:
  - At rest: F_max_rear = μ·N_static_rear
  - During acceleration: N_rear increases → F_max_rear increases!
  - This is self-limiting feedback (good for stability)
- Verify rear wheels don't spin if torque is reasonable
- Compare acceleration with/without load transfer effects
- Observe transient: as vehicle accelerates, load shifts, traction capacity increases

---

## Parameter Ranges

### Typical Values

| Parameter | Compact Car | Mid-Size Sedan | SUV/Truck |
|-----------|-------------|----------------|-----------|
| Mass (kg) | 1000-1300 | 1400-1700 | 2000-3000 |
| Wheelbase L (m) | 2.4-2.6 | 2.7-2.9 | 2.8-3.2 |
| CG height h_cg (m) | 0.45-0.55 | 0.50-0.60 | 0.65-0.85 |
| a (m) - CG to front | 1.0-1.2 | 1.2-1.4 | 1.3-1.6 |
| b (m) - CG to rear | 1.3-1.5 | 1.4-1.6 | 1.5-1.8 |
| Weight dist. front | 58-62% | 55-60% | 50-55% |
| Cd [-] | 0.28-0.35 | 0.30-0.38 | 0.35-0.45 |
| A (m²) | 2.0-2.3 | 2.2-2.5 | 2.5-3.0 |
| Crr [-] | 0.010-0.015 | 0.012-0.018 | 0.015-0.025 |

### Load Transfer Examples

**Example 1: Compact Car Acceleration**

- m = 1200 kg, L = 2.5 m, h_cg = 0.50 m
- a = 3.0 m/s² (moderate acceleration)
- ΔN = 1200 × 3.0 × 0.50 / 2.5 = 720 N
- This is ~6% of vehicle weight - noticeable effect!

**Example 2: SUV Hard Braking**

- m = 2500 kg, L = 3.0 m, h_cg = 0.75 m (higher CG!)
- a = -8.0 m/s² (emergency braking)
- ΔN = 2500 × (-8.0) × 0.75 / 3.0 = -5000 N
- Front gains 5000 N, rear loses 5000 N
- This is ~20% of vehicle weight - major effect!
- Risk: rear wheels may lock up if not careful

### Physical Constraints

- `m > 0` (positive mass)
- `L > 0` (positive wheelbase)
- `h_cg > 0` (CG above ground)
- `a > 0`, `b > 0`, and `a + b = L` exactly
- `0 < a/L < 1` (CG between axles)
- `Cd > 0` (drag always opposes motion)
- `A > 0` (positive area)
- `rho > 0` (positive air density)
- `Crr >= 0` (non-negative resistance)
- `-π/4 < theta < π/4` (reasonable grade limits: ±45°)
- For stability: typically h_cg < 0.3·L (prevents easy rollover)

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
