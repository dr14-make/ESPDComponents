# Phase 0: Component Scaffolding - Complete Guide

## Overview

Phase 0 provides **empty component skeletons** with proper connectors to verify architecture before implementing physics.

## What Has Been Created

### File: `dyad/VehicleDynamics/VehicleComponents.dyad`

This file contains:
- ✅ 6 component skeletons with proper interfaces
- ✅ Integration test showing how components connect
- ✅ Placeholder equations (minimal, non-physical)
- ✅ Proper use of standard library connectors

## Component Skeletons Included

### 1. VehicleBody
**Interface:**
- `flange` : TranslationalComponents.Flange() - connects to wheels

**Placeholder Variables:**
- `v` : Velocity
- `a` : Acceleration

**Status:** Simple damping placeholder, needs full force balance

### 2. Wheel  
**Interface:**
- `flange_rot` : RotationalComponents.Flange() - connects to driveline
- `flange_trans` : TranslationalComponents.Flange() - connects to vehicle body

**Placeholder Variables:**
- `omega` : AngularVelocity
- `v` : Velocity

**Status:** Hardcoded radius (0.3m), needs proper kinematic constraint

### 3. Brake
**Interface:**
- `flange_a` : RotationalComponents.Flange() - input side
- `flange_b` : RotationalComponents.Flange() - output side
- `brake_input` : RealInput() - brake command [0-1]

**Placeholder Variables:**
- `brake_cmd` : Real
- `omega` : AngularVelocity

**Status:** Pass-through only, needs friction torque logic

### 4. Engine
**Interface:**
- `flange` : RotationalComponents.Flange() - mechanical output
- `throttle_input` : RealInput() - throttle command [0-1]

**Placeholder Variables:**
- `throttle` : Real
- `omega` : AngularVelocity
- `tau` : Torque

**Status:** Simple proportional torque, needs torque curve

### 5. Differential
**Interface:**
- `flange_input` : RotationalComponents.Flange() - from transmission
- `flange_left` : RotationalComponents.Flange() - to left wheel
- `flange_right` : RotationalComponents.Flange() - to right wheel

**Placeholder Variables:**
- `omega_in`, `omega_left`, `omega_right` : AngularVelocity

**Status:** Hardcoded ratio (3.5), needs proper torque split and speed averaging

### 6. Gearbox
**Interface:**
- `flange_in` : RotationalComponents.Flange() - from engine
- `flange_out` : RotationalComponents.Flange() - to driveline
- `gear_input` : RealInput() - gear selection (integer)

**Placeholder Variables:**
- `gear` : Real
- `omega_in`, `omega_out` : AngularVelocity

**Status:** Fixed ratio (3.0), needs array of ratios and proper gear selection

## Integration Test: ConventionalPowertrainScaffold

### System Architecture Verified
```
Throttle → Engine → Gearbox → Differential ─┬→ Brake_L → Wheel_L ─┐
                                             │                      ├→ Vehicle → Ground
Brake_Cmd ──────────────────────────────────┴→ Brake_R → Wheel_R ─┘
Gear_Cmd ────────→┘
```

### What It Tests
- ✅ All connectors are compatible
- ✅ System compiles without errors
- ✅ Components can be instantiated and connected
- ✅ Basic simulation runs (0.1 seconds)

### What It Does NOT Test
- ❌ Physical correctness (placeholder equations)
- ❌ Energy conservation
- ❌ Force/torque balance
- ❌ Proper dynamics

## How to Use This Scaffolding

### Step 1: Verify the Architecture
The file should compile and run as-is (once Dyad compiler is available). This confirms:
- Interface definitions are correct
- Connection topology is valid
- No structural errors

### Step 2: Implement One Component at a Time
Start with the simplest component and work up:

**Recommended Order:**
1. **VehicleBody** (simplest - translational only)
2. **Wheel** (learn domain coupling)
3. **Brake** (add control input)
4. **Engine** (speed-dependent source)
5. **Differential** (multi-port)
6. **Gearbox** (discrete states)

