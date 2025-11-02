# DC-DC Converter Component Specification

## Overview

The DC-DC converter transforms voltage between battery and motor with efficiency losses and power balance constraints.

---

## Physical Model

### Your Task

Model a DC-DC converter that:
- Transforms voltage level (buck/step-down or boost/step-up)
- Maintains power balance with efficiency losses
- Has input and output electrical ports
- Current relationship follows from power conservation
- Dissipates power as heat

### Key Physical Phenomena

1. **Voltage Transformation:**
   - Output voltage related to input voltage by a ratio
   - Buck converter: lowers voltage (ratio < 1)
   - Boost converter: raises voltage (ratio > 1)
   - Efficiency reduces ideal transformation

2. **Power Conservation:**
   - Input power = output power / efficiency
   - Power loss = input power - output power
   - Current and voltage inversely related through transformation

3. **Bidirectional Operation:**
   - Forward mode: battery to motor (power flow one direction)
   - Reverse mode: motor to battery during regeneration (power flow reversed)
   - Efficiency may differ by direction

### Simplifications for Phase 2B
- **Fixed ratio:** No pulse-width modulation control
- **Constant efficiency:** Independent of load
- **Instantaneous response:** No switching dynamics
- **Ideal regulation:** Perfect voltage control

---

## Implementation Guidelines

### Interface Requirements

**Connectors:**
- Two `ElectricalComponents.Pin()` for input side (battery)
- Two `ElectricalComponents.Pin()` for output side (motor)

**Suggested Parameters:**
- Voltage transformation ratio
- Efficiency [0-1] (typical: 0.90-0.98)

### Important Considerations

- **Power balance:** Input power must equal output power plus losses
- **Current direction:** Handle bidirectional power flow
- **Sign conventions:** Voltage and current signs must be consistent

---

## Test Harness Requirements

### Test 1: Steady-State Power Conversion

**Objective:** Verify voltage transformation and power balance

**Suggested Test Configuration:**
- DC-DC converter with known ratio and efficiency
- Voltage source on input
- Resistive load on output
- Measure steady-state voltages, currents, powers

**What to Validate:**
- Output voltage = input voltage × ratio (accounting for efficiency)
- Power balance: P_in = P_out / efficiency
- Calculate expected output power from input and efficiency
- Verify power loss = P_in - P_out

### Test 2: Variable Load

**Objective:** Verify converter maintains voltage ratio under changing load

**Suggested Test Configuration:**
- Step change in load resistance
- Observe voltage and power response

**What to Validate:**
- Voltage ratio maintained despite load change
- Power scales with load
- Efficiency remains constant

### Implementation Tasks

1. Enforce voltage transformation
2. Enforce power balance with efficiency
3. Calculate power loss
4. Handle bidirectional power flow (if needed)

---

## Test Harness Requirements

### Test: Step Load Response

**Configuration:**
- Input: 400 V battery
- Ratio: 0.5 (buck to 200 V)
- Efficiency: 0.95
- Step load from 0 to 50 A at output

**Expected Results (calculate!):**
- V_out = ?
- I_in = ?
- P_loss = ?

**Validation:**
- Output voltage = V_in × ratio
- Power balance: P_in = P_out / η
- Efficiency = P_out / P_in

---

## Parameter Ranges

| Type | Efficiency | Typical Ratio |
|------|-----------|---------------|
| Buck | 0.90-0.95 | 0.3-0.8 |
| Boost | 0.85-0.93 | 1.2-3.0 |
| Buck-Boost | 0.80-0.90 | 0.3-3.0 |

---

**Status:** 🔴 Not Started  
**Priority:** MEDIUM  
**Complexity:** Low (algebraic constraints)
