# Standard Library Components - Quick Reference

## Overview

**CRITICAL:** Always use standard library components. DO NOT create custom connectors or basic elements.

**Location:** `/home/dr14/Projects/CVUT/ESPDComponents/dyad_resources/dyad_stdlib/`

---

## How to Use This Guide

**Before using ANY component:**

1. Find it in this reference
2. Read its source file: `cat dyad_resources/dyad_stdlib/[Domain]Components.dyad`
3. Understand its interface (what flanges/ports it has)
4. Check what parameters it needs
5. Look at examples in the source file

---

## Vehicle Dynamics Domain Components

**File:** `dyad/VehicleDynamics/Connectors/`

### Specialized Connectors

#### WheelContact

```dyad
VehicleDynamics.Connectors.WheelContact
  # Variables:
  # - s_traction: longitudinal position [m]
  # - f_traction: traction force [N] (flow variable)
  # - s_normal: vertical position [m]
  # - f_normal: normal force [N] (flow variable)
  # 
  # Combines both traction and normal forces in single connector
  # Used between Wheel and VehicleBody components
```

**Purpose:** Couples wheel-body interface with both traction and normal forces.

**Documentation:** See [WheelContact.md](Components/WheelContact.md) for detailed guide.

### Helper Components for Testing

| Component | Description | Use Case |
|-----------|-------------|----------|
| `WheelContactBreakout` | Converts WheelContact to separate standard Flanges | Testing with standard library components |
| `WheelContactForceSource` | Applies controlled traction + normal forces | Unit testing wheels with prescribed forces |

**Example Usage:**

```dyad
test component TestWheelWithStandardLib
  wheel = Wheel()
  breakout = VehicleDynamics.Connectors.WheelContactBreakout()
  
  # Now use standard library components
  traction_force = TranslationalComponents.Force()
  ground = TranslationalComponents.Fixed()
  
relations
  connect(wheel.contact, breakout.contact)
  connect(breakout.flange_traction, traction_force.flange)
  connect(breakout.flange_normal, ground.flange)
end
```

---

## Rotational Domain Components

**File:** `dyad_resources/dyad_stdlib/RotationalComponents.dyad`

### Connectors

```dyad
RotationalComponents.Flange
  # Variables:
  # - phi: angular position [rad]
  # - tau: torque [N⋅m]
  # Sign convention: tau > 0 means torque INTO component
```

### Basic Elements

| Component | Description | Parameters | Use Case |
|-----------|-------------|------------|----------|
| `Inertia` | Rotational inertia: τ = J·α | `J` (kg⋅m²) | Wheel inertia, engine flywheel |
| `Spring` | Torsional spring: τ = k·φ | `k` (N⋅m/rad) | Driveshaft flexibility |
| `Damper` | Rotational damper: τ = d·ω | `d` (N⋅m⋅s/rad) | Viscous friction, damping |
| `Fixed` | Fixed rotation point | none | Ground reference, support |

### Sources and Sensors

| Component | Description | Input/Output | Use Case |
|-----------|-------------|--------------|----------|
| `TorqueSource` | Applies torque | Input: `tau` | Engine torque, brake torque |
| `Speed` | Enforces angular velocity | Input: `w` [rad/s] | Constant speed tests |

### Gear Elements

| Component | Description | Parameters | Use Case |
|-----------|-------------|------------|----------|
| `IdealGear` | Ideal gear ratio: ω₂ = ω₁/ratio | `ratio` | Simple gearbox models |
| `IdealRollingWheel` | Rolling without slip | `radius` (m) | Wheel-road coupling |

**Usage Example:**

```dyad
# In your component
inertia = RotationalComponents.Inertia(J = 0.5)  # 0.5 kg⋅m²
spring = RotationalComponents.Spring(k = 100.0)   # 100 N⋅m/rad

relations
  connect(inertia.flange_a, spring.flange_a)
end
```

---

## Translational Domain Components

**File:** `dyad_resources/dyad_stdlib/TranslationalComponents.dyad`

### Connectors

```dyad
TranslationalComponents.Flange
  # Variables:
  # - s: position [m]
  # - f: force [N]
  # Sign convention: f > 0 means force INTO component
```

### Basic Elements

| Component | Description | Parameters | Use Case |
|-----------|-------------|------------|----------|
| `Mass` | Translational mass: F = m·a | `m` (kg) | Vehicle body mass |
| `Spring` | Linear spring: F = k·x | `k` (N/m) | Suspension springs |
| `Damper` | Linear damper: F = d·v | `d` (N⋅s/m) | Shock absorbers, aero drag approximation |
| `Fixed` | Fixed position | none | Ground, road surface |

### Sources and Sensors

| Component | Description | Input/Output | Use Case |
|-----------|-------------|--------------|----------|
| `Force` | Applies force | Input: `f` [N] | Traction force, external forces |
| `Position` | Enforces position | Input: `s` [m] | Position control |
| `Velocity` | Enforces velocity | Input: `v` [m/s] | Velocity control |

**Usage Example:**

```dyad
# Vehicle body with damper for air resistance
vehicle = TranslationalComponents.Mass(m = 1500.0)     # 1500 kg
aero = TranslationalComponents.Damper(d = 0.5)         # Approximate drag
ground = TranslationalComponents.Fixed()

relations
  connect(vehicle.flange_b, aero.flange_a)
  connect(aero.flange_b, ground.flange)
end
```

---

## Block/Signal Domain Components

**File:** `dyad_resources/dyad_stdlib/BlockComponents.dyad`

### Signal Connectors

```dyad
BlockComponents.RealInput   # Input port for Real signals
BlockComponents.RealOutput  # Output port for Real signals
```

### Sources

| Component | Description | Parameters | Use Case |
|-----------|-------------|------------|----------|
| `Constant` | Constant output | `k` | Fixed throttle, constant load |
| `Step` | Step change | `height`, `offset`, `startTime` | Sudden throttle change, brake application |
| `Ramp` | Linear ramp | `height`, `duration`, `offset`, `startTime` | Gradual acceleration |
| `Sine` | Sinusoidal | `amplitude`, `frequency`, `offset` | Oscillating loads |

### Math Operations

| Component | Description | Use Case |
|-----------|-------------|----------|
| `Gain` | Multiply by constant | Scaling signals |
| `Add` | Addition | Combining forces/torques |
| `Product` | Multiplication | Nonlinear calculations |

**Usage Example:**

```dyad
# Test with step input
test component TestMyComponent
  comp = MyComponent()
  
  # Step throttle input: 0 → 0.5 at t=2s
  throttle_cmd = BlockComponents.Step(
    height = 0.5,
    offset = 0.0,
    startTime = 2.0
  )
  
relations
  connect(throttle_cmd.y, comp.throttle_input)
end
```

---

## Electrical Domain Components (if needed)

**File:** `dyad_resources/dyad_stdlib/ElectricalComponents.dyad`

### Connectors

```dyad
ElectricalComponents.Pin
  # Variables:
  # - v: voltage [V]
  # - i: current [A]
```

### Basic Elements

| Component | Description | Parameters | Use Case |
|-----------|-------------|------------|----------|
| `Resistor` | Ohm's law: V = I·R | `R` (Ω) | Electrical loads |
| `Capacitor` | I = C·dV/dt | `C` (F) | Energy storage |
| `Inductor` | V = L·dI/dt | `L` (H) | Coils, motors |
| `Ground` | Reference voltage | none | Circuit ground |

**Use for:** Hybrid/electric vehicle components (batteries, motors, generators)

---

## Common Patterns

### Pattern 1: Simple Test with Constant Input

```dyad
test component TestMyRotationalComponent
  comp = MyComponent(param1 = value1)
  
  # Constant torque source
  source = RotationalComponents.TorqueSource()
  torque = BlockComponents.Constant(k = 100.0)  # 100 N⋅m
  
  # Simple load
  load = RotationalComponents.Inertia(J = 1.0)
  
relations
  connect(torque.y, source.tau)
  connect(source.flange, comp.flange_a)
  connect(comp.flange_b, load.flange)
  
  initial load.phi = 0.0
  initial der(load.phi) = 0.0
end
```

