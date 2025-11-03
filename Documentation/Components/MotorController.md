# Motor Controller Component Specification

## Overview

The MotorController translates driver demand (throttle/brake) into motor torque commands with regenerative braking capability.

---

## Physical Model

### Your Task

Model a motor controller that:

- Receives throttle input (0-1) from driver
- Receives brake input (0-1) from driver
- Receives motor speed feedback
- Outputs torque command to motor
- Implements regenerative braking logic
- Handles mode transitions (drive, coast, regen brake)

### Key Physical Phenomena

1. **Throttle Mapping:**
   - Throttle input (0-1) maps to motor torque command
   - 0 = no torque, 1 = maximum motor torque
   - Linear or nonlinear mapping

2. **Regenerative Braking:**
   - When brake is pressed and motor is spinning, use motor as generator
   - Negative torque command slows vehicle while generating electrical power
   - Only works above minimum speed threshold
   - Limited by maximum regen torque (battery charge rate, motor limits)

3. **Mode Logic:**
   - **Accelerate:** Throttle > 0, brake = 0 → positive torque
   - **Coast:** Throttle = 0, brake = 0 → zero torque (or small drag)
   - **Regen:** Brake > 0, speed sufficient → negative torque
   - **Mechanical brake:** Brake > 0, speed too low for regen → mechanical brakes (separate system)

4. **Speed Threshold:**
   - Regen ineffective at very low speeds
   - Below threshold, rely on mechanical brakes
   - Smooth transition between regen and mechanical

### Simplifications for Phase 2B

- **Simple logic:** No PID control, direct mapping
- **No blending:** Regenerative vs mechanical braking not blended (just threshold)
- **No battery feedback:** Don't check SOC for regen limiting
- **No thermal limits:** Assume motor can sustain torque

---

## Implementation Guidelines

### Interface Requirements

**Connectors:**

- `Dyad.RealInput()` for throttle [0-1]
- `Dyad.RealInput()` for brake [0-1]
- `Dyad.RealInput()` for motor speed feedback [rad/s]
- `Dyad.RealOutput()` for torque command [N·m]

**Suggested Parameters:**

- Maximum motor torque (positive) [N·m]
- Maximum regen torque (magnitude) [N·m]
- Minimum speed for regen [rad/s]

### Important Considerations

- **Priority logic:** What if throttle AND brake both pressed?
- **Sign conventions:** Positive torque = forward acceleration, negative = braking
- **Smooth transitions:** Avoid discontinuous torque commands

---

## Test Harness Requirements

### Test 1: Acceleration Mode

**Objective:** Verify throttle to torque mapping

**Suggested Test Configuration:**

- Provide various throttle inputs (0, 0.5, 1.0)
- Brake = 0
- Motor speed > 0

**What to Validate:**

- Torque output scales with throttle
- Torque = throttle × max_torque
- No regen torque when throttle active

### Test 2: Regenerative Braking

**Objective:** Verify regen mode activation and torque

**Suggested Test Configuration:**

- Throttle = 0
- Brake input (0.5, then 1.0)
- Motor speed above regen threshold

**What to Validate:**

- Torque command becomes negative
- Magnitude proportional to brake input
- Only activates above speed threshold

### Test 3: Low-Speed Transition

**Objective:** Verify regen disables below speed threshold

**Suggested Test Configuration:**

- Brake pressed
- Motor speed ramping down through threshold

**What to Validate:**

- Regen torque active above threshold
- Regen torque goes to zero below threshold
- Smooth transition (no discontinuity)

**Expected:** τ_cmd < 0 (negative torque for braking)

### Test 3: Low-Speed Friction Braking

**Configuration:**

- Brake: 0.5
- Motor speed: 5 rad/s (below regen threshold)

**Expected:** τ_cmd = 0 (use friction brakes instead)

---

## Validation Checklist

- [ ] Torque proportional to throttle
- [ ] Regeneration only at sufficient speed
- [ ] Smooth transitions between modes
- [ ] No simultaneous throttle and brake

---

**Status:** 🔴 Not Started  
**Priority:** MEDIUM  
**Complexity:** Low (control logic)
