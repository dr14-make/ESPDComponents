# Wheel Component Specification

## Overview

The Wheel component models the coupling between rotational (driveline) and translational (vehicle body) domains. It represents a rigid wheel with rolling radius that converts torque to traction force under a zero-slip assumption.

---

## Physical Model

### Conceptual Diagram

```
        Rotational Domain          Translational Domain
              (τ, ω)                     (F, v)
                
    [Driveline] → ⊕ Wheel ⊕ → [Vehicle Body]
                   radius r
                      ↓
                   N (normal force)
                   ═══ (road surface)
```

### Your Task

Model a wheel that:

- Connects the **rotational driveline** (torque, angular velocity) to the **translational vehicle body** (force, linear velocity)
- Converts between domains using the wheel's rolling radius
- Enforces a kinematic constraint (rolling without slipping)
- Optionally includes rotational inertia effects

### Key Physical Phenomena

1. **Rolling Without Slip:**
   - The linear velocity of the contact patch equals the tangential velocity of the wheel
   - Relationship involves angular velocity and rolling radius

2. **Force-Torque Coupling:**
   - Torque from driveline creates traction force on ground
   - Relationship involves rolling radius as a lever arm

3. **Power Conservation:**
   - Power in rotational domain equals power in translational domain (for ideal wheel)
   - Verify: rotational power = translational power

4. **Optional Inertia:**
   - Wheel has rotational inertia that resists angular acceleration
   - May include rolling resistance as a resistive torque

### Simplifications for Phase 1

- **Zero slip:** Perfect traction, no wheel spin or lock-up
- **Rigid wheel:** No tire deflection or compliance
- **No vertical dynamics:** Normal force is constant
- **Start simple:** Begin with massless wheel, add inertia if desired

---

## Implementation Guidelines

### Interface Requirements

**Required Connectors:**

- `RotationalComponents.Flange()` for driveline connection (torque input)
- `TranslationalComponents.Flange()` for vehicle body connection (force output)
- **ACTION:** Read both Flange sources to understand sign conventions!

**Suggested Parameters:**

- Rolling radius [m] (typical: 0.25-0.40 m)
- Optional: Rotational inertia [kg⋅m²] if including wheel mass effects

### Important Considerations

- **Sign conventions:** Torque and force must have consistent signs through the transformation
- **Power conservation:** Rotational power must equal translational power
- **Kinematic constraint:** The no-slip condition is a constraint equation
- **Initialization:** If including inertia, need initial angular velocity

---

## Test Harness Requirements

### Test 1: Kinematic Verification

**Objective:** Verify the rolling-without-slip relationship

**Suggested Test Configuration:**

- Wheel with known radius
- Apply constant angular velocity (use `RotationalComponents.Speed()`)
- Connect to vehicle body mass
- Measure resulting linear velocity

**Components You'll Need:**

- Your Wheel component
- `RotationalComponents.Speed()` for angular velocity source
- `BlockComponents.Constant()` for the velocity value
- `TranslationalComponents.Mass()` for the vehicle body

**What to Validate:**

- Calculate expected linear velocity from angular velocity and radius **before** running
- Verify linear velocity matches prediction
- Check power conservation: τ·ω = F·v

### Test 2: Force-Torque Relationship

**Objective:** Verify torque-to-force conversion

**Suggested Test Configuration:**

- Wheel with known radius
- Apply constant torque (use `RotationalComponents.TorqueSource()`)
- Connect to vehicle body with some resistance (damper)
- Verify steady-state force and velocity

**What to Validate:**

- Calculate expected traction force from torque and radius **before** running
- Verify force matches prediction
- Check steady-state velocity makes sense with load
- Verify power balance

### Test 3: Inertia Response (If Implemented)

**Objective:** Verify rotational dynamics if wheel has inertia

**Suggested Test Configuration:**

- Wheel with specified inertia
- Apply step torque input
- Observe angular acceleration response

**What to Validate:**

- Calculate expected angular acceleration from τ = J·α
- Verify acceleration matches prediction
- Check transient response is physically reasonable

---

## Parameter Ranges

### Typical Values

| Parameter | Small Car | Mid-Size Car | SUV/Truck |
|-----------|-----------|--------------|-----------|
| Radius (m) | 0.25-0.28 | 0.30-0.34 | 0.35-0.42 |
| Tire Size | 175/65R14 | 205/55R16 | 265/70R17 |
| Inertia (kg⋅m²) | 0.5-1.0 | 1.0-1.5 | 2.0-3.0 |
| Mass (kg) | 8-12 | 12-18 | 20-30 |

### Calculating Radius from Tire Size

Tire designation: `Width/AspectRatio R DiameterInches`

Example: `205/55R16`

- Width: 205 mm
- Aspect ratio: 55% (sidewall height = 0.55 × 205 = 112.75 mm)
- Rim diameter: 16 inches = 406.4 mm
- Total diameter: 406.4 + 2×112.75 = 631.9 mm
- **Radius: 0.316 m**

Formula:

```
radius [m] = (rim_diameter_inch × 25.4 + 2 × width_mm × aspect_ratio) / 2000
```

### Calculating Wheel Inertia

Approximate wheel+tire as hollow cylinder:

```
J = m_wheel × r²
```

