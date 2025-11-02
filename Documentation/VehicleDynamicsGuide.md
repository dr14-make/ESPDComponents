# Vehicle Dynamics Project Guide

## Project Organization

### Directory Structure

```
dyad/VehicleDynamics/
├── Components/                  # Component implementations
│   ├── VehicleBody.dyad
│   ├── Wheel.dyad
│   ├── Engine.dyad
│   ├── Gearbox.dyad
│   ├── Brake.dyad
│   ├── Differential.dyad
│   └── Electric/               # Electric powertrain submodule
│       ├── Battery.dyad
│       ├── ElectricMotor.dyad
│       ├── MotorController.dyad
│       └── DCDC.dyad
├── Tests/                      # Unit tests (one test per file)
│   ├── VehicleBody/
│   │   ├── TestVehicleBody_ConstantForce.dyad
│   │   ├── TestVehicleBody_AeroDrag.dyad
│   │   └── TestVehicleBody_CoastDown.dyad
│   ├── Wheel/
│   │   ├── TestWheel_Kinematics.dyad
│   │   ├── TestWheel_ForceTorque.dyad
│   │   └── TestWheel_Inertia.dyad
│   └── Electric/
│       ├── TestBattery_ConstantDischarge.dyad
│       ├── TestBattery_Charging.dyad
│       ├── TestBattery_LoadStep.dyad
│       ├── TestElectricMotor_NoLoad.dyad
│       ├── TestElectricMotor_Load.dyad
│       └── TestElectricMotor_Regeneration.dyad
└── IntegrationTests/           # Full system tests
    ├── ConventionalPowertrain.dyad
    ├── ElectricPowertrain.dyad
    └── ComparisonTest.dyad
```

## Component Implementation Workflow

### 1. Read Component Header

Each component file contains:
- Physics description (what to model)
- Interface requirements (connectors)
- TODO sections with examples
- Implementation hints
- Validation criteria

**Location of hints:** File header (comment section before `component` keyword)

### 2. Implement Component

Follow the TODO sections in the header:

```dyad
# TODO: Add parameters
# Example provided in header

# TODO: Add variables
# Example provided in header

# TODO: Implement physics (relations section)
# Hints provided in header
```

### 3. Create Test Harness

For each test aspect:
1. Open the corresponding test file
2. Follow TODO sections in test file header
3. Instantiate your component
4. Add required sources/loads
5. Connect components
6. Set initial conditions
7. Add analysis definition

### 4. Calculate Expected Results

**Before running simulation:**
- Calculate steady-state values by hand
- Estimate transient behavior
- Document expected results in test file

### 5. Run and Validate

**Validation levels:**
1. **Compiles** - No syntax errors
2. **Runs** - `sol.retcode == Success`
3. **Physics validated** - Results match hand calculations (<1% error)

## Testing Organization

### Unit Tests (12 total)

**One test file = One validation aspect**

**VehicleBody (3 tests):**
- `TestVehicleBody_ConstantForce.dyad` - Verify F=ma
- `TestVehicleBody_AeroDrag.dyad` - Verify terminal velocity
- `TestVehicleBody_CoastDown.dyad` - Verify combined resistance

**Wheel (3 tests):**
- `TestWheel_Kinematics.dyad` - Verify v = ω × r
- `TestWheel_ForceTorque.dyad` - Verify F = τ / r
- `TestWheel_Inertia.dyad` - Verify rotational dynamics

**Battery (3 tests):**
- `TestBattery_ConstantDischarge.dyad` - Verify SOC dynamics
- `TestBattery_Charging.dyad` - Verify regeneration
- `TestBattery_LoadStep.dyad` - Verify internal resistance

**ElectricMotor (3 tests):**
- `TestElectricMotor_NoLoad.dyad` - Verify back-EMF
- `TestElectricMotor_Load.dyad` - Verify torque-current
- `TestElectricMotor_Regeneration.dyad` - Verify generator mode

