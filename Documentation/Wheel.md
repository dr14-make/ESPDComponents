# Wheel Component Specification

## Overview

The Wheel component models the coupling between rotational (driveline) and translational (vehicle body) domains. It represents a rigid wheel with rolling radius that converts torque to traction force under a zero-slip assumption.

---

## Physical Model

### Free Body Diagram

```
        Rotational Domain          Translational Domain
              (τ, ω)                     (F, v)
                
    [Driveline] → ⊕ Wheel ⊕ → [Vehicle Body]
                   radius r
                      ↓
                   N (normal force)
                   ═══ (road surface)
```

### Governing Equations

**Kinematic Constraint (Zero-Slip):**
```
v = ω·r
```
Where:
- `v` = linear velocity of wheel contact patch [m/s]
- `ω` = angular velocity of wheel [rad/s]
- `r` = rolling radius [m]

**Force-Torque Relationship:**
```
F_traction = τ_drive / r
```
Where:
- `F_traction` = traction force at contact patch [N]
- `τ_drive` = drive torque from driveline [N⋅m]
- `r` = rolling radius [m]

**Power Conservation (Ideal Wheel):**
```
P_rotational = P_translational
τ·ω = F·v
```

**Inertia (Optional):**
```
J·α = τ_drive - τ_resistance
```
Where:
- `J` = wheel rotational inertia [kg⋅m²]
- `α` = angular acceleration [rad/s²]
- `τ_resistance` = rolling resistance torque [N⋅m]

### Simplifications for Phase 1
- **Zero slip:** Perfect traction, no wheel spin
- **Rigid wheel:** No tire deflection or compliance
- **No vertical dynamics:** Normal force assumed constant or from vehicle weight
- **Massless (option 1):** J = 0, purely kinematic coupling
- **Small inertia (option 2):** J ≈ 0.5-2.0 kg⋅m² for realism

---

## Dyad Implementation

### Option A: Massless Wheel (Simplest - Start Here)

```dyad
component WheelMassless
  # Rotational interface (driveline side)
  flange_rot = RotationalComponents.Flange()
  
  # Translational interface (vehicle body side)
  flange_trans = TranslationalComponents.Flange()
  
  # Parameters
  parameter radius::Length = 0.32              # Rolling radius [m] (typical: 0.25-0.40)
  
  # Variables for observability
  variable omega::AngularVelocity             # Wheel angular velocity [rad/s]
  variable v::Velocity                        # Linear velocity [m/s]
  variable tau::Torque                        # Drive torque [N⋅m]
  variable F::Force                           # Traction force [N]
  
relations
  # Extract velocities from flanges
  omega = der(flange_rot.phi)
  v = der(flange_trans.s)
  
  # Zero-slip kinematic constraint
  v = omega * radius
  
  # Extract torque and force
  tau = flange_rot.tau
  F = -flange_trans.f  # Sign: positive F = forward force on vehicle
  
  # Force-torque relationship
  F = tau / radius
  
end
```

**Pros:** Simple, fast, no initialization issues
**Cons:** No inertia effects, instantaneous response

### Option B: Wheel with Inertia (More Realistic)

```dyad
component WheelWithInertia
  # Rotational interface
  flange_rot = RotationalComponents.Flange()
  
  # Translational interface
  flange_trans = TranslationalComponents.Flange()
  
  # Parameters
  parameter radius::Length = 0.32              # Rolling radius [m]
  parameter J::Inertia = 1.0                   # Rotational inertia [kg⋅m²]
  parameter Crr::Real = 0.015                  # Rolling resistance coefficient [-]
  parameter m_vehicle::Mass = 1500.0           # Vehicle mass (for rolling resistance) [kg]
  parameter g::Acceleration = 9.81             # Gravity [m/s²]
  
  # Variables
  variable omega::AngularVelocity             
  variable alpha::AngularAcceleration
  variable v::Velocity
  variable tau_drive::Torque
  variable tau_roll::Torque                    # Rolling resistance torque
  variable F_traction::Force
  variable F_roll::Force
  
relations
  # Kinematics
  omega = der(flange_rot.phi)
  alpha = der(omega)
  v = der(flange_trans.s)
  
  # Zero-slip constraint
  v = omega * radius
  
  # Rolling resistance
  F_roll = Crr * m_vehicle * g * sign(omega)
  tau_roll = F_roll * radius
  
  # Torque extraction
  tau_drive = flange_rot.tau
  
  # Rotational dynamics
  J * alpha = tau_drive - tau_roll
  
  # Force to vehicle body
  F_traction = tau_drive / radius - F_roll
  flange_trans.f = -F_traction
  
end
```

**Pros:** Realistic dynamics, smooth transients
**Cons:** More complex, requires initial conditions for omega

---

## Test Harness

### Test 1: Kinematic Verification (Massless Wheel)

**Objective:** Verify v = ω·r relationship

