# Driver Controller Component Specification

## Overview

The DriverController component models driver behavior for speed tracking in drive cycle simulations. It generates throttle and brake commands to follow a target speed profile.

---

## Physical Model

### Control Strategy

**Simple PI Controller:**
```
error = v_target - v_actual

throttle = Kp × error + Ki × ∫error dt    (if error > 0)
brake = -Kp × error                         (if error < 0)
```

**Constraints:**
```
throttle ∈ [0, 1]
brake ∈ [0, 1]
```

### Advanced Strategy (Phase 3+)
- Predictive control: anticipate speed changes
- Gear selection logic based on speed/throttle
- Smooth transitions to avoid aggressive inputs

---

## Dyad Implementation (Simplified)

```dyad
component DriverControllerPI
  # Inputs
  speed_target = BlockComponents.RealInput()    # Target speed [m/s]
  speed_actual = BlockComponents.RealInput()    # Actual speed [m/s]
  
  # Outputs
  throttle = BlockComponents.RealOutput()       # Throttle command [0, 1]
  brake = BlockComponents.RealOutput()          # Brake command [0, 1]
  
  # Parameters
  parameter Kp::Real = 0.5                      # Proportional gain
  parameter Ki::Real = 0.1                      # Integral gain
  parameter deadband::Velocity = 0.5            # Speed error deadband [m/s]
  
  # Variables
  variable v_target::Velocity
  variable v_actual::Velocity
  variable error::Velocity                      # Speed error
  variable error_integral::Real                 # Integrated error
  variable throttle_raw::Real
  variable brake_raw::Real
  
relations
  # Read inputs
  v_target = speed_target.u
  v_actual = speed_actual.u
  
  # Calculate error
  error = v_target - v_actual
  
  # Integral (with anti-windup)
  der(error_integral) = if abs(error) > deadband then error else 0
  
  # Control law
  throttle_raw = if error > deadband then
    Kp * error + Ki * error_integral
  else
    0.0
  
  brake_raw = if error < -deadband then
    -Kp * error
  else
    0.0
  
  # Saturate outputs
  throttle.y = clamp(throttle_raw, 0.0, 1.0)
  brake.y = clamp(brake_raw, 0.0, 1.0)
  
end
```

---

## Test Harness

### Test: Step Speed Target

```dyad
test component TestDriverController
  controller = DriverControllerPI(
    Kp = 0.3,
    Ki = 0.05,
    deadband = 0.2
  )
  
  # Target: step from 0 to 20 m/s at t=1s
  target_speed = BlockComponents.Step(
    height = 20.0,
    offset = 0.0,
    startTime = 1.0
  )
  
  # Simplified vehicle (1st order lag)
  # dv/dt = (throttle × a_max - brake × b_max) / τ
  # This would connect to actual vehicle model
  
relations
  connect(target_speed.y, controller.speed_target)
  # ... connect to vehicle, feedback actual speed
end
```

**Expected Results:**
- At t < 1s: error = 0, throttle = 0, brake = 0
- At t = 1s: error = 20 m/s, throttle increases
- Vehicle accelerates, error decreases
- Steady state: v ≈ 20 m/s, error ≈ 0
- Overshoot < 10%, settling time < 10s

---

## Tuning Guidelines

### Proportional Gain (Kp)
- Too low: slow response, large steady-state error
- Too high: overshoot, oscillation
- Typical: 0.1-0.5 for vehicle control

### Integral Gain (Ki)
- Eliminates steady-state error
- Too high: overshoot, instability
- Typical: 0.01-0.1

### Deadband
- Prevents chattering around target speed
- Too large: sluggish response
- Typical: 0.2-1.0 m/s

---

## Validation Checklist

- [ ] Step response: reaches target within 10s
- [ ] Overshoot < 20%
- [ ] No steady-state error (integral action working)
- [ ] Smooth throttle/brake commands (no chattering)
- [ ] Saturation handling: outputs stay in [0, 1]

---

**Component Status:** 🔴 Not Started  
**Priority:** MEDIUM (needed for Phase 3 drive cycles)  
**Complexity:** Low-Medium (control logic)  
**Prerequisites:** Working vehicle model for closed-loop testing

---

## Reference

- Control theory: Åström & Murray "Feedback Systems"
- Drive cycle tracking: EPA FTP-75, WLTP standards
