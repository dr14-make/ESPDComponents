# Electric Motor Component Specification

## Overview

The ElectricMotor component models a DC/BLDC motor with electrical-mechanical power conversion, back-EMF, and torque-current relationship.

---

## Physical Model

### Your Task

Model an electric motor that:

- Converts electrical power to mechanical torque (and vice versa)
- Has back-EMF proportional to rotational speed
- Has torque proportional to current
- Has electrical resistance causing losses
- Includes rotor inertia
- Operates bidirectionally (motor and generator modes)

### Key Physical Phenomena

1. **Back-EMF (Electromotive Force):**
   - Rotating motor generates voltage that opposes applied voltage
   - Proportional to angular velocity
   - Motor constant relates speed to back-EMF voltage
   - Limits no-load speed for given voltage

2. **Torque Generation:**
   - Current through windings creates torque
   - Torque constant relates current to torque
   - For ideal DC motor: torque constant = back-EMF constant (in SI units)

3. **Electrical-Mechanical Coupling:**
   - Applied voltage = back-EMF + resistive voltage drop
   - Electrical power in = mechanical power out + resistive losses
   - Bidirectional: can motor (drive) or generate (brake/regen)

4. **Rotational Dynamics:**
   - Motor has rotor inertia
   - Net torque (motor torque + load torque) causes angular acceleration

5. **Operating Modes:**
   - **Motoring:** Positive current → positive torque (driving vehicle)
   - **Regeneration:** Motor spins faster than no-load speed → negative current → charging battery

### Simplifications for Phase 2B

- **Ideal motor constants:** K_t = K_e
- **No saturation:** Linear torque-current relationship
- **No cogging or ripple:** Smooth torque
- **Constant parameters:** No temperature dependence

---

## Implementation Guidelines

### Interface Requirements

**Connectors:**

- Two `Dyad.Pin()` for electrical side (positive and negative terminals)
- `Dyad.Spline()` for mechanical shaft output

**Suggested Parameters:**

- Back-EMF constant K_e [V/(rad/s)] or [V·s/rad]
- Torque constant K_t [N·m/A]
- Winding resistance [Ω]
- Rotor inertia [kg·m²]

### Important Considerations

- **Bidirectional operation:** Must work in both motor and generator modes
- **Power conservation:** Verify P_elec = P_mech + P_loss
- **Sign conventions:** Current and torque signs must be consistent

---

## Test Harness Requirements

### Test 1: No-Load Speed

**Objective:** Verify back-EMF limits no-load speed

**Suggested Test Configuration:**

- Apply constant voltage to motor
- No mechanical load (free spinning)
- Observe acceleration to steady-state speed

**What to Validate:**

- Motor accelerates from rest
- Reaches steady-state speed where back-EMF ≈ applied voltage
- Calculate expected no-load speed
- Verify current is small at steady state (only overcoming friction/resistance)

### Test 2: Load Torque

**Objective:** Verify torque-current relationship

**Suggested Test Configuration:**

- Motor connected to mechanical load (inertia or damper)
- Apply voltage
- Measure steady-state current and torque

**What to Validate:**

- Torque proportional to current
- Power balance: electrical power in = mechanical power out + resistive losses
- Calculate expected current for given load

### Test 3: Regenerative Braking

**Objective:** Verify generator mode operation

**Suggested Test Configuration:**

- Motor initially spinning at high speed
- Reduce applied voltage or reverse polarity
- Motor acts as generator, slowing down

**What to Validate:**

- Current reverses (negative = generating)
- Motor decelerates
- Power flows from mechanical to electrical
- Verify energy is returned (would charge battery in full system)

**Configuration:**

- Apply constant voltage (e.g., 400 V)
- No load on shaft
- Measure final speed

**Expected:** ω_no_load = V / K_e (calculate first!)

### Test 2: Loaded Operation

**Configuration:**

- Constant voltage
- Apply constant load torque
- Measure equilibrium speed and current

**Expected:** Calculate I from torque, then ω from back-EMF

### Test 3: Regenerative Braking

**Configuration:**

- Motor spinning at known speed
- Apply negative torque (brake)
- Verify current reverses (charges battery)

**Expected:** Negative current, power flows to electrical side

---

## Parameter Ranges

| Type | K_t [N⋅m/A] | K_e [V/(rad/s)] | R [Ω] | J [kg⋅m²] |
|------|-------------|-----------------|-------|-----------|
| Small | 0.1-0.5 | 0.1-0.5 | 0.05-0.2 | 0.01-0.05 |
| Medium | 0.5-2.0 | 0.5-2.0 | 0.01-0.05 | 0.05-0.2 |
| Large | 2.0-10.0 | 2.0-10.0 | 0.001-0.01 | 0.2-1.0 |

---

## Validation Checklist

- [ ] Back-EMF increases with speed
- [ ] Torque proportional to current
- [ ] Power balance: P_elec = P_mech + P_loss
- [ ] Regeneration works (negative current when braking)
- [ ] No-load speed = V / K_e

---

**Status:** 🔴 Not Started  
**Priority:** HIGH  
**Complexity:** Medium (multi-domain coupling)
