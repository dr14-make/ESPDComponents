# Vehicle Body Component Specification

## Overview

The VehicleBody component models the translational dynamics of a vehicle as a point mass subject to longitudinal forces. This is the foundation component for the vehicle dynamics library.

---

## Physical Model

### Free Body Diagram

```
        Ftraction →  [VEHICLE MASS]  ← Faero + Froll + Fgrade
                         (m)
                          ↓
                        m·g
```

### Governing Equations

**Newton's Second Law (Longitudinal):**
```
ma = Ftraction - Faero - Froll - Fgrade
```

Where:
- `m` = vehicle mass [kg]
- `a` = longitudinal acceleration [m/s²]
- `Ftraction` = traction force from wheels [N]
- `Faero` = aerodynamic drag [N]
- `Froll` = rolling resistance [N]
- `Fgrade` = grade resistance [N]

**Aerodynamic Drag:**
```
Faero = ½ρ·Cd·A·v²·sign(v)
```
- `ρ` = air density [kg/m³] (standard: 1.225)
- `Cd` = drag coefficient [-] (typical car: 0.3-0.4)
- `A` = frontal area [m²] (typical car: 2.0-2.5)
- `v` = vehicle velocity [m/s]
- `sign(v)` = ensures drag opposes motion

**Rolling Resistance:**
```
Froll = Crr·m·g·cos(θ)·sign(v)
```
- `Crr` = rolling resistance coefficient [-] (asphalt: ~0.015)
- `g` = gravitational acceleration [m/s²] (9.81)
- `θ` = road grade angle [rad]
- `sign(v)` = ensures resistance opposes motion

**Grade Resistance:**
```
Fgrade = m·g·sin(θ)
```
- Positive for uphill, negative for downhill

### Simplifications for Phase 1
- **Flat road:** θ = 0 → Fgrade = 0, cos(θ) = 1
- **Zero-slip tires:** No wheel spin or lock-up
- **No pitch dynamics:** Vehicle treated as point mass
- **No lateral forces:** Straight-line motion only

---

## Implementation Guidelines

### Interface Requirements

**Required Connector:**
- Use `TranslationalComponents.Flange()` for mechanical connection to wheels

**Required Parameters:**
- Vehicle mass [kg]
- Drag coefficient [-]
- Frontal area [m²]
- Air density [kg/m³]
- Rolling resistance coefficient [-]
- Gravitational acceleration [m/s²]
- Road grade angle [rad] (for Phase 1, can set to 0)

**Required Variables:**
- Position, velocity, acceleration
- Individual force components (traction, aero, rolling, grade)
- Net force

### Implementation Tasks

1. **Kinematic Relationships:**
   - Position is integral of velocity
   - Velocity is integral of acceleration

2. **Force Calculations:**
   - Aerodynamic drag: Quadratic with velocity
   - Rolling resistance: Proportional to normal force
   - Grade resistance: Component of weight
   - Ensure forces oppose motion (sign handling)

3. **Newton's Second Law:**
   - Net force = Sum of all forces
   - m × a = F_net

4. **Flange Connection:**
   - Position must match flange position
   - Force from flange is traction force (mind sign convention)

### Important Considerations

- **Sign Convention:** Check TranslationalComponents.Flange documentation for force direction
- **Discontinuity at v=0:** Drag and rolling resistance change sign - use smooth approximation
- **Initial Conditions:** Need initial position and velocity for integration

---

## Test Harness Requirements

### Test 1: Constant Force Acceleration

**Objective:** Verify F=ma with known force input

**Test Configuration:**
- Vehicle with mass 1000 kg
- Disable aero drag (Cd = 0)
- Disable rolling resistance (Crr = 0)
- Apply constant 1000 N force
- Simulate for 10 seconds

**Required Components:**
- Your VehicleBody component
- `TranslationalComponents.Force()` for force input
- `BlockComponents.Constant()` for constant 1000 N

**Expected Results (calculate before implementing):**
- Acceleration: a = ? m/s² (from F=ma)
- Velocity at t=10s: v = ? m/s
- Position at t=10s: s = ? m
- Plot: Linear velocity increase, quadratic position increase

**Validation Criteria:**
- Acceleration constant and matches F/m
- Velocity increases linearly
- Position increases quadratically

### Test 2: Aerodynamic Drag Only

**Objective:** Verify drag force reaches terminal velocity

**Test Configuration:**
- Vehicle: m=1000 kg, Cd=0.4, A=2.0 m², rho=1.225 kg/m³
- Disable rolling resistance (Crr = 0)
- Apply constant 500 N thrust force
- Simulate for 50 seconds

