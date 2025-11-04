# Wheel Component Specification

## Overview

The Wheel component models the coupling between rotational (driveline) and translational (vehicle body) domains, with explicit consideration of normal force for traction limits. This is critical for modeling realistic acceleration, braking, and the effects of load transfer.

---

## Physical Model

### Conceptual Diagram

```
        Rotational Domain          Translational Domain
              (τ, ω)                     (F, v)
                
    [Driveline] → ⊕ Wheel ⊕ → [Vehicle Body]
                   radius r
                      ↓
                   N (normal force from body)
                   ═══ (road surface)
                   
    Traction Limit: F_max = μ × N
```

### Your Task

Model a wheel that:

- Connects the **rotational driveline** (torque, angular velocity) to the **translational vehicle body** (force, linear velocity)
- Converts between domains using the wheel's rolling radius
- **Receives normal force from vehicle body** (critical for load transfer effects!)
- **Enforces traction limits** based on normal force: F_max = μ·N
- Enforces a kinematic constraint (rolling without slipping, up to traction limit)
- Optionally includes rotational inertia effects

### Key Physical Phenomena

1. **Rolling Without Slip (up to friction limit):**
   - The linear velocity of the contact patch equals the tangential velocity of the wheel
   - v = ω·r (kinematic constraint)
   - This holds AS LONG AS traction is not exceeded

2. **Force-Torque Coupling:**
   - Torque from driveline creates traction force on ground
   - Desired force: F_desired = τ / r
   - Relationship involves rolling radius as a lever arm

3. **Traction Limit (NEW - Critical!):**
   - Maximum traction depends on: F_max = μ·N
   - μ = tire-road friction coefficient (dry: 0.8-1.0, wet: 0.5-0.7)
   - N = normal force (from vehicle body, varies with load transfer!)
   - Actual traction: F = min(F_desired, F_max)
   - If F_desired > F_max → wheel spins (slip occurs)

4. **Power Conservation:**
   - Power in rotational domain equals power in translational domain (for ideal wheel)
   - Verify: τ·ω = F·v

5. **Load Transfer Interaction:**
   - During acceleration: rear wheels gain normal force → more traction!
   - During braking: front wheels gain normal force → more braking!
   - This is feedback coupling between VehicleBody and Wheel

6. **Optional Inertia:**
   - Wheel has rotational inertia that resists angular acceleration
   - May include rolling resistance as a resistive torque

### Simplifications for Phase 1

- **Zero slip (below limit):** Perfect traction when F < F_max
- **Instant saturation:** Abrupt transition at traction limit (can smooth later)
- **Rigid wheel:** No tire deflection or compliance
- **No slip dynamics:** Advanced slip models (Pacejka) for Phase 4
- **Start simple:** Begin with massless wheel, add inertia if desired

---

## Implementation Guidelines

### Interface Requirements

**Required Connectors:**

- `flange_rot`: Dyad.Spline (driveline connection - torque input from drivetrain)
- `contact`: VehicleDynamics.Connectors.WheelContact (combined traction + normal force interface to vehicle body)
  - `contact.s_traction`: Longitudinal position [m]
  - `contact.f_traction`: Traction force [N] (flow variable)
  - `contact.s_normal`: Vertical position [m] (typically fixed at 0)
  - `contact.f_normal`: Normal force [N] (flow variable)
- **ACTION:** Read WheelContact connector source to understand sign conventions!

**About WheelContact Connector:**
The WheelContact connector combines both traction and normal forces in a single interface, simplifying connections and ensuring consistent force coupling between wheels and vehicle body. See `dyad/VehicleDynamics/Connectors/WheelContact.dyad` for implementation details.

**Suggested Parameters:**

- Rolling radius [m] (typical: 0.25-0.40 m)
- Friction coefficient μ [-] (dry: 0.8-1.0, wet: 0.5-0.7, ice: 0.1-0.3)
- Optional: Rotational inertia [kg⋅m²] if including wheel mass effects

### Important Considerations

- **Sign conventions:** Torque, forces, and velocities must have consistent signs
- **Normal force direction:** N comes FROM vehicle body (check sign!)
- **Traction saturation:** Must handle F_desired > F_max smoothly
- **Power conservation:** Rotational power must equal translational power (when not slipping)
- **Kinematic constraint:** v = ω·r holds when no slip occurs
- **Initialization:** If including inertia, need initial angular velocity
- **Smooth saturation:** Use tanh() for smooth transition, not hard clamp

---

## Test Harness Requirements

### Test 1: Traction Limit Verification

**Objective:** Verify that wheel respects traction limit F_max = μ·N

**Suggested Test Configuration:**

- Wheel with known radius r = 0.3 m, friction μ = 0.8
- Apply constant normal force N = 5000 N (use `TranslationalComponents.Force()`)
- Apply varying torque (ramp or step)
- Observe traction force saturation

**Components You'll Need:**

