# Vehicle Dynamics Library

## Directory Structure

```
VehicleDynamics/
├── README.md                                      ← You are here
│
├── Components/                                    ← Component implementations
│   ├── VehicleBody.dyad                          → Vehicle mass dynamics
│   ├── Wheel.dyad                                → Rotational-translational coupling
│   ├── Brake.dyad                                → Friction braking
│   ├── Engine.dyad                               → ICE torque source
│   ├── Differential.dyad                         → Torque splitting
│   ├── Gearbox.dyad                              → Multi-ratio transmission
│   └── Electric/                                  ← Electric powertrain components
│       ├── Battery.dyad                          → Energy storage with SOC
│       ├── DCDC.dyad                             → Voltage converter
│       ├── ElectricMotor.dyad                    → Electric machine
│       └── MotorController.dyad                  → Torque controller
│
├── Tests/                                        ← Component-level tests
│   ├── VehicleBodyTests.dyad
│   ├── WheelTests.dyad
│   ├── BrakeTests.dyad                           → (Students create)
│   ├── EngineTests.dyad                          → (Students create)
│   ├── DifferentialTests.dyad                    → (Students create)
│   ├── GearboxTests.dyad                         → (Students create)
│   └── Electric/                                  ← Electric component tests
│       ├── BatteryTests.dyad
│       ├── ElectricMotorTests.dyad
│       └── ... (students create remaining)
│
└── IntegrationTests/                             ← System-level tests
    ├── ConventionalPowertrain.dyad               → Full ICE vehicle
    └── ElectricPowertrain.dyad                   → Full EV (students create)
```

## Workflow for Student Teams

### Team-Based Development Approach

**Note:** Components can be developed **in parallel** by different teams. Each team is responsible for:
1. Implementing their assigned component(s)
2. Creating comprehensive test harnesses
3. Validating physics thoroughly
4. Documenting any assumptions

### Phase 0: Setup and Team Assignment
1. Read `../../Documentation/STUDENT_QUICKSTART.md`
2. Review this README
3. Understand the directory structure
4. **Receive team assignments** from instructor

### Phase 1: Parallel Component Development

Teams work independently on assigned components:

#### Conventional Powertrain Components (6 components)
- **VehicleBody** - Vehicle mass dynamics with resistance forces
- **Wheel** - Rotational-translational domain coupling  
- **Brake** - Friction braking with control input
- **Engine** - Speed-dependent ICE torque source
- **Differential** - Torque splitting with speed averaging
- **Gearbox** - Multi-ratio transmission with efficiency

#### Electric Powertrain Components (4 components)
- **Battery** - Energy storage with SOC dynamics and internal resistance
- **DCDC** - Voltage converter with efficiency losses
- **ElectricMotor** - Electro-mechanical energy conversion with back-EMF
- **MotorController** - Torque command with regenerative braking logic

### Component Development Workflow (Per Team)

**For each assigned component:**
1. **Read:** `../../Documentation/ComponentName.md`
2. **Implement:** Open `Components/ComponentName.dyad` and replace TODOs
3. **Test:** Create `Tests/ComponentNameTests.dyad` with multiple scenarios
4. **Validate:** Verify all three levels (compiles, runs, physics correct)
5. **Document:** Note any assumptions or design decisions

### Phase 2: Integration Testing (3-4 hours)

Once all components are working individually:

1. **Review:** `IntegrationTests/ConventionalPowertrain.dyad`
2. **Uncomment:** All TODO sections
3. **Connect:** All components together
4. **Run:** Full vehicle simulation
5. **Validate:** System-level behavior
6. **Measure:** 0-100 km/h time, top speed, etc.

### Phase 3: Refinement and Documentation (2-3 hours)

- Add missing test files
- Document any assumptions made
- Create plots of key variables
- Write summary report

## File Naming Conventions

### Component Files
- Filename: `ComponentName.dyad`
- Component: `component ComponentName`
- Location: `Components/`

### Test Files
- Filename: `ComponentNameTests.dyad`
- Tests: `test component TestComponentName_ScenarioName`
- Analyses: `analysis TestComponentName_ScenarioName_Analysis`
- Location: `Tests/`

### Integration Tests
- Filename: `SystemName.dyad`
- Test: `test component SystemNameIntegration`
- Analysis: `analysis SystemNameIntegration_Analysis`
- Location: `IntegrationTests/`

## Component Dependencies and Integration

### Shared Components
- **VehicleBody** - Needed by both conventional and electric powertrains
- **Wheel** - Needed by both conventional and electric powertrains  
- **Brake** - Needed by both conventional and electric powertrains

### Conventional Powertrain Chain
```
Engine → Gearbox → Differential → Brake → Wheel → VehicleBody
```

### Electric Powertrain Chain
```
Battery → DCDC → ElectricMotor → MotorController
                      ↓
                 Differential → Brake → Wheel → VehicleBody
```

### Integration Dependencies
- **ConventionalPowertrain** requires: All 6 conventional components
- **ElectricPowertrain** requires: Shared (3) + Electric (4) components

**Note:** Teams can work in parallel since most components are independent. Shared components (VehicleBody, Wheel, Brake) should be prioritized or assigned to experienced teams.

