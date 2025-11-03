# Vehicle Dynamics Library - Quick Reference Card

**For Students:** Keep this handy while implementing components!

---

## Connector Types - Copy-Paste Ready

### Rotational (Mechanical)

```dyad
flange = Dyad.Spline()  # For: Engine, Gearbox, Differential, Brake, Wheel
# Variables: phi (angle), tau (torque)
```

### Electrical

```dyad
pin = Dyad.Pin()  # For: Battery, DCDC, ElectricMotor
# Variables: v (voltage), i (current)
```

### Signals (Control/Sensing)

```dyad
input = Dyad.RealInput()    # Receives signal
output = Dyad.RealOutput()  # Sends signal
int_input = Dyad.IntegerInput()  # For gear selection
```

### Wheel-Body Interface (Special!)

```dyad
contact = ESPDComponents.VehicleDynamics.Connectors.WheelContact()
# Variables: 
#   s_traction (position), f_traction (force) - longitudinal
#   s_normal (position), f_normal (force) - vertical
# Use in: Wheel, VehicleBody
```

---

## Sign Conventions - Critical

### WheelContact Forces

**Traction (f_traction):**

- From Wheel: `> 0` = pushing vehicle forward
- From Body: `< 0` = receiving forward push
- Formula in Wheel: `contact.f_traction = F_traction_provided`
- Formula in Body: `F_traction_received = -contact.f_traction`

**Normal (f_normal):**

- From Wheel: `> 0` = load on wheel (compression)
- From Body: `< 0` = body pushing down on wheel
- Formula in Wheel: `N = -contact.f_normal` (magnitude)
- Formula in Body: `contact.f_normal = -N_provided`

