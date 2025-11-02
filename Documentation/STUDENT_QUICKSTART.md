# Vehicle Dynamics Project - Quick Start Guide for Students 🚗

## What You're Building

A complete vehicle dynamics simulation library with components for:
- **Conventional vehicles:** Engine, gearbox, differential, wheels, brakes
- **Electric vehicles (bonus):** Battery, motor, controller

## Where to Start

### Step 1: Understand the Architecture (15 minutes)
📖 Read: `Documentation/task.md` - Overview of the project  
📖 Read: `Documentation/PHASE_0_SCAFFOLDING.md` - How scaffolding works  
👀 Look at: `dyad/VehicleDynamics/VehicleComponents.dyad` - See how components connect

### Step 2: Choose Your Starting Component (5 minutes)
🎯 **Recommended:** Start with VehicleBody (easiest)

**Difficulty Guide:**
- ⭐☆☆☆☆ VehicleBody - Translational dynamics (START HERE)
- ⭐⭐☆☆☆ Wheel - Domain coupling
- ⭐⭐☆☆☆ Brake - Control input
- ⭐⭐⭐☆☆ Engine - Speed-dependent source
- ⭐⭐⭐☆☆ Differential - Multi-port
- ⭐⭐⭐⭐☆ Gearbox - Arrays/indexing

