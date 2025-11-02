# Battery Component Specification

## Overview

The Battery component models an electrical energy storage system with voltage-current characteristics, state of charge (SOC) dynamics, and internal resistance effects.

---

## Physical Model

### Governing Equations

**Terminal Voltage:**

```
V_terminal = V_oc - I × R_internal
```

Where:

- `V_terminal` = voltage at battery terminals [V]
- `V_oc` = open-circuit voltage (function of SOC) [V]
- `I` = current (positive = discharge, negative = charge) [A]
- `R_internal` = internal resistance [Ω]

**State of Charge Dynamics:**

```
dSOC/dt = -I / Q_capacity
```

Where:

- `SOC` ∈ [0, 1] = state of charge (1 = full, 0 = empty)
- `Q_capacity` = battery capacity [A⋅s] or [A⋅h]
- Negative sign: discharge (I > 0) decreases SOC

**Open-Circuit Voltage:**

```
V_oc(SOC) = V_nominal + k × (SOC - 0.5)
```

Simple linear approximation:

- `V_nominal` = nominal voltage at SOC=0.5
- `k` = voltage sensitivity to SOC

**Power:**

```
P_electrical = V_terminal × I
P_loss = I² × R_internal
P_stored = -d(Energy)/dt = -V_oc × I
```

### Simplifications for Phase 2B

- **Linear V_oc(SOC):** Simple approximation (realistic curves in Phase 4)
- **Constant R_internal:** No temperature or SOC dependence
- **No thermal effects:** Assume constant temperature
- **Ideal charge/discharge:** No coulombic efficiency loss

---

## Implementation Guidelines

### Interface Requirements

**Required Connectors:**

- Use `ElectricalComponents.Pin()` for positive terminal
- Use `ElectricalComponents.Pin()` for negative terminal (or ground)

**Required Parameters:**

- Nominal voltage [V]
- Capacity [A⋅h] or [A⋅s]
- Internal resistance [Ω]
- Voltage sensitivity to SOC [V]
- Initial SOC [-]

**Required Variables:**

- State of charge (SOC) [0-1]
- Open-circuit voltage [V]
- Terminal voltage [V]
- Current [A]
- Power [W]

### Implementation Tasks

1. **Electrical Interface:**
   - Terminal voltage relates to pin voltage
   - Current flows through internal resistance

2. **SOC Dynamics:**
   - SOC is differential state
   - Integrate current over time
   - Enforce limits: 0 ≤ SOC ≤ 1

3. **Voltage Calculation:**
   - Calculate V_oc from SOC
   - Apply voltage drop: V_term = V_oc - I×R

4. **Power Balance:**
   - Electrical power at terminals
   - Internal losses
   - Change in stored energy

### Important Considerations

- **Sign Convention:** Check ElectricalComponents.Pin for current direction
- **SOC Limits:** Prevent SOC < 0 or SOC > 1 (add constraints or warnings)
- **Initial Conditions:** Need initial SOC value
- **Capacity Units:** Convert A⋅h to A⋅s if needed (1 A⋅h = 3600 A⋅s)

---

## Test Harness Requirements

### Test 1: Constant Discharge

**Objective:** Verify SOC decreases linearly with constant current

**Test Configuration:**

- Battery: Capacity = 100 A⋅h, V_nominal = 400 V, R = 0.1 Ω
- Initial SOC = 1.0 (fully charged)
- Constant discharge: I = 50 A
- Simulate for 1 hour

**Required Components:**

- Your Battery component
- `ElectricalComponents.Resistor()` or `CurrentSource()` for load
- `ElectricalComponents.Ground()` for reference

**Expected Results (calculate before implementing):**

- Time to discharge: t = Q / I = ? hours
- Energy delivered: E = ? W⋅h
- Final SOC after 1 hour: SOC = ?
- Voltage drop due to internal resistance: ΔV = ?
- Power loss in internal resistance: P_loss = ?

**Validation Criteria:**

- SOC decreases linearly
- SOC(1 hour) matches calculation
- Terminal voltage = V_oc - I×R
- Energy balance: ΔE_stored = P_delivered + P_loss

### Test 2: Charge-Discharge Cycle

**Objective:** Verify battery can charge and discharge

**Test Configuration:**

- Battery: Same as Test 1
- Initial SOC = 0.5
- Discharge for 30 min at 50 A
- Charge for 30 min at 50 A (negative current)
- Total simulation: 1 hour

**Required Setup:**

- Your Battery component
- Time-varying current source (discharge then charge)
- Use `BlockComponents.Step()` to switch current direction

**Expected Results (calculate before implementing):**

- SOC after discharge phase: SOC = ?
- SOC after charge phase: SOC = ?
- Round-trip efficiency considering I²R losses
- Voltage behavior during charge vs discharge

**Validation Criteria:**

- SOC returns close to initial value (accounting for losses)
- Voltage increases during charge, decreases during discharge
- Charge accepted = Discharge delivered (minus losses)

