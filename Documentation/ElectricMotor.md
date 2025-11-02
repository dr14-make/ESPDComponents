# Electric Motor Component Specification

## Overview

The ElectricMotor component models a DC brushless motor with electrical-mechanical power conversion, back-EMF, and torque-current relationship.

---

## Physical Model

### Governing Equations

**Electrical Side:**
```
V_applied = K_e × ω + I × R_motor
```
- `V_applied` = terminal voltage [V]
- `K_e` = back-EMF constant [V/(rad/s)]
- `ω` = angular velocity [rad/s]
- `I` = motor current [A]
- `R_motor` = winding resistance [Ω]

**Mechanical Side:**
```
τ_motor = K_t × I
J_motor × α = τ_motor + τ_load
```
- `τ_motor` = motor torque [N⋅m]
- `K_t` = torque constant [N⋅m/A]
- `J_motor` = rotor inertia [kg⋅m²]
- `α` = angular acceleration [rad/s²]
- `τ_load` = load torque [N⋅m]

**Power Balance:**
```
P_electrical = V × I
P_mechanical = τ × ω
P_loss = I² × R_motor
```

**Note:** For ideal DC motor: K_t = K_e (SI units)

### Motor Modes
- **Motoring:** I > 0, τ > 0 (power flows electrical → mechanical)
- **Generating (Regen):** I < 0, τ < 0 (power flows mechanical → electrical)

---

## Implementation Guidelines

### Interface Requirements

**Connectors:**
- `ElectricalComponents.Pin()` × 2 for electrical side (or use positive + ground)
- `RotationalComponents.Flange()` for mechanical output shaft

**Parameters:**
- Back-EMF constant K_e [V/(rad/s)]
- Torque constant K_t [N⋅m/A]
- Motor resistance R [Ω]
- Motor inertia J [kg⋅m²]

**Variables:**
- Voltage, current (electrical)
- Angular velocity, torque (mechanical)
- Power (electrical and mechanical)

### Implementation Tasks

1. Implement back-EMF equation
2. Implement torque-current relationship
3. Couple electrical and mechanical domains
4. Include rotational inertia dynamics
5. Ensure bidirectional power flow (regeneration)

---

## Test Harness Requirements

### Test 1: No-Load Speed

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