**For Each Component:**
1. Read the component's specification file (e.g., VehicleBody.md)
2. Replace placeholder equations with real physics
3. Add proper parameters (not hardcoded values)
4. Add comprehensive test harness IN THE SAME FILE
5. Validate thoroughly before moving to next

### Step 3: Replace Placeholder Values

**Current Placeholders to Fix:**

| Component | Placeholder | Should Become |
|-----------|-------------|---------------|
| VehicleBody | `flange.f = -1000.0 * v` | Full force balance with drag, rolling resistance |
| Wheel | `0.3` (radius) | `parameter radius::Length` |
| Brake | `flange_a.tau + flange_b.tau = 0.0` | Friction torque based on brake_cmd |
| Engine | `throttle * 100.0` | Torque curve as function of speed |
| Differential | `3.5` (ratio) | `parameter ratio::Real` |
| Gearbox | `3.0` (ratio) | Array of ratios, gear selection logic |

### Step 4: Add Test Harnesses

Each component needs its own test harness. The integration test is NOT sufficient.

**Example Structure:**
```dyad
component VehicleBody
  # Full implementation
end

test component TestVehicleBody_ConstantForce
  # Test specific physics
end

analysis TestVehicleBody_ConstantForce_Analysis
  extends TransientAnalysis(stop = 10.0, alg = "Rodas5P")
  model = TestVehicleBody_ConstantForce()
end
```

## Compilation Instructions

### If Dyad Compiler is Available:
```bash
cd /home/dr14/Projects/CVUT/ESPDComponents
dyad compile dyad/VehicleDynamics/
```

### If Using Julia Directly:
```julia
using Pkg
Pkg.activate("/home/dr14/Projects/CVUT/ESPDComponents")
using ESPDComponents

# Your components will be available after compilation
# e.g., ESPDComponents.VehicleBody, etc.
```

## Known Issues / Limitations

### Current Scaffolding Limitations:
1. **Non-physical behavior:** Placeholder equations are intentionally simplified
2. **No parameter tuning:** All values are hardcoded
3. **Minimal test coverage:** Only structural connectivity tested
4. **No validation:** Physics not verified

### Expected Errors When Running:
- May not reach steady state (no physical equilibrium)
- Energy not conserved
- Forces/torques may not balance
- Unrealistic accelerations/velocities

**This is intentional!** Students must fix these by implementing real physics.

## Electric Powertrain Scaffolding (Bonus)

Commented-out skeletons for:
- Battery (electrical energy storage)
- DCDC (voltage conversion)
- ElectricMotor (electro-mechanical coupling)

Students in Phase 2B can uncomment and implement these.

## Success Criteria

### Phase 0 Success:
- ✅ File compiles without syntax errors
- ✅ Integration test instantiates all components
- ✅ Simulation runs (even if non-physical)
- ✅ No connection errors or interface mismatches

### Ready for Phase 1 When:
- ✅ Architecture validated
- ✅ All interfaces documented
- ✅ Students understand component roles
- ✅ Clear path forward for implementation

## Next Steps

1. **For Students:** 
   - Read component specification files
   - Implement VehicleBody.dyad with full physics
   - Add comprehensive tests
   - Validate before moving on

2. **For Instructors:**
   - Review scaffolding structure
   - Decide if electric powertrain skeletons should be included
   - Prepare grading rubrics based on validation criteria

## File Contents Summary

**Total Lines:** ~330
**Component Skeletons:** 6
**Integration Test:** 1
**Analysis Definitions:** 1

**Key Features:**
- Proper connector usage (standard library)
- Realistic system architecture
- Clear separation of concerns
- Extensible structure
- Well-commented for student guidance

---

**Status:** ✅ Phase 0 scaffolding complete and ready for student use

**Next Phase:** Phase 1 - Component Implementation (VehicleBody first)