**Required Components:**
- Your VehicleBody component with drag enabled
- `TranslationalComponents.Force()` for thrust
- `BlockComponents.Constant()` for 500 N

**Expected Results (calculate before implementing):**
- Terminal velocity when F_thrust = F_drag
- Calculate: 500 = 0.5 × rho × Cd × A × v²
- Solve for v_terminal = ? m/s
- Time to reach 95% of terminal velocity

**Validation Criteria:**
- Velocity approaches calculated terminal velocity
- At steady state: acceleration ≈ 0
- Power balance: P_thrust = P_drag

### Test 3: Coast-Down Test

**Objective:** Verify combined rolling resistance and aerodynamic drag

**Test Configuration:**
- Realistic vehicle: m=1500 kg, Cd=0.32, A=2.2 m², Crr=0.015
- No applied force (coasting)
- Initial velocity: 30 m/s (~108 km/h)
- Simulate until vehicle stops

**Required Setup:**
- Your VehicleBody component
- No external force source (or zero force)
- Initial condition: v(0) = 30 m/s

**Expected Results (calculate before implementing):**
- Initial deceleration at v=30 m/s:
  - Calculate F_aero, F_roll, a_initial
- Deceleration profile:
  - High speed: drag dominates
  - Low speed: rolling resistance dominates
- Time to stop and distance traveled

**Validation Criteria:**
- Initial deceleration matches calculated value
- Vehicle eventually stops (v → 0)
- Deceleration curve shape matches theory

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

#### Energy Conservation
- [ ] Power balance: P_in = P_drag + P_roll + dE_kinetic/dt
- [ ] At steady state: P_traction = P_drag + P_roll
- [ ] E_kinetic = ½mv² matches integrated power

#### Force Balance
- [ ] At t=0 with v=0: F_aero = 0, F_roll = 0
- [ ] F_net = m·a verified numerically (residual < 1e-6)
- [ ] Steady state: F_traction = F_drag + F_roll (a ≈ 0)

#### Kinematic Consistency
- [ ] v = ds/dt (numerical derivative matches state)
- [ ] a = dv/dt (numerical derivative matches state)
- [ ] Position increases monotonically for positive velocity

#### Steady-State Accuracy
- [ ] Terminal velocity within 1% of analytical calculation
- [ ] Coast-down distance within 5% of analytical integration
- [ ] Zero force → zero acceleration at rest

---

## Common Issues & Solutions

### Issue 1: Discontinuity at v=0
**Problem:** Sign function causes solver issues when vehicle stops
**Solution:** Use smooth tanh approximation or if/else with cutoff speed

### Issue 2: Negative Velocity
**Problem:** Vehicle can theoretically accelerate backward
**Solution:** For Phase 1, assume forward motion only. Add constraint: v >= 0

### Issue 3: Initialization Failure
**Problem:** Algebraic constraints not satisfied at t=0
**Solution:** Ensure initial conditions are consistent:
- If v(0) = 0, then F_aero(0) = 0, F_roll(0) = 0
- If F_traction(0) specified, must be compatible with initial forces

### Issue 4: Stiff Dynamics at High Speed
**Problem:** Aero drag has v² dependence → stiffness
**Solution:** Use stiff solver (Rodas5P) if needed, or reduce max speed in test

---

## Integration Notes

### Connection to Wheels
The VehicleBody component connects to wheels through the translational flange:
```dyad
connect(wheel.flange_translational, vehicle_body.flange)
```

The wheel component must convert rotational torque to translational force:
```dyad
# In Wheel component
F_traction = tau_wheel / radius
flange_translational.f = -F_traction
```

### Multiple Wheels
For multiple wheels (4-wheel vehicle), forces sum:
```dyad
# In system
F_total = F_wheel_FL + F_wheel_FR + F_wheel_RL + F_wheel_RR
```

Or use adder component if available.

---

## References

### Theory
- Gillespie, T.D. "Fundamentals of Vehicle Dynamics" Chapter 3: Acceleration Performance
- Wong, J.Y. "Theory of Ground Vehicles" Chapter 2: Performance Characteristics

### Modelica Reference
- File: `temp/modelica/ipowertrain/Vehicles/BasicVehicle.mo`
- Lines 16-28: Parameter definitions
- Lines 95-101: Force equations in wrapped component

### Relevant Standards
- SAE J1263: Road Load Measurement and Dynamometer Simulation
- ISO 2416: Passenger cars - Mass distribution

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
