from sympy import Derivative,diff,sqrt,exp,symbols,Matrix,diff,init_printing,latex,simplify
from sympy.abc import n,a

init_printing()
Hx,Hy,Hz,normH = symbols("Hx Hy Hz |H|")
Bx,By,Bz,normB = symbols("Bx By Bz |B|")
mu0,mur0,m0 = symbols("mu0 mur0 m0")

mu = mu0*(1+(1/(mur0-1)+sqrt(Hx**2+Hy**2+Hz**2)/m0)**-1)
B = Matrix([mu*Hx,mu*Hy,mu*Hz])

H = Matrix([Hx,Hy,Hz])
dBdHcommon = mu0/(normH*(m0+normH*(mur0-1))**2)
print("μ")
print(latex(mu))
print("dB/dH")
print(latex(dBdHcommon)+latex(simplify(B.jacobian(H).subs(sqrt(Hx**2+Hy**2+Hz**2),normH))/dBdHcommon))