## Compilation

### Compile All Components
```bash
cd /path/to/ESPDComponents
dyad compile dyad/VehicleDynamics/Components/
```

### Compile Specific Component
```bash
dyad compile dyad/VehicleDynamics/Components/VehicleBody.dyad
```

### Compile Tests
```bash
dyad compile dyad/VehicleDynamics/Tests/
```

### Compile Integration Tests
```bash
dyad compile dyad/VehicleDynamics/IntegrationTests/
```

## Running Tests

After compilation, tests become available in Julia:

```julia
using Pkg
Pkg.activate("/path/to/ESPDComponents")
using ESPDComponents

# Run individual component test
# (Test names will be generated based on your analysis definitions)

# Run integration test
# (Once all components are complete)
```

## Standard Library References

Components you'll frequently use:

### Connectors
- `TranslationalComponents.Flange()` - Linear motion (position, force)
- `RotationalComponents.Flange()` - Rotational motion (angle, torque)
- `RealInput()` - Control signal input
- `RealOutput()` - Sensor output

### Sources
- `TranslationalComponents.Force()` - Apply force
- `RotationalComponents.TorqueSource()` - Apply torque
- `RotationalComponents.Speed()` - Enforce angular velocity
- `BlockComponents.Constant()` - Constant signal
- `BlockComponents.Step()` - Step change
- `BlockComponents.Ramp()` - Ramp signal

### References
- `TranslationalComponents.Fixed()` - Fixed position (ground)
- `RotationalComponents.Fixed()` - Fixed angle

### Basic Elements
- `TranslationalComponents.Mass()` - Translational inertia
- `RotationalComponents.Inertia()` - Rotational inertia
- `TranslationalComponents.Damper()` - Linear damping
- `RotationalComponents.Damper()` - Rotational damping

**Full reference:** `../../Documentation/StandardLibraryReference.md`

## Validation Checklist

For each component:

### Level 1: Compiles (Required)
- [ ] No syntax errors
- [ ] All variables have types
- [ ] All parameters have units
- [ ] Uses correct connector types

### Level 2: Runs (Required)
- [ ] `sol.retcode == ReturnCode.Success`
- [ ] Simulation completes to stop time
- [ ] No NaN or Inf values
- [ ] No solver crashes or warnings

### Level 3: Physics Validated (Required)
- [ ] Hand calculations match simulation (< 1% error)
- [ ] Energy/power conservation verified
- [ ] Force/torque balance verified numerically
- [ ] Transient behavior physically reasonable
- [ ] Steady-state matches analytical solution
- [ ] Boundary cases tested

### Level 4: Code Quality (Good Practice)
- [ ] Parameters not hardcoded
- [ ] Variables well-named
- [ ] Comments explain non-obvious equations
- [ ] Test coverage comprehensive
- [ ] Initial conditions documented

## Common Issues

### Component Won't Compile
- Check syntax (semicolons, end keywords)
- Verify all types are defined
- Check connector names match stdlib

### Component Compiles but Won't Run
- Did you set initial conditions?
- Are equations balanced?
- Check for division by zero
- Verify constraint equations

### Component Runs but Wrong Results
- Calculate expected values by hand FIRST
- Check sign conventions on connectors
- Verify units (rad/s vs rpm, etc.)
- Plot intermediate variables
- Check power/energy balance

### Integration Test Fails
- Verify each component individually FIRST
- Check connection topology
- Review initial conditions for all components
- Start with simplified test (fewer components)

## Getting Help

### Documentation
- `../../Documentation/STUDENT_QUICKSTART.md` - Getting started
- `../../Documentation/ComponentName.md` - Component specifications
- `../../Documentation/StandardLibraryReference.md` - Available components
- `../../dyad_resources/dyad_docs/` - Dyad language reference

### Standard Library Examples
- `../../dyad_resources/dyad_stdlib/` - Source code to learn from

### Debugging
1. Read error messages carefully
2. Check your math on paper
3. Start with simplest test case
4. Add complexity incrementally
5. Ask instructor (after attempting yourself!)

## Status Tracking

Track your progress:

- [ ] VehicleBody implemented and validated
- [ ] Wheel implemented and validated
- [ ] Brake implemented and validated
- [ ] Engine implemented and validated
- [ ] Differential implemented and validated
- [ ] Gearbox implemented and validated
- [ ] Integration test passes
- [ ] System-level validation complete

## Next Steps After Completion

Once all tests pass:

1. **Performance Analysis**
   - 0-100 km/h acceleration time
   - Top speed calculation
   - Fuel economy estimate
   - Brake distance analysis

2. **Parametric Studies**
   - Effect of mass on performance
   - Drag coefficient impact
   - Gear ratio optimization

3. **Drive Cycle Simulation**
   - WLTP or NEDC cycle
   - Velocity tracking
   - Energy consumption

4. **Phase 2B: Electric Powertrain (Optional)**
   - Battery, DCDC, ElectricMotor, MotorController
   - Regenerative braking
   - Energy efficiency analysis

## Questions?

Start with documentation, then consult your instructor.

Good luck! 🚗💨
