Group {
  DefineGroup[
    Omega, NonLinOmegaC, LinOmegaC, OmegaC, OmegaC_stranded, OmegaCC, BndOmegaC, BndOmegaC_side,
    Air, AirInf, AirTot, Shell_lim
    MagnDomain, MagnLinDomain, MagnAnhyDomain, MagnHystDomain, NonMagnDomain, CstMagnDomain,
    InnerDomain, SurfOut, SurfSym, SurfAll, CutV, ArbitraryPoint,
    Super, Substrate, Copper, Cond1, Cond2, Cuts, Ferro
  ];
}

Function {
    mu0 = 4*Pi*1e-7; // [H/m]
    nu0 = 1.0/mu0; // [m/H]
    directionApplied[] = Vector[0., 0., 1.]; // Direction of current
    DefineFunction[Dim]; // Should be given
    DefineFunction[ec, jc, n, epsSigma, epsSigma2]; // Parameters that must be defined for Superconductor
    DefineFunction[mur0, m0, epsMu, epsNu]; // Parameters that must be defined for Anhysteretic Ferro

    // ----------------------------------------------------------------------------
    // -------------------------- CONSTITUTIVE LAWS -------------------------------
    // ----------------------------------------------------------------------------
    // ------- Ferromagnetic (anhysteretic) material constitutive law -------
    If(nonlinferro == 0)
        mu[MagnAnhyDomain] = mur*mu0;
        dbdh[MagnAnhyDomain] = mu[];
        nu[MagnAnhyDomain] = 1/mu[];
        dhdb[MagnAnhyDomain] = nu[];
    Else
    // For the h-formulation
        mu[MagnAnhyDomain] = mu0 * ( 1.0 + 1.0 / ( 1/(mur0-1) + Norm[$1]/m0 ) );
        dbdh[MagnAnhyDomain] = ($iter > 20) ? ((1.0/$relaxFactor) * (mu0 * (1.0 + (1.0/(1/(mur0-1)+Norm[$1]/m0))#1 ) * TensorDiag[1, 1, 1]
                    - mu0/m0 * (#1)^2 * 1/(Norm[$1]+epsMu) * SquDyadicProduct[$1])) :
                    (mu0 * ( 1.0 + 1.0 / ( 1/(mur0-1) + Norm[$1]/m0 ) ) * TensorDiag[1, 1, 1]); // Hybrid lin. technique
        // For the a-formulation
        nu[MagnAnhyDomain] = 1/2 * ( (Norm[$1]+epsNu)#1 /mu0 - (mur0*m0/(mur0-1))#2
            + ( (#2 - #1/mu0)^2 + 4*m0*#1/((mur0-1)*mu0) )^(1/2) ) * 1/#1;
        dhdb[MagnAnhyDomain] = (1.0/$relaxFactor) *
            (1.0 / (2*(Norm[$1]+epsNu)#1)
                * (#1/mu0 - (mur0*m0/(mur0-1))#2
                    + (( (#2 - #1/mu0)^2 + 4*m0*#1/((mur0-1)*mu0) )^(1/2))#3 ) * TensorDiag[1, 1, 1]
            + 1.0 / (2 * (#1)^3) * ( #2 - #3
                + #1/(#3*mu0) * ( (2-mur0)/(mur0-1) * m0 + #1/mu0 ) ) * SquDyadicProduct[$1]);
    EndIf
    mu[MagnLinDomain] = mu0;
    mu[BndOmegaC] = mu0;
    nu[MagnLinDomain] = nu0;

    // ------- Superconductor constitutive law -------
    // h-formulation: Power law e(j) = rho(j) * j, with rho(j) = ec/jc * (|j|/jc)^(n-1)
    jcb[Super] = jc;///(1 + $1);
    rho[Super] = ec / jcb[$2] * (Min[($TimeStep<-1)?1.5*jcb[$2]:1e99, Norm[$1]]/jcb[$2])^(n - 1);
    dedj[Super] = (1.0/$relaxFactor) *
      (ec / jcb[$2] * (Min[($TimeStep<-1)?1.5*jcb[$2]:1e99, Norm[$1]]/jcb[$2])^(n - 1) * TensorDiag[1, 1, 1] +
       ec / jcb[$2]^3 * (n - 1) * (Min[($TimeStep<-1)?1.5*jcb[$2]:1e99, Norm[$1]]/jcb[$2])^(n - 3) * SquDyadicProduct[$1]);
    // a-formulation: Power law j(e) = sigma(e) * e, with sigma(e) = jc/ec^(1/n) * |e|^((1-n)/n)
    sigma[Super] = jc / ec * 1.0 / ( epsSigma + ( Norm[$1]/ec )^((n-1.0)/n) );
    sigmae[Super] = sigma[$1] * $1;
    djde[Super] = ($iter > -1) ? ((1.0/$relaxFactor) *
        ( jc / ec * (1.0 / (epsSigma + ( (Norm[$1]/ec)#3 )^((n-1.0)/n) ))#4 * TensorDiag[1, 1, 1]
        + jc/ec^3 * (1.0-n)/n * (#4)^(2) * 1/((#3)^((n+1.0)/n) + epsSigma2 ) * SquDyadicProduct[$1]))
            : (jc / ec * 1.0 / ( epsSigma + ( Norm[$1]/ec )^((n-1.0)/n) ) * TensorDiag[1, 1, 1] );

    // ------- Copper constitutive law -------
    sigma[LinOmegaC] = 58e6; // [S/m]
    rho[LinOmegaC] = 1./sigma[];
    sigmae[LinOmegaC] = sigma[$1] * $1;// [S/m]

}
