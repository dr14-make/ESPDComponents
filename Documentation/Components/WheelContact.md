# WheelContact Connector Specification

## Overview

The **WheelContact** connector is a specialized connector that combines both **traction** (tangential) and **normal** (vertical) forces in a single interface. It represents the mechanical coupling between a wheel and the vehicle body at the tire-road contact patch.

---

## Purpose

Traditional approaches use separate connectors for traction and normal forces, requiring multiple connection statements and potentially leading to inconsistencies. The WheelContact connector:

- **Simplifies connection topology** - Single `connect()` statement handles both force components
- **Ensures coupling** - Traction and normal forces are always properly paired at each contact point
- **Reduces errors** - Fewer connections mean less opportunity for sign convention mistakes
- **Matches physical reality** - A single contact patch transmits both force components

---

## Connector Definition

**File:** `dyad/VehicleDynamics/Connectors/WheelContact.dyad`

```dyad
connector WheelContact
  # Traction (longitudinal/tangential direction)
  potential s_traction::Position     # Longitudinal position [m]
  flow f_traction::Force             # Traction force [N]
  
  # Normal (vertical direction)
  potential s_normal::Position       # Vertical position [m]
  flow f_normal::Force               # Normal force [N]
end
```

---

## Sign Conventions

### Traction Force (`f_traction`)

**From Wheel Perspective:**

- `f_traction > 0`: Wheel pushes vehicle **forward** (acceleration)
- `f_traction < 0`: Wheel pushes vehicle **backward** (braking/regeneration)

**From Vehicle Body Perspective:**

- Receives traction force from wheels
- Multiple wheels connected to same axle: forces sum automatically

**Direction:**

- Positive = forward motion (standard vehicle coordinate system)
- Flow variable = distributed via Kirchhoff's law at connection point

### Normal Force (`f_normal`)

**From Wheel Perspective:**

- `f_normal > 0`: Load **ON** the wheel (wheel supports vehicle weight)
- Determines traction limit: `F_max = μ × f_normal`

**From Vehicle Body Perspective:**

- Provides weight to wheel
- Includes static weight distribution + dynamic load transfer
- `f_normal` varies with acceleration/braking

**Direction:**

- Positive = compression (weight on wheel)
- Flow variable = force exerted by body onto wheel

### Position Variables

**`s_traction`:**

- Longitudinal position of contact point
- All wheels connected to same body share same `s_traction` (rigid body assumption)
- Used to enforce kinematic coupling

**`s_normal`:**

- Vertical position of contact point
- Typically fixed at ground level: `s_normal = 0.0`
- Represents road surface height

---

## Usage Examples

### In Wheel Component

```dyad
component Wheel
  # Rotational connection to driveline
  flange_rot = Dyad.Spline()
  
  # Combined traction + normal force connection to vehicle body
  contact = VehicleDynamics.Connectors.WheelContact()
  
  # Parameters
  parameter radius::Length = 0.3
  parameter mu::Real = 0.8
  
  # Variables
  variable N::Force            # Normal force received from body
  variable F_traction::Force   # Traction force provided to body
  variable F_max::Force        # Maximum traction based on normal force
  
relations
  # Extract normal force from body
  N = -contact.f_normal       # Sign: body pushes down on wheel
  
  # Calculate traction limit
  F_max = mu * N
  
  # Apply traction force (limited by F_max)
  F_traction = saturate(flange_rot.tau / radius, -F_max, F_max)
  contact.f_traction = F_traction
  
  # Fix vertical position at ground level
  contact.s_normal = 0.0
  
  # Kinematic coupling (position)
  contact.s_traction = radius * flange_rot.phi
end
```

### In VehicleBody Component