### Test 3: Power Delivery to Load

**Objective:** Verify power delivery and voltage sag under load

**Test Configuration:**

- Battery: Capacity = 50 A⋅h, V_nominal = 400 V, R = 0.2 Ω
- Initial SOC = 0.8
- Variable resistive load: R_load steps from ∞ to 10 Ω at t=1s
- Simulate for 10 seconds

**Required Components:**

- Your Battery component
- `ElectricalComponents.Resistor()` with variable resistance
- `BlockComponents.Step()` to change load

**Expected Results (calculate before implementing):**

- Before load: I = 0, V_terminal = V_oc
- After load applied:
  - Calculate I from circuit: V_term = V_oc - I×R_internal = I×R_load
  - Solve for current: I = ?
  - Terminal voltage: V_terminal = ?
  - Power delivered: P_load = ?

**Validation Criteria:**

- Initial voltage = open-circuit voltage
- Current increases when load applied
- Voltage sags according to V = V_oc - I×R
- Power balance: P_from_battery = P_to_load + P_internal_loss

---

## Parameter Ranges

### Typical Battery Pack Values

| Application | Voltage | Capacity | Internal R | Mass |
|-------------|---------|----------|------------|------|
| Small EV | 200-400 V | 20-40 kW⋅h | 0.05-0.2 Ω | 200-400 kg |
| Mid EV | 300-500 V | 40-80 kW⋅h | 0.03-0.1 Ω | 300-600 kg |
| Large EV | 400-800 V | 80-150 kW⋅h | 0.02-0.05 Ω | 500-1000 kg |

### Conversions

- Energy: kW⋅h = Capacity [A⋅h] × Voltage [V] / 1000
- Power: P [kW] = V [V] × I [A] / 1000
- 1 A⋅h = 3600 A⋅s (for SI units in integration)

---

## Validation Checklist

### Level 1: Compiles

- [ ] No syntax errors
- [ ] Proper electrical connectors
- [ ] Units correct (A⋅h vs A⋅s)

### Level 2: Runs

- [ ] `sol.retcode == ReturnCode.Success`
- [ ] SOC stays within [0, 1]
- [ ] No numerical instabilities

### Level 3: Physics Validated

#### Electrical Behavior

- [ ] V_terminal = V_oc - I×R verified
- [ ] Open-circuit voltage matches SOC
- [ ] Current sign correct (discharge positive, charge negative)

#### Energy Balance

- [ ] Power: P = V×I
- [ ] Losses: P_loss = I²×R
- [ ] Energy stored decreases with discharge
- [ ] ΔE_stored + P_loss = Energy delivered

#### SOC Dynamics

- [ ] dSOC/dt = -I / Q_capacity
- [ ] Linear SOC decrease with constant discharge
- [ ] Charge increases SOC
- [ ] Round-trip efficiency < 100% (due to losses)

---

## Common Issues & Solutions

### Issue 1: SOC Goes Negative or > 1

**Problem:** Integration without bounds
**Solution:** Add constraints or use saturated integration

### Issue 2: Units Mismatch (A⋅h vs A⋅s)

**Problem:** SOC calculation incorrect due to units
**Solution:** Convert capacity: Q [A⋅s] = Q [A⋅h] × 3600

### Issue 3: Sign Convention Confusion

**Problem:** Charge vs discharge direction
**Solution:** Document clearly: I > 0 = discharge (SOC decreases)

### Issue 4: Algebraic Loop with Resistive Load

**Problem:** V_term and I interdependent
**Solution:** Battery Pin voltage and current resolved by solver

---

## Integration Notes

### Connection to DC-DC Converter

```dyad
# Battery high-voltage side
connect(battery.pin_positive, dcdc.input_positive)
connect(battery.pin_negative, ground.pin)
```

### Connection to Motor Controller

```dyad
# Direct battery to motor (no DC-DC)
connect(battery.pin_positive, motor_controller.power_in_positive)
connect(battery.pin_negative, ground.pin)
```

### Multiple Batteries

For series/parallel configurations (Phase 4)

---

## Advanced Topics (Phase 4)

### Nonlinear V_oc(SOC)

Realistic S-curve using lookup tables

### Temperature Effects

- R_internal = f(T)
- Thermal dynamics

### Degradation

- Capacity fade
- Resistance increase

### Battery Management System (BMS)

- Cell balancing
- Protection limits

---

## References

### Theory

- Plett, G.L. "Battery Management Systems" (Artech House)
- Tremblay, O. "Experimental Validation of a Battery Dynamic Model"

### Modelica Reference

- File: `temp/modelica/ipowertrain/HybridElectric/Battery.mo`

### Standards

- SAE J1798: Recommended Practice for Performance Rating of Electric Vehicle Battery Modules

---

**Component Status:** 🔴 Not Started  
**Priority:** HIGH - Core EV component  
**Complexity:** Medium (differential equation, electrical domain)  
**Prerequisites:** None (can test standalone)
