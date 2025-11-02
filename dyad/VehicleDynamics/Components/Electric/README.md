# Electric Powertrain Components

This directory contains components for electric vehicle powertrain modeling.

## Components

### Battery.dyad
**Physics:**
- State of charge (SOC) dynamics: der(SOC) = -I / Q_capacity
- Terminal voltage: V_terminal = V_oc(SOC) - I * R_internal
- Internal resistance losses: P_loss = I² * R_internal

**Key Equations:**
```dyad
der(SOC) = -I / Q_capacity
V_oc = f(SOC)  # Voltage-SOC relationship
V_terminal = V_oc - I * R_internal
```

**Testing:** `Tests/Electric/TestBattery_*`

### ElectricMotor.dyad
**Physics:**
- Back-EMF: V_bemf = K_e * omega
- Torque generation: tau = K_t * I
- Voltage equation: V = V_bemf + I * R
- Rotational dynamics: J * alpha = tau + tau_load
- Bidirectional operation (motor and generator modes)

**Key Equations:**
```dyad
V_bemf = K_e * omega
tau = K_t * I
V = V_bemf + I * R
J * der(omega) = tau + flange.tau
```

**Note:** For ideal DC motor, K_t = K_e (in SI units)

**Testing:** `Tests/Electric/TestElectricMotor_*`

### MotorController.dyad
**Physics:**
- Mode logic (accelerate, coast, regen)
- Speed-dependent regeneration threshold
- Torque command generation

**Control Modes:**
1. **Accelerate**: throttle > 0, brake = 0
   - tau_cmd = throttle * tau_max_motor
2. **Coast**: throttle = 0, brake = 0
   - tau_cmd = 0
3. **Regen**: brake > 0, omega > omega_min_regen
   - tau_cmd = -brake * tau_max_regen
4. **Mechanical Brake**: brake > 0, omega < omega_min_regen
   - tau_cmd = 0 (use mechanical brakes)

**Testing:** Tested indirectly in integration tests

### DCDC.dyad
**Physics:**
- Voltage transformation: V_out = V_in * ratio
- Power balance: P_in = P_out / efficiency
- Current relationship: I_in = I_out * V_out / (V_in * efficiency)

**Key Equations:**
```dyad
V_out = V_in * ratio
P_out = P_in * efficiency
I_in * V_in = I_out * V_out / efficiency
```

**Bidirectional Operation:**
- Forward (motor): efficiency typical 0.90-0.98
- Reverse (regen): may use different efficiency

**Testing:** Tested indirectly in integration tests

## Electric Powertrain Architecture

```
Battery → DCDC → Motor → Mechanical Load
   ↑              ↓
   └── Controller ←┘
```

**Power Flow:**
- **Motoring**: Battery → DCDC → Motor → Wheels
- **Regeneration**: Wheels → Motor → DCDC → Battery

## Sign Conventions

### Current
- Positive = Discharge (battery) / Motoring (motor)
- Negative = Charge (battery) / Generating (motor)

### Torque
- Positive = Forward acceleration
- Negative = Braking/Regeneration

### Voltage
- Battery: p.v - n.v = terminal voltage
- Motor: p.v - n.v = applied voltage

## Energy Flow Analysis

### Motoring Mode
```
Battery:     P_elec = V * I (output)
DCDC:        P_loss = P_in * (1 - efficiency)
Motor:       P_loss = I² * R
             P_mech = tau * omega (output)
```

### Regeneration Mode
```
Wheels:      P_mech = tau * omega (input, negative)
Motor:       P_elec = V * I (output, negative current)
DCDC:        P_in < P_out (efficiency applies)
Battery:     P_stored = V * I (negative = charging)
```

## Implementation Tips

### Battery
1. Choose SOC-voltage relationship (linear or lookup)
2. Handle SOC limits (0 to 1)
3. Set appropriate initial SOC
4. Verify energy balance

### ElectricMotor
1. Use consistent K_e and K_t (equal for ideal motor)
2. Include rotor inertia J
3. Handle both motor and generator modes
4. Check power conservation

### MotorController
1. Implement smooth mode transitions
2. Use speed threshold for regen
3. Avoid discontinuities (use tanh if needed)
4. Decide throttle/brake priority

### DCDC
1. Choose transformation ratio
2. Set realistic efficiency (0.90-0.98)
3. Handle bidirectional power flow
4. Verify power balance

## Common Issues

### Battery
- **SOC drift**: Check sign of current
- **Wrong voltage drop**: Verify I * R_internal sign
- **Energy imbalance**: Check power loss calculation

### ElectricMotor
- **Runaway speed**: Wrong back-EMF sign
- **No torque**: Wrong K_t or current sign
- **Power imbalance**: Missing I² * R loss

### MotorController
- **Discontinuous torque**: Use smooth transitions
- **No regen**: Check speed threshold logic
- **Conflicting commands**: Define throttle/brake priority

### DCDC
- **Power imbalance**: Check efficiency application
- **Wrong current**: Verify bidirectional logic

## Testing Strategy

1. **Battery**: Test discharge, charge, load step independently
2. **Motor**: Test no-load, loaded, regeneration modes
3. **Integration**: Test full powertrain in `IntegrationTests/`

## See Also

- `../Tests/Electric/` - Individual component tests
- `../IntegrationTests/ElectricPowertrain.dyad` - Full system test
- `Documentation/` - Detailed physics documentation
