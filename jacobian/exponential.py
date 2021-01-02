from sympy import Derivative,diff,sqrt,exp,symbols,Matrix,diff,init_printing,latex,simplify
from sympy.abc import n,a

init_printing()
Hx,Hy,Hz,normH = symbols("Hx Hy Hz |H|",real=True)
Jx,Jy,Jz,normJ = symbols("Jx Jy Jz |J|",real=True)
mu,Ec,Jc0,B0,symbJc = symbols("mu Ec Jc0 B0 Jc")

H = Matrix([Hx,Hy,Hz])
J = Matrix([Jx,Jy,Jz])

Jc = Jc0*exp(-(mu*H.norm()/B0)**a)
sigma = Ec/Jc*(J.norm()/Jc)**(n-1)
# sigma = Ec/Jc0*(sqrt(Jx**2+Jy**2+Jz**2)/Jc0)**(n-1)
E = Matrix([sigma*Jx,sigma*Jy,sigma*Jz])

dEdJcommon = (Ec*(normJ/Jc)**n/(normJ**3)).subs(sqrt(Jx**2+Jy**2+Jz**2),normJ).subs(sqrt(Hx**2+Hy**2+Hz**2),normH)
dEdHcommon = (Ec*a*n*(mu*sqrt(Hx**2+Hy**2+Hz**2)/B0)**a*(normJ/Jc)**n/(normH**2*normJ)).subs(sqrt(Jx**2+Jy**2+Jz**2),normJ).subs(sqrt(Hx**2+Hy**2+Hz**2),normH)
print("dE/dJ")
print(latex((Ec*(normJ/symbJc)**n/(normJ**3)).subs(sqrt(Jx**2+Jy**2+Jz**2),normJ).subs(sqrt(Hx**2+Hy**2+Hz**2),normH))+latex(simplify(E.jacobian(J).subs(sqrt(Jx**2+Jy**2+Jz**2),normJ).subs(sqrt(Hx**2+Hy**2+Hz**2),normH))/dEdJcommon))
print("dE/dH")
print(latex((Ec*a*n*(mu*sqrt(Hx**2+Hy**2+Hz**2)/B0)**a*(normJ/symbJc)**n/(normH**2*normJ)).subs(sqrt(Jx**2+Jy**2+Jz**2),normJ).subs(sqrt(Hx**2+Hy**2+Hz**2),normH))+latex(simplify(E.jacobian(H).subs(sqrt(Jx**2+Jy**2+Jz**2),normJ).subs(sqrt(Hx**2+Hy**2+Hz**2),normH))/dEdHcommon))