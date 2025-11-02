# VehicleDynamics Library - Implementation Plan

## Project Overview

**Goal:** Create a comprehensive Dyad-based VehicleDynamics library for simulating longitudinal vehicle movement (acceleration, braking, gear changes) with a modular powertrain architecture.

**Scope:** This library will model the complete powertrain chain from engine torque generation through transmission, differential, wheels, and vehicle body dynamics including aerodynamic and rolling resistance.

**Reference:** Based on the IPowertrain Modelica library structure found in `temp/modelica/ipowertrain/`

---

## Architecture Overview

```
Engine → Clutch → Gearbox → Driveshaft → Differential → Wheels → Vehicle Body
         ↑                    ↑                          ↑
      Controller          Controller                  Brakes
```

### Key Subsystems

**Conventional Powertrain:**

1. **Engine** - Torque generation with speed-dependent characteristics
2. **Clutch/Coupling** - Power transmission control between engine and gearbox
3. **Gearbox** - Multiple gear ratios with efficiency losses
4. **Differential** - Split torque to wheels with final drive ratio
5. **Wheels** - Tire dynamics, rolling resistance, traction
6. **Brakes** - Friction-based deceleration
7. **Vehicle Body** - Mass, aerodynamic drag, rolling resistance
8. **Controllers** - Shift logic, driver demand, brake control

**Electric Powertrain:**

1. **Battery** - Energy storage with voltage and SOC dynamics
2. **DC-DC Converter** - Voltage regulation between battery and motor
3. **Electric Motor** - Torque generation from electrical power
4. **Motor Controller** - Torque/speed control with regenerative braking

---

## Component Documentation

### Essential Reading (Read FIRST)

- **[Standard Library Reference](./StandardLibraryReference.md)** - ⭐ **READ THIS FIRST** ⭐
  - Complete guide to available components
  - Usage patterns and examples
  - How to check what's available
  - When to use vs. create components

### Component Specifications

**Shared Components (Both Powertrains):**

- [Vehicle Body Component](./VehicleBody.md) - Mass and resistance forces (START HERE)
- [Wheel Component](./Wheel.md) - Tire dynamics and rolling resistance
- [Brake Component](./Brake.md) - Friction braking system
- [Differential Component](./Differential.md) - Torque split with final drive

**Conventional Powertrain Components:**

- [Engine Component](./Engine.md) - Torque source with map-based characteristics
- [Gearbox Component](./Gearbox.md) - Multi-ratio transmission with losses
- [Driver Controller](./DriverController.md) - Pedal input and control logic

**Electric Powertrain Components:**

- [Battery Component](./Battery.md) - Energy storage with SOC dynamics
- [DC-DC Converter](./DCDC.md) - Voltage regulation
- [Electric Motor Component](./ElectricMotor.md) - Torque from electrical power
- [Motor Controller](./MotorController.md) - Torque control with regeneration

---

## Development Phases

### Phase 0: Library Scaffolding (DO THIS FIRST)

Create empty component skeletons with proper connectors to establish the library structure.

**Status:** 🔴 Not Started

**Objective:** Define all component interfaces and connections BEFORE implementing physics. This allows us to:

- Verify the component architecture compiles
- Ensure all connections are compatible
- Catch interface issues early
- Provide a clear roadmap for implementation

#### Tasks

