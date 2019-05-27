Include "cube_data.pro";

Group {
    // ------- PROBLEM DEFINITION -------
    // Dimension of the problem
    Dim = 3;
    // Material type of region MATERIAL, 0: air, 1: super, 2: copper, 3: soft ferro
    MaterialType = 1;
    // Axisymmetry of the problem
    Axisymmetry = 0; // Not axi
    // Excitation type of the system
    // 0: External applied field
    // 1: Imposed current intensity NOT POSSIBLE HERE
    // 2: Imposed voltage NOT POSSIBLE YET
    // 3: Both applied field and current intensity NOT POSSIBLE YET
    SourceType = 0;


    // Test name - for output files
    name = "cube";
    // (directory name for .txt files, not .pos files)
    DefineConstant [testname = "cube_model"];

    // ------- WEAK FORMULATION -------
    // Choice of the formulation
    DefineConstant [formulation = a_formulation];
    // Iterative methods. Always N-R for the coupled formulation (whatever the values below)
    DefineConstant [Flag_NR_Super = 0]; // 1: N-R, 0: Picard
    DefineConstant [Flag_NR_Ferro = 1]; // 1: N-R, 0: Picard

    // ------- Definition of the physical regions -------
    // Regions that must be properly completed (can be empty)
    DefineGroup[LinOmegaC, NonLinOmegaC, OmegaC, OmegaCC, Omega];
    DefineGroup[Cuts, BndOmegaC, BndOmegaC_side, Electrodes];
    DefineGroup[MagnLinDomain, MagnAnhyDomain, MagnHystDomain];
    DefineGroup[Gamma_e, Gamma_h, GammaAll];

    // Filling the regions
    Air = Region[ AIR ];
    DefineGroup [Super, Copper, Cond1, Cond2, Cut1, Cut2, Electrode1, Electrode2];
    DefineGroup [Ferro, FerroAnhy, FerroHyst];
    IsThereFerro = 0; // Will be updated below if necessary
    IsThereSuper = 0; // Will be updated below if necessary
    Flag_Hysteresis = 0; // Will be updated below if necessary
    Flag_LinearProblem = 1; // Will be updated below if necessary
    If(MaterialType == 0)
        Air += Region[ MATERIAL ];
    ElseIf(MaterialType == 1)
        Super += Region[ MATERIAL ];
        Cond1 = Region[ MATERIAL ];
        BndOmegaC += Region[ BND_MATERIAL ];
        IsThereSuper = 1;
        Flag_LinearProblem = 0;
    ElseIf(MaterialType == 2)
        Copper += Region[ MATERIAL ];
        Cond1 = Region[ MATERIAL ];
        BndOmegaC += Region[ BND_MATERIAL ];
    ElseIf(MaterialType == 3)
        FerroAnhy += Region[ MATERIAL ];
        IsThereFerro = 1;
        Flag_LinearProblem = 0;
    EndIf
    Ferro = Region[ {FerroAnhy, FerroHyst} ];
    SurfOut = Region[ SURF_OUT ];
    SurfSym_bn0 = Region[ {SURF_SYM_MAT_bn0, SURF_SYM_bn0} ];
    SurfSym_ht0 = Region[ {SURF_SYM_MAT_ht0, SURF_SYM_ht0} ];
    SurfSym = Region[ {SurfSym_bn0, SurfSym_ht0} ];
    ArbitraryPoint = Region[ {} ];
    // Remaining regions
    LinOmegaC = Region[ {Copper} ];
    NonLinOmegaC = Region[ {Super} ];
    OmegaC = Region[ {LinOmegaC, NonLinOmegaC} ];
    Cuts = Region[ {Cut1} ];
    Electrodes = Region[ {Electrode1} ];
    OmegaCC = Region[ {Air, Ferro} ];
    Omega = Region[ {OmegaC, OmegaCC} ];
    MagnLinDomain = Region[ {Air, Super, Copper} ];
    MagnAnhyDomain = Region[ {FerroAnhy} ];
    MagnHystDomain = Region[ {FerroHyst} ];
    Gamma_h = Region[{SurfOut, SurfSym_ht0}];
    Gamma_e = Region[{SurfSym_bn0}];

    GammaAll = Region[ {Gamma_h, Gamma_e} ];
    OmegaGamma = Region[ {Omega, GammaAll} ];


}


