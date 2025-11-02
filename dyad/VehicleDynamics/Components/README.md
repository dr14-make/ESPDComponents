# VehicleDynamics Components

This directory contains the core components for vehicle dynamics modeling.

## Component Organization

### Mechanical Components
- **VehicleBody.dyad** - Translational dynamics with aerodynamic drag and rolling resistance
- **Wheel.dyad** - Rotational-translational coupling with rolling constraint
- **Brake.dyad** - Friction braking system

### Powertrain Components
- **Engine.dyad** - Speed-dependent torque source
- **Gearbox.dyad** - Multi-ratio transmission
- **Differential.dyad** - Open differential with torque splitting

### Electric Powertrain (`Electric/`)
- **Battery.dyad** - Energy storage with SOC dynamics
- **ElectricMotor.dyad** - DC/BLDC motor with back-EMF
- **MotorController.dyad** - Torque command with regenerative braking
- **DCDC.dyad** - Voltage converter with efficiency

## Implementation Guide

### 1. Read Component Header
Each component file contains:
- Physics description
- Interface (connectors)
- TODO sections with examples
- Implementation hints
- Validation reminders

### 2. Understand the Physics
Before coding:
- Review the physics equations in Documentation/
- Understand sign conventions
- Identify state variables vs algebraic variables
- Plan conservation law verification

### 3. Implement Step-by-Step

**Parameters:**
```dyad
parameter m::Mass = 1500.0           # Vehicle mass [kg]
parameter Cd::Real = 0.32            # Drag coefficient [-]
```

**Variables:**
```dyad
variable v::Velocity                 # Velocity [m/s]
variable F_drag::Force               # Drag force [N]
```

**Relations:**
```dyad
relations
  v = der(flange.s)
  F_drag = 0.5 * rho * Cd * A * v^2
  flange.f = -F_drag  # Force opposes motion
end
```

### 4. Sign Conventions

**Critical for correct physics:**
- **Connectors**: Follow MTK/Dyad conventions
  - Pin.i > 0: current INTO component
  - Flange.f > 0: force ON the flange
  - Flange.tau > 0: torque ON the flange
- **Resistance Forces**: Always oppose motion (negative signs)
- **Power Flow**: Verify P_in = P_out + P_loss

### 5. Handle Edge Cases
- Division by zero (v=0 for sign functions)
- Smooth approximations (tanh instead of sign)
- Physical limits (SOC between 0 and 1)

### 6. Component Testing
After implementation:
1. Go to `../Tests/ComponentName/`
2. Implement test harnesses
3. Calculate expected results
4. Run and validate
5. Verify energy conservation

## Component Dependencies

### Standalone Components
- VehicleBody
- Engine
- Brake
- Battery
- MotorController
- DCDC

### Coupled Components
- Wheel (needs rotational AND translational connections)
- Gearbox (needs two rotational connections)
- Differential (needs three rotational connections)
- ElectricMotor (needs electrical AND rotational connections)

## Domain Interfaces

### Electrical
```dyad
p = ElectricalComponents.Pin()  # Positive terminal
n = ElectricalComponents.Pin()  # Negative terminal
```

### Rotational
```dyad
flange = RotationalComponents.Flange()
```

### Translational
```dyad
flange = TranslationalComponents.Flange()
```

### Control/Signal
```dyad
input = RealInput()
output = RealOutput()
```

## Common Pitfalls

1. **Wrong Sign**: Resistance forces must oppose motion
2. **Missing Dynamics**: Forgetting der() for differential equations
3. **Algebraic Loops**: Circular dependencies without dynamics
4. **Unit Inconsistency**: Mix SI units consistently
5. **Conservation Violation**: Power/energy not conserved

## Next Steps

1. Start with simplest component (e.g., Wheel or VehicleBody)
2. Implement one component at a time
3. Test thoroughly before moving to next
4. Build up to integration tests
5. Compare conventional vs electric powertrains

See `../Tests/` for test harnesses and `../IntegrationTests/` for system-level validation.
