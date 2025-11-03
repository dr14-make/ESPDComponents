# Vehicle Dynamics Library - Student Guide

## Project Overview

This project involves building a comprehensive **vehicle dynamics simulation library** in Dyad for modeling:

- **Conventional vehicles** (Internal Combustion Engine powertrain)
- **Electric vehicles** (Battery-electric powertrain)
- **Comparative analysis** (ICE vs EV performance)

The project uses a **team-based approach** where different teams work on different components in parallel, then integrate them into complete vehicle systems.

---

## Table of Contents

1. [Quick Start](#quick-start)
2. [Project Structure](#project-structure)
3. [Components Overview](#components-overview)
4. [Team Workflow](#team-workflow)
5. [Component Documentation](#component-documentation)
6. [Implementation Files](#implementation-files)
7. [Standard Library Reference](#standard-library-reference)
8. [Validation Requirements](#validation-requirements)
9. [Integration Testing](#integration-testing)
10. [Grading Criteria](#grading-criteria)

---

## Quick Start

### Step 1: Understand the Project (30 minutes)

1. Read this README completely
2. Review the [Project Structure](#project-structure)
3. Understand [Team Workflow](#team-workflow)

### Step 2: Get Your Assignment

- Receive component assignment from instructor
- Note your team members
- Identify your deliverables

### Step 3: Study Your Component (1-2 hours)

1. Read the component documentation (see [Component Documentation](#component-documentation))
2. Understand the physics concepts (equations NOT provided - you derive them!)
3. Review the implementation file structure
4. Check the standard library for available components

### Step 4: Implement (1-2 weeks)

1. Derive physics equations from first principles
2. Implement in your component file
3. Create comprehensive test harnesses
4. Validate thoroughly (3 levels)

### Step 5: Submit for Integration

- Submit completed component with tests
- Document any assumptions or design decisions
- Participate in system integration

---

## Project Structure

### Directory Layout

```
ESPDComponents/
├── dyad/VehicleDynamics/
│   ├── README.md                          ← Detailed workflow guide
│   │
│   ├── Components/                        ← YOUR IMPLEMENTATION HERE
│   │   ├── VehicleBody.dyad
│   │   ├── Wheel.dyad
│   │   ├── Brake.dyad
│   │   ├── Engine.dyad
│   │   ├── Differential.dyad
│   │   ├── Gearbox.dyad
│   │   └── Electric/
│   │       ├── Battery.dyad
│   │       ├── DCDC.dyad
│   │       ├── ElectricMotor.dyad
│   │       └── MotorController.dyad
│   │
│   ├── Tests/                            ← YOUR TESTS HERE
│   │   ├── VehicleBodyTests.dyad (template provided)
│   │   ├── WheelTests.dyad (template provided)
│   │   └── Electric/
│   │       ├── BatteryTests.dyad (template provided)
│   │       └── ElectricMotorTests.dyad (template provided)
│   │
│   └── IntegrationTests/                 ← SYSTEM-LEVEL TESTS
│       ├── ConventionalPowertrain.dyad
│       ├── ElectricPowertrain.dyad
│       └── ComparisonTest.dyad
│
├── Documentation/                        ← YOU ARE HERE
│   ├── README.md (this file)
│   ├── StandardLibraryReference.md
│   └── Components/
│       ├── VehicleBody.md
│       ├── Wheel.md
│       ├── Brake.md
│       ├── Engine.md
│       ├── Differential.md
│       ├── Gearbox.md
│       ├── Battery.md
│       ├── DCDC.md
│       ├── ElectricMotor.md
│       └── MotorController.md
│
└── dyad_resources/
    ├── dyad_docs/                        ← Language reference
    └── dyad_stdlib/                      ← Standard library source
```

---

## Components Overview

### Shared Components (Used by Both Powertrains)

| Component | Description | Domain | Key Physics |
|-----------|-------------|--------|-------------|
| **VehicleBody** | Vehicle mass with resistance forces | Translational | F=ma, drag, rolling resistance |
| **Wheel** | Rotational-translational coupling | Mixed | Kinematic constraint, power conservation |
| **Brake** | Friction braking | Rotational | Friction torque, energy dissipation |

### Conventional Powertrain Specific

| Component | Description | Domain | Key Physics |
|-----------|-------------|--------|-------------|
| **Engine** | ICE torque source | Rotational | Torque curve, inertia, friction |
| **Differential** | Torque splitting | Rotational | Equal torque split, speed averaging |
| **Gearbox** | Multi-ratio transmission | Rotational | Gear ratios, efficiency losses |

### Electric Powertrain Specific

| Component | Description | Domain | Key Physics |
|-----------|-------------|--------|-------------|
| **Battery** | Energy storage | Electrical | SOC dynamics, internal resistance |
| **DCDC** | Voltage converter | Electrical | Voltage transformation, efficiency |
| **ElectricMotor** | Electric machine | Mixed | Back-EMF, torque-current, bidirectional |
| **MotorController** | Torque controller | Control | Command mapping, regen logic |

### System Architecture

**Conventional Powertrain:**

```
Engine → Gearbox → Differential → Brake → Wheel → VehicleBody
```

**Electric Powertrain:**

```
Battery → DCDC → ElectricMotor → Differential → Brake → Wheel → VehicleBody
                      ↑
                MotorController
```

---

## Team Workflow

### Phase 1: Component Development (Weeks 1-2)

**Your team's responsibilities:**

1. **Understand the Physics**
   - Read your component's documentation file
   - Research the underlying physics
   - Derive the governing equations from first principles
   - Calculate expected behavior by hand

2. **Implement the Component**
   - Open your component file in `dyad/VehicleDynamics/Components/`
   - Replace TODO markers with your implementation
   - Add parameters (with units!)
   - Add variables (with types!)
   - Implement physics equations

3. **Create Test Harnesses**
   - Create test file in `dyad/VehicleDynamics/Tests/`
   - Multiple test scenarios (at least 3)
   - Test edge cases and boundary conditions
   - Include validation checks

4. **Validate Thoroughly**
   - Level 1: Compiles without errors
   - Level 2: Runs to completion (sol.retcode == Success)
   - Level 3: Physics validated (matches hand calculations < 1% error)

5. **Document**
   - Note any assumptions made
   - Document parameter choices
   - Explain design decisions
   - Comment non-obvious code

### Phase 2: Integration (Week 3)

**Integration team responsibilities:**

1. Collect all completed components
2. Run integration tests:
   - `IntegrationTests/ConventionalPowertrain.dyad`
   - `IntegrationTests/ElectricPowertrain.dyad`
3. Debug interface mismatches
4. Validate system-level behavior
5. Run performance analysis

### Phase 3: Analysis and Reporting (Week 4)

1. Run comparison tests (ICE vs EV)
2. Measure performance metrics
3. Analyze efficiency differences
4. Create visualizations
5. Write final report

---

## Component Documentation

### How to Read Component Documentation

Each component has a documentation file in `Documentation/Components/` that provides:

- **Description** - What the component does
- **Physical phenomena** - What physics to model (NO EQUATIONS!)
- **Interface requirements** - What connectors to use
- **Test objectives** - What to validate
- **Parameter ranges** - Typical values

**Important:** Equations are NOT provided. You must derive them from physics principles!

### Component Documentation Files

**Shared Components:**

- [VehicleBody.md](Components/VehicleBody.md) - Vehicle mass dynamics
- [Wheel.md](Components/Wheel.md) - Rotational-translational coupling
- [Brake.md](Components/Brake.md) - Friction braking
- [WheelContact.md](Components/WheelContact.md) - Specialized connector for wheel-body interface

**Conventional Powertrain:**

- [Engine.md](Components/Engine.md) - ICE torque source
- [Differential.md](Components/Differential.md) - Torque splitting
- [Gearbox.md](Components/Gearbox.md) - Multi-ratio transmission

**Electric Powertrain:**

- [Battery.md](Components/Battery.md) - Energy storage with SOC
- [DCDC.md](Components/DCDC.md) - Voltage converter
- [ElectricMotor.md](Components/ElectricMotor.md) - Electric machine
- [MotorController.md](Components/MotorController.md) - Torque controller

---

## Implementation Files

### Component Implementation Files

**Location:** `dyad/VehicleDynamics/Components/`

**What you'll find:**

- Empty component skeleton with proper connectors
- TODO markers showing what to implement
- Hints for implementation
- Placeholder equations (to be replaced)

**What you must add:**

- Parameters (with units and descriptions)
- Variables (with types)
- Physics equations (derived by you!)
- Proper sign conventions
- Initial conditions handling

### Test Implementation Files

**Location:** `dyad/VehicleDynamics/Tests/`

**Templates provided for:**

- VehicleBodyTests.dyad
- WheelTests.dyad
- BatteryTests.dyad
- ElectricMotorTests.dyad

**You must create:**

- Remaining test files for your component
- Multiple test scenarios per component
- Validation checks in each test

### Integration Test Files

**Location:** `dyad/VehicleDynamics/IntegrationTests/`

**Provided:**

- ConventionalPowertrain.dyad - Template for ICE vehicle
- ElectricPowertrain.dyad - Template for EV
- ComparisonTest.dyad - ICE vs EV comparison (optional)

**Note:** Integration tests will be completed by integration team after all components are ready.

---

## Standard Library Reference

### Available Components

You will frequently use standard library components. **Full reference:** [StandardLibraryReference.md](StandardLibraryReference.md)

### Key Components You'll Use

**Connectors:**

- `TranslationalComponents.Flange()` - Linear motion (position, force)
- `RotationalComponents.Flange()` - Rotational motion (angle, torque)
- `ElectricalComponents.Pin()` - Electrical connection (voltage, current)
- `VehicleDynamics.Connectors.WheelContact()` - Combined traction + normal force (wheel-body interface)
- `RealInput()` - Control signal input
- `RealOutput()` - Sensor output

**Sources:**

- `TranslationalComponents.Force()` - Apply force
- `RotationalComponents.TorqueSource()` - Apply torque
- `ElectricalComponents.VoltageSource()` - Apply voltage
- `BlockComponents.Constant()` - Constant signal
- `BlockComponents.Step()` - Step change

**Basic Elements:**

- `TranslationalComponents.Mass()` - Translational inertia
- `RotationalComponents.Inertia()` - Rotational inertia
- `ElectricalComponents.Resistor()` - Electrical resistance
- `ElectricalComponents.Ground()` - Electrical ground reference
- `TranslationalComponents.Fixed()` - Fixed position (ground)
- `RotationalComponents.Fixed()` - Fixed angle

### How to Learn More

**Standard library source code:** `dyad_resources/dyad_stdlib/`

Read the source code to understand:

- How components are implemented
- What parameters they need
- How to use connectors properly
- Sign conventions

---

## Validation Requirements

### Three Levels of Validation

Every component must pass all three levels:

#### Level 1: Compiles (20% of grade)

- [ ] No syntax errors
- [ ] All variables have types (e.g., `variable v::Velocity`)
- [ ] All parameters have units (e.g., `parameter m::Mass = 1500.0`)
- [ ] Proper connector usage
- [ ] Relations section complete

#### Level 2: Runs (30% of grade)

- [ ] `sol.retcode == ReturnCode.Success`
- [ ] Simulation completes to stop time
- [ ] No NaN or Inf values in results
- [ ] No solver crashes or warnings
- [ ] Initial conditions properly set

#### Level 3: Physics Validated (50% of grade)

- [ ] **Hand calculations match simulation** (< 1% error)
- [ ] Energy/power conservation verified numerically
- [ ] Force/torque balance verified at steady state
- [ ] Transient behavior physically reasonable
- [ ] Steady-state matches analytical solution
- [ ] Multiple test scenarios pass
- [ ] Boundary cases tested

### How to Validate

**Before running simulation:**

1. Calculate expected results by hand
2. Derive steady-state values analytically
3. Estimate transient time constants
4. Write down expected values in test comments

**After running simulation:**

1. Compare simulation to hand calculations
2. Check conservation laws (energy, power, momentum)
3. Verify force/torque balances at nodes
4. Plot results and check physical reasonableness
5. Test boundary cases (zero velocity, high speed, etc.)

---

## Integration Testing

### Conventional Powertrain Integration

**File:** `IntegrationTests/ConventionalPowertrain.dyad`

**Required components:**

- VehicleBody, Wheel (×2), Brake (×2)
- Engine, Gearbox, Differential

**System validates:**

- Complete power flow: Engine → Wheels → Vehicle
- Gear shifting behavior
- Mechanical braking
- Realistic vehicle acceleration

### Electric Powertrain Integration

**File:** `IntegrationTests/ElectricPowertrain.dyad`

**Required components:**

- VehicleBody, Wheel (×2), Brake (×2)
- Battery, DCDC, ElectricMotor, MotorController, Differential

**System validates:**

- Complete power flow: Battery ↔ Motor (bidirectional!)
- Regenerative braking (SOC increases during braking!)
- Motor controller logic
- Realistic EV acceleration

### Comparison Test (Optional Advanced)

**File:** `IntegrationTests/ComparisonTest.dyad`

**Purpose:** Side-by-side ICE vs EV comparison

**Compares:**

- Acceleration performance (0-100 km/h)
- Top speed
- Energy consumption
- Efficiency (tank-to-wheels vs battery-to-wheels)
- Regenerative braking benefit

---

## Grading Criteria

### Component-Level Grading (Per Team)

**Component Implementation (60%)**

- Compiles correctly (10%)
- Runs successfully (15%)
- Physics validated (35%)
  - Hand calculations match (15%)
  - Energy conservation (10%)
  - Multiple test scenarios (10%)

**Test Harnesses (20%)**

- Comprehensive test coverage (10%)
- Validation checks included (5%)
- Boundary cases tested (5%)

**Documentation (10%)**

- Clear parameter definitions
- Assumptions documented
- Design decisions explained
- Code comments

**Code Quality (10%)**

- Proper naming conventions
- No hardcoded values (use parameters)
- Clean, readable code
- Follows Dyad best practices

### Integration Grading (For Integration Team)

**System Integration (40%)**

- All components connect correctly (10%)
- System compiles (10%)
- System runs successfully (20%)

**System Validation (40%)**

- Realistic vehicle behavior (15%)
- Energy balance correct (15%)
- Performance metrics reasonable (10%)

**Analysis (20%)**

- Performance metrics calculated
- Comparison analysis (if applicable)
- Plots and visualizations
- Final report quality

---

## Common Issues and Tips

### Getting Started Issues

**"I don't know what equations to use"**

- Review basic physics textbooks
- Check references in component documentation
- Draw free body diagrams
- Start with Newton's laws / Kirchhoff's laws
- Ask instructor for physics guidance (NOT equations)

**"I don't understand the connectors"**

- Read the standard library source code
- Check `TranslationalComponents.Flange()` definition
- Look at example components in dyad_stdlib/
- Pay attention to sign conventions

**"My component won't compile"**

- Check syntax (missing `end`, semicolons)
- Verify all types are defined (`:Velocity`, `::Mass`)
- Check connector names match standard library
- Read error messages carefully

### Implementation Issues

**"I don't know what parameters I need"**

- Read the component documentation
- Check typical value ranges
- Think about what physics equations need
- Start with minimal parameters, add as needed

**"How do I handle sign conventions?"**

- Read the connector documentation carefully
- For Flange: positive force = INTO component
- Draw direction arrows
- Test with simple scenarios first

**"My equations create circular dependencies"**

- Use `guess` statements for algebraic variables
- Check if you have proper causality
- Review initialization documentation

### Validation Issues

**"Simulation runs but results are wrong"**

- Calculate expected values by hand FIRST
- Check parameter values and units
- Verify sign conventions
- Plot intermediate variables
- Check power/energy balance

**"How accurate should my results be?"**

- Steady-state: < 1% error vs analytical
- Transient: shape and time constants correct
- Energy conservation: < 0.1% error
- Always verify by hand calculation first

### Getting Help

**When to ask instructor:**

- Physics concepts unclear
- Dyad syntax questions
- Structural/interface issues
- Integration coordination

**What NOT to ask:**

- "What's the equation for X?"
- "Can you give me the code?"
- "What should the answer be?"

**How to ask good questions:**

- "I derived this equation: [show work]. Is my approach correct?"
- "I get this error: [show error]. I tried [what you tried]. What am I missing?"
- "My results don't match. Expected: X, Got: Y. Here's my calculation: [show work]"

---

## Resources

### Dyad Language Resources

- `dyad_resources/dyad_docs/syntax.md` - Language syntax
- `dyad_resources/dyad_docs/initialization.md` - Initial conditions
- `dyad_resources/dyad_docs/analyses.md` - Running simulations

### Standard Library

- `dyad_resources/dyad_stdlib/` - Source code for all standard components
- `Documentation/StandardLibraryReference.md` - Quick reference guide

### Physics References

- Gillespie, T.D. "Fundamentals of Vehicle Dynamics"
- Wong, J.Y. "Theory of Ground Vehicles"
- Basic physics and electrical engineering textbooks

### Project Files

- `dyad/VehicleDynamics/README.md` - Detailed workflow guide
- `COMPLETE_PROJECT_SUMMARY.md` - Full project overview (instructor)

---

## Timeline

**Week 1: Setup and Component Development Start**

- Day 1: Team assignment, introduction
- Days 2-5: Physics derivation, initial implementation

**Week 2: Component Development and Testing**

- Days 1-3: Complete implementation
- Days 4-5: Create comprehensive tests, validate

**Week 3: Integration**

- Days 1-2: Submit components, integration team combines
- Days 3-5: Debug integration, system validation

**Week 4: Analysis and Reporting**

- Days 1-3: Run comparison tests, analyze results
- Days 4-5: Create visualizations, write report

---

## Success Checklist

### Before Submitting Your Component

- [ ] Component compiles without errors
- [ ] All parameters have units
- [ ] All variables have types
- [ ] Physics equations derived and verified by hand
- [ ] Multiple test scenarios created
- [ ] All tests pass (Level 1, 2, and 3)
- [ ] Hand calculations match simulation (< 1%)
- [ ] Energy/power conservation verified
- [ ] Boundary cases tested
- [ ] Code documented (comments, parameter descriptions)
- [ ] Assumptions documented
- [ ] Design decisions explained

### Before Final Submission (Integration Team)

- [ ] All components collected
- [ ] ConventionalPowertrain test passes
- [ ] ElectricPowertrain test passes
- [ ] System behavior realistic
- [ ] Performance metrics calculated
- [ ] Comparison analysis complete
- [ ] Visualizations created
- [ ] Final report written

---

## Questions?

**First, check:**

1. This README
2. Component documentation
3. Standard library reference
4. Dyad language documentation

**Still stuck?**

- Discuss with your team
- Check with other teams (for interface questions)
- Ask instructor during office hours

**Remember:** The goal is to learn by deriving and implementing the physics yourself. The challenge is intentional!

---

**Good luck! Build great models! 🚗⚡💨**