Function{
    // ------- PARAMETERS -------
    // Superconductor parameters
    DefineConstant [ec = 1e-4]; // Critical electric field [V/m]
    DefineConstant [jc = 1e8]; // Critical current density [A/m2]
    DefineConstant [n = 100]; // Superconductor exponent (n) value [-]
    DefineConstant [epsSigma = 1e-8]; // Importance of the linear part for a-formulation [-]
    DefineConstant [epsSigma2 = 1e-15]; // To prevent division by 0 in sigma [-]
    // Ferromagnetic material parameters
    DefineConstant [mur0 = 1700.0]; // Relative permeability at low fields [-]
    DefineConstant [m0 = 1.04e6]; // Magnetic field at saturation [A/m]
    DefineConstant [epsMu = 1e-15]; // To prevent division by 0 in mu [A/m]
    DefineConstant [epsNu = 1e-10]; // To prevent division by 0 in nu [T]

    // Excitation - Source field or imposed current intensty
    // 0: sine, 1: triangle, 2: up-down-pause, 3: step, 4: up-pause-down
    DefineConstant [Flag_Source = 0];
    DefineConstant [Imax = 1]; // Maximum imposed current intensity [A]
    DefineConstant [f = 50]; // Frequency of imposed current intensity [Hz]
    DefineConstant [bmax = 0.2]; // Maximum applied magnetic induction [T]
    DefineConstant [timeStart = 0]; // Initial time [s]
    DefineConstant [timeFinal = 1.25/f]; // Final time for source definition [s]
    DefineConstant [timeFinalSimu = timeFinal]; // Final time of simulation [s]
    DefineConstant [stepTime = 0.01]; // Initiation of the step [s]
    DefineConstant [stepSharpness = 0.001]; // Duration of the step [s]

    // Numerical parameters
    DefineConstant [nbStepsPerPeriod = 4]; // Number of time steps over one period [-]
    DefineConstant [dt = 1/(nbStepsPerPeriod*f)]; // Time step (initial if adaptive)[s]
    DefineConstant [adaptive = 1]; // Allow adaptive time step increase (case 0 not implemented yet)
    DefineConstant [dt_max = dt]; // Maximum allowed time step [s]
    DefineConstant [iter_max = 500]; // Maximum number of nonlinear iterations
    DefineConstant [extrapolationOrder = 1]; // Extrapolation order
    // Use relaxation factors? (the inverse multiplies the Jacobian)
    tryrelaxationfactors = 0;
    // Convergence criterion
    // 0: energy estimate
    // 1: absolute/relative residual (do not use)
    // 2: relative increment (do not use either)
    DefineConstant [convergenceCriterion = 0];
    DefineConstant [tol_energy = 1e-6]; // Relative tolerance on the energy estimates (1e-10 for j distr. as in the article)
    DefineConstant [tol_abs = 1e-12]; //Absolute tolerance on nonlinear residual
    DefineConstant [tol_rel = 1e-6]; // Relative tolerance on nonlinear residual
    DefineConstant [tol_incr = 5e-3]; // Relative tolerance on the solution increment
    multFix = 1e0;
    // Output information
    DefineConstant [economPos = 0]; // 0: Saves all fields. 1: Does not save fields (.pos)
    DefineConstant [economInfo = 0]; // 0: Saves all iteration/residual info. 1: Does not save them
    // Parameters
    DefineConstant [saveAll = 0];  // Save all the iterations? (pay attention to memory! heavy files)
    DefineConstant [saveAllSteps = 0];
    DefineConstant [saveAllStepsSeparately = 0];
    DefineConstant [writeInterval = dt]; // Time interval between two successive output file saves [s]
    DefineConstant [savedPoints = 2000]; // Resolution of the line saving postprocessing
    // Control points
    controlPoint1 = {1e-5,0, 0}; // CP1
    controlPoint2 = {a/2-1e-5, 0, 0}; // CP2
    controlPoint3 = {0, a/2+2e-3, 0}; // CP3
    controlPoint4 = {a/2, a/2+2e-3, 0}; // CP4

    // Direction of applied field
    directionApplied[] = Vector[0., 0., 1.]; // Only possible choice provided the symmetry of the geometry
    DefineFunction [I, hsVal];
    mu0 = 4*Pi*1e-7; // [H/m]
    nu0 = 1.0/mu0;
    // ------- Constitutive law outside ferro and super -------
    mu[MagnLinDomain] = mu0;
    mu[BndOmegaC] = mu0;
    nu[MagnLinDomain] = nu0;

    sigma[Copper] = 6e9; // [S/m]
    rho[Copper] = 1./sigma[];
    sigmae[Copper] = sigma[$1] * $1;// [S/m]

}


Constraint {
    { Name a ;
        Case {
            {Region SurfSym_bn0; Value 0.0;}
        }
    }
    { Name phi ;
        Case {
            {Region SurfOut ; Value XYZ[]*directionApplied[] ; TimeFunction hsVal[] ;}
            {Region SurfSym_ht0 ; Value 0. ;} // If symmetry (and then, use only purely vertical hs!)
        }
    }
    { Name h ;
        Case {
            {Region SurfSym_ht0 ; Value 0. ;}
        }
    }
    { Name Current ;
        Case {

        }
    }
    { Name Voltage ;
        Case {

        }
    } // Nothing
}

Include "../lib/formulations.pro";
Include "../lib/resolution.pro";

PostOperation {
    { Name MagDyn;
        If(formulation == h_formulation)
            NameOfPostProcessing MagDyn_htot;
        ElseIf(formulation == a_formulation)
            NameOfPostProcessing MagDyn_avtot;
        ElseIf(formulation == coupled_formulation)
            NameOfPostProcessing MagDyn_coupled;
        EndIf
        Operation {
            If(economPos == 0)
                If(formulation == h_formulation)
                    Print[ phi, OnElementsOf OmegaCC , File "res/phi.pos", Name "phi [A]" ];
                ElseIf(formulation == a_formulation)
                    Print[ a, OnElementsOf Omega , File "res/a.pos", Name "a [Tm]" ];
                    Print[ ur, OnElementsOf OmegaC , File "res/ur.pos", Name "ur [V/m]" ];
                EndIf
                Print[ j, OnElementsOf OmegaC , File "res/j.pos", Name "j [A/m2]" ];
                Print[ e, OnElementsOf OmegaC , File "res/e.pos", Name "e [V/m]" ];
                Print[ h, OnElementsOf Omega , File "res/h.pos", Name "h [A/m]" ];
                Print[ b, OnElementsOf Omega , File "res/b.pos", Name "b [T]" ];
            EndIf
            Print[ j, OnLine{{List[controlPoint1]}{List[controlPoint2]}} {savedPoints},
                Format TimeTable, File outputCurrent];
            Print[ b, OnLine{{List[controlPoint1]}{List[controlPoint2]}} {savedPoints},
                Format TimeTable, File outputMagInduction1];
            Print[ b, OnLine{{List[controlPoint3]}{List[controlPoint4]}} {savedPoints},
                Format TimeTable, File outputMagInduction2];
            Print[ hsVal[Omega], OnRegion Omega, Format TimeTable, File outputAppliedField];
        }
    }
}
