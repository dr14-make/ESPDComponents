# Pacejka Magic Formula Tire Model

## Overview

The Pacejka "Magic Formula" is an empirical tire model that predicts longitudinal tire forces based on wheel slip. It uses fitting coefficients to match real tire behavior without modeling the underlying physics.

---

## Physical Variables

| Symbol | Description | Units |
|--------|-------------|-------|
| Ω | Wheel angular velocity | rad/s |
| r_w | Wheel radius | m |
| V_x | Wheel hub longitudinal velocity | m/s |
| V_T | Tire tread longitudinal velocity = r_w·Ω | m/s |
| V_sx | Contact patch slip velocity = V_x - V_T | m/s |
| κ (or k) | Wheel slip ratio | - |
| F_x | Longitudinal force on tire | N |
| F_z | Vertical load on tire | N |
| F_z0 | Nominal vertical load | N |

---

## Slip Ratio Definition

The wheel slip ratio κ represents the deviation from pure rolling:

```
κ = -V_sx / |V_x| = -(V_x - r_w·Ω) / |V_x|
```

**Physical Interpretation:**
- **κ = 0:** Pure rolling (no slip) → V_x = r_w·Ω
- **κ > 0:** Driving slip (wheel spins faster than vehicle moves)
- **κ < 0:** Braking slip (wheel rotates slower than vehicle moves)
- **κ = -1:** Locked wheel (sliding)

**Sign Convention:**
- Positive slip → acceleration/driving
- Negative slip → braking

---

## Magic Formula (Constant Coefficients)

The longitudinal force is given by:

```
F_x = F_z · D · sin(C · arctan{B·κ - E·[B·κ - arctan(B·κ)]})
```

Where:
- **B:** Stiffness factor (controls initial slope)
- **C:** Shape factor (controls curve shape)
- **D:** Peak factor (peak friction coefficient μ_peak)
- **E:** Curvature factor (controls shape after peak)

**Initial Slope:**
```
dF_x/dκ|_(κ=0) = B·C·D·F_z
```

---

## Typical Coefficient Values

| Surface | B | C | D | E | Notes |
|---------|---|---|---|---|-------|
| **Dry tarmac** | 10 | 1.9 | 1.0 | 0.97 | Best grip |
| **Wet tarmac** | 12 | 2.3 | 0.82 | 1.0 | Reduced peak |
| **Snow** | 5 | 2.0 | 0.3 | 1.0 | Low grip |
| **Ice** | 4 | 2.0 | 0.1 | 1.0 | Minimal grip |

**Example: Dry Tarmac**
- Peak friction: D = 1.0 (100% of vertical load)
- At F_z = 4000 N → F_x_max = 4000 N
- Slip stiffness: B·C·D = 10 · 1.9 · 1.0 = 19

---

## Numerical Implementation Considerations

### 1. Slip Denominator Saturation

To avoid division by zero at low velocities:

```
|V_x|_saturated = max(|V_x|, V_XLOW)
```

Where V_XLOW ≈ 0.1 m/s (typical).

Use smooth transition (tanh) near V_XLOW to avoid discontinuities.

### 2. Slip Limits

Constrain slip to valid range:

```
κ_min ≤ κ ≤ κ_max
```

Typical: κ_min = -1.0 (locked wheel), κ_max = 1.0 (pure spin)

### 3. Smoothing at Zero Velocity

At low velocities, use smooth transition:

```
κ_smooth = κ · tanh(|V_x| / V_transition)
```

Where V_transition ≈ 0.1 m/s.

---

## Simplified Model for Phase 1

For initial implementation without full Pacejka complexity:

```
F_x = F_z · μ_eff(κ)
```

Where:

```
μ_eff(κ) = D · tanh(B·C·κ)
```

This approximates the Magic Formula near κ = 0 with:
- Same initial slope: B·C·D
- Saturation at: D (peak friction)
- Simple to implement and numerically stable

---

## Integration with Current Wheel Model

The current Wheel component enforces **kinematic constraint** (no slip):
```
V_x = r_w·Ω  →  κ = 0
```

To add Pacejka model:

1. **Remove kinematic constraint** `phi = s/r`
2. **Add rotational dynamics:** `J·der(Ω) = τ - F_x·r_w`
3. **Calculate slip:** `κ = -(V_x - r_w·Ω) / max(|V_x|, V_XLOW)`
4. **Calculate force:** `F_x = f_Pacejka(κ, F_z)`
5. **Apply to vehicle:** Force couples wheel rotation to vehicle motion

---

## References

1. Pacejka, H.B. (2012). "Tire and Vehicle Dynamics" (3rd ed.)
2. Pacejka, H.B., & Bakker, E. (1992). "The Magic Formula Tyre Model"
3. MATLAB/Simscape Documentation: Tire-Road Interaction (Magic Formula)

---

## Next Steps

For implementation:
1. Start with **simplified Pacejka** (tanh approximation)
2. Test with **dry tarmac** parameters first
3. Validate against **wheel spin test** (Test 4)
4. Add **load-dependent coefficients** later if needed

---

**Component Status:** 📝 Documentation Complete - Ready for Implementation  
**Prerequisite:** Current Wheel (Tests 1-4) must remain functional  
**Approach:** Create separate `WheelWithSlip` component to preserve existing tests