- [ ] **Task 0.1:** Create library structure and empty components
  - File: `dyad/VehicleDynamics/VehicleComponents.dyad` (all components in one file initially)
  - Create ALL component skeletons with:
    - Proper connectors (Flange types)
    - Minimal placeholder equations
    - NO parameters yet (use hardcoded values)
    - NO full physics yet
  - Components to scaffold:
    - `VehicleBody` - TranslationalComponents.Flange
    - `Wheel` - Rotational + Translational Flanges
    - `Brake` - Rotational Flanges (2)
    - `Engine` - Rotational Flange + control input
    - `Differential` - Rotational Flanges (1 input, 2 outputs)
    - `Gearbox` - Rotational Flanges (2) + gear signal
  - Create simple integration test that connects all components
  - **Success Criteria:** Compiles without errors, all connections valid
  - [Details](#phase-0-scaffolding-details)

### Phase 1: Foundation Components (CRITICAL PATH)

Build and validate individual components in isolation before integration.

**Status:** 🔴 Not Started

#### Tasks

- [ ] **Task 1.1:** Implement `VehicleBody` component (from scaffold)
  - File: `dyad/VehicleDynamics/VehicleBody.dyad`
  - Physics: F = ma, aero drag, rolling resistance, grade force
  - Test: Constant force input → verify acceleration profile
  - Success: Steady-state velocity matches force balance
  - [Details](./VehicleBody.md)

- [ ] **Task 1.2:** Create `Wheel` component  
  - File: `dyad/VehicleDynamics/Wheel.dyad`
  - Physics: Rotational-translational coupling, rolling radius
  - Test: Constant angular velocity → verify linear velocity
  - Success: Zero-slip relationship verified
  - [Details](./Wheel.md)

- [ ] **Task 1.3:** Create `Brake` component
  - File: `dyad/VehicleDynamics/Brake.dyad`
  - Physics: Friction torque proportional to brake signal
  - Test: Rotating inertia with brake applied → verify deceleration
  - Success: Brake torque matches expected friction
  - [Details](./Brake.md)

### Phase 2A: Conventional Powertrain Components

**Status:** 🔴 Not Started

#### Tasks

- [ ] **Task 2A.1:** Create `Engine` component
  - File: `dyad/VehicleDynamics/Engines/Engine.dyad`
  - Physics: Torque = f(speed, throttle), inertia, friction losses
  - Test: Fixed load → verify speed stabilization at equilibrium
  - Success: Torque-speed curve matches expected map
  - [Details](./Engine.md)

- [ ] **Task 2A.2:** Create `Differential` component
  - File: `dyad/VehicleDynamics/Transmissions/Differential.dyad`
  - Physics: Speed averaging, torque splitting, gear ratio
  - Test: Single input → verify equal torque split to outputs
  - Success: Kinematic constraints satisfied (ωin = (ωL + ωR)/2 × ratio)
  - [Details](./Differential.md)

- [ ] **Task 2A.3:** Create `Gearbox` component
  - File: `dyad/VehicleDynamics/Transmissions/Gearbox.dyad`
  - Physics: Discrete ratios, efficiency losses, shift dynamics
  - Test: Fixed gear → verify ratio and efficiency
  - Success: Power balance correct with losses
  - [Details](./Gearbox.md)

### Phase 2B: Electric Powertrain Components

**Status:** 🔴 Not Started

#### Tasks

- [ ] **Task 2B.1:** Create `Battery` component
  - File: `dyad/VehicleDynamics/Electric/Battery.dyad`
  - Physics: Voltage-current relationship, SOC dynamics, internal resistance
  - Test: Constant discharge → verify voltage drop and SOC decrease
  - Success: Energy balance correct, SOC reaches expected value
  - [Details](./Battery.md)

- [ ] **Task 2B.2:** Create `DCDC` converter component
  - File: `dyad/VehicleDynamics/Electric/DCDC.dyad`
  - Physics: Voltage transformation with efficiency, power balance
  - Test: Step load → verify output voltage regulation
  - Success: Output voltage maintained, efficiency losses correct
  - [Details](./DCDC.md)

- [ ] **Task 2B.3:** Create `ElectricMotor` component
  - File: `dyad/VehicleDynamics/Electric/ElectricMotor.dyad`
  - Physics: Torque from current, back-EMF, electrical-mechanical power
  - Test: Constant voltage → verify speed and torque characteristics
  - Success: Torque-speed curve matches motor type, regeneration works
  - [Details](./ElectricMotor.md)

- [ ] **Task 2B.4:** Create `MotorController` component
  - File: `dyad/VehicleDynamics/Controllers/MotorController.dyad`
  - Physics: Torque command to current, regenerative braking logic
  - Test: Driving and braking cycles → verify torque control
  - Success: Torque tracking accurate, regeneration charges battery
  - [Details](./MotorController.md)

### Phase 3: Integration & System Tests

**Status:** 🔴 Not Started

#### Conventional Vehicle Tasks

- [ ] **Task 3.1:** Simple conventional vehicle test (no gearbox)
  - File: `dyad/VehicleDynamics/IntegrationTests/SimpleConventionalVehicle.dyad`
  - System: Engine → Differential → Wheels → Body
  - Test: Constant throttle → acceleration → coast
  - Success: Reaches expected top speed, energy balance verified

- [ ] **Task 3.2:** Full conventional powertrain test
  - File: `dyad/VehicleDynamics/IntegrationTests/FullConventionalVehicle.dyad`
  - System: Engine → Gearbox → Differential → Wheels → Body → Brakes
  - Test: Acceleration through gears → cruise → brake
  - Success: Smooth gear shifts, no discontinuities

- [ ] **Task 3.3:** Conventional drive cycle simulation
  - File: `dyad/VehicleDynamics/IntegrationTests/ConventionalDriveCycle.dyad`
  - System: Full vehicle with driver controller
  - Test: Follow speed profile (e.g., simplified WLTP)
  - Success: Speed tracking error < 5%, realistic fuel consumption

#### Electric Vehicle Tasks

- [ ] **Task 3.4:** Simple electric vehicle test
  - File: `dyad/VehicleDynamics/IntegrationTests/SimpleElectricVehicle.dyad`
  - System: Battery → Motor → Differential → Wheels → Body
  - Test: Constant torque command → acceleration → coast
  - Success: Motor performance matches specifications, SOC decreases correctly

- [ ] **Task 3.5:** Full electric powertrain test with regeneration
  - File: `dyad/VehicleDynamics/IntegrationTests/FullElectricVehicle.dyad`
  - System: Battery → DCDC → Motor → Controller → Differential → Wheels → Body → Brakes
  - Test: Acceleration → cruise → regenerative braking
  - Success: Regeneration charges battery, energy recovery validated

- [ ] **Task 3.6:** Electric vehicle drive cycle with energy analysis
  - File: `dyad/VehicleDynamics/IntegrationTests/ElectricDriveCycle.dyad`
  - System: Full EV with motor controller
  - Test: Follow speed profile with regen braking
  - Success: Speed tracking < 5%, energy efficiency calculated, SOC prediction accurate

### Phase 4: Advanced Features

**Status:** 🔴 Not Started

#### Tasks

- [ ] **Task 4.1:** Implement `Clutch` component with slip dynamics
  - File: `dyad/VehicleDynamics/Components/Clutch.dyad`
  - Physics: Friction clutch with three modes (disengaged, slipping, locked)
  - Test: Engagement under load → slip → lock-up
  - Success: Smooth transitions between modes, positive power dissipation
  - [Details](./Components/Clutch.md)
- [ ] **Task 4.2:** Engine thermal model integration
- [ ] **Task 4.3:** Regenerative braking for hybrid vehicles
- [ ] **Task 4.4:** Advanced tire models (slip, saturation)

---

## Critical Design Decisions

### 1. Connector Types

**Decision Required:** Define mechanical interfaces for powertrain chain

**Options:**

- Use standard `RotationalComponents.Flange` for all rotational connections
- Use standard `TranslationalComponents.Flange` for vehicle body
- Create custom `PowertrainConnector` with torque, speed, and efficiency signals

**Recommendation:** Start with standard Flanges, migrate to custom if needed

### 2. Efficiency Modeling

**Decision Required:** How to model losses in gearbox/differential

**Options:**

- Constant efficiency factor (simple, fast)
- Speed-dependent efficiency map (realistic, moderate complexity)
- Power-direction dependent (handles regeneration, complex)

**Recommendation:** Start with constant, add maps in Phase 4

### 3. Control Architecture

**Decision Required:** How to implement shift logic and driver input

**Options:**

- External controller components (modular, testable)
- Built-in control logic (simple, less flexible)
- Hybrid: simple built-in with external override capability

**Recommendation:** External controllers for flexibility

### 4. Parameter Sources

**Decision Required:** How to handle complex data (torque maps, efficiency curves)

**Options:**

- Inline parameters (simple, limited to small datasets)
- External data files (realistic, requires file I/O)
- Analytical approximations (good for testing, less accurate)

**Recommendation:** Start with analytical, plan for external data in Phase 4

---

## Component Development Standards

### MANDATORY Requirements for EVERY Component

**1. Use Standard Library Components**

- **ALWAYS** use existing components from:
  - `RotationalComponents.*` - for rotational mechanics (Flange, Inertia, Spring, Damper, etc.)
  - `TranslationalComponents.*` - for translational mechanics (Flange, Mass, Spring, Damper, etc.)
  - `BlockComponents.*` - for signals and control (Constant, Step, Ramp, RealInput, RealOutput, etc.)
  - `ElectricalComponents.*` - if electrical domain needed
- **DO NOT** create custom connector types unless absolutely necessary
- **BEFORE** using any component: Read its source in `dyad_resources/dyad_stdlib/`

**2. Test Harness in SAME File**

- **EVERY** component MUST have test harness in the SAME .dyad file
- Format:

  ```dyad
  component MyComponent
    # Component definition
  end
  
  # MANDATORY TEST HARNESS
  test component TestMyComponent
    # Test setup
  end
  
  analysis TestMyComponent_Analysis
    extends TransientAnalysis(stop=10.0, alg="Rodas5P")
    model = TestMyComponent()
  end
  ```

- Test MUST validate component behavior with realistic parameters
- Test MUST include expected results stated as comments

**3. Module Organization**

- Each domain has its own module folder:
  - `dyad/VehicleDynamics/` - vehicle-specific components
  - Use subdirectories if needed: `Engines/`, `Transmissions/`, `Wheels/`, etc.
- Component naming: `VehicleDynamics.ComponentName`
- Tests follow naming: `TestComponentName`, `TestComponentName_SpecificCase`

**4. Documentation Requirements**

- **File-level documentation** at top of each .dyad file:

  ```dyad
  # ComponentName - Brief description
  # 
  # Physics: Brief equation summary
  # Parameters: Key parameters listed
  # Connections: What it connects to
  # Test: Description of test cases included
  # Reference: External references if applicable
  ```

- **Component documentation** before component definition:

  ```dyad
  # ComponentName component
  # 
  # Detailed description of what it does
  # Key equations and assumptions
  ```

- **Inline comments** for non-obvious equations
- **Test documentation** explaining what each test validates

### Component Interface Specifications

### Rotational Components (Engine, Gearbox, Differential, Wheel, Brake)

```dyad
# Standard rotational interface - USE EXISTING RotationalComponents.Flange
component RotationalComponent
  flange_a = RotationalComponents.Flange()  # Input - ALWAYS use standard Flange
  flange_b = RotationalComponents.Flange()  # Output - ALWAYS use standard Flange
  
  # Standard Flange provides (READ THE SOURCE):
  #   - phi: angular position [rad]
  #   - tau: torque [N⋅m], positive = into component
  
relations
  # Component equations here
  # Use RotationalComponents.Inertia, Spring, Damper, etc. where applicable
end
```

### Translational Components (Vehicle Body)

```dyad
# Standard translational interface - USE EXISTING TranslationalComponents.Flange
component TranslationalComponent
  flange = TranslationalComponents.Flange()  # ALWAYS use standard Flange
  
  # Standard Flange provides (READ THE SOURCE):
  #   - s: position [m]
  #   - f: force [N], positive = into component
  
relations
  # Component equations here
  # Use TranslationalComponents.Mass, Spring, Damper, etc. where applicable
end
```

### Control Signals

**ALWAYS** use `BlockComponents` for control signals:

- `BlockComponents.RealInput` - for throttle, brake, gear commands
- `BlockComponents.RealOutput` - for speed, torque feedback
- `BlockComponents.Constant` - for constant values in tests
- `BlockComponents.Step` - for step inputs in tests
- `BlockComponents.Ramp` - for ramp inputs in tests

**Check available components:**

```bash
ls dyad_resources/dyad_stdlib/BlockComponents.dyad
ls dyad_resources/dyad_stdlib/RotationalComponents.dyad
ls dyad_resources/dyad_stdlib/TranslationalComponents.dyad
```

---

## Physics Validation Checklist

For EACH component, verify:

### Energy Conservation

- [ ] Power in = Power out + Losses
- [ ] No energy creation or destruction
- [ ] Losses always positive (dissipative)

### Kinematic Constraints

- [ ] Gear ratio: ωout = ωin / ratio (within slip tolerance)
- [ ] Rolling: v_vehicle = ω_wheel × radius
- [ ] Differential: ωpropshaft = (ωleft + ωright) / 2 × ratio

### Torque Balance

- [ ] At each connection: Στ = 0
- [ ] Inertia: τnet = J × α
- [ ] Friction: τfriction opposes motion

### Force Balance

- [ ] Vehicle: ΣF = m × a
- [ ] Aero drag: Fdrag = ½ρCdAv²
- [ ] Rolling: Froll = Crr × m × g × cos(θ)

### Steady-State Validation

- [ ] At equilibrium: acceleration = 0
- [ ] Power balance: Pengine = Pdrag + Proll + Plosses
- [ ] Calculate expected top speed analytically, compare to simulation

---

## Test Harness Requirements

Each component MUST include test harness in SAME file:

```dyad
component MyComponent
  # Component definition
relations
  # Component equations
end

# MANDATORY TEST HARNESS
test component TestMyComponent
  comp = MyComponent(param1=value1)
  # Add sources, sinks, boundary conditions
relations
  # Setup test conditions
  # Add initial conditions and guesses
end

analysis TestMyComponentTransient
  extends TransientAnalysis(stop=10.0, alg="Rodas5P")
  model = TestMyComponent()
end
```

### Test Success Criteria

1. **Compiles:** No syntax errors
2. **Runs:** `sol.retcode == ReturnCode.Success`
3. **Physics Validated:**
   - Steady-state within 1% of hand calculation
   - Conservation laws verified numerically
   - Transient behavior matches theory (time constants, damping)

---

## File Organization

```
dyad/VehicleDynamics/
├── VehicleBody.dyad               # Task 1.1 - MUST include test harness
│                                  # Component: VehicleDynamics.VehicleBody
│                                  # Test: TestVehicleBody, TestVehicleBody_Analysis
├── Wheel.dyad                     # Task 1.2 - MUST include test harness
│                                  # Component: VehicleDynamics.Wheel
├── Brake.dyad                     # Task 1.3 - MUST include test harness
│                                  # Component: VehicleDynamics.Brake
├── Engines/
│   └── Engine.dyad                # Task 2.1 - MUST include test harness
│                                  # Component: VehicleDynamics.Engines.Engine
├── Transmissions/
│   ├── Gearbox.dyad               # Task 2.3 - MUST include test harness
│   │                              # Component: VehicleDynamics.Transmissions.Gearbox
│   └── Differential.dyad          # Task 2.2 - MUST include test harness
│                                  # Component: VehicleDynamics.Transmissions.Differential
├── Controllers/
│   └── DriverController.dyad      # MUST include test harness
└── IntegrationTests/
    ├── SimpleVehicle.dyad         # Task 3.1 - Full integration test
    ├── FullVehicle.dyad           # Task 3.2 - Complete powertrain
    └── DriveCycle.dyad            # Task 3.3 - Drive cycle tracking

Notes:
- EVERY .dyad file MUST contain its test harness
- Integration tests can be separate files (they test multiple components)
- Use subdirectories for logical grouping
- Each file includes: component definition + test + analysis
```

### File Template

**Every component file MUST follow this structure:**

```dyad
# ============================================================================
# ComponentName - Brief one-line description
# ============================================================================
#
# Physics: F = ma, τ = Iα, etc. (key equations)
# Domain: Rotational / Translational / Mixed / Control
# 
# Parameters:
#   - param1: description [units]
#   - param2: description [units]
#
# Connections:
#   - flange_a: connects to X
#   - flange_b: connects to Y
#
# Test Cases:
#   - Test1: what it validates
#   - Test2: what it validates
#
# References:
#   - Source paper / book / standard
#   - Modelica reference: path/to/file.mo
#
# Status: [Development / Testing / Validated]
# ============================================================================

# ComponentName component
#
# Detailed multi-line description of the component.
# Explain the physics, assumptions, and limitations.
component VehicleDynamics.ComponentName
  # Use standard library components
  flange = RotationalComponents.Flange()
  
  # Parameters with units and descriptions
  parameter mass::Mass = 1000.0  # Vehicle mass [kg]
  
  # Variables
  variable velocity::Velocity    # Description [units]
  
relations
  # Equations with inline comments for clarity
  der(velocity) = force / mass   # Newton's second law
  
end

# ============================================================================
# TEST HARNESS - MANDATORY
# ============================================================================

# Test case 1: Brief description
test component TestComponentName_Case1
  comp = VehicleDynamics.ComponentName(mass = 1500.0)
  
  # Use standard library for test fixtures
  source = RotationalComponents.TorqueSource()
  input = BlockComponents.Constant(k = 100.0)
  
relations
  connect(input.y, source.tau)
  connect(source.flange, comp.flange)
  
  # Initial conditions
  initial comp.flange.phi = 0.0
  initial der(comp.flange.phi) = 0.0
  
  # Expected results (as comments for validation):
  # At t=1s: velocity ≈ 10 m/s
  # At steady state: force = drag
  
end

analysis TestComponentName_Case1_Analysis
  extends TransientAnalysis(stop = 10.0, alg = "Rodas5P")
  model = TestComponentName_Case1()
end

# Additional test cases as needed...
```

---

## Getting Started - Next Steps

### Immediate Actions

1. **Read Prerequisites** (MANDATORY before writing ANY code):
   - `dyad_resources/dyad_docs/syntax.md`
   - `dyad_resources/dyad_docs/initialization.md`
   - `dyad_resources/dyad_docs/analyses.md`
   - `dyad_resources/mtk_cheatsheet.jl`

2. **Survey Available Standard Library Components:**

   ```bash
   # See what components are available
   cat dyad_resources/dyad_stdlib/RotationalComponents.dyad | grep "^component"
   cat dyad_resources/dyad_stdlib/TranslationalComponents.dyad | grep "^component"
   cat dyad_resources/dyad_stdlib/BlockComponents.dyad | grep "^component"
   
   # Read relevant component sources BEFORE using
   cat dyad_resources/dyad_stdlib/RotationalComponents.dyad
   cat dyad_resources/dyad_stdlib/TranslationalComponents.dyad
   ```

   **Available components you WILL use:**
   - RotationalComponents: `Flange`, `Inertia`, `Spring`, `Damper`, `IdealGear`, `TorqueSource`, `Speed`, `Fixed`
   - TranslationalComponents: `Flange`, `Mass`, `Spring`, `Damper`, `Force`, `Fixed`
   - BlockComponents: `Constant`, `Step`, `Ramp`, `RealInput`, `RealOutput`

3. **Create Directory Structure:**

   ```bash
   mkdir -p dyad/VehicleDynamics
   mkdir -p dyad/VehicleDynamics/Engines
   mkdir -p dyad/VehicleDynamics/Transmissions
   mkdir -p dyad/VehicleDynamics/Controllers
   mkdir -p dyad/VehicleDynamics/IntegrationTests
   ```

4. **Start with Task 1.1** - VehicleBody component:
   - Simplest dynamics (translational mass)
   - Foundation for wheel testing
   - Clear validation criteria
   - Uses `TranslationalComponents.Mass` as building block

5. **Follow ONE component at a time rule:**
   - Complete component implementation
   - Complete test harness IN SAME FILE
   - Validate physics (all 3 levels)
   - Document results in component header
   - Move to next component

### Before Starting Each Component

1. Read component detail file (e.g., `VehicleBody.md`)
2. Sketch free body diagram
3. Write governing equations by hand
4. Calculate expected steady-state analytically
5. THEN start coding in Dyad

---

## Progress Tracking

### Phase 0: Scaffolding

| Task | Status | File | Compiles | Notes |
|------|--------|------|----------|-------|
| Library Structure | 🔴 Not Started | VehicleComponents.dyad | ❌ | **START HERE** |
| All Skeletons | 🔴 Not Started | VehicleComponents.dyad | ❌ | 6 components |
| Integration Test | 🔴 Not Started | VehicleComponents.dyad | ❌ | Connectivity only |

### Phase 1+: Component Implementation

| Component | Status | File | Test Pass | Physics Valid | Notes |
|-----------|--------|------|-----------|---------------|-------|
| VehicleBody | 🔴 Not Started | - | ❌ | ❌ | After Phase 0 |
| Wheel | 🔴 Not Started | - | ❌ | ❌ | After VehicleBody |
| Brake | 🔴 Not Started | - | ❌ | ❌ | After Wheel |
| Engine | 🔴 Not Started | - | ❌ | ❌ | Phase 2 |
| Differential | 🔴 Not Started | - | ❌ | ❌ | Phase 2 |
| Gearbox | 🔴 Not Started | - | ❌ | ❌ | Phase 2 |
| SimpleVehicle | 🔴 Not Started | - | ❌ | ❌ | Phase 3 |
| FullVehicle | 🔴 Not Started | - | ❌ | ❌ | Phase 3 |

**Legend:**

- 🔴 Not Started
- 🟡 In Progress
- 🟢 Complete
- ✅ Passed
- ❌ Not Tested

---

## References

### Modelica Reference Implementation

- Location: `/home/dr14/Projects/CVUT/ESPDComponents/temp/modelica/ipowertrain/`
- Key files analyzed:
  - `Vehicles/BasicVehicle.mo` - Vehicle dynamics reference
  - `Engines/BasicEngine.mo` - Torque source with maps
  - `Gearsets/TransmissionGearbox.mo` - Multi-ratio gearbox
  - `Gearsets/BasicDifferential.mo` - Torque splitting
  - `Tyres/BasicTyre.mo` - Wheel dynamics

### Vehicle Dynamics Theory

- **Gillespie, T.D.** - "Fundamentals of Vehicle Dynamics" (SAE International)
- **Wong, J.Y.** - "Theory of Ground Vehicles"
- Longitudinal dynamics: $F_{net} = ma = F_{traction} - F_{aero} - F_{roll} - F_{grade}$
- Aerodynamic drag: $F_{aero} = \frac{1}{2}\rho C_d A v^2$
- Rolling resistance: $F_{roll} = C_{rr} m g \cos\theta$

### Dyad Resources

- Syntax reference: `dyad_resources/dyad_docs/syntax.md`
- Initialization patterns: `dyad_resources/dyad_docs/initialization.md`
- Standard library: `dyad_resources/dyad_stdlib/`
- Investigation tools: `dyad_resources/mtk_cheatsheet.jl`

---

## Success Criteria for Complete Library

### Functional Requirements

- ✅ All Phase 1-2 components implemented and validated
- ✅ Simple vehicle test passes all validation checks
- ✅ Full vehicle test demonstrates smooth operation
- ✅ Drive cycle tracking within 5% error

### Performance Requirements

- ✅ Simulation faster than real-time (1s sim < 1s wall time)
- ✅ No solver failures or instabilities
- ✅ Numerical accuracy: relative tolerance < 1e-6

### Code Quality Requirements

- ✅ All components have test harnesses
- ✅ All components pass 3-level validation
- ✅ Documentation complete for each component
- ✅ Physics equations documented with references

---

## Known Issues & Limitations

### Current Limitations

1. **No lateral dynamics** - This library focuses on longitudinal motion only
2. **Rigid body assumption** - No suspension compliance or pitch dynamics
3. **Perfect traction** - No tire slip or wheel lock modeling
4. **Simplified aerodynamics** - Constant drag coefficient, no pitch effects

### Future Enhancements

1. Add clutch with slip dynamics
2. Include engine thermal model
3. Implement advanced tire models (Pacejka Magic Formula)
4. Add grade/elevation profile support
5. Regenerative braking for hybrid/EV

---

## Contact & Collaboration

This is a living document. Update status as tasks complete.

**Current Phase:** Foundation (Phase 1)  
**Next Milestone:** VehicleBody component validated  
**Blocked By:** None - ready to start

---

## Phase 0 Scaffolding Details

### Objective

Create a minimal, compilable skeleton of the entire VehicleDynamics library to verify:

1. All component interfaces are correctly defined
2. All connections between components are valid
3. The overall architecture compiles
4. We have a clear foundation to build upon

### Implementation Plan

**Single File Approach (Phase 0):**

- Create one file: `dyad/VehicleDynamics/VehicleComponents.dyad`
- Contains ALL component skeletons
- One integration test showing full powertrain connection
- Once validated, split into individual files in Phase 1+

### Component Requirements

#### 1. VehicleBody (Translational Domain)

**Interface:**

- Use `TranslationalComponents.Flange()` for connection to wheels

**Required Variables:**

- Velocity and force variables

**Minimal Physics:**

- Implement F = ma with hardcoded mass (1000 kg)
- Connect force from flange to acceleration

#### 2. Wheel (Mixed Domain: Rotational → Translational)

**Interfaces:**

- `RotationalComponents.Flange()` for driveline connection
- `TranslationalComponents.Flange()` for vehicle body connection

**Required Variables:**

- Angular velocity (omega) and linear velocity (v)

**Minimal Physics:**

- Zero-slip constraint: v = omega × radius (use hardcoded radius ~0.3 m)
- Force-torque relationship: F = tau / radius

#### 3. Brake (Rotational Domain)

**Interfaces:**

- Two `RotationalComponents.Flange()` (input and output)
- `BlockComponents.RealInput()` for brake signal [0-1]

**Required Variables:**

- Angular velocity, brake torque

**Minimal Physics:**

- Rigid connection between flanges (same angle)
- Brake torque proportional to signal (hardcoded max ~1000 N⋅m)
- Torque balance equation

#### 4. Engine (Rotational Domain)

**Interfaces:**

- `RotationalComponents.Flange()` for output shaft
- `BlockComponents.RealInput()` for throttle signal [0-1]

**Required Variables:**

- Angular velocity, torque

**Minimal Physics:**

- Torque proportional to throttle (hardcoded max ~200 N⋅m)
- Include minimal inertia (~0.1 kg⋅m²)

#### 5. Differential (Rotational Domain)

**Interfaces:**

- `RotationalComponents.Flange()` for input (propshaft)
- Two `RotationalComponents.Flange()` for outputs (left/right axles)

**Required Variables:**

- Three angular velocities (input, left, right)

**Minimal Physics:**

- Speed averaging: omega_in = (omega_left + omega_right) / 2 × ratio
- Equal torque split (hardcoded ratio ~3.5)

#### 6. Gearbox (Rotational Domain)

**Interfaces:**

- Two `RotationalComponents.Flange()` (input and output)
- `BlockComponents.IntegerInput()` for gear selection

**Required Variables:**

- Two angular velocities, gear ratio

**Minimal Physics:**

- Speed ratio: omega_out = omega_in / ratio (hardcoded ratio ~2.0 for now)
- Torque multiplication (ideal, no losses)

### Integration Test Requirements

**Purpose:** Verify all components can be connected in a complete powertrain chain.

**Required Connections:**

1. Control signals → Engine, Gearbox, Brakes
2. Powertrain chain: Engine → Gearbox → Differential → Brakes → Wheels
3. Vehicle body connection to both wheels
4. Proper grounding/fixed references

**Test should include:**

- All 6 components instantiated
- Control inputs (throttle, gear, brake signals)
- Complete connection chain
- Minimal initial conditions
- Analysis definition for short simulation (~1 second)

### Success Criteria for Phase 0

- [ ] File compiles without syntax errors
- [ ] All 6 component skeletons defined with correct connectors
- [ ] Integration test compiles
- [ ] All Flange types are correct (Rotational vs Translational)
- [ ] All connections are compatible
- [ ] Can create Analysis (simulation success not required)

**Note:** The simulation may NOT produce correct physics or even run successfully. The goal is COMPILATION and INTERFACE VALIDATION only.

### Next Steps After Phase 0

Once scaffolding is complete:

1. Review the architecture
2. Identify any interface issues
3. Split into individual files (one per component)
4. Begin Phase 1: Implement full physics for each component

---

**Last Updated:** 2024 (Initial Creation, Added Phase 0)  
**Document Version:** 1.1  
**Maintainer:** AI Agent + User Collaboration