### Step 3: Read the Component Specification (20 minutes)
📖 Read: `Documentation/VehicleBody.md` (or whichever you're working on)

**What you'll learn:**
- What the component does
- Physical phenomena to model (NO equations given!)
- Required interfaces/connectors
- Test objectives

**What you WON'T find:**
- The equations (you derive these!)
- Expected numerical results (you calculate these!)
- Implementation code (you write this!)

### Step 4: Derive the Physics (30-60 minutes)
📝 Work out the equations on paper FIRST:
- Draw free body diagram
- Write governing equations
- Calculate expected steady-state values
- Figure out what variables and parameters you need

**Resources:**
- Your physics textbooks
- Referenced books (Gillespie, Wong for vehicles)
- Conservation laws (energy, momentum, power)

### Step 5: Implement in Dyad (1-2 hours)
💻 Open: `dyad/VehicleDynamics/StarterTemplate.dyad`

**Copy the template for your component:**
```dyad
component VehicleBody
  # Connector
  flange = TranslationalComponents.Flange()
  
  # TODO: Add your parameters
  parameter m::Mass = 1500.0
  
  # TODO: Add your variables
  variable v::Velocity
  
relations
  # TODO: Replace placeholders with your physics
  # ...
end
```

**Replace all TODOs with:**
- Your parameters (with units!)
- Your variables (with types!)
- Your equations (from Step 4!)

**Check the standard library:**
```bash
# See what's available
ls dyad_resources/dyad_stdlib/
cat dyad_resources/dyad_stdlib/TranslationalComponents/*.dyad
```

### Step 6: Create Test Harness (30-60 minutes)
🧪 In the SAME file as your component:

```dyad
test component TestVehicleBody_ConstantForce
  vehicle = VehicleBody(m = 1000.0, Cd = 0.0, Crr = 0.0)
  force_source = TranslationalComponents.Force()
  constant_force = BlockComponents.Constant(k = 1000.0)
  ground = TranslationalComponents.Fixed()
  
relations
  connect(constant_force.y, force_source.f_input)
  connect(force_source.flange, vehicle.flange)
  connect(vehicle.flange, ground.flange)
  
  initial vehicle.flange.s = 0.0
  initial vehicle.v = 0.0
end

analysis TestVehicleBody_ConstantForce_Analysis
  extends TransientAnalysis(stop = 10.0, alg = "Rodas5P")
  model = TestVehicleBody_ConstantForce()
end
```

### Step 7: Validate Physics (1-2 hours)
✅ Run your simulation and check:

**Level 1: Does it compile?**
- No syntax errors
- All types correct

**Level 2: Does it run?**
- Simulation completes
- No NaN or Inf values

**Level 3: Is the physics correct?**
- Compare to your hand calculations (< 1% error)
- Verify energy conservation
- Check force/torque balance
- Test boundary conditions

### Step 8: Move to Next Component
🎉 Once validated, move to the next component in order:
1. VehicleBody ✓
2. Wheel
3. Brake
4. Engine
5. Differential
6. Gearbox

## File Structure

```
Your workspace:
├── dyad/VehicleDynamics/
│   ├── VehicleComponents.dyad    ← Full system example (read for reference)
│   └── StarterTemplate.dyad      ← Your starting templates (copy from here)
│
├── Documentation/
│   ├── VehicleBody.md           ← Read BEFORE implementing
│   ├── Wheel.md
│   ├── Brake.md
│   ├── Engine.md
│   ├── Differential.md
│   ├── Gearbox.md
│   └── StandardLibraryReference.md  ← What components exist
│
└── dyad_resources/
    ├── dyad_docs/               ← Dyad language reference
    └── dyad_stdlib/             ← Standard library source (read for examples)
```

## Common Mistakes to Avoid

### ❌ DON'T:
- Copy equations from the internet without understanding
- Hardcode values (use parameters!)
- Forget initial conditions
- Ignore sign conventions
- Skip validation
- Move on before current component works

### ✅ DO:
- Derive equations from first principles
- Use parameters with units
- Set initial conditions for differential variables
- Check sign conventions carefully (read Flange docs!)
- Validate thoroughly
- Test boundary cases

## Tools and Resources

### Standard Library Documentation:
```bash
# See what connectors are available
cat dyad_resources/dyad_stdlib/Connectors/*.dyad

# See translational components
cat dyad_resources/dyad_stdlib/TranslationalComponents/*.dyad

# See rotational components
cat dyad_resources/dyad_stdlib/RotationalComponents/*.dyad

# See block/signal components
cat dyad_resources/dyad_stdlib/BlockComponents/*.dyad
```

### Key Connectors You'll Use:
- `TranslationalComponents.Flange()` - For linear motion (position, force)
- `RotationalComponents.Flange()` - For rotation (angle, torque)
- `RealInput()` - For control signals (throttle, brake, gear)
- `RealOutput()` - For sensor outputs

### Key Components You'll Use in Tests:
- `TranslationalComponents.Force()` - Apply force
- `TranslationalComponents.Fixed()` - Ground reference
- `RotationalComponents.TorqueSource()` - Apply torque
- `RotationalComponents.Fixed()` - Fixed rotation point
- `BlockComponents.Constant()` - Constant signal
- `BlockComponents.Step()` - Step change
- `BlockComponents.Ramp()` - Ramp signal

## Debugging Tips

### Compilation Errors:
- Check syntax (semicolons, `end` keywords)
- Verify all variables have types
- Verify all parameters have units
- Check connector names match stdlib

### Runtime Errors:
- Did you set initial conditions?
- Are your equations balanced?
- Check for division by zero
- Look for sign errors

### Wrong Results:
- Calculate expected values by hand FIRST
- Check units (rad/s vs rpm, etc.)
- Verify power conservation
- Plot intermediate variables

## Getting Help

### When Stuck:
1. Read the component .md file again
2. Check standard library examples
3. Draw diagrams (free body, power flow)
4. Calculate by hand
5. Ask instructor (but show your work first!)

### What to Ask:
- ✅ "I derived this equation, is my approach correct?"
- ✅ "How do I use this connector from the stdlib?"
- ✅ "My power balance is off by X%, what could cause this?"

### What NOT to Ask:
- ❌ "What equations should I use?"
- ❌ "Can you give me the code?"
- ❌ "What should the answer be?"

## Success Criteria

### You're Done with a Component When:
- ✅ Compiles without errors
- ✅ Runs to completion
- ✅ Hand calculations match simulation (< 1% error)
- ✅ Energy/power is conserved
- ✅ All test cases pass
- ✅ Boundary conditions tested
- ✅ Code is documented

### You're Ready for Integration When:
- ✅ All individual components validated
- ✅ Interfaces match scaffolding
- ✅ No hardcoded values
- ✅ Comprehensive test coverage

## Timeline Estimate

**Per Component:**
- Physics derivation: 0.5-1 hour
- Implementation: 1-2 hours
- Testing: 0.5-1 hour
- Validation: 1-2 hours
- **Total: 3-5 hours per component**

**Full Project:**
- 6 components × 4 hours avg = **24 hours total**
- Plus integration testing: **+4 hours**
- **Grand total: ~28 hours** (about 3-4 full days of work)

## Final Tip

**Physics First, Code Second!**

If you can't derive the equations and calculate expected results by hand, don't start coding yet. Go back to your physics books.

The best developers in this project will be those who:
- Understand the physics deeply
- Calculate before coding
- Validate thoroughly
- Think systematically

Good luck! You've got this! 🚀

---

**Questions?** Start with the documentation, then ask your instructor.

**Stuck?** Break the problem into smaller pieces. Test the simplest case first.

**Working?** Great! Validate thoroughly before moving on. Don't skip validation!
