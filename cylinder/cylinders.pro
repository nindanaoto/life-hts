Include "cylinders_data.pro";

Group {
    // Preset choice of formulation
    DefineConstant[preset = {4, Highlight "Blue",
      Choices{
        1="h-formulation",
        3="a-formulation (small steps)",
        4="coupled formulation"},
      Name "Input/5Method/0Preset formulation" },
      expMode = {0, Choices{0,1}, Name "Input/5Method/1Allow changes?"}];
    // Output choice
    DefineConstant[ realTimeSolution = 0 ];
    DefineConstant[ realTimeInfo = 1 ];

    // ------- PROBLEM DEFINITION -------
    // Dimension of the problem
    Dim = 2;
    // Which cylinders are materials, 0: none (air), 1: super, 2: ferro, 3: both
    MaterialType = 3;
    // Axisymmetry of the problem, 0: no, 1: yes
    Axisymmetry = 1;
    // Excitation type of the system
    // 0: External applied field
    // 1: Imposed current intensity NOT SUITED HERE FOR THIS AXISYMMETRIC EXAMPLE
    // 2: Imposed voltage NOT IMPLEMENTED YET
    // 3: Both applied field and current intensity NOT IMPLEMENTED YET
    SourceType = 0;

    // Test name - for output files
    name = "cylinder";
    // (directory name for .txt files, not .pos files)
    DefineConstant [testname = "cylinders_model"];

    // ------- WEAK FORMULATION -------
    // Choice of the formulation
    DefineConstant [formulation = (preset==1) ? h_formulation : ((preset == 3) ? a_formulation : coupled_formulation)];
    // Iterative methods. Always N-R for the coupled formulation (whatever the values below)
    DefineConstant [Flag_NR_Super = (preset==3) ? 0 : 1]; // 1: N-R, 0: Picard
    DefineConstant [Flag_NR_Ferro = 1]; // 1: N-R, 0: Picard

    // ------- Definition of the physical regions -------
    // Regions that must be properly completed (can be empty)
    DefineGroup[LinOmegaC, NonLinOmegaC, OmegaC, OmegaCC, Omega];
    DefineGroup[Cuts, BndOmegaC, BndOmegaC_side, Electrodes];
    DefineGroup[MagnLinDomain, MagnAnhyDomain, MagnHystDomain];
    DefineGroup[Gamma_e, Gamma_h, GammaAll];

    // Filling the regions
    Air = Region[ AIR ];
    Air += Region[ AIR_OUT ];
    DefineGroup [Super, Copper, Cond1, Cond2, Cut1, Cut2, Electrode1, Electrode2];
    DefineGroup [Ferro, FerroAnhy, FerroHyst];
    IsThereFerro = 0; // Will be updated below if necessary
    IsThereSuper = 0; // Will be updated below if necessary
    Flag_Hysteresis = 0; // Will be updated below if necessary
    Flag_LinearProblem = 1; // Will be updated below if necessary
    If(MaterialType == 0)
        Air += Region[ SUPER ];
        Air += Region[ FERRO ];
    ElseIf(MaterialType == 1)
        Super += Region[ SUPER ];
        Cond1 = Region[ SUPER ];
        BndOmegaC += Region[ BND_OMEGA_C ];
        IsThereSuper = 1;
        Air += Region[ FERRO ];
        Flag_LinearProblem = 0;
    ElseIf(MaterialType == 2)
        Air += Region[ SUPER ];
        FerroAnhy = Region[ FERRO ];
        IsThereFerro = 1;
        Flag_LinearProblem = 0;
    ElseIf(MaterialType == 3)
        Super += Region[ SUPER ]; // HERE
        Cond1 = Region[ SUPER ];
        BndOmegaC += Region[ BND_OMEGA_C ];
        FerroAnhy += Region[ FERRO ];
        IsThereSuper = 1;
        IsThereFerro = 1;
        Flag_LinearProblem = 0;
    EndIf
    Ferro = Region[ {FerroAnhy, FerroHyst} ];
    SurfOut = Region[ SURF_OUT ];
    SurfSym = Region[ SURF_SYM ];
    SurfSymMat = Region[ SURF_SYM_MAT ];
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
    If(formulation == h_formulation)
        Gamma_h = Region[{SurfOut}];
        Gamma_e = Region[{SurfSym, SurfSymMat}];
    ElseIf(formulation == a_formulation)
        Gamma_h = Region[{}];
        Gamma_e = Region[{SurfOut, SurfSym, SurfSymMat}];
    ElseIf(formulation == coupled_formulation)
        Gamma_h = Region[{}];
        Gamma_e = Region[{SurfOut, SurfSym, SurfSymMat}];
    EndIf
    GammaAll = Region[ {Gamma_h, Gamma_e} ];
    OmegaGamma = Region[ {Omega, GammaAll} ];
}

