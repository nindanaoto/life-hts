from sympy import Derivative,diff,sqrt,exp,symbols,Matrix,diff,init_printing,latex,simplify,eye
from sympy.abc import n,a

init_printing()
Hx,Hy,Hz,normH = symbols("Hx Hy Hz |H|",real=True)
Bx,By,Bz,normB = symbols("Bx By Bz |B|",real=True)
mu0,mur0,m0 = symbols("mu0 mur0 m0")

H = Matrix([Hx,Hy,Hz])

mu = mu0*(1+(1/(mur0-1)+H.norm()/m0)**-1)

B = mu*H

dBdHcommon = mu0/((m0+normH*(mur0-1))**2)
print("μ")
print(latex(mu))
print("dB/dH")
print(latex(dBdHcommon)+latex(simplify(B.jacobian(H).subs(sqrt(Hx**2+Hy**2+Hz**2),normH))/dBdHcommon))

paperdBdH = mu*eye(3)-mu0/m0*(1/(mur0-1)+H.norm()/m0)**-2*Matrix([[i*j/H.norm() for j in H]for i in H])
print("paperdBdH")
print(latex(paperdBdH))
diff = simplify(paperdBdH-B.jacobian(H))
print("diff")
print(latex(diff))