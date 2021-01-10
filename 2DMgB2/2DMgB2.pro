Include "2DMgB2_data.pro";

Group {
  Air = Region[AIR];
  AirInf = Region[INF];
  BndMatrix = Region[BND_WIRE];
  BndOmegaC = Region[BndMatrix]; // boundary of conducting domain
  LinOmegaC = Region[{CU,FE}];
  Filaments = Region[{FILAMENT0,FILAMENT1,FILAMENT2,FILAMENT3,FILAMENT4,FILAMENT5,FILAMENT6,FILAMENT7,FILAMENT8,FILAMENT9}];
  MagnAnhyDomain = Region[FE];
  MagnLinDomain = Region[{CU, Filaments , Air, AirInf}];
  Ferrite = Region[FE];
  Copper = Region[CU];

  OmegaC = Region[{LinOmegaC,Filaments}]; // conducting domain
  OmegaCC = Region[{Air, AirInf}]; // non-conducting domain
  Cut = Region[CUT]; // thick cut
  Omega = Region[{OmegaC, OmegaCC}]; // full domain
}

Function {
  mu0 = 4*Pi*1e-7; // [Hm⁻¹]

  DefineConstant[
    cusigma = {6e7,
      Name "Input/4Materials/Copper conductivity [Sm⁻¹]"},
    fesigma = {1e7,
      Name "Input/4Materials/Ferrum conductivity [Sm⁻¹]"},
    Itot = {300, 
      Name "Input/3Source/Total current [A]"},
    Ec = {1e-6,
      Name "Input/4Materials/Critical electric field [Vm⁻¹]"},
    Jc = {3.48e9,
      Name "Input/4Materials/Critical current density [Am⁻²]"},
    n = {21, Min 3, Max 40, Step 1,
       Highlight "LightYellow",
      Name "Input/4Materials/Exponent (n) value"},
    Freq = {50, Min 1, Max 100, Step 1,
      Name "Input/3Source/Frequency [Hz]"},
    periods = {1., Min 0.1, Max 2.0, Step 0.05,
      Name "Input/Solver/0Periods to simulate"},
    time0 = 0, // initial time
    time1 = periods * (1 / Freq), // final time
    dt = {2e-4, Min 1e-7, Max 1e-3, Step 1e-6,
      Name "Input/Solver/1Time step [s]"}
    adaptive = {0, Choices{0,1},
      Name "Input/Solver/2Allow adaptive time step increase"},
    dt_max = {0.1 * (1 / Freq), Visible adaptive,
      Name "Input/Solver/2Maximum time step [s]"},
    tol_abs = {1e-7,
      Name "Input/Solver/3Absolute tolerance on nonlinear residual"},
    tol_rel = {1e-6,
      Name "Input/Solver/3Relative tolerance on nonlinear residual"},
    iter_max = {30,
      Name "Input/Solver/Maximum number of nonlinear iterations"},
    visu = {0, Choices{0, 1}, AutoCheck 0,
      Name "Input/Solver/Visu", Label "Real-time visualization"},
    m0 = {1.04e6,
      Name "Input/Solver/Magnetic field at saturation"},
    mur0 = {1700.0,
      Name "Input/Solver/Relative permeability at low fields"},
    epsMu = {1e-15,
      Name "Input/Solver/numerical epsiron of mu"}
  ];

  dt_max = adaptive ? dt_max : dt;

  mu[MagnLinDomain] =  mu0;
  rho[Ferrite] = 1 / fesigma;
  rho[Copper] = 1 / cusigma;

  // power law E(J) = rho(J) * J, with rho(j) = Ec/Jc * (|J|/Jc)^(n-1)
  rho[Filaments] = Ec / Jc * (Norm[$1]/Jc)^(n - 1);
  dEdJ[Filaments] =
    Ec / Jc * (Norm[$1]/Jc)^(n - 1) * TensorDiag[1, 1, 1] +
    Ec / Jc^3 * (n - 1) * (Norm[$1]/Jc)^(n - 3) * SquDyadicProduct[$1];
  mu[MagnAnhyDomain] = mu0 * ( 1.0 + 1.0 / ( 1/(mur0-1) + Norm[$1]/m0 ) );
  dbdh[MagnAnhyDomain] = (mu0 * (1.0 + (1.0/(1/(mur0-1)+Norm[$1]/m0))#1 ) * TensorDiag[1, 1, 1]
    - mu0/m0 * (#1)^2 * 1/(Norm[$1]+epsMu) * SquDyadicProduct[$1]); 
}

Jacobian {
  { Name Vol ;
    Case {
      { Region AirInf ; Jacobian VolCylShell{R_air, R_inf} ; }
      { Region All ; Jacobian Vol ; }
    }
  }
}

Integration {
  { Name Int ;
    Case {
      { Type Gauss ;
	Case {
	  { GeoElement Triangle ; NumberOfPoints  4 ; }
          { GeoElement Quadrangle ; NumberOfPoints  4 ; }
	  { GeoElement Tetrahedron ; NumberOfPoints  5 ; }
	}
      }
    }
  }
}

Constraint {
  { Name Voltage ;
    Case {
    }
  }
  { Name Current ;
    Case {
      { Region Cut; Value -Itot ; TimeFunction Sin_wt_p[]{2*Pi*Freq, 0.} ; }
    }
  }
}

FunctionSpace {
  { Name HSpace; Type Form1;
    BasisFunction {
      { Name sn; NameOfCoef phin; Function BF_GradNode;
        Support Omega; Entity NodesOf[OmegaCC]; }
      { Name se; NameOfCoef he; Function BF_Edge;
        Support OmegaC; Entity EdgesOf[All, Not BndOmegaC]; }
      { Name sc1; NameOfCoef I1; Function BF_GroupOfEdges;
        Support Omega; Entity GroupsOfEdgesOf[Cut]; }
    }
    GlobalQuantity {
      { Name Current1 ; Type AliasOf        ; NameOfCoef I1 ; }
      { Name Voltage1 ; Type AssociatedWith ; NameOfCoef I1 ; }
    }
    Constraint {
      { NameOfCoef Current1 ;
        EntityType GroupsOfEdgesOf ; NameOfConstraint Current ; }
      { NameOfCoef Voltage1 ;
        EntityType GroupsOfEdgesOf ; NameOfConstraint Voltage ; }
    }
  }
}

Formulation {
  { Name MagDynH; Type FemEquation;
    Quantity {
      { Name h; Type Local; NameOfSpace HSpace; }
      { Name I1; Type Global; NameOfSpace HSpace[Current1]; }
      { Name V1; Type Global; NameOfSpace HSpace[Voltage1]; }
    }
    Equation {
      // Nonlinear weak form: Find h_k such that
      //
      //   \partial_t (\mu h_k, h') + (\rho(curl h_k) curl h_k, curl h')
      //     + < n x e, h'> = 0,
      //
      // for all h' in Hspace.
      //
      // Linearization in the superconducting filaments:
      //
      //   E(J_k) \approx E(J_k-1) + (dE/dJ)_k-1 * (J_k - J_k-1)
      //
      // i.e.
      //
      //   (\rho(curl h_k) curl h_k, curl h') \approx
      //       (\rho(curl h_k-1) curl h_k-1, curl h')
      //     + (dEdJ(curl h_k-1) curl h_k, curl h')
      //     - (dEdJ(curl h_k-1) curl h_k-1, curl h')
      //
      Galerkin { DtDof [ mu[] * Dof{h} , {h} ];
        In MagnLinDomain; Integration Int; Jacobian Vol;  }
      
      Galerkin { [ mu[{h}] * {h} / $DTime , {h} ];
        In MagnAnhyDomain; Integration Int; Jacobian Vol;  }
      Galerkin { [ - mu[{h}[1]] * {h}[1] / $DTime , {h} ];
        In MagnAnhyDomain; Integration Int; Jacobian Vol;  }
      Galerkin { JacNL[dbdh[{h}] * Dof{h} / $DTime , {h}];
        In MagnAnhyDomain; Integration Int; Jacobian Vol;  }

      //Galerkin { [ mu[] * DtHs[] , {h} ];
      //  In Omega; Integration Int; Jacobian Vol;  }

      Galerkin { [ rho[] * Dof{d h} , {d h} ];
        In LinOmegaC; Integration Int; Jacobian Vol;  }

      Galerkin { [ rho[{d h}] * {d h} , {d h} ];
        In Filaments; Integration Int; Jacobian Vol;  }
      Galerkin { JacNL[dEdJ[{d h}] * Dof{d h} , {d h} ];
        In Filaments; Integration Int; Jacobian Vol;  }

      GlobalTerm { [ Dof{V1} , {I1} ] ; In Cut ; }
    }
  }
}

Resolution {
  { Name MagDynHTime;
    System {
      { Name A; NameOfFormulation MagDynH; }
    }
    Operation {
      //options for PETsC
      // SetGlobalSolverOptions["-ksp_view -pc_type none -ksp_type gmres -ksp_monitor_singular_value -ksp_gmres_restart 1000"];
      // SetGlobalSolverOptions["-ksp_type preonly -pc_type lu"];   
      // SetGlobalSolverOptions["-ksp_type preonly -pc_type lu -pc_factor_mat_solver_type mumps"];  
      SetGlobalSolverOptions["-ksp_type preonly -pc_type lu -pc_factor_mat_solver_type mkl_pardiso"];  
      // SetGlobalSolverOptions["-ksp_type preonly -pc_type lu -pc_factor_mat_solver_type strumpack"];
      // SetGlobalSolverOptions["-ksp_type preonly -pc_type lu -pc_factor_mat_solver_type superlu_dist"];  
      // SetGlobalSolverOptions["-ksp_type preonly -pc_type lu -pc_factor_mat_solver_type klu"];  
      // SetGlobalSolverOptions["-ksp_type bcgsl -pc_type ilu -pc_factor_mat_solver_type strumpack -dm_mat_type aijcusparse -dm_vec_type cusp"];
      // SetGlobalSolverOptions["-ksp_type pipecg -pc_type ilu -pc_factor mat_solver_type strumpack"];
      // SetGlobalSolverOptions["-pc_type ilu -ksp_type bcgsl -mat_type aijcusparse -vec_type cuda"];  
      SetGlobalSolverOptions["-pc_type gamg -pc_gamg_type agg -ksp_type gmres -ksp_gmres_restart 50 -ksp_rtol 1.e-15 -ksp_abstol 1.e-14 -ksp_max_it 1500"];
      // SetGlobalSolverOptions["-pc_type ilu -ksp_type bcgsl -ksp_abstol 1.e-13"];  
      // SetGlobalSolverOptions["-pc_type hmg -ksp_type fgmres -ksp_rtol 1.e-12"];
      // SetGlobalSolverOptions["-ksp_type bcgsl -pc_type ilu -pc_factor_pivot_in_blocks -pc_factor_nonzeros_along_diagonal "];

      // create directory to store result files
      CreateDirectory["res"];

      // set a runtime variable to count the number of linear system solves (to
      // compare the performance of adaptive vs. non-adaptive time stepping
      // scheme)
      Evaluate[ $syscount = 0 ];

      Evaluate[$iter = 0];
      
      // initialize relaxation factor
      Evaluate[$relaxFactor = 1];

      // initialize the solution (initial condition)
      InitSolution[A];

      // enter implicit Euler time-stepping loop
      TimeLoopTheta[time0, time1, dt, 1] {

        // compute first solution guess and residual at step $TimeStep
        GenerateJac[A]; SolveJac[A]; Evaluate[ $syscount = $syscount + 1 ];
        GenerateJac[A]; GetResidual[A, $res0]; Evaluate[ $res = $res0, $iter = 0 ];
        Print[{$iter, $res, $res / $res0},
              Format "Residual %03g: abs %14.12e rel %14.12e"];

        // iterate until convergence
        While[$res > tol_abs && $res / $res0 > tol_rel &&
              $res / $res0 <= 1 && $iter < iter_max]{
          SolveJac[A]; Evaluate[ $syscount = $syscount + 1 ];
          GenerateJac[A]; GetResidual[A, $res]; Evaluate[ $iter = $iter + 1 ];
          Print[{$iter, $res, $res / $res0},
                Format "Residual %03g: abs %14.12e rel %14.12e"];
        }

        // save and visualize the solution if converged...
        Test[ $iter < iter_max && $res / $res0 <= 1 ]{
          SaveSolution[A];
          Test[ GetNumberRunTime[visu]{"Input/Solver/Visu"} ]{
            PostOperation[MagDynH];
          }
          // increase the step if we converged sufficiently "fast"
          Test[ $iter < iter_max / 4 && $DTime < dt_max ]{
            Evaluate[ $dt_new = Min[$DTime * 1.5, dt_max] ];
            Print[{$dt_new},
              Format "*** Fast convergence: increasing time step to %g"];
            SetDTime[$dt_new];
          }
        }
        // ...otherwise reduce the time step and try again
        {
          Evaluate[ $dt_new = $DTime / 3 ];
          Print[{$iter, $dt_new},
            Format "*** Non convergence (iter %g): recomputing with reduced step %g"];
          SetTime[$Time - $DTime];
          SetTimeStep[$TimeStep - 1];
          RemoveLastSolution[A];
          SetDTime[$dt_new];
        }
      }

      Print[{$syscount}, Format "Total number of linear systems solved: %g"];
    }
  }

}

PostProcessing {
  { Name MagDynH; NameOfFormulation MagDynH;
    Quantity {
      { Name phi; Value{ Local{ [ {dInv h} ] ;
            In Omega; Jacobian Vol; } } }
      { Name h; Value{ Local{ [ {h} ] ;
	    In Omega; Jacobian Vol; } } }
      { Name j; Value{ Local{ [ {d h} ] ;
	    In OmegaC; Jacobian Vol; } } }
      { Name norm_j; Value{ Local{ [ Norm[{d h}] ] ;
	    In OmegaC; Jacobian Vol; } } }
      { Name b; Value{ Local{ [ mu[]*{h} ] ;
            In Omega; Jacobian Vol; } } }
      { Name dtb; Value{ Local{ [ mu[]* Dt[{h}] ] ;
            In Omega; Jacobian Vol; } } }
      { Name I1 ; Value { Term { [ {I1} ] ;
            In Cut ; } } }
      { Name V1 ; Value { Term { [ {V1} ] ;
            In Cut ; } } }
      { Name Z1 ; Value { Term { [ {V1} / {I1} ] ;
            In Cut ; } } }
      { Name Losses ; Value { Integral { [ rho[{d h}] * {d h} * {d h}];
            In OmegaC ; Integration Int; Jacobian Vol; } } }
    }
  }
}

PostOperation {
  { Name MagDynH ; NameOfPostProcessing MagDynH ; LastTimeStepOnly visu ;
    Operation {
      Echo["General.Verbosity=3;", File "res/option.pos"];
      Print[ h, OnElementsOf Omega , File "res/h.pos", Name "h [Am⁻1]" ];
      Print[ j, OnElementsOf OmegaC , File "res/j.pos", Name "j [Am⁻²]" ];
      // Print[ norm_j, OnElementsOf OmegaC , File "res/norm_j.pos", Name "|j| [Am⁻²]" ];
      Print[ Losses[OmegaC],  OnGlobal, Format TimeTable,
        File > "res/losses_total.txt", SendToServer "Output/Losses [W]"] ;
      Print[ Losses[Filaments], OnGlobal, Format TimeTable,
        File > "res/losses_filaments.txt"] ;
      Print[ Losses[LinOmegaC], OnGlobal, Format TimeTable,
        File > "res/losses_matrix.txt"] ;
      Print[I1, OnRegion Cut, Format TimeTable, File "res/I1.pos"];
      Print[V1, OnRegion Cut, Format TimeTable, File "res/V1.pos"];
      Print[Z1, OnRegion Cut, Format TimeTable, File "res/Z1.pos"];
      Echo["General.Verbosity=5;", File "res/option.pos"];
    }
  }
}

DefineConstant[
  R_ = {"MagDynHTime", Name "GetDP/1ResolutionChoices", Visible 0},
  C_ = {"-solve -bin -v 3 -v2", Name "GetDP/9ComputeCommand", Visible 0},
  P_ = { "", Name "GetDP/2PostOperationChoices", Visible 0}
];