### Pattern 2: Step Response Test

```dyad
test component TestMyComponent_Step
  comp = MyComponent()
  
  # Step input
  step_input = BlockComponents.Step(
    height = 1.0,
    offset = 0.0,
    startTime = 1.0
  )
  
  source = RotationalComponents.TorqueSource()
  load = RotationalComponents.Inertia(J = 2.0)
  
relations
  connect(step_input.y, source.tau)
  connect(source.flange, comp.flange_a)
  connect(comp.flange_b, load.flange)
  
  initial load.phi = 0.0
  initial der(load.phi) = 0.0
end
```

### Pattern 3: Mixed Domain (Rotation + Translation)

```dyad
test component TestWheel
  wheel = MyWheelComponent(radius = 0.3)
  
  # Rotational input
  torque_source = RotationalComponents.TorqueSource()
  torque = BlockComponents.Constant(k = 200.0)
  
  # Translational output (vehicle body)
  vehicle = TranslationalComponents.Mass(m = 1000.0)
  
relations
  connect(torque.y, torque_source.tau)
  connect(torque_source.flange, wheel.flange_rot)
  connect(wheel.flange_trans, vehicle.flange)
  
  initial vehicle.s = 0.0
  initial vehicle.v = 0.0
end
```

### Pattern 4: Load with Damping (for equilibrium tests)

```dyad
test component TestEngine_Load
  engine = MyEngine()
  
  throttle = BlockComponents.Constant(k = 0.5)  # 50%
  
  # Damper represents speed-dependent load
  load = RotationalComponents.Damper(d = 0.5)  # τ_load = 0.5×ω
  fixed = RotationalComponents.Fixed()
  
relations
  connect(throttle.y, engine.throttle_input)
  connect(engine.flange, load.flange_a)
  connect(load.flange_b, fixed.flange)
  
  initial engine.flange.phi = 0.0
  initial der(engine.flange.phi) = 10.0  # Start at idle
end
```

---

## Finding Available Components

### Command Line Search

```bash
# List all rotational components
grep "^component" dyad_resources/dyad_stdlib/RotationalComponents.dyad

# List all translational components
grep "^component" dyad_resources/dyad_stdlib/TranslationalComponents.dyad

# List all block components
grep "^component" dyad_resources/dyad_stdlib/BlockComponents.dyad

# Search for specific component
grep -A 10 "component Inertia" dyad_resources/dyad_stdlib/RotationalComponents.dyad
```

### Reading Component Source

```bash
# See full component definition
cat dyad_resources/dyad_stdlib/RotationalComponents.dyad | less

# Or open in editor
nano dyad_resources/dyad_stdlib/RotationalComponents.dyad
```

---

## When You MIGHT Need Custom Components

**Only create custom components if:**

1. No standard library component exists for your physics
2. You need to combine multiple standard components into a reusable unit
3. You have domain-specific logic (e.g., engine torque curves)

**Even then:**

- Build from standard library primitives internally
- Use standard Flange connectors for interfaces
- Document why standard components were insufficient

**Example of acceptable custom component:**

```dyad
component VehicleDynamics.Engine
  # Uses standard Flange for interface
  flange = RotationalComponents.Flange()
  
  # Uses standard Inertia internally
  inertia = RotationalComponents.Inertia(J = J_engine)
  
  # Custom physics (torque map)
  variable tau_produced::Torque
  
relations
  # Custom torque calculation
  tau_produced = throttle * tau_max_curve(omega)
  
  # But uses standard inertia dynamics
  connect(flange, inertia.flange_a)
  # ... etc
end
```

---

## Quick Checklist Before Implementation

- [ ] Read syntax.md, initialization.md, analyses.md
- [ ] Survey available components in relevant domains
- [ ] Identify which standard components you'll use
- [ ] Read source of those components
- [ ] Plan your test harness with standard components
- [ ] Write component using standard interfaces
- [ ] Test, validate, document

---

**Remember:** The standard library is your friend. Use it extensively!
