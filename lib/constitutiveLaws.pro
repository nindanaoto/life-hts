Group {
  DefineGroup[
    Omega, NonLinOmegaC, LinOmegaC, OmegaC, OmegaCC, BndOmegaC, BndOmegaC_side,
    Air, AirInf, AirTot, Shell_lim
    MagnDomain, MagnLinDomain, MagnAnhyDomain, MagnHystDomain, NonMagnDomain, CstMagnDomain,
    InnerDomain, SurfOut, SurfSym, SurfAll, CutV, ArbitraryPoint,
    Super, Substrate, Copper, Cond1, Cond2, Cuts, Ferro
  ];
}

Function {
    mu0 = 4*Pi*1e-7; // [H/m]
    nu0 = 1.0/mu0; // [m/H]
    DefineFunction[Dim]; // Should be given
    DefineFunction[ec, jc, n, epsSigma, epsSigma2]; // Parameters that must be defined for Superconductor
    DefineFunction[mur0, m0, epsMu, epsNu]; // Parameters that must be defined for Anhysteretic Ferro

    // ----------------------------------------------------------------------------
    // -------------------------- CONSTITUTIVE LAWS -------------------------------
    // ----------------------------------------------------------------------------
    // ------- Ferromagnetic (anhysteretic) material constitutive law -------
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
    // A posteriori formula for loss computation
    LossPerCycle_aPosteriori_b[MagnAnhyDomain] = (Norm[$1]#1 >= 0.1) ? ((#1 <= 1.53) ? 171.1*(#1)^(1.344) : 375 * (1 - Exp[- ((#1)/1.407)^(6.787)])) : 0;
    LossPerCycle_aPosteriori_h[MagnAnhyDomain] = 1e99; // NOT IMPLEMENTED YET

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
    // Closer to critical-state model
    /*
    ecTilde = 1e-7;
    sigma[Super] = (Norm[$1] <= ecTilde) ? jc / ecTilde : jc/Norm[$1];
    sigmae[Super] = sigma[$1] * $1;
    */

    // ----------------------------------------------------------------------------
    // -------------------------- PRE-DEFINED SOURCE FUNCTIONS --------------------
    // ----------------------------------------------------------------------------
    If(SourceType == 0 || SourceType == 3)
        qttMax = bmax / mu0;
    ElseIf(SourceType == 1)
        qttMax = Imax;
    EndIf

    If(Flag_Source == 0)
        // Sine source field
        controlTimeInstants = {timeFinalSimu, 1/(2*f), 1/f, 3/(2*f), 2*timeFinal};
        qttVal[] = qttMax * Sin[2.0 * Pi * f * $Time];
        qttVal_prev[] = qttMax * Sin[ 2.0 * Pi * f * ($Time-$DTime)];
    ElseIf(Flag_Source == 1)
        // Triangle source field (5/4 of a complete cycle)
        controlTimeInstants = {timeFinal, timeFinal/5.0, 3.0*timeFinal/5.0, timeFinal};
        rate = qttMax * 5.0 / timeFinal;
        qttVal[] = (($Time < timeFinal/5.0) ? $Time * rate :
                    ($Time >= timeFinal/5.0 && $Time < 3.0*timeFinal/5.0) ?
                    qttMax - ($Time - timeFinal/5.0) * rate :
                    - qttMax + ($Time - 3.0*timeFinal/5.0) * rate);
        qttVal_prev[] = ((($Time-$DTime) < timeFinal/5.0) ? ($Time-$DTime) * rate :
                    (($Time-$DTime) >= timeFinal/5.0 && ($Time-$DTime) < 3.0*timeFinal/5.0) ?
                    qttMax - (($Time-$DTime) - timeFinal/5.0) * rate :
                    - qttMax + (($Time-$DTime) - 3.0*timeFinal/5.0) * rate);
    ElseIf(Flag_Source == 2)
        // Up-down-pause source field
        controlTimeInstants = {timeFinalSimu, timeFinal/5.0, 2.0*timeFinal/5.0, timeFinal};
        rate = qttMax * 5.0 / timeFinal;
        qttVal[] = (($Time < timeFinal/5.0) ? $Time * rate :
                    ($Time >= timeFinal/5.0 && $Time < 2.0*timeFinal/5.0) ?
                    qttMax - ($Time - timeFinal/5.0) * rate : 0);
        qttVal_prev[] = ((($Time-$DTime) < timeFinal/5.0) ? ($Time-$DTime) * rate :
                    (($Time-$DTime) >= timeFinal/5.0 && ($Time-$DTime) < 2.0*timeFinal/5.0) ?
                    qttMax - (($Time-$DTime) - timeFinal/5.0) * rate : 0);
    ElseIf(Flag_Source == 3)
        // Step of magnetic field
        controlTimeInstants = {stepTime, stepTime + stepSharpness, timeFinal};
        qttVal[] = ($Time < stepTime) ? 0.0 :
            ($Time < stepTime + stepSharpness) ? ($Time-stepTime) * qttMax/stepSharpness : qttMax;
        qttVal_prev[] = ($Time-$DTime < stepTime) ? 0.0 :
            ($Time-$DTime < stepTime + stepSharpness) ? ($Time-$DTime-stepTime) * qttMax/stepSharpness : qttMax;
    ElseIf(Flag_Source == 4)
        // Up-pause-down
        controlTimeInstants = {timeFinal/3.0, 2.0*timeFinal/3.0, timeFinal};
        rate = qttMax * 3.0 / timeFinal;
        qttVal[] = (($Time < timeFinal/3.0) ? $Time * rate :
                    ($Time < 2.0*timeFinal/3.0 ? qttMax : qttMax - ($Time - 2.0*timeFinal/3.0) * rate));
        qttVal_prev[] = (($Time-$DTime < timeFinal/3.0) ? ($Time-$DTime) * rate :
                    ($Time-$DTime < 2.0*timeFinal/3.0 ? qttMax : qttMax - ($Time-$DTime - 2.0*timeFinal/3.0) * rate));
    ElseIf(Flag_Source == 5)
        // Sine source field with harmonics
        controlTimeInstants = {1/(2*f), 1/f, 3/(2*f), 2*timeFinal};
        qttVal[] = qttMax * Sin[2.0 * Pi * f * $Time] + qttMax/3 * Sin[2.0 * Pi * 7 * f * $Time];
        qttVal_prev[] = qttMax * Sin[ 2.0 * Pi * f * ($Time-$DTime)] + qttMax/3 * Sin[2.0 * Pi * 7 * f * ($Time-$DTime)];
    EndIf

    If(Axisymmetry == 0)
        coef[] = 1.0; // Not axi
    Else
        coef[] = 2.0; // Axisymmetric
    EndIf

    If(SourceType == 1)
        // Imposed current intensity
        I[] = qttVal[];
        hsVal[] = 0.0;
        // For the h-formulation
        hs[] = 0.0 * directionApplied[];
        hs_prev[] = 0.0 * directionApplied[];
        // For the a-formulation
        bs[] = mu0 * hs[];
        bs_prev[] = mu0 * hs_prev[];
        as[] = Vector[0.0, 0.0, 0.0];
        as_prev[] = Vector[0.0, 0.0, 0.0];
        hsCrossN[] = Vector[0.0, 0.0, 0.0];
    Else
        // Imposed external field
        I[] = 0.0;
        hsVal[] = qttVal[];
        // For the h-formulation
        hs[] = 0 * qttVal[] * directionApplied[];
        hs_prev[] = 0 * qttVal_prev[] * directionApplied[];
        bs_bnd[] = mu0 * qttVal[] * directionApplied[];
        bs_bnd_prev[] = mu0 * qttVal_prev[] * directionApplied[];
        // For the a-formulation
        bs[] = mu0 * hs[];
        bs_prev[] = mu0 * hs_prev[];
        as[] = directionApplied[] /\ XYZ[] * mu0 * qttVal[]/coef[];
        as_prev[] = directionApplied[] /\ XYZ[] * mu0 * qttVal_prev[]/coef[];
        hsCrossN[] = Vector[0., 0., - qttVal[]]; // For Neumann BC
    EndIf
}
