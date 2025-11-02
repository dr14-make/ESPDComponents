# Student Documentation - Quick Reference

## What Changed

All component specification files have been simplified to remove detailed equations and solutions. Students must now derive the physics and implementation themselves.

## File Status

| Component | File | Status | Complexity | Prerequisites |
|-----------|------|--------|------------|---------------|
| **VehicleBody** | VehicleBody.md | ✅ Ready | Low | Basic mechanics |
| **Wheel** | Wheel.md | ✅ Ready | Low-Medium | VehicleBody |
| **Brake** | Brake.md | ✅ Ready | Low | Basic rotational mechanics |
| **Engine** | Engine.md | ✅ Ready | Medium | Rotational dynamics |
| **Differential** | Differential.md | ✅ Ready | Medium | Gears, kinematics |
| **Gearbox** | Gearbox.md | ✅ Ready | Medium | Differential |
| **Battery** | Battery.md | ✅ Ready | Medium | Basic electrical circuits |
| **DCDC** | DCDC.md | ✅ Ready | Medium | Battery, power electronics |
| **ElectricMotor** | ElectricMotor.md | ✅ Ready | High | Electrical + mechanical |
| **MotorController** | MotorController.md | ✅ Ready | Medium | ElectricMotor |

## Suggested Assignment Order

### Phase 1: Foundation (Conventional Vehicle)

1. **VehicleBody** - Start here (simplest)
2. **Wheel** - Learn domain coupling
3. **Brake** - Add control input
4. **Engine** - Speed-dependent source
5. **Differential** - Multi-port component
6. **Gearbox** - Discrete states

### Phase 2: Electric Vehicle (Alternative Path)

1. **VehicleBody** - Start here
2. **Wheel** - Domain coupling
3. **Battery** - Differential state (SOC)
4. **ElectricMotor** - Bidirectional power
5. **MotorController** - Control logic
6. **DCDC** - Power electronics

### Phase 3: Integration

- Combine components into full vehicle systems
- Test drive cycles
- Validate energy balance

## What Students Get

For each component, the documentation provides:

### ✅ Included

- **Purpose:** What the component does
- **Conceptual diagram:** Visual representation
- **Physical phenomena:** What needs to be modeled (descriptive)
- **Interface requirements:** Which connectors to use
- **Test objectives:** What to validate
- **Parameter ranges:** Typical values
- **Important considerations:** Hints on tricky aspects

### ❌ Removed

- Governing equations (students derive these)
- Implementation code (students write this)
- Expected numerical results (students calculate these)
- Validation assertions (students verify manually)
- Step-by-step solutions

## Example: What Students See

### VehicleBody.md - Before vs After

**Before (gave away solution):**

```markdown
F_net = F_traction - F_aero - F_roll
F_aero = 0.5 × ρ × Cd × A × v²
m × a = F_net

Test: With m=1000kg, F=1000N:
- Expected a = 1.0 m/s²
- Expected v(10s) = 10.0 m/s
```

**After (requires thinking):**

```markdown
Model a vehicle body experiencing:
- Traction force from wheels
- Aerodynamic drag (increases with velocity squared)
- Rolling resistance (proportional to normal force)

What to Validate:
- Calculate expected acceleration from F=ma BEFORE running
- Verify velocity increases as expected
- Compare simulation to hand calculations
```

## Support Resources for Students

### Available in Repository

- `StandardLibraryReference.md` - What components exist in stdlib
- `dyad_resources/dyad_docs/syntax.md` - Dyad language reference
- `dyad_resources/dyad_docs/initialization.md` - How to set initial conditions
- `dyad_resources/dyad_stdlib/` - Source code of standard library components

### External References (Cited in Docs)

- Gillespie: "Fundamentals of Vehicle Dynamics"
- Wong: "Theory of Ground Vehicles"
- Basic physics textbooks for mechanics and circuits

## Grading Considerations

Each component has clear validation requirements:

1. **Level 1: Compiles** (20%)
   - No syntax errors
   - Proper types and units

2. **Level 2: Runs** (30%)
   - Simulation completes successfully
   - No NaN or Inf values

3. **Level 3: Physics Validated** (50%)
   - Steady-state matches hand calculations
   - Energy/power conservation verified
   - Transient behavior physically reasonable

## Common Student Challenges (Expected)

1. **Sign conventions** - Figuring out positive/negative force/torque directions
2. **Units** - Converting between rpm/rad/s, kW·h/J, etc.
3. **Initialization** - Setting initial conditions for differential states
4. **Constraint equations** - Kinematic relationships (wheel, differential)
5. **Discontinuities** - Handling sign functions smoothly (drag, friction)

These challenges are **intentional** - students learn by solving them.

## Instructor Support

If students are stuck:

### Good Hints

- "What does Newton's second law say about this?"
- "Check the sign convention in the Flange documentation"
- "Draw a free body diagram first"
- "What should the power balance be?"

### Avoid

- Giving the equations directly
- Showing implementation code
- Providing numerical answers

### When to Intervene

- Dyad syntax questions (refer to docs)
- Compiler/solver errors (help debug)
- Conceptual physics questions (Socratic method)
- Completely stuck after reasonable effort

## Files NOT Simplified

- `task.md` - Project structure (kept detailed)
- `StandardLibraryReference.md` - Reference docs (kept detailed)
- `STUDENT_VERSION_NOTES.md` - Internal tracking
- `SIMPLIFICATION_COMPLETE.md` - Internal summary

## Quick Start for Students

1. Read `task.md` to understand the project
2. Read `StandardLibraryReference.md` to see available components
3. Start with Phase 0 (scaffolding) or Phase 1 Task 1.1 (VehicleBody)
4. For each component:
   - Read the component's .md file
   - Derive the equations from physics
   - Read stdlib sources for connector usage
   - Implement in Dyad
   - Create test harness
   - Validate physics

---

**Questions?** Check the documentation files or ask your instructor.

**Stuck?** Start with a simpler test case. Break the problem down.

**Working?** Validate thoroughly before moving on. Physics first!