```dyad
component VehicleBody
  # Separate contacts for front and rear axles
  contact_front = VehicleDynamics.Connectors.WheelContact()
  contact_rear = VehicleDynamics.Connectors.WheelContact()
  
  # Parameters
  parameter m::Mass = 1500.0
  parameter L::Length = 2.7
  parameter a::Length = 1.2        # CG to front axle
  parameter b::Length = 1.5        # CG to rear axle
  parameter h_cg::Length = 0.5     # CG height
  
  # Variables
  variable v::Velocity
  variable ax::Acceleration
  variable N_front::Force
  variable N_rear::Force
  variable F_front::Force
  variable F_rear::Force
  
relations
  # Extract traction forces from wheels
  F_front = -contact_front.f_traction   # Sign: force ON body from wheels
  F_rear = -contact_rear.f_traction
  
  # Longitudinal dynamics
  m * ax = F_front + F_rear - F_drag - F_roll - F_grade
  
  # Load transfer calculation
  delta_N = m * ax * h_cg / L
  N_front = m * g * (b/L) - delta_N    # Static - dynamic transfer
  N_rear = m * g * (a/L) + delta_N     # Static + dynamic transfer
  
  # Provide normal forces to wheels
  contact_front.f_normal = -N_front    # Sign: body pushes down on wheels
  contact_rear.f_normal = -N_rear
  
  # Kinematic coupling (both axles move with body)
  contact_front.s_traction = s_body
  contact_rear.s_traction = s_body
  der(s_body) = v
end
```

### Connection Pattern (System Level)

```dyad
# Conventional two-wheel-per-axle system
component SimpleVehicle
  body = VehicleBody()
  wheel_front_left = Wheel()
  wheel_front_right = Wheel()
  wheel_rear_left = Wheel()
  wheel_rear_right = Wheel()
  
relations
  # Front axle: both wheels connect to same contact point
  connect(wheel_front_left.contact, body.contact_front)
  connect(wheel_front_right.contact, body.contact_front)
  
  # Rear axle: both wheels connect to same contact point
  connect(wheel_rear_left.contact, body.contact_rear)
  connect(wheel_rear_right.contact, body.contact_rear)
  
  # Forces automatically sum at each connection point!
  # body.contact_front.f_traction = wheel_FL.f_traction + wheel_FR.f_traction
  # body.contact_rear.f_traction = wheel_RL.f_traction + wheel_RR.f_traction
end
```

---

## Testing Considerations

### Issue: WheelContact Not Compatible with Standard Library Components

**Problem:** Standard library components (Force, Mass, Fixed) use simple Flanges, not WheelContact.

**Solution:** Create **helper/adapter components** for testing:

#### Helper: WheelContact Force Source

```dyad
# Apply specified traction and normal forces to WheelContact for testing
component WheelContactForceSource
  contact = VehicleDynamics.Connectors.WheelContact()
  f_traction_input = Dyad.RealInput()
  f_normal_input = Dyad.RealInput()
  
relations
  contact.f_traction = f_traction_input.u
  contact.f_normal = f_normal_input.u
  contact.s_normal = 0.0
  contact.s_traction = 0.0  # Fixed position test
end
```

#### Helper: WheelContact to Separate Flanges

```dyad
# Break out WheelContact into separate flanges for testing with stdlib
component WheelContactBreakout
  contact = VehicleDynamics.Connectors.WheelContact()
  flange_traction = Dyad.Flange()
  flange_normal = Dyad.Flange()
  
relations
  # Traction mapping
  flange_traction.s = contact.s_traction
  flange_traction.f = -contact.f_traction
  
  # Normal mapping
  flange_normal.s = contact.s_normal
  flange_normal.f = -contact.f_normal
end
```

### Example: Testing VehicleBody with Helper Components

```dyad
test component TestVehicleBody_LoadTransfer
  body = VehicleBody()
  
  # Use breakout to connect standard library components
  front_breakout = WheelContactBreakout()
  rear_breakout = WheelContactBreakout()
  
  # Apply traction forces using standard Force component
  front_force = TranslationalComponents.Force()
  rear_force = TranslationalComponents.Force()
  front_cmd = BlockComponents.Constant(k = 3000.0)
  rear_cmd = BlockComponents.Constant(k = 3000.0)
  
  # Ground references
  ground_front = TranslationalComponents.Fixed()
  ground_rear = TranslationalComponents.Fixed()
  
relations
  # Connect body to breakouts
  connect(body.contact_front, front_breakout.contact)
  connect(body.contact_rear, rear_breakout.contact)
  
  # Connect breakouts to standard library
  connect(front_cmd.y, front_force.f)
  connect(front_force.flange, front_breakout.flange_traction)
  connect(front_breakout.flange_normal, ground_front.flange)
  
  connect(rear_cmd.y, rear_force.f)
  connect(rear_force.flange, rear_breakout.flange_traction)
  connect(rear_breakout.flange_normal, ground_rear.flange)
end
```

