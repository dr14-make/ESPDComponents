# VehicleDynamics Project Structure

## Overview

This project contains skeleton components and test harnesses for vehicle dynamics modeling in Dyad. All TODO comments are in file headers (documentation sections) to comply with Dyad syntax.

## Directory Organization

```
VehicleDynamics/
├── Components/              # Component implementations
│   ├── Electric/           # Electric powertrain submodule
│   └── (mechanical components)
├── Tests/                  # Unit tests (one test per file)
│   ├── VehicleBody/       # VehicleBody component tests
│   ├── Wheel/             # Wheel component tests
│   └── Electric/          # Electric component tests
└── IntegrationTests/      # Full system integration tests
```

## Components (10 total)

### Mechanical Components (6)
1. **VehicleBody.dyad** - Translational dynamics with resistance forces
2. **Wheel.dyad** - Rotational-translational coupling
3. **Engine.dyad** - Speed-dependent torque source
4. **Gearbox.dyad** - Multi-ratio transmission
5. **Brake.dyad** - Friction braking
6. **Differential.dyad** - Open differential

### Electric Components (4)
Located in `Components/Electric/`:
1. **Battery.dyad** - Energy storage with SOC dynamics
2. **ElectricMotor.dyad** - DC/BLDC motor with back-EMF
3. **MotorController.dyad** - Torque command controller
4. **DCDC.dyad** - Voltage converter

## Unit Tests (12 total)

Each test component is in its own file for independent testing:

### VehicleBody Tests (3)
- `TestVehicleBody_ConstantForce.dyad` - Verify F=ma
- `TestVehicleBody_AeroDrag.dyad` - Verify terminal velocity
- `TestVehicleBody_CoastDown.dyad` - Verify combined resistance

### Wheel Tests (3)
- `TestWheel_Kinematics.dyad` - Verify v = ω × r
- `TestWheel_ForceTorque.dyad` - Verify F = τ / r
- `TestWheel_Inertia.dyad` - Verify rotational dynamics

### Battery Tests (3)
- `TestBattery_ConstantDischarge.dyad` - Verify SOC dynamics
- `TestBattery_Charging.dyad` - Verify regeneration
- `TestBattery_LoadStep.dyad` - Verify internal resistance

### ElectricMotor Tests (3)
- `TestElectricMotor_NoLoad.dyad` - Verify back-EMF
- `TestElectricMotor_Load.dyad` - Verify torque-current
- `TestElectricMotor_Regeneration.dyad` - Verify generator mode

## Integration Tests (3)

Full system tests in `IntegrationTests/`:
1. **ConventionalPowertrain.dyad** - Engine-based vehicle
2. **ElectricPowertrain.dyad** - Battery-electric vehicle
3. **ComparisonTest.dyad** - Compare both architectures

## File Structure Convention

### Component Files
```dyad
# ============================================================================
# Component Name
# ============================================================================
#
# Description: Brief physics description
# Domain: Mechanical/Electrical/Mixed
#
# Physics to Model:
#   - List of key physics
#
# Interface:
#   - List of connectors
#
# Status: Empty skeleton - students implement physics
# Reference: Documentation/ComponentName.md
#
# TODO: Add parameters
# Example: (parameter declarations)
#
# TODO: Add variables
# Example: (variable declarations)
#
# TODO: Implement physics
# Hints: (implementation guidance)
#
# Remember: (key reminders)
# ============================================================================

component ComponentName
  # Connectors
  
relations
  # Placeholder to prevent compilation error (REMOVE when implementing):
  # (minimal placeholder code)
end
```

### Test Files
```dyad
# ============================================================================
# Component Test: Test Name
# ============================================================================
#
# Objective: What this test validates
# Expected: Expected behavior
#
# Reference: Documentation/ComponentName.md
#
# TODO: Instantiate component
# Example: (instantiation code)
#
# TODO: Add sources/loads
# Example: (supporting components)
#
# TODO: Connect components
# Example: (connection code)
#
# TODO: Set initial conditions
# Example: (initialization code)
#
# TODO: Add analysis
# Example: (analysis definition)
#
# VALIDATION (calculate BEFORE running):
# - Expected values
# - Physics checks
#
# VALIDATION CHECKLIST:
# [ ] Compiles without errors
# [ ] Runs to completion
# [ ] Results match calculations
# ============================================================================

test component TestName
relations
end
```

## Key Design Decisions

### 1. One Test Per File
**Rationale:** 
- Independent testing
- Clear organization
- Easier to navigate
- Better version control

### 2. TODOs in Headers
**Rationale:**
- Complies with Dyad syntax (no comments in code blocks)
- Students see guidance before implementation
- Cleaner separation of documentation and code

### 3. Submodule Organization
**Rationale:**
- Electric components are logically grouped
- Reduces clutter in main Components folder
- Mirrors architectural separation

### 4. Placeholder Relations
**Rationale:**
- Components compile without errors
- Students can test partial implementations
- Clear marking for removal

## Student Workflow

1. **Read Documentation**
   - Component header with TODO sections
   - README files for context
   - Reference documentation

2. **Implement Component**
   - Add parameters
   - Add variables
   - Implement physics in relations

3. **Select Test**
   - Choose appropriate test file
   - Read test objectives

4. **Implement Test Harness**
   - Follow test file TODOs
   - Instantiate components
   - Connect system
   - Add analysis

5. **Calculate Expected Results**
   - Hand calculations
   - Document in test file

6. **Run and Validate**
   - Compile and simulate
   - Check validation checklist
   - Verify conservation laws

7. **Iterate**
   - Debug using forensic protocol
   - Refine implementation
   - Move to next test

## Validation Philosophy

Every test includes:
- **Pre-simulation calculation** of expected results
- **Validation checklist** for systematic verification
- **Conservation law checks** (energy, power, KCL, KVL)
- **Error tolerance** specifications (< 1% typical)

## Benefits of This Structure

### For Students
- Clear separation of concerns
- One concept per file
- Progressive complexity
- Immediate feedback per test

### For Instructors
- Easy to grade individual tests
- Track progress per component
- Identify common issues
- Modular assignment structure

### For Development
- Independent testing
- Parallel development possible
- Clear dependencies
- Easier debugging

## Migration from Old Structure

**Old:** Multiple tests in single file (e.g., `VehicleBodyTests.dyad` with 3 test components)

**New:** Each test in own file (e.g., `TestVehicleBody_ConstantForce.dyad`)

**Benefits:**
- Compile individual tests
- Run specific validation
- Clear file naming
- Better organization

## Next Steps

1. Review component headers and TODOs
2. Start with simplest component (Wheel or VehicleBody)
3. Implement and test incrementally
4. Build up to integration tests
5. Compare conventional vs electric powertrains

## Documentation

- `README.md` files in each directory provide context
- Component headers contain implementation guidance
- Test headers contain validation criteria
- `Documentation/` folder has detailed physics references

## Summary Statistics

- **10 Components** (6 mechanical + 4 electric)
- **12 Unit Tests** (3-4 tests per major component)
- **3 Integration Tests** (system-level validation)
- **5 README files** (navigation and guidance)
- **0 Syntax violations** (all TODOs in headers)
