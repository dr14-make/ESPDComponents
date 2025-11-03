# Gearbox Component Specification

## Overview

The Gearbox component models a multi-ratio transmission with discrete gear ratios and mechanical efficiency losses.

---

## Physical Model

### Your Task

Model a multi-speed gearbox that:

- Has input and output rotational flanges
- Receives a gear selection command (integer: 1, 2, 3, etc.)
- Implements different speed ratios for each gear
- Multiplies torque inversely to speed ratio
- Includes efficiency losses
- Maintains power conservation (with losses)

### Key Physical Phenomena

1. **Gear Ratios:**
   - Each gear has a different speed ratio
   - **Low gears (1st, 2nd):** High ratio = low output speed, high output torque (acceleration)
   - **High gears (4th, 5th):** Low ratio = high output speed, low output torque (cruising)
   - Typical 5-speed: [3.5, 2.0, 1.3, 1.0, 0.8]

2. **Speed-Torque Trade-off:**
   - Output speed inversely proportional to ratio
   - Output torque proportional to ratio
   - Power ideally conserved (torque × speed in = torque × speed out, minus losses)

3. **Mechanical Losses:**
   - Efficiency factor (typically 95-98%)
   - Reduces output power relative to input
   - Losses converted to heat

4. **Discrete Gear Selection:**
   - Gear number is an integer input
   - Instant switching between ratios (Phase 1 simplification)
   - No clutch slip or synchromesh dynamics

### Simplifications for Phase 1

- **Instant shifting:** No transition dynamics between gears
- **No clutch:** Direct connection assumed
- **Constant efficiency:** Not load or speed dependent
- **No neutral/reverse:** Only forward gears

---

## Implementation Guidelines

### Interface Requirements

**Required Connectors:**

- Two `Dyad.Spline()` connections (input from engine, output to driveline)
- `Dyad.IntegerInput()` for gear selection (integer signal)

**Suggested Parameters:**

- Array/vector of gear ratios (one per gear)
- Efficiency value(s)
- Optional: Input shaft inertia

### Important Considerations

- **Array/vector parameters:** May need to use Dyad array syntax or multiple parameters
- **Gear selection logic:** Handle bounds (what if gear command is 0 or > max?)
- **Power conservation:** Check that P_out ≈ P_in × efficiency
- **Sign conventions:** Torque direction through transformation

---

## Test Harness Requirements

### Test 1: Fixed Gear Ratio Verification

**Objective:** Verify speed ratio and torque multiplication for a single gear

**Suggested Test Configuration:**

- Gearbox set to specific gear (e.g., 2nd gear, ratio = 2.0)
- Apply input torque
- Connect load to output
- Verify relationships

**What to Validate:**

- Output speed = input speed / ratio
- Output torque ≈ input torque × ratio × efficiency
- Power conservation with losses

### Test 2: Gear Shifting

**Objective:** Verify behavior when changing gears

**Suggested Test Configuration:**

- Start in one gear
- Change gear command during simulation
- Observe speed and torque changes

**What to Validate:**

- Speed ratio changes instantly (Phase 1)
- Torque multiplication changes accordingly
- No discontinuities that break solver
- System remains stable through shifts

---

## Test Harness

### Test 1: Fixed Gear Ratio Verification

```dyad
test component TestGearbox_FixedGear
  gearbox = GearboxSimple(
    ratios = [3.0, 2.0, 1.5, 1.0, 0.75],
    efficiencies = [0.95, 0.96, 0.97, 0.97, 0.97],
    tau_loss = 5.0
  )
  
  # Fixed gear 3 (ratio = 1.5)
  gear_select = BlockComponents.IntegerConstant(k = 3)
  
  # Input: constant speed
  speed_source = RotationalComponents.Speed()
  speed_cmd = BlockComponents.Constant(k = 100.0)  # 100 rad/s
  
  # Output: load
  load = RotationalComponents.Inertia(J = 2.0)
  
relations
  connect(gear_select.y, gearbox.gear_cmd)
  connect(speed_cmd.y, speed_source.w)
  connect(speed_source.flange, gearbox.flange_in)
  connect(gearbox.flange_out, load.flange)
  
  initial load.phi = 0.0
  initial der(load.phi) = 0.0
end
```

**Expected Results:**

- Gear 3: ratio = 1.5, η = 0.97
- Input speed: ω_in = 100 rad/s
- Output speed: ω_out = 100/1.5 = 66.67 rad/s
- At equilibrium (zero acceleration):
  - τ_in ≈ τ_loss / (1 - ratio×η) (complex, verify numerically)

**Validation:**

```julia
@assert gearbox.gear == 3
@assert abs(gearbox.ratio - 1.5) < 1e-6
@assert abs(sol(5.0, idxs=sys.gearbox.omega_out) - 66.67) < 0.5
```