### Integration Tests (3 total)

**Full system validation:**
- `ConventionalPowertrain.dyad` - ICE vehicle
- `ElectricPowertrain.dyad` - Electric vehicle
- `ComparisonTest.dyad` - ICE vs EV comparison

## Component Dependencies

### Standalone Components
- VehicleBody, Engine, Brake, Battery, MotorController, DCDC

### Coupled Components
- **Wheel** - Requires rotational AND translational connections
- **Gearbox** - Requires two rotational connections
- **Differential** - Requires three rotational connections
- **ElectricMotor** - Requires electrical AND rotational connections

### System Architectures

**Conventional:**
```
Engine → Gearbox → Differential → Brake → Wheel → VehicleBody
```

**Electric:**
```
Battery → DCDC → ElectricMotor → Differential → Brake → Wheel → VehicleBody
                      ↑
                MotorController
```

## Sign Conventions

### Electrical Components
- **Pin.i > 0:** Current INTO component
- **Battery discharge:** i > 0 (SOC decreases)
- **Battery charge:** i < 0 (SOC increases)

### Mechanical Components
- **Flange.f > 0:** Force ON the flange (INTO component)
- **Flange.tau > 0:** Torque ON the flange (INTO component)
- **Resistance forces:** Must oppose motion (negative)

### Power Flow
Always verify: P_in = P_out + P_loss

## Compilation

```bash
# From project root
cd /path/to/ESPDComponents

# Compile all components
dyad-compile dyad/VehicleDynamics/Components/

# Compile specific component
dyad-compile dyad/VehicleDynamics/Components/VehicleBody.dyad

# Compile all tests
dyad-compile dyad/VehicleDynamics/Tests/

# Compile integration tests
dyad-compile dyad/VehicleDynamics/IntegrationTests/
```

## Validation Checklist

**For each component:**

### Level 1: Compiles
- [ ] No syntax errors
- [ ] All variables have types
- [ ] All parameters have units
- [ ] Proper connector usage

### Level 2: Runs
- [ ] `sol.retcode == Success`
- [ ] Simulation completes to stop time
- [ ] No NaN or Inf values
- [ ] No solver crashes

### Level 3: Physics Validated
- [ ] Hand calculations match simulation (< 1% error)
- [ ] Energy/power conservation verified
- [ ] Force/torque balance verified
- [ ] Transient behavior physically reasonable
- [ ] Steady-state matches analytical solution
- [ ] Boundary cases tested

## Common Issues

### Component Won't Compile
- Check syntax (semicolons, `end` keywords)
- Verify all types are defined (`:Velocity`, `::Mass`)
- Check connector names match stdlib

### Component Runs but Wrong Results
- Calculate expected values by hand FIRST
- Check sign conventions
- Verify units (rad/s vs rpm)
- Plot intermediate variables
- Check power/energy balance

### Empty Relations Block Error
- Do NOT use `relations` keyword if block is empty
- Components need placeholder equations (e.g., `flange.f = 0.0`)
- Tests should omit `relations` keyword entirely until implementation

## Component Documentation

Detailed physics specifications:

**Shared Components:**
- [VehicleBody.md](Components/VehicleBody.md)
- [Wheel.md](Components/Wheel.md)
- [Brake.md](Components/Brake.md)

**Conventional Powertrain:**
- [Engine.md](Components/Engine.md)
- [Differential.md](Components/Differential.md)
- [Gearbox.md](Components/Gearbox.md)

**Electric Powertrain:**
- [Battery.md](Components/Battery.md)
- [DCDC.md](Components/DCDC.md)
- [ElectricMotor.md](Components/ElectricMotor.md)
- [MotorController.md](Components/MotorController.md)

## See Also

- [README.md](README.md) - Main project guide
- [StandardLibraryReference.md](StandardLibraryReference.md) - Available components
- `../dyad_resources/dyad_docs/` - Dyad language reference