Function{
    // ------- PARAMETERS -------
    // Superconductor parameters
    DefineConstant [ec = 1e-4]; // Critical electric field [V/m]
    DefineConstant [jc = {3e8, Name "Input/3Material Properties/2jc (Am⁻²)"}]; // Critical current density [A/m2]
    DefineConstant [n = {40, Name "Input/3Material Properties/1n (-)"}]; // Superconductor exponent (n) value [-]
    DefineConstant [epsSigma = 1e-8]; // Importance of the linear part for a-formulation [-]
    DefineConstant [epsSigma2 = 1e-15]; // To prevent division by 0 in sigma [-]
    // Ferromagnetic material parameters
    DefineConstant [mur0 = 1700.0]; // Relative permeability at low fields [-]
    DefineConstant [m0 = 1.04e6]; // Magnetic field at saturation [A/m]
    DefineConstant [epsMu = 1e-15]; // To prevent division by 0 in mu [A/m]
    DefineConstant [epsNu = 1e-10]; // To prevent division by 0 in nu [T]
    // Excitation - Source field or imposed current intensty
    // 0: sine, 1: triangle, 2: up-down-pause, 3: step, 4: up-pause-down
    DefineConstant [Flag_Source = {1, Highlight "yellow", Choices{
        0="Sine",
        1="Triangle",
        4="Up-pause-down"}, Name "Input/4Source/0Source field type" }];
    DefineConstant [Imax = jc*H_super*W/2]; // Maximum imposed current intensity [A]
    DefineConstant [f = {0.1, Visible (Flag_Source ==0), Name "Input/4Source/1Frequency (Hz)"}]; // Frequency of imposed current intensity [Hz]
    DefineConstant [bmax = {1.5, Name "Input/4Source/2Field amplitude (T)"}]; // Maximum applied magnetic induction [T]
    DefineConstant [partLength = {5, Visible (Flag_Source != 0), Name "Input/4Source/1Ramp duration (s)"}];
    DefineConstant [timeStart = 0]; // Initial time [s]
    DefineConstant [timeFinal = (Flag_Source == 0) ? 5/(4*f) : ((Flag_Source == 1) ? 5*partLength : 3*partLength)]; // Final time for source definition [s]
    DefineConstant [timeFinalSimu = timeFinal]; // Final time of simulation [s]
    DefineConstant [stepTime = 0.01]; // Initiation of the step [s]
    DefineConstant [stepSharpness = 0.001]; // Duration of the step [s]

    // ------- NUMERICAL PARAMETERS -------
    DefineConstant [dt = {meshMult*timeFinal/600, Highlight "LightBlue",
        ReadOnly !expMode, Name "Input/5Method/Time step (s)"}]; // Time step (initial if adaptive)[s]
    DefineConstant [adaptive = 1]; // Allow adaptive time step increase (case 0 not implemented yet)
    DefineConstant [dt_max = dt]; // Maximum allowed time step [s]
    DefineConstant [iter_max = {(preset==3) ? 600 : 30, Highlight "LightBlue",
        ReadOnly !expMode, Name "Input/5Method/Max number of iteration (-)"}]; // Maximum number of nonlinear iterations
    DefineConstant [extrapolationOrder = (preset==3) ? 2 : 1]; // Extrapolation order
    // Use relaxation factors?
    tryrelaxationfactors = 0;
    // Convergence criterion
    // 0: energy estimate
    // 1: absolute/relative residual (do not use)
    // 2: relative increment (do not use either)
    DefineConstant [convergenceCriterion = 0];
    DefineConstant [tol_energy = {(preset == 3) ? 1e-4 : 1e-6, Highlight "LightBlue",
        ReadOnly !expMode, Name "Input/5Method/Relative tolerance (-)"}]; // Relative tolerance on the energy estimates
    DefineConstant [tol_abs = 1e-12]; //Absolute tolerance on nonlinear residual
    DefineConstant [tol_rel = 1e-6]; // Relative tolerance on nonlinear residual
    DefineConstant [tol_incr = 5e-3]; // Relative tolerance on the solution increment
    multFix = 1e0;
    // Output information
    DefineConstant [economPos = 0]; // 0: Saves all fields. 1: Does not save fields (.pos)
    DefineConstant [economInfo = 0]; // 0: Saves all iteration/residual info. 1: Does not save them
    // Parameters
    DefineConstant [saveAll = 0];  // Save all the iterations? (pay attention to memory! heavy files)
    DefineConstant [writeInterval = dt]; // Time interval between two successive output file saves [s]
    DefineConstant [saveAllSteps = 0];
    DefineConstant [saveAllStepsSeparately = 0];
    DefineConstant [savedPoints = 2000]; // Resolution of the line saving postprocessing
    // Control points
    controlPoint1 = {1e-5,0, 0}; // CP1
    controlPoint2 = {W/2-1e-5, 0, 0}; // CP2
    controlPoint3 = {0, H_super/2+2e-3, 0}; // CP3
    controlPoint4 = {W/2, H_super/2+2e-3, 0}; // CP4

    // Direction of applied field
    directionApplied[] = Vector[0., 1., 0.]; // Only choice for axi
    DefineFunction [I, hsVal];
    mu0 = 4*Pi*1e-7; // [H/m]
    nu0 = 1.0/mu0;
    // ------- Constitutive law outside ferro and super -------
    mu[MagnLinDomain] = mu0;
    mu[BndOmegaC] = mu0;
    nu[MagnLinDomain] = nu0;

    sigma[Copper] = 1e11; // [S/m]
    rho[Copper] = 1./sigma[];
    sigmae[Copper] = sigma[$1] * $1;// [S/m]
}


