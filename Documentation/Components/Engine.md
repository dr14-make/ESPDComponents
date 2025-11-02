# Engine Component Specification

## Overview

The Engine component models an internal combustion engine as a torque source with speed-dependent characteristics, rotational inertia, and throttle control.

---

## Physical Model

### Your Task

Model an internal combustion engine that:
- Produces torque based on throttle input (0-1 range)
- Has a characteristic torque curve that varies with engine speed
- Includes rotational inertia of the crankshaft and moving parts
- Has friction losses that oppose rotation
- Can accelerate/decelerate based on net torque

### Key Physical Phenomena

1. **Speed-Dependent Torque:**
   - Maximum available torque varies with engine speed
   - Typical curve: low at idle, peaks at mid-range RPM, drops at high RPM
   - Throttle position scales the torque (0% = no torque, 100% = max available)

2. **Rotational Inertia:**
   - Engine has rotational mass (flywheel, crankshaft, pistons)
   - Resists changes in angular velocity
   - Net torque causes angular acceleration

3. **Friction Losses:**
   - Internal friction opposes rotation
   - Can be constant or speed-dependent
   - Reduces net output torque

4. **Power Characteristics:**
   - Power = Torque × Speed
   - Power curve typically peaks at higher RPM than torque curve

### Simplifications for Phase 1
- **Simple torque curve:** Use analytical function (parabola, polynomial) instead of lookup table
- **Simplified friction:** Constant friction torque
- **No thermal effects:** Ignore temperature-dependent performance
- **Instant response:** No combustion cycle dynamics

---

## Implementation Guidelines

### Interface Requirements

**Required Connectors:**
- `RotationalComponents.Flange()` for mechanical output to driveline
- `BlockComponents.RealInput()` for throttle command [0, 1]

**Suggested Parameters:**
- Engine inertia [kg⋅m²]
- Peak torque [N⋅m]
- Engine speed at peak torque [rad/s or rpm]
- Maximum engine speed [rad/s or rpm]
- Friction torque [N⋅m]

### Important Considerations

- **Torque curve shape:** Research typical gasoline/diesel engine characteristics
- **Speed limits:** Engine should not exceed maximum speed (fuel cut, rev limiter)
- **Sign conventions:** Positive torque accelerates engine
- **Initialization:** Need initial engine speed (idle RPM)

---

## Test Harness Requirements

### Test 1: No-Load Acceleration

**Objective:** Verify torque curve shape and speed-dependent behavior

**Suggested Test Configuration:**
- Engine with no load (free to spin)
- Ramp throttle from 0 to 100%
- Observe acceleration profile and final speed

**What to Validate:**
- Engine accelerates when throttle applied
- Speed increases follow expected torque curve behavior
- Friction limits maximum no-load speed
- Plot torque vs. speed and compare to intended curve shape

### Test 2: Steady-State with Load

**Objective:** Verify equilibrium between engine torque and load

**Suggested Test Configuration:**
- Engine with resistive load (damper or constant torque)
- Apply constant throttle
- Wait for steady-state speed

**What to Validate:**
- System reaches equilibrium (constant speed)
- Calculate expected equilibrium speed where engine torque = load + friction
- Verify simulation matches calculation
- Power balance: power produced = power dissipated

---

## Parameter Ranges

| Engine Type | Displacement | Peak Torque | Peak Speed | Inertia |
|-------------|--------------|-------------|------------|---------|
| Small 4-cyl | 1.0-1.6 L | 100-140 N⋅m | 3500-4500 rpm | 0.10-0.15 kg⋅m² |
| Mid 4-cyl | 1.8-2.5 L | 150-220 N⋅m | 4000-5000 rpm | 0.15-0.25 kg⋅m² |
| V6 | 2.5-3.5 L | 220-320 N⋅m | 4000-5500 rpm | 0.25-0.40 kg⋅m² |
| V8 | 4.0-6.0 L | 350-600 N⋅m | 3500-5000 rpm | 0.40-0.70 kg⋅m² |

---

## Advanced Features (Phase 4)

### Map-Based Engine
Use 2D lookup table: `τ = f(ω, throttle)`
- Read from external data file
- More accurate for specific engines
- Include fuel consumption maps

### Thermal Effects
- Coolant temperature affects performance
- Thermal inertia and heat rejection
- Integration with cooling system

### Starter Motor
- Cranking torque to start engine
- Key-on logic

---

## Validation Checklist

- [ ] Torque curve shape matches theory
- [ ] Peak torque at specified speed
- [ ] Zero torque at throttle = 0
- [ ] Friction opposes motion
- [ ] Energy balance: P_in = P_out + P_friction
- [ ] Stable operation under load

---

**Component Status:** 🔴 Not Started  
**Priority:** HIGH - Core powertrain component  
**Complexity:** Medium  
**Prerequisites:** None (standalone test possible)

---

## Reference

- Modelica: `temp/modelica/ipowertrain/Engines/BasicEngine.mo`
- Heywood, J.B. "Internal Combustion Engine Fundamentals"
