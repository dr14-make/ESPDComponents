# https://nl.mathworks.com/help/sdl/ref/tireroadinteractionmagicformula.html

## better version in PacejkaTireModel.md

Tire-Road Interaction (Magic Formula)
Tire-road dynamics given by Magic Formula coefficientsexpand all in page
Tire-Road Interaction (Magic Formula) block
Libraries:
Simscape / Driveline / Tires & Vehicles / Tire Subcomponents

Description
The Tire-Road Interaction (Magic Formula) block represents the interaction between the tire tread and the road pavement. The Magic Formula predicts the longitudinal force that results from this interaction by using an empirical equation based on fitting coefficients. The block ignores tire properties such as compliance and inertia. You can easily visualize the longitudinal friction force with respect to the wheel slip. To view the figure, click the Plot friction force versus slip hyperlink in the Description section of the block dialog box.

Longitudinal force versus wheel slip figure window

Tire-Road Interaction Model
The block represents the longitudinal forces at the tire-road contact patch using the Magic Formula of Pacejka [2].

The figure displays the forces on the tire. The table defines the tire model variables.

Tire illustration demonstrating F_z, F_x, V_x, and rotational velocity, Omega

Symbol	Description
Ω	Wheel angular velocity.
rw	Wheel radius.
Vx	Wheel hub longitudinal velocity.
r
w
Ω	Tire tread longitudinal velocity.
u	Tire longitudinal deformation.
V
T
=r
w
Ω
′
=r
w
Ω+
˙
u
Tire tread longitudinal velocity. Typically, the tire tread longitudinal velocity has a component due to tire rotation, rwΩ, and an optional component due to tire deformation, 
˙
u
. Because port T computes VT, the calculations for tire rotations and deformation occur outside of the block.
V
sx
=V
x
−V
T
Contact patch slip velocity. If there is no tire longitudinal compliance, then u=0.
k=−
V
sx
∣V
x
∣
smooth
Wheel slip for a tire without compliance.
Fz	Vertical load on tire.
Fz0	Nominal vertical load on tire.
F
x
=f(k,F
z
)	Longitudinal force exerted on the tire at the contact point.
f is a characteristic function of the tire.
Tire Response
You can model tire roll and slip.

Forces and Characteristic Function
The block uses a steady-state tire characteristic function, F
x
=f(k,F
z
), where:

Fx is the longitudinal force on the tire.

Fz is the vertical load.

k is the wheel slip

Roll and Slip
The equation for translational motion of a non-slipping, non-compliant tire is V
x
=r
w
Ω. When tires experience slip, they develop a longitudinal force, Fx.

The contact patch slip velocity is V
sx
=V
x
−r
w
Ω−
˙
u
. For a tire without compliance, u = 0. The unsmoothed contact patch slip is

k=−
V
sx
∣V
x
∣
,

and the block saturates the slip denominator as

∣V
x
∣={
V
XLOW
∣V
x
∣
if  ∣V
x
∣<V
XLOW
otherwise

where VXLOW is the Lower boundary of slip denominator, VXLOW parameter. The block smoothly transitions |Vx| to VXLOW over the transition regions -VXLOW - Vth/2 < Vx < -VXLOW + Vth/2 and VXLOW - Vth/2 < Vx < VXLOW + Vth/2. The block saturates slip according to

k=⎧⎪⎪⎪⎨⎪⎪⎪⎩
kpumin
kpumax
−
V
sx
∣V
x
∣
if −
V
sx
∣V
x
∣
<kpumin
if −
V
sx
∣V
x
∣
>kpumax
otherwise

where kpumin is the Minimum valid wheel slip, KPUMIN parameter and kpumax is the Maximum valid wheel slip, KPUMAX parameter. The block transitions k over the regions kpumin - kth/2 < k < kpumin + kth/2 and kpumax - kth/2 < k < kpumax + kth/2. The block defines the slip smoothing threshold as

k
th
=
V
th
1m/s
.

For this equation, a locked, sliding wheel has k = -1. For perfect rolling, k = 0.

Magic Formula Coefficients for Typical Road Conditions
The block uses numerical values based on empirical tire data. These values are typical sets of constant Magic Formula coefficients for common road conditions.

Surface	B	C	D	E
Dry tarmac	10	1.9	1	0.97
Wet tarmac	12	2.3	0.82	1
Snow	5	2	0.3	1
Ice	4	2	0.1	1
Parameterizations
Peak Longitudinal Force and Corresponding Slip
When you set Parameterize by to Peak longitudinal force and corresponding slip, the block uses a representative set of Magic Formula coefficients. The block scales the coefficients to yield the peak longitudinal force Fx0 at the corresponding slip κ0 that you specify, for rated vertical load Fz0.

Magic Formula with Constant Coefficients
When you set Parameterize by to Constant Magic Formula coefficients, the block uses the dimensionless coefficients, B, C, D, and E, or stiffness, shape, peak, and curvature, such that


F
x
=f(κ,F
z
)=F
z
⋅D⋅sin(C⋅arctan{Bκ−E[Bκ−arctan(Bκ)]}).


The slope of f at k=0 is BCD⋅F
z
.

Magic Formula with Load-Dependent Coefficients
When you set Parameterize by to Load-dependent Magic Formula coefficients, the block uses dimensionless coefficients that are functions of the tire load. A more complex set of parameters p_i, entered in the property inspector, specifies these functions:

F
x0
=D
x
sin(C
x
arctan{B
x
κ
x
−E
x
[B
x
κ
x
−arctan(B
x
κ
x
)]})+S
Vx
,

where:

df
z
= 
(F
z
–F
z0
)
F
z0

κ
x
=κ+S
Hx

C
x
= p_Cx1

D
x
=μ
x
·F
z

μ
x
= p_Dx1 + p_Dx2·df
z

E
x
= (p_Ex1 + p_Ex2·df
z
+ p_Ex3·df
z
2
)[1 – p_Ex4·sgn(κ
x
)]

K
xκ
=F
z
⋅(p_Kx1 + p_Kx2·df
z
)⋅e
(p_Kx3·df
z
)

B
x
=
K
xκ
C
x
D
x
+ε
x

S
Hx
= p_Hx1 + p_Hx2·df
z

S
Vx
=F
z
·(p_Vx1 + p_Vx2·df
z
)

SHx and SVx represent offsets to the slip and longitudinal force in the force-slip function, or horizontal and vertical offsets if the function is plotted as a curve. μx is the longitudinal load-dependent friction coefficient. εx is a small number that prevents division by zero as Fz approaches zero.

Assumptions and Limitations
The Tire-Road Interaction (Magic Formula) block assumes only longitudinal motion and includes no camber, turning, or lateral motion.

