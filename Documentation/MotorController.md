# Motor Controller Component Specification

## Overview

The MotorController translates driver demand (throttle/brake) into motor torque commands with regenerative braking capability.

---

## Physical Model

### Control Logic

**Torque Command:**
```
τ_cmd = throttle × τ_max_motor    (if throttle > 0)
τ_cmd = brake × τ_max_regen × (-1) (if brake > 0 and ω > ω_min_regen)
```

**Regenerative Braking Conditions:**
- Motor speed above minimum threshold (ω > ω_min)
- Brake pedal pressed
- Battery not fully charged (SOC < SOC_max)

**Current Command:**
```
I_cmd = τ_cmd / K_t
```

---

## Implementation Guidelines

### Interface Requirements

**Connectors:**
- `BlockComponents.RealInput()` for throttle [0-1]
- `BlockComponents.RealInput()` for brake [0-1]
- `BlockComponents.RealInput()` for motor speed (feedback)
- `BlockComponents.RealOutput()` for torque command [N⋅m]

**Parameters:**
- Maximum motor torque [N⋅m]
- Maximum regen torque [N⋅m]
- Minimum regen speed [rad/s]
- Torque constant K_t [N⋅m/A]

### Implementation Tasks

1. Read throttle and brake inputs
2. Calculate torque command based on mode
3. Implement regeneration logic with speed threshold
4. Output torque command (or current command)
5. Handle mode transitions smoothly

---

## Test Harness Requirements

### Test 1: Acceleration

**Configuration:**
- Throttle: 0.5 (50%)
- Brake: 0
- Motor speed: increasing from 0

**Expected:** τ_cmd = 0.5 × τ_max

### Test 2: Regenerative Braking

**Configuration:**
- Throttle: 0
- Brake: 0.3 (30%)
- Motor speed: 100 rad/s (above threshold)

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