---

## Advantages Over Separate Connectors

### Traditional Approach (Separate Flanges)

**Problems:**

- Four separate connectors per wheel: `flange_rot`, `flange_trans`, `flange_normal_in`, `flange_normal_out`
- Six connection statements per wheel
- Easy to mix up traction and normal force connections
- No guarantee that traction and normal forces are properly paired
- Sign convention errors common

**Example:**

```dyad
# Traditional approach - verbose and error-prone
connect(wheel.flange_trans, body.flange_traction)
connect(body.flange_normal, wheel.flange_normal_in)
# Wait, which direction is the normal force flowing?
```

### WheelContact Approach

**Benefits:**

- **Two connectors per wheel:** `flange_rot`, `contact`
- **Two connection statements per wheel:** one for drivetrain, one for body
- Traction and normal forces always paired
- Clear physical meaning: "contact point"
- Matches engineering diagrams

**Example:**

```dyad
# WheelContact approach - clear and concise
connect(wheel.flange_rot, differential.flange_out_left)
connect(wheel.contact, body.contact_rear)
# Both forces handled in single connection!
```

---

## Physical Interpretation

The WheelContact connector represents a **single physical point** - the tire-road contact patch. At this point:

1. **Traction force** (tangential to road):
   - Generated by wheel torque
   - Limited by friction: `F ≤ μ × N`
   - Propels or brakes vehicle

2. **Normal force** (perpendicular to road):
   - Weight of vehicle segment
   - Includes static load + dynamic load transfer
   - Determines traction capacity

3. **Positions:**
   - `s_traction`: Where along the road (longitudinal coordinate)
   - `s_normal`: How high above road (typically zero = ground level)

Think of it as a **force transducer** at the contact patch that measures both normal load and tangential traction simultaneously.

---

## Common Mistakes

### Mistake 1: Wrong Sign on Normal Force

**Incorrect:**

```dyad
N = contact.f_normal  # Wrong! This has the wrong sign
```

**Correct:**

```dyad
N = -contact.f_normal  # Correct! Body pushes down, wheel sees compression
```

### Mistake 2: Forgetting to Fix Normal Position

**Incorrect:**

```dyad
# Missing: contact.s_normal constraint
```

**Correct:**

```dyad
contact.s_normal = 0.0  # Fix at ground level
```

### Mistake 3: Sign Convention Confusion

**Remember:**

- From **wheel's** perspective: `f_normal > 0` means load ON wheel
- From **body's** perspective: `f_normal < 0` means body PUSHES DOWN
- Sign flip occurs because of flow variable convention

---

## Validation Checklist

When implementing components with WheelContact:

- [ ] Normal force is positive when wheel is loaded
- [ ] Traction force direction matches wheel rotation direction
- [ ] `s_normal = 0.0` is enforced (unless modeling suspension)
- [ ] All wheels connected to same axle share same `s_traction`
- [ ] Force balance: traction forces sum correctly at each axle
- [ ] Sign conventions are consistent between wheel and body
- [ ] Load transfer: normal forces change with acceleration

---

## See Also

- [Wheel.md](Wheel.md) - Implementation of wheel using WheelContact
- [VehicleBody.md](VehicleBody.md) - Implementation of body using WheelContact
- [VehicleDynamics/Connectors/WheelContact.dyad](../../dyad/VehicleDynamics/Connectors/WheelContact.dyad) - Source code

---

**Status:** ✅ Implemented  
**Location:** `dyad/VehicleDynamics/Connectors/WheelContact.dyad`  
**Used By:** Wheel, VehicleBody components