// Only external field is implemented
Constraint {
    { Name a ;
        Case {
            // Square because axisymmetry and circulation on perpendicular edge
            {Region Gamma_e ; Value -X[]^2 * mu0 / 2.0 ; TimeFunction hsVal[] ;}
        }
    }
    { Name a2 ;
        Case {
            {Region Gamma_e ; Value 0.0 ;} // Second-order hierarchical elements
        }
    }
    { Name phi ;
        Case {
            {Region SurfOut ; Value XYZ[]*directionApplied[] ; TimeFunction hsVal[] ;}
        }
    }
    { Name h ;
        Case {

        }
    }
    { Name Current ;
        Case {

        }
    }
    { Name Voltage ;
        Case {
            If(formulation == h_formulation || formulation == coupled_formulation)
                // No cut in this geometry
            Else
                // a-formulation and BF_RegionZ
                { Region Cond1; Value 0.0; }
            EndIf
        }
    }
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
                ElseIf(formulation == coupled_formulation)
                    //Print[ phi, OnElementsOf BndOmegaC , File "res/phi.pos", Name "phi [A]" ];
                    Print[ a, OnElementsOf OmegaCC , File "res/a.pos", Name "a [Tm]" ];
                    Print[ mur, OnElementsOf OmegaCC , File "res/mur.pos", Name "mur [-]" ];
                EndIf
                Print[ j, OnElementsOf OmegaC , File "res/j.pos", Name "j [A/m2]" ];
                Print[ jz, OnElementsOf OmegaC , File "res/jz.pos", Name "j [A/m2]" ];
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
            Print[ b, OnPlane{{List[controlPoint1]}{List[controlPoint2]}{List[controlPoint3]}} {100,50},
                File "res/b_onPlane.pos", Format Gmsh];
            Print[ hsVal[Omega], OnRegion Omega, Format TimeTable, File outputAppliedField];
        }
    }
}

DefineConstant[
  R_ = {"MagDyn", Name "GetDP/1ResolutionChoices", Visible 0},
  C_ = {"-solve -pos -bin -v 3 -v2", Name "GetDP/9ComputeCommand", Visible 0},
  P_ = { "MagDyn", Name "GetDP/2PostOperationChoices", Visible 0}
];
