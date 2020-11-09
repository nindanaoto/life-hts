Include "concentric_data.pro";

Group {
    // Preset choice of formulation
    DefineConstant[preset = {1, Highlight "Blue",
      Choices{
        1="h-formulation",
        2="a-formulation (large steps)",
        3="a-formulation (small steps)"},
      Name "Input/5Method/0Preset formulation" },
      expMode = {0, Choices{0,1}, Name "Input/5Method/1Allow changes?"}];
    // Output choice
    DefineConstant[onelabInterface = {0, Choices{0,1}, Name "Input/3Problem/2Get solution during simulation?"}]; // Set to 0 for launching in terminal (faster)
    realTimeInfo = 1;
    realTimeSolution = onelabInterface;

    // ------- PROBLEM DEFINITION -------
    // Dimension of the problem
    Dim = 2;
    // Material type of region MATERIAL, 0: air, 1: super, 2: copper, 3: soft ferro
    MaterialType = 1;
    // Axisymmetry of the problem, 0: no, 1: yes
    Axisymmetry = 0;
    // Other constants
    nonlinferro = 0;
    Flag_CTI = 0;
    Flag_MB = 0;
    Flag_rotating = Flag_MB;
    // Test name - for output files
    name = "concentric";
    // (directory name for .txt files, not .pos files)
    DefineConstant [testname = "concentric_model"];

    // ------- WEAK FORMULATION -------
    // Choice of the formulation
    DefineConstant [formulation = (preset==1) ? h_formulation : a_formulation];
    // Iterative methods. Always N-R for the coupled formulation (whatever the values below)
    DefineConstant [Flag_NR_Super = (preset==1) ? 1 : 0]; // 1: N-R, 0: Picard
    DefineConstant [Flag_NR_Ferro = 1]; // 1: N-R, 0: Picard

    // ------- Definition of the physical regions -------
    // Regions that must be properly completed (can be empty)
    DefineGroup[LinOmegaC, NonLinOmegaC, OmegaC, OmegaCC, Omega];
    DefineGroup[Cuts, BndOmegaC, BndOmegaC_side, Electrodes];
    DefineGroup[MagnLinDomain, MagnAnhyDomain, MagnHystDomain];
    DefineGroup[Gamma_e, Gamma_h, GammaAll];

    // Filling the regions
    Air = Region[ {AIR,CU} ];
    Air += Region[ AIR_OUT ];
    DefineGroup [Super, Copper, Cond1, Cond2, Cut1, Cut2, Electrode1, Electrode2];
    DefineGroup [Ferro, FerroAnhy, FerroHyst];
    IsThereFerro = 0; // Will be updated below if necessary
    IsThereSuper = 0; // Will be updated below if necessary
    Flag_Hysteresis = 0; // Will be updated below if necessary
    Flag_LinearProblem = 1; // Will be updated below if necessary

    Super += Region[ SU ];
    Cond1 = Region[ SU ];
    BndOmegaC += Region[ {BND_SU_OUTER,BND_SU_INNER} ];
    Cuts = Region[ CUT ];
    IsThereSuper = 1;
    Flag_LinearProblem = 0;

    FerroHyst = Region[{FE1,FE2}];
    Ferro = Region[ {FerroAnhy, FerroHyst} ];
    SurfOut = Region[ SURF_OUT ];
    // SurfSym = Region[ SURF_SYM ];
    SurfSymMat = Region[ {} ];
    ArbitraryPoint = Region[ ARBITRARY_POINT ];
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
    Gamma_h = Region[{}];
    // Gamma_e = Region[{SurfOut, SurfSym, SurfSymMat}];

    GammaAll = Region[ {Gamma_h, Gamma_e} ];
    OmegaGamma = Region[ {Omega, GammaAll} ];
}


Function{
    // ------- PARAMETERS -------
    // Superconductor parameters
    DefineConstant [ec = 1e-4]; // Critical electric field [V/m]
    DefineConstant [jc = {3e8, Name "Input/3Material Properties/2jc (Am⁻²)"}]; // Critical current density [A/m2]
    DefineConstant [n = {20, Name "Input/3Material Properties/1n (-)"}]; // Superconductor exponent (n) value [-]
    DefineConstant [epsSigma = 1e-8]; // Importance of the linear part for a-formulation [-]
    DefineConstant [epsSigma2 = 1e-15]; // To prevent division by 0 in sigma [-]
    // Ferromagnetic material parameters
    DefineConstant [mur0 = 1700.0]; // Relative permeability at low fields [-]
    DefineConstant [m0 = 1.04e6]; // Magnetic field at saturation [A/m]
    DefineConstant [mur = 1000.0]; // Relative permeability for linear material [-]
    DefineConstant [epsMu = 1e-15]; // To prevent division by 0 in mu [A/m]
    DefineConstant [epsNu = 1e-10]; // To prevent division by 0 in nu [T]
    // Excitation - Source field or imposed current intensty
    // 0: sine, 1: triangle, 2: up-down-pause, 3: step, 4: up-pause-down
    DefineConstant [Flag_Source = {0, Highlight "yellow", Choices{
        0="Sine",
        1="Triangle",
        4="Up-pause-down"}, Name "Input/4Source/0Source field type" }];
    DefineConstant [IFraction = {0.9, Name "Input/4Source/0Fraction of max. current intensity (-)"}];
    DefineConstant [Imax = IFraction*jc]; // Maximum imposed current intensity [A]
    DefineConstant [f = 50]; // Frequency of imposed current intensity [Hz]
    DefineConstant [bmax = 1]; // Maximum applied magnetic induction [T]
    DefineConstant [timeStart = 0]; // Initial time [s]
    DefineConstant [timeFinal = 1.25/f]; // Final time for source definition [s]
    DefineConstant [timeFinalSimu = 1.25/f]; // Final time of simulation [s]
    DefineConstant [stepTime = 0.01]; // Initiation of the step [s]
    DefineConstant [stepSharpness = 0.001]; // Duration of the step [s]

    // ------- NUMERICAL PARAMETERS -------
    DefineConstant [dt = {(preset==1 || preset == 3) ? meshMult*timeFinal/300 : timeFinal/15, Highlight "LightBlue",
        ReadOnly !expMode, Name "Input/5Method/Time step (s)"}]; // Time step (initial if adaptive)[s]
    DefineConstant [adaptive = 1]; // Allow adaptive time step increase (case 0 not implemented yet)
    DefineConstant [dt_max = dt]; // Maximum allowed time step [s]
    DefineConstant [iter_max = {(preset==1) ? 30 : 600, Highlight "LightBlue",
        ReadOnly !expMode, Name "Input/5Method/Max number of iteration (-)"}]; // Maximum number of nonlinear iterations
    DefineConstant [extrapolationOrder = (preset==1) ? 1 : 2]; // Extrapolation order
    // Use relaxation factors?
    tryrelaxationfactors = 0;
    // Convergence criterion
    // 0: energy estimate
    // 1: absolute/relative residual (do not use)
    // 2: relative increment (do not use either)
    DefineConstant [convergenceCriterion = 0];
    DefineConstant [tol_energy = {(preset == 1) ? 1e-6 : 1e-4, Highlight "LightBlue",
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
    controlPoint1 = {-R_wire,0, 0}; // CP1
    controlPoint2 = {R_wire, 0, 0}; // CP2
    controlPoint3 = {0, R_wire, 0}; // CP3
    controlPoint4 = {0, -R_wire, 0}; // CP4

    // Direction of applied field
    directionApplied[] = Vector[0., 1., 0.]; // Only choice for axi
    DefineFunction [I, js, hsVal];
    mu0 = 4*Pi*1e-7; // [H/m]
    nu0 = 1.0/mu0; // [m/H]
    hmax = bmax / mu0;

    // Sine source field
    controlTimeInstants = {timeFinalSimu, 1/(2*f), 1/f, 3/(2*f), 2*timeFinal};
    I[] = Imax * Sin[2.0 * Pi * f * $Time];

}

// Only external field is implemented
Constraint {
    { Name a ;
        Case {
            {Region SurfOut ; Value 0.0;}
        }
    }
    { Name phi ;
        Case {
            {Region ArbitraryPoint ; Value 0.0;} // If no surf sym, fix it at one point
        }
    }
    { Name h ;
        Case {

        }
    }
    { Name Current ; Type Assign;
        Case {
            If(formulation == h_formulation || formulation == coupled_formulation)
                // h-formulation and cuts
                { Region Cuts; Value 1.0; TimeFunction I[]; }
            Else
                // a-formulation and BF_RegionZ
                { Region Cond1; Value 1.0; TimeFunction I[]; }
            EndIf
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

Include "lib/cohomformulations.pro";
Include "lib/resolution.pro";

PostOperation {
    // Runtime output for graph plot
    { Name Info;
        If(formulation == h_formulation)
            NameOfPostProcessing MagDyn_htot ;
        ElseIf(formulation == a_formulation)
            NameOfPostProcessing MagDyn_avtot ;
        ElseIf(formulation == coupled_formulation)
            NameOfPostProcessing MagDyn_coupled ;
        EndIf
        Operation{
            Print[ time[OmegaC], OnRegion OmegaC, LastTimeStepOnly, Format Table, SendToServer "Output/0Time [s]"] ;
            Print[ bsVal[OmegaC], OnRegion OmegaC, LastTimeStepOnly, Format Table, SendToServer "Output/1Applied field [T]"] ;
            Print[ m_avg_y_tesla[OmegaC], OnGlobal, LastTimeStepOnly, Format Table, SendToServer "Output/2Avg. magnetization [T]"] ;
            Print[ dissPower[OmegaC], OnGlobal, LastTimeStepOnly, Format Table, SendToServer "Output/2Joule loss [W]"] ;
        }
    }
    { Name MagDyn; LastTimeStepOnly realTimeSolution ;
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
                Print[ jz, OnElementsOf OmegaC , File "res/jz.pos", Name "jz [A/m2]" ];
                Print[ e, OnElementsOf OmegaC , File "res/e.pos", Name "e [V/m]" ];
                Print[ h, OnElementsOf Omega , File "res/h.pos", Name "h [A/m]" ];
                Print[ b, OnElementsOf Omega , File "res/b.pos", Name "b [T]" ];
            EndIf
            Print[ m_avg[OmegaC], OnRegion OmegaC, Format TimeTable, File outputMagnetization];
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

DefineConstant[
  R_ = {"MagDyn", Name "GetDP/1ResolutionChoices", Visible 0},
  C_ = {"-solve -pos -bin -v 3 -v2", Name "GetDP/9ComputeCommand", Visible 0},
  P_ = { "MagDyn", Name "GetDP/2PostOperationChoices", Visible 0}
];