- Your Wheel component
- `TranslationalComponents.Force()` for normal force input
- `RotationalComponents.Torque()` for drive torque
- `TranslationalComponents.Mass()` for vehicle body
- `BlockComponents.Constant()` or `BlockComponents.Ramp()` for signals

**What to Validate:**

- Calculate F_max = μ·N = 0.8 × 5000 = 4000 N **before** running
- At low torque: F_traction = τ/r (linear relationship)
- At high torque: F_traction saturates at F_max = 4000 N
- Verify wheel doesn't produce more force than physically possible
- Example: τ = 2000 N·m → F_desired = 2000/0.3 = 6667 N → F_actual = 4000 N (limited!)

### Test 2: Load Transfer Effect on Traction

**Objective:** Verify that increasing normal force increases traction capacity

**Suggested Test Configuration:**

- Wheel with known parameters
- Vary normal force (simulate load transfer)
- Apply constant high torque (exceeds initial traction limit)
- Observe how traction force increases with normal force

**What to Validate:**

- At N = 3000 N: F_max = 0.8 × 3000 = 2400 N
- At N = 5000 N: F_max = 0.8 × 5000 = 4000 N
- At N = 7000 N: F_max = 0.8 × 7000 = 5600 N
- With same torque, traction force should scale with normal force
- This demonstrates why load transfer matters!

### Test 3: Kinematic Verification (No Slip)

**Objective:** Verify the rolling-without-slip relationship below traction limit

**Suggested Test Configuration:**

- Wheel with known radius
- Apply moderate torque (below traction limit)
- Apply adequate normal force
- Measure resulting linear and angular velocities

**What to Validate:**

- Calculate expected relationship: v = ω·r
- Verify v/ω = r (error < 0.1%)
- Check power conservation: τ·ω = F·v (when not saturated)
- Verify no slip occurs when within traction limit

### Test 4: Wheel Spin Scenario

**Objective:** Verify behavior when traction limit is exceeded

**Suggested Test Configuration:**

- Rear-wheel-drive scenario
- Low normal force (e.g., lightweight vehicle or ice)
- High torque demand (aggressive acceleration)
- Observe traction saturation and reduced acceleration

**What to Validate:**

- Calculate available traction: F_max = μ·N
- Calculate desired traction: F_desired = τ/r
- If F_desired > F_max: vehicle acceleration limited by F_max, not τ
- Acceleration: a = F_max / m (not F_desired / m)
- Energy consideration: excess torque "wasted" in wheel spin

### Test 5: Integration with VehicleBody (Advanced)

**Objective:** Verify complete load transfer feedback loop

**Suggested Test Configuration:**

- Connect Wheel to VehicleBody with normal force coupling
- Apply high torque to rear wheels
- Observe:
  1. Initial traction attempt
  2. Acceleration begins
  3. Load transfers to rear
  4. N_rear increases → F_max increases
  5. More traction available → more acceleration
  6. This is self-reinforcing (up to a limit)

**What to Validate:**

- Calculate initial F_max with static weight distribution
- As vehicle accelerates, rear N increases
- Traction capacity increases dynamically
- Final acceleration higher than would be possible without load transfer
- This is realistic vehicle dynamics!

---

## Parameter Ranges

### Typical Values

| Parameter | Small Car | Mid-Size Car | SUV/Truck |
|-----------|-----------|--------------|-----------|
| Radius (m) | 0.25-0.28 | 0.30-0.34 | 0.35-0.42 |
| Tire Size | 175/65R14 | 205/55R16 | 265/70R17 |
| Friction μ [-] | See table below | See table below | See table below |
| Inertia (kg⋅m²) | 0.5-1.0 | 1.0-1.5 | 2.0-3.0 |
| Mass (kg) | 8-12 | 12-18 | 20-30 |

### Tire-Road Friction Coefficients (μ)

| Surface Condition | Longitudinal μ | Braking μ | Lateral μ | Notes |
|-------------------|----------------|-----------|-----------|-------|
| **Dry asphalt** | 0.8 - 1.0 | 0.9 - 1.1 | 0.7 - 0.9 | Best grip |
| **Wet asphalt** | 0.5 - 0.7 | 0.6 - 0.8 | 0.4 - 0.6 | Reduced ~30% |
| **Dry concrete** | 0.7 - 0.9 | 0.8 - 1.0 | 0.6 - 0.8 | Slightly lower |
| **Wet concrete** | 0.4 - 0.6 | 0.5 - 0.7 | 0.3 - 0.5 | Slippery |
| **Gravel** | 0.4 - 0.6 | 0.5 - 0.7 | 0.3 - 0.5 | Loose surface |
| **Snow (packed)** | 0.2 - 0.4 | 0.3 - 0.5 | 0.2 - 0.3 | Very low |
| **Ice** | 0.1 - 0.2 | 0.15 - 0.25 | 0.1 - 0.15 | Critical! |

**For Phase 1 simplicity:** Use single μ value (dry asphalt, μ = 0.8)

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
