from sympy import Derivative,diff,sqrt,exp,symbols,Matrix,diff,init_printing,latex,simplify
from sympy.abc import a
from sympy.functions.elementary.hyperbolic import coth

init_printing()
Hx,Hy,Hz,normH = symbols("Hx Hy Hz |H|")
Mx,My,Mz = symbols("Mx My Mz")
alpha,Ms = symbols("alpha Ms")

H = Matrix([Hx,Hy,Hz])
M = Matrix([Mx,My,Mz])

He = H + alpha*M
Mah = Ms*(coth(He.norm())-a/He.norm())

B = Matrix([mu*Hx,mu*Hy,mu*Hz])

H = Matrix([Hx,Hy,Hz])
dBdHcommon = mu0/((m0+normH*(mur0-1))**2)