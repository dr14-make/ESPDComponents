# Wheel Component - Project by Luuk Milo van Breugel
This document contains all the validations by me ( Luuk Milo van Breugel ) for the ESPD project.

## Phase 1


### Test 1 - Traction Limit Verification
    Verifying that traction limit F_max = μ·N: 
    radius r = 0.3 m, friction μ = 0.8
    Apply constant normal force N = 5000 N -> F_max = 4000 N
    Apply varying torque (ramp or step)
    -> Observe traction force saturation

F_max = μ·N = 0.8 × 5000 = 4000 N
- At low torque: F_traction = τ/r (linear relationship)
- At high torque: F_traction saturates at F_max = 4000 N
- Verify wheel doesn't produce more force than physically possible
- Example: τ = 2000 N·m → F_desired = 2000/0.3 = 6667 N → F_actual = 4000 N (limited!)


![alt text](./TestWheel_ForceTorque_Validation.png)