### Test 2: Gear Shift Sequence

```dyad
test component TestGearbox_Shifting
  gearbox = GearboxSimple(
    ratios = [3.5, 2.0, 1.3, 1.0],
    efficiencies = [0.96, 0.97, 0.97, 0.97]
  )
  
  # Gear sequence: 1 → 2 → 3 → 4
  gear_select = BlockComponents.IntegerStep([
    (time = 0.0, value = 1),
    (time = 2.0, value = 2),
    (time = 4.0, value = 3),
    (time = 6.0, value = 4)
  ])
  
  # Constant input torque
  torque_source = RotationalComponents.TorqueSource()
  torque_cmd = BlockComponents.Constant(k = 100.0)
  
  # Load
  load = RotationalComponents.Damper(d = 0.2)
  fixed = RotationalComponents.Fixed()
  
relations
  connect(gear_select.y, gearbox.gear_cmd)
  connect(torque_cmd.y, torque_source.tau)
  connect(torque_source.flange, gearbox.flange_in)
  connect(gearbox.flange_out, load.flange_a)
  connect(load.flange_b, fixed.flange)
  
  initial gearbox.flange_in.phi = 0.0
  initial der(gearbox.flange_in.phi) = 0.0
end
```

**Expected Results:**

- Each gear produces different output torque
- Gear 1 (ratio=3.5): τ_out ≈ 100×3.5×0.96 = 336 N⋅m
- Gear 4 (ratio=1.0): τ_out ≈ 100×1.0×0.97 = 97 N⋅m
- Output speed increases with higher gears (lower ratio)
- **Note:** Discrete shifts cause discontinuities (Phase 4: add smooth shifting)

---

## Parameter Ranges

### Typical Gear Ratios

**Manual Transmission (5-speed):**

```
1st: 3.5-4.5
2nd: 2.0-2.5
3rd: 1.3-1.7
4th: 1.0-1.2
5th: 0.7-0.9 (overdrive)
```

**Automatic Transmission (6-speed):**

```
1st: 4.0-5.0
2nd: 2.5-3.0
3rd: 1.5-2.0
4th: 1.0-1.5
5th: 0.8-1.0
6th: 0.6-0.8 (overdrive)
```

**Performance (close-ratio):**

- Smaller steps between gears (1.2-1.4× ratio change)
- Keeps engine in power band

**Economy (wide-ratio):**

- Larger steps (1.5-2.0× ratio change)
- Optimizes fuel efficiency

### Efficiency Values

- Manual transmission: η = 0.94-0.97
- Automatic (torque converter): η = 0.85-0.92
- Dual-clutch (DCT): η = 0.95-0.98
- CVT: η = 0.85-0.90

---

## Advanced Features (Phase 4)

### Smooth Gear Shifting

Interpolate ratio during shifts:

```
gear_actual = gear_cmd + shift_rate × dt
ratio = interpolate(ratios, gear_actual)
```

Prevents discontinuities, models synchronizer action.

### Shift Dynamics

Add shift time delay and torque interruption:

```
if shifting:
  tau_out = 0  # Torque interruption
  t_shift = 0.1-0.3 s  # Shift duration
```

### Neutral Gear

```
if gear == 0:
  flange_in and flange_out decoupled
  tau_out = 0
```

### Reverse Gear

Negative ratio: `ratio_reverse = -3.5`

---

## Validation Checklist

- [ ] Speed ratio: ω_out/ω_in = 1/ratio (error < 1%)
- [ ] Torque multiplication: τ_out = τ_in × ratio × η
- [ ] Power with losses: P_out = P_in × η - P_loss
- [ ] All gears selectable (1 to N)
- [ ] Efficiency < 1.0 (no energy creation)
- [ ] Higher gear → lower ratio → higher speed

---

## Common Issues

### Issue 1: Discontinuous Shifts

**Problem:** Instantaneous ratio change causes solver issues
**Solution:**

- Phase 1: Accept small discontinuity, use stiff solver
- Phase 4: Implement smooth shifting with time constant

### Issue 2: Efficiency Direction

**Problem:** Efficiency should degrade in both directions
**Solution:** Check power flow direction, apply η correctly

### Issue 3: Invalid Gear Selection

**Problem:** gear_cmd outside valid range
**Solution:** Bounds checking with default to gear 1

---

**Component Status:** 🔴 Not Started  
**Priority:** HIGH  
**Complexity:** Medium-High (discrete states, efficiency)  
**Prerequisites:** None (can test standalone)

---

## Reference

- Modelica: `temp/modelica/ipowertrain/Gearsets/TransmissionGearbox.mo`
- Naunheimer, H. "Automotive Transmissions"
- SAE J2926: Transmission Efficiency Measurement