**Remember:** Flow variables sum at connections (Kirchhoff's law)

### Spline (Rotational)

- `tau > 0` = torque INTO component (driving)
- `tau < 0` = torque OUT OF component (braking/loading)

### Pin (Electrical)

- `i > 0` = current INTO component (consuming)
- `i < 0` = current OUT OF component (generating)

---

## Testing with Helper Components

### Problem

WheelContact doesn't work with standard Force/Mass/Fixed components.

### Solution: Use Breakout Adapter

```dyad
test component TestMyWheel
  wheel = Wheel()
  
  # INSERT THIS ADAPTER:
  breakout = ESPDComponents.VehicleDynamics.Connectors.WheelContactBreakout()
  
  # Now use standard library:
  traction_force = TranslationalComponents.Force()
  normal_force = TranslationalComponents.Force()
  body_mass = TranslationalComponents.Mass(m = 1000.0)
  ground = TranslationalComponents.Fixed()
  
relations
  # Connect wheel to adapter:
  connect(wheel.contact, breakout.contact)
  
  # Connect adapter to standard library:
  connect(breakout.flange_traction, traction_force.flange)
  connect(breakout.flange_traction, body_mass.flange)
  connect(breakout.flange_normal, normal_force.flange)
  connect(breakout.flange_normal, ground.flange)
  
  # Drive signals:
  connect(traction_cmd.y, traction_force.f)
  connect(normal_cmd.y, normal_force.f)
end
```

---

## Common Patterns

### Engine/Motor to Drivetrain

```dyad
engine = Engine()
gearbox = Gearbox()

relations
  connect(engine.flange, gearbox.flange_in)  # Both Spline
```

### Differential to Wheels

```dyad
diff = Differential()
wheel_left = Wheel()
wheel_right = Wheel()

relations
  connect(diff.flange_left, wheel_left.flange_rot)
  connect(diff.flange_right, wheel_right.flange_rot)
```

### Wheels to Body

```dyad
wheel_front = Wheel()
wheel_rear = Wheel()
body = VehicleBody()

relations
  # Single connection handles BOTH traction and normal!
  connect(wheel_front.contact, body.contact_front)
  connect(wheel_rear.contact, body.contact_rear)
```

### Battery to Motor

```dyad
battery = Battery()
motor = ElectricMotor()
ground = Dyad.Ground()  # Electrical reference

relations
  connect(battery.p, motor.p)
  connect(battery.n, ground.g)
  connect(motor.n, ground.g)
```

---

## Initial Conditions

### Differential States (has der())

```dyad
initial component.variable = value
```

Examples:

- `initial wheel.flange_rot.phi = 0.0` (angle)
- `initial body.v = 10.0` (velocity)
- `initial battery.SOC = 0.8` (state of charge)

### Algebraic States (in loops)

```dyad
guess component.variable = value
```

Examples:

- `guess node.voltage = 400.0`
- `guess joint.force = 1000.0`

**Rule:** If you get "uninitialized" errors, you need initial/guess!

---

## Units - CRITICAL

### Always Specify Units

```dyad
parameter m::Mass = 1500.0        # kg
parameter R::Resistance = 0.1     # Ω
parameter L::Length = 2.7         # m
variable v::Velocity              # m/s
variable F::Force                 # N
```

### Common Unit Types

- `Mass`, `Length`, `Time`, `Velocity`, `Acceleration`
- `Force`, `Torque`, `Inertia`, `Angle`, `AngularVelocity`
- `Voltage`, `Current`, `Resistance`, `Power`
- `Real` (dimensionless)

---

## Validation Before Running

### Checklist

- [ ] All connectors match this reference (Dyad.Spline, not RotationalComponents.Flange!)
- [ ] WheelContact used for wheel-body (not separate flanges)
- [ ] All parameters have units: `parameter x::Type = value`
- [ ] All variables have types: `variable x::Type`
- [ ] Sign conventions correct (check WheelContact.md)
- [ ] Initial conditions set for differential states
- [ ] Guesses provided for algebraic loops

---

## When Things Go Wrong

### "Connector not found"

→ Check spelling: `Dyad.Spline()` not `RotationalComponents.Flange()`

### "Cannot connect Flange to WheelContact"

→ Use `WheelContactBreakout()` adapter (see Testing section above)

### "Uninitialized variable"

→ Add `initial` or `guess` statement

### "System is unbalanced"

→ Count equations vs unknowns (see docs for debugging)

### "Wrong physics" (simulation runs but results are wrong)

→ Check sign conventions in WheelContact.md (most common error!)

---

## Key Documentation Files

**Must Read First:**

1. `Components/WheelContact.md` - If implementing Wheel or VehicleBody
2. `StandardLibraryReference.md` - For all standard components
3. Your component's .md file in `Components/`

**Reference During Implementation:**

- This file (Quick Reference) - Keep open!
- `dyad_resources/dyad_docs/syntax.md` - Language syntax
- `dyad_resources/dyad_docs/initialization.md` - Initial conditions

**For Testing:**

- Test template files in `Tests/[YourComponent]/`
- Examples in `Components/WheelContact.md` section "Testing Considerations"

---

## Copy-Paste Template: Test with Breakout

```dyad
test component TestMyComponent
  # YOUR COMPONENT
  comp = MyComponent(param1 = value1)
  
  # ADAPTER (if using WheelContact)
  breakout = ESPDComponents.VehicleDynamics.Connectors.WheelContactBreakout()
  
  # STANDARD LIBRARY COMPONENTS
  source = SomeSource()
  load = SomeLoad()
  ground = TranslationalComponents.Fixed()
  
  # CONTROL SIGNALS
  cmd = BlockComponents.Constant(k = 100.0)
  
relations
  # YOUR CONNECTIONS HERE
  connect(comp.contact, breakout.contact)  # If using WheelContact
  connect(breakout.flange_traction, load.flange)
  connect(breakout.flange_normal, ground.flange)
  connect(cmd.y, source.input)
  
  # INITIAL CONDITIONS
  initial comp.phi = 0.0
  guess comp.some_algebraic_var = 0.0
end

analysis TestMyComponent_Analysis
  extends TransientAnalysis(stop = 5.0, alg = "Rodas5P")
  model = TestMyComponent()
end
```

---

## Emergency Contact

**Stuck? Check:**

1. This Quick Reference
2. WheelContact.md (if using wheels/body)
3. Your component's specific .md file
4. StandardLibraryReference.md

**Still stuck? Verify:**

- Connector types match this reference exactly
- Sign conventions correct (WheelContact is tricky!)
- All units specified
- Initial conditions set

---

**Remember:**

- `Dyad.Spline` for rotation
- `Dyad.Pin` for electrical
- `WheelContact` for wheel-body (special!)
- Always check sign conventions!

**Good luck!** 🚗⚡
