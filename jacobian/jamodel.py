from sympy import Derivative,diff,sqrt,exp,symbols,Matrix,diff,init_printing,latex,simplify
from sympy.abc import n,a
from sympy.functions.elementary.hyperbolic import coth

init_printing()
Hx,Hy,Hz,normH = symbols("Hx Hy Hz |H|")
Mx,My,Mz = symbols("Mx My Mz")
alpha,Ms = symbols("alpha Ms")

H = Matrix([Hx,Hy,Hz])
M = Matrix([Mx,My,Mz])

He = H + alpha*M

Mah = Ms*coth()

mu = mu0*(1+(1/(mur0-1)+sqrt(Hx**2+Hy**2+Hz**2)/m0)**-1)
B = Matrix([mu*Hx,mu*Hy,mu*Hz])

H = Matrix([Hx,Hy,Hz])
dBdHcommon = mu0/((m0+normH*(mur0-1))**2)