# VehicleDynamics Component Tests

This directory contains unit tests for individual vehicle dynamics components. Each test component is in its own file for better organization and independent testing.

## Directory Structure

```
Tests/
├── VehicleBody/          # Tests for VehicleBody component
│   ├── TestVehicleBody_ConstantForce.dyad
│   ├── TestVehicleBody_AeroDrag.dyad
│   └── TestVehicleBody_CoastDown.dyad
├── Wheel/                # Tests for Wheel component
│   ├── TestWheel_Kinematics.dyad
│   ├── TestWheel_ForceTorque.dyad
│   └── TestWheel_Inertia.dyad
└── Electric/             # Tests for electric powertrain components
    ├── TestBattery_ConstantDischarge.dyad
    ├── TestBattery_Charging.dyad
    ├── TestBattery_LoadStep.dyad
    ├── TestElectricMotor_NoLoad.dyad
    ├── TestElectricMotor_Load.dyad
    └── TestElectricMotor_Regeneration.dyad
```

## Testing Workflow

### 1. Implement Component Physics
Before testing, implement the physics in your component (e.g., `Components/VehicleBody.dyad`)

### 2. Select Test
Choose the appropriate test for the aspect you want to validate

### 3. Implement Test Harness
- Open the test file
- Follow the TODO comments in the header
- Instantiate your component with appropriate parameters
- Add required sources, loads, and references
- Connect components
- Set initial conditions

### 4. Add Analysis
Create an analysis that references your test component:
```dyad
analysis TestName_Analysis
  extends TransientAnalysis(stop = 10.0, alg = "Rodas5P")
  model = TestComponentName()
end
```

### 5. Calculate Expected Results
Before running the simulation:
- Calculate expected steady-state values
- Determine time constants
- Predict transient behavior
- Document in the test file

### 6. Compile and Run
```bash
# From project root
dyad-compile dyad/VehicleDynamics
```

### 7. Validate Results
Check the validation checklist in each test file:
- [ ] Compiles without errors
- [ ] Runs to completion (sol.retcode == Success)
- [ ] No NaN or Inf values
- [ ] Results match hand calculations (< 1% error)
- [ ] Conservation laws verified
- [ ] Physical behavior correct

## Test Categories

### VehicleBody Tests
1. **ConstantForce**: Verify F=ma with no resistance
2. **AeroDrag**: Verify quadratic drag and terminal velocity
3. **CoastDown**: Verify combined resistance forces

### Wheel Tests
1. **Kinematics**: Verify v = ω × r constraint
2. **ForceTorque**: Verify F = τ / r relationship
3. **Inertia**: Verify rotational dynamics (optional)

### Battery Tests
1. **ConstantDischarge**: Verify SOC dynamics
2. **Charging**: Verify regeneration mode
3. **LoadStep**: Verify internal resistance

### ElectricMotor Tests
1. **NoLoad**: Verify back-EMF limits speed
2. **Load**: Verify torque-current relationship
3. **Regeneration**: Verify generator mode

## Best Practices

1. **One Test, One Aspect**: Each test should validate one specific physical principle
2. **Calculate First**: Always calculate expected results before running
3. **Incremental Testing**: Test simple cases before complex ones
4. **Energy Balance**: Always verify conservation laws
5. **Document Assumptions**: Note any simplifications or assumptions

## Integration Tests

After individual components are validated, see `../IntegrationTests/` for full system tests.