```dyad
test component TestWheel_Kinematics
  wheel = WheelMassless(radius = 0.3)  # 0.3 m radius
  
  # Apply constant angular velocity
  speed_source = RotationalComponents.Speed()
  constant_speed = BlockComponents.Constant(k = 10.0)  # 10 rad/s
  
  # Measure resulting linear velocity
  body = TranslationalComponents.Mass(m = 1000.0)
  
relations
  connect(constant_speed.y, speed_source.w)
  connect(speed_source.flange, wheel.flange_rot)
  connect(wheel.flange_trans, body.flange)
  
  # Initial conditions
  initial body.s = 0.0
  initial body.v = 0.0
  guess wheel.flange_trans.f = 0.0
  
end

analysis TestWheel_Kinematics_Analysis
  extends TransientAnalysis(stop = 5.0, alg = "Rodas5P")
  model = TestWheel_Kinematics()
end
```

**Expected Results:**
- ω = 10 rad/s (constant)
- v = ω·r = 10 × 0.3 = 3.0 m/s
- After transient, body velocity should match exactly

**Validation:**
```julia
omega = 10.0
r = 0.3
v_expected = omega * r  # = 3.0 m/s

# At steady state (t > 1s)
@assert abs(sol(5.0, idxs=sys.wheel.v) - v_expected) < 1e-6
@assert abs(sol(5.0, idxs=sys.wheel.omega) - omega) < 1e-6
@assert abs(sol(5.0, idxs=sys.body.v) - v_expected) < 1e-3
```

### Test 2: Force-Torque Relationship

**Objective:** Verify F = τ/r

```dyad
test component TestWheel_ForceTorque
  wheel = WheelMassless(radius = 0.3)
  
  # Apply constant torque
  torque_source = RotationalComponents.TorqueSource()
  constant_torque = BlockComponents.Constant(k = 300.0)  # 300 N⋅m
  
  # Load: mass with drag
  body = TranslationalComponents.Mass(m = 1000.0)
  damper = TranslationalComponents.Damper(d = 100.0)  # 100 N⋅s/m
  fixed = TranslationalComponents.Fixed()
  
relations
  connect(constant_torque.y, torque_source.tau)
  connect(torque_source.flange, wheel.flange_rot)
  connect(wheel.flange_trans, body.flange_a)
  connect(body.flange_b, damper.flange_a)
  connect(damper.flange_b, fixed.flange)
  
  initial body.s = 0.0
  initial body.v = 0.0
  
end
```

**Expected Results:**
- Applied torque: τ = 300 N⋅m
- Traction force: F = τ/r = 300/0.3 = 1000 N
- At steady state: F = F_damper = d·v_ss
- v_ss = F/d = 1000/100 = 10 m/s
- Power balance: P = τ·ω = F·v = 300×(10/0.3) = 10,000 W = 1000×10 ✓

**Validation:**
```julia
tau = 300.0
r = 0.3
d = 100.0
F_expected = tau / r  # 1000 N
v_ss_expected = F_expected / d  # 10 m/s
omega_ss = v_ss_expected / r  # 33.33 rad/s

@assert abs(sol(10.0, idxs=sys.wheel.F) - F_expected) < 1.0
@assert abs(sol(10.0, idxs=sys.body.v) - v_ss_expected) < 0.1
@assert abs(sol(10.0, idxs=sys.wheel.omega) - omega_ss) < 0.5
```

### Test 3: Wheel with Inertia Response

**Objective:** Verify rotational dynamics J·α = τ

```dyad
test component TestWheel_Inertia
  wheel = WheelWithInertia(
    radius = 0.3,
    J = 2.0,               # 2 kg⋅m²
    Crr = 0.0,             # Ignore rolling resistance for this test
    m_vehicle = 1000.0
  )
  
  # Step torque input
  torque_source = RotationalComponents.TorqueSource()
  step_torque = BlockComponents.Step(
    height = 100.0,        # 100 N⋅m step
    offset = 0.0,
    startTime = 1.0
  )
  
  # Very heavy vehicle (acts like fixed load for inertia test)
  body = TranslationalComponents.Mass(m = 1e6)
  
relations
  connect(step_torque.y, torque_source.tau)
  connect(torque_source.flange, wheel.flange_rot)
  connect(wheel.flange_trans, body.flange)
  
  initial wheel.flange_rot.phi = 0.0
  initial der(wheel.flange_rot.phi) = 0.0
  initial body.s = 0.0
  initial body.v = 0.0
  
end
```

**Expected Results:**
- Before t=1s: ω = 0, α = 0
- At t=1s: Step torque applied
- Angular acceleration: α = τ/J = 100/2 = 50 rad/s²
- Linear acceleration: a = α·r = 50×0.3 = 15 m/s²
- After 1 second: ω = 50 rad/s, v = 15 m/s

**Validation:**
```julia
tau = 100.0
J = 2.0
r = 0.3
alpha_expected = tau / J  # 50 rad/s²
a_expected = alpha_expected * r  # 15 m/s²

# Just after step at t = 1.01s
@assert abs(sol(1.01, idxs=sys.wheel.alpha) - alpha_expected) < 1.0
@assert abs(sol(1.01, idxs=sys.body.a) - a_expected) < 0.5

# After some time: t = 2.0s (1 second after step)
omega_at_2s = alpha_expected * 1.0  # = 50 rad/s
@assert abs(sol(2.0, idxs=sys.wheel.omega) - omega_at_2s) < 2.0
```

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