More accurate (80% of mass at rim):

```
J = 0.8 × m_wheel × r²
```

Typical: `J = 1.0-2.0 kg⋅m²` for passenger cars

---

## Validation Checklist

### Level 1: Compiles

- [ ] No syntax errors
- [ ] Proper unit types for radius, inertia
- [ ] Both flanges correctly declared

### Level 2: Runs

- [ ] `sol.retcode == ReturnCode.Success`
- [ ] No kinematic constraint violations
- [ ] Simulation completes without instability

### Level 3: Physics Validated

#### Kinematic Consistency

- [ ] v = ω·r verified numerically (error < 0.1%)
- [ ] At all times, not just steady state
- [ ] Works for both positive and negative velocities

#### Force-Torque Relationship

- [ ] F·r = τ verified numerically (error < 1%)
- [ ] Power conservation: P_rot = τ·ω = F·v = P_trans
- [ ] Energy balance over time matches

#### Dynamic Response (with Inertia)

- [ ] Angular acceleration α = τ_net/J (error < 5%)
- [ ] Transient response time scale matches J/damping
- [ ] Step response has correct initial slope

#### Steady-State Accuracy

- [ ] Final velocity matches applied force/damping ratio
- [ ] Final angular velocity matches v/r
- [ ] Zero torque → constant velocity (no drift)

---

## Common Issues & Solutions

### Issue 1: Algebraic Loop at v=0

**Problem:** Kinematic constraint v = ω·r can create algebraic loop
**Solution:**

- Use differential variables properly: `der(flange_rot.phi)` and `der(flange_trans.s)`
- Add small inertia if using massless wheel with stiff connection

### Issue 2: Inconsistent Initial Conditions

**Problem:** Initial ω and v don't satisfy v = ω·r
**Solution:**

```dyad
initial flange_rot.phi = 0.0
initial flange_trans.s = 0.0
# Let velocities be computed from constraint
```

### Issue 3: Sign Convention Confusion

**Problem:** Force and torque signs inconsistent
**Solution:** Document clearly:

- `flange_rot.tau > 0` → torque INTO wheel (driving)
- `flange_trans.f > 0` → force INTO wheel (resistance)
- Traction force on vehicle: `F_vehicle = -flange_trans.f`

### Issue 4: Rolling Resistance Discontinuity

**Problem:** Sign(ω) creates discontinuity at zero speed
**Solution:** Use smooth approximation:

```dyad
tau_roll = F_roll * radius * tanh(omega / omega_cutoff)
```

where `omega_cutoff` ≈ 0.1 rad/s

---

## Integration Notes

### Connection to Differential

Multiple wheels connect to differential outputs:

```dyad
# In vehicle system
differential = Differential(ratio = 3.5)
wheel_left = Wheel(radius = 0.3)
wheel_right = Wheel(radius = 0.3)

connect(differential.flange_out_left, wheel_left.flange_rot)
connect(differential.flange_out_right, wheel_right.flange_rot)
```

### Connection to Vehicle Body

Translational flanges sum forces:

```dyad
# For single axle
connect(wheel_left.flange_trans, body.flange)
connect(wheel_right.flange_trans, body.flange)
# Forces add automatically at connection point
```

### With Brake Component

Brake torque adds in series with wheel:

```dyad
# Option 1: Brake between driveline and wheel
connect(driveline.flange, brake.flange_a)
connect(brake.flange_b, wheel.flange_rot)

# Option 2: Brake incorporated in wheel model (Phase 2)
```

---

## Advanced Topics (Phase 4)

### Slip Modeling

For more realistic behavior, include slip ratio:

```
slip = (v - ω·r) / max(v, ω·r)
F_traction = F_traction_max × f(slip)
```

Where f(slip) is typically a nonlinear saturation function (e.g., Pacejka Magic Formula)

### Tire Compliance

Add spring-damper for vertical dynamics:

```
F_normal = k·(r_nominal - r_actual) + d·der(r_actual)
```

### Temperature Effects

Tire pressure and grip depend on temperature:

```
r_effective = r_nominal × (1 + α_T × ΔT)
μ = μ_nominal × f(T_tire)
```

---

## References

### Theory

- Gillespie, T.D. "Fundamentals of Vehicle Dynamics" Chapter 2: Tires
- Pacejka, H.B. "Tire and Vehicle Dynamics" Chapter 3: Tire Modeling

### Modelica Reference

- File: `temp/modelica/ipowertrain/Tyres/BasicTyre.mo`
- Lines 22-25: Parameter definitions (radius, rolling resistance)
- Lines 40-49: Force and motion equations

### Standards

- SAE J2452: Stepwise Coastdown Methodology for Measuring Tire Rolling Resistance
- ISO 8767: Passenger car wheels – Method for measuring relative offset

---

## Next Steps

After Wheel is validated:

1. Integrate with **VehicleBody** component
2. Add **Brake** component for deceleration
3. Test combined: Torque → Wheel → Body (with coast-down)
4. Proceed to **Differential** for multi-wheel configuration

---

**Component Status:** 🔴 Not Started  
**Priority:** HIGH - Critical for powertrain-vehicle coupling  
**Estimated Complexity:** Medium (kinematic constraint, two domains)  
**Prerequisite Components:** None (can test standalone)
