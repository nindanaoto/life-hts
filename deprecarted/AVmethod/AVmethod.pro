Include "AVmethod_data.pro";

Group {
  Air = Region[AIR];
  AirInf = Region[INF];
  LinOmegaC = Region[{CU,FE}];
  NonLinOmegaC = Region[{FILAMENT0,FILAMENT1,FILAMENT2,FILAMENT3,FILAMENT4,FILAMENT5,FILAMENT6,FILAMENT7,FILAMENT8,FILAMENT9}];
  MagnAnhyDomain = Region[FE];
  MagnLinDomain = Region[{CU, NonLinOmegaC, Air, AirInf}];
  Ferrite = Region[FE];
  Copper = Region[CU];

  OmegaC = Region[{LinOmegaC,NonLinOmegaC}]; // conducting domain
  OmegaCC = Region[{Air, AirInf}]; // non-conducting domain
  BndOmegaC = Region[BND_WIRE]; // boundary of conducting domain
  Surf_a_noGauge = Region[{BND_WIRE}];
  Cut = Region[CUT]; // thick cut
  Omega = Region[{OmegaC, OmegaCC}]; // full domain
  Lower = Region[LOWERSURFACE];
  Upper = Region[UPPERSURFACE];
  Electrodes = Region[LOWERSURFACE];
}

Function {
  mu0 = 4*Pi*1e-7; // [Hm⁻¹]
  nu0 = 1/mu0;
  epsSigma = 1e-8; // Importance of the linear part for a-formulation [-]
  epsSigma2 = 1e-15; // To prevent division by 0 in sigma [-]
  epsNu = 1e-10; // To prevent division by 0 in nu [T]


  DefineConstant[
    cusigma = {6e7,
      Name "Input/4Materials/Copper conductivity [Sm⁻¹]"},
    fesigma = {1e7,
      Name "Input/4Materials/Ferrum conductivity [Sm⁻¹]"},
    Itot = {15,
      Name "Input/3Source/Total current [A]"},
    Ec = {1e-4,
      Name "Input/4Materials/Critical electric field [Vm⁻¹]"},
    Jc = {3e8,
      Name "Input/4Materials/Critical current density [Am⁻²]"},
    n = {30, Min 3, Max 40, Step 1,
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
    tol_abs = {1e-9,
      Name "Input/Solver/3Absolute tolerance on nonlinear residual"},
    tol_rel = {1e-6,
      Name "Input/Solver/3Relative tolerance on nonlinear residual"},
    iter_max = {100,
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

  nu[MagnLinDomain] =  nu0;
  sigma[Ferrite] = fesigma;
  sigma[Copper] = cusigma;

  // power law E(J) = rho(J) * J, with rho(j) = Ec/Jc * (|J|/Jc)^(n-1)
  rho[NonLinOmegaC] = Ec / Jc * (Norm[$1]/Jc)^(n - 1);
  dEdJ[NonLinOmegaC] =
    Ec / Jc * (Norm[$1]/Jc)^(n - 1) * TensorDiag[1, 1, 1] +
    Ec / Jc^3 * (n - 1) * (Norm[$1]/Jc)^(n - 3) *
      Tensor[CompX[$1]^2, CompX[$1] * CompY[$1], CompX[$1] * CompZ[$1],
             CompY[$1] * CompX[$1], CompY[$1]^2, CompY[$1] * CompZ[$1],
             CompZ[$1] * CompX[$1], CompZ[$1] * CompY[$1], CompZ[$1]^2];
  // a-formulation: Power law j(e) = sigma(e) * e, with sigma(e) = jc/ec^(1/n) * |e|^((1-n)/n)
  sigma[NonLinOmegaC] = Jc / Ec * 1.0 / ( epsSigma + ( Norm[$1]/Ec )^((n-1.0)/n) );
  sigmae[NonLinOmegaC] = sigma[$1] * $1;
  djde[NonLinOmegaC] = ($iter > -1) ? ((1.0/$relaxFactor) *
      ( Jc / Ec * (1.0 / (epsSigma + ( (Norm[$1]/Ec)#3 )^((n-1.0)/n) ))#4 * TensorDiag[1, 1, 1]
      + Jc/Ec^3 * (1.0-n)/n * (#4)^(2) * 1/((#3)^((n+1.0)/n) + epsSigma2 ) * SquDyadicProduct[$1]))
          : (Jc / Ec * 1.0 / ( epsSigma + ( Norm[$1]/Ec )^((n-1.0)/n) ) * TensorDiag[1, 1, 1] );
  nu[MagnAnhyDomain] = 1/2 * ( (Norm[$1]+epsNu)#1 /mu0 - (mur0*m0/(mur0-1))#2
    + ( (#2 - #1/mu0)^2 + 4*m0*#1/((mur0-1)*mu0) )^(1/2) ) * 1/#1;
  dhdb[MagnAnhyDomain] = (1.0/$relaxFactor) *
      (1.0 / (2*(Norm[$1]+epsNu)#1)
          * (#1/mu0 - (mur0*m0/(mur0-1))#2
              + (( (#2 - #1/mu0)^2 + 4*m0*#1/((mur0-1)*mu0) )^(1/2))#3 ) * TensorDiag[1, 1, 1]
      + 1.0 / (2 * (#1)^3) * ( #2 - #3
          + #1/(#3*mu0) * ( (2-mur0)/(mur0-1) * m0 + #1/mu0 ) ) * SquDyadicProduct[$1]);
  RotatePZ[] = Rotate[ Vector[$X,$Y,$Z+$2], 0, 0, $1 ];
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
      { Region Electrodes; Value 1.0 ;}
    }
  }
  { Name Current ;
    Case {
      { Region Electrodes; Value -Itot ; TimeFunction Sin_wt_p[]{2*Pi*Freq, 0.} ; }
    }
  }
  { Name GaugeCondition ; Type Assign ;
    Case {
        // Zero on edges of a tree in Omega_CC, containing a complete tree on Surf_a_noGauge
        {Region OmegaCC ; SubRegion Surf_a_noGauge; Value 0.; }
    }
  }
  { Name Periodic;
    Case {
      { Region Lower; Type Link ; RegionRef Upper;
        Coefficient 1; Function RotatePZ[SliceAngle,SlicePitch];
      }
    }
  }
}

FunctionSpace {
  { Name ASpace; Type Form1;
    BasisFunction {
        { Name psie ; NameOfCoef ae ; Function BF_Edge ;
            Support Omega ; Entity EdgesOf[ All, Not BndOmegaC ] ; }
        { Name psie2 ; NameOfCoef ae2 ; Function BF_Edge ;
            Support Omega ; Entity EdgesOf[ BndOmegaC ] ; } // To keep all dofs of BndOmegaC where a is unique (because e is known)
    }
    Constraint {
        // { NameOfCoef ae; EntityType EdgesOf; NameOfConstraint a; }
        // { NameOfCoef ae2; EntityType EdgesOf; NameOfConstraint a; }
        // Gauge condition
        { NameOfCoef ae; EntityType EdgesOfTreeIn; //EntitySubType StartingOn;
            NameOfConstraint GaugeCondition; }
    }
  }
  { Name GradVSpace; Type Form1;
    BasisFunction {
        { Name vi; NameOfCoef Vi; Function BF_GradGroupOfNodes;
            Support ElementsOf[OmegaC, OnPositiveSideOf Electrodes];
            Entity GroupsOfNodesOf[Electrodes]; }
    }
    GlobalQuantity {
        { Name V; Type AliasOf; NameOfCoef Vi; }
        { Name I; Type AssociatedWith; NameOfCoef Vi; }
    }
    Constraint {
        { NameOfCoef V;
            EntityType GroupsOfNodesOf; NameOfConstraint Voltage; }
        { NameOfCoef I;
            EntityType GroupsOfNodesOf; NameOfConstraint Current; }
    }
  }
}

Formulation {
  { Name MagDynA; Type FemEquation;
    Quantity {
      { Name a; Type Local; NameOfSpace ASpace; }
      // { Name ap; Type Local; NameOfSpace ASpace; } // To avoid auto-symmetrization by GetDP
      { Name ur; Type Local; NameOfSpace GradVSpace; }
      { Name I; Type Global; NameOfSpace GradVSpace [I]; }
      { Name U; Type Global; NameOfSpace GradVSpace [V]; }
    }
    Equation {
        // Curl h term - NonMagnDomain
        Galerkin { [ nu[] * Dof{d a} , {d a} ];
            In MagnLinDomain; Integration Int; Jacobian Vol; }
        // Curl h term - MagnAnhyDomain
        Galerkin { [ nu[{d a}] * {d a} , {d a} ];
            In MagnAnhyDomain; Integration Int; Jacobian Vol; }
        Galerkin { [ dhdb[{d a}] * Dof{d a} , {d a} ];
            In MagnAnhyDomain; Integration Int; Jacobian Vol; }
        Galerkin { [ - dhdb[{d a}] * {d a} , {d a} ];
            In MagnAnhyDomain; Integration Int; Jacobian Vol; }
        // Induced currents
        // Non-linear OmegaC
        Galerkin { [ sigma[ (- {a} + {a}[1]) / $DTime - {ur}] * Dof{a} / $DTime , {a} ];
            In NonLinOmegaC; Integration Int; Jacobian Vol;  }
        Galerkin { [ - sigma[ (- {a} + {a}[1]) / $DTime - {ur}] * {a}[1] / $DTime ,  {a} ];
            In NonLinOmegaC; Integration Int; Jacobian Vol;  }

        Galerkin { [ sigma[ (- {a} + {a}[1]) / $DTime - {ur}] * Dof{ur} , {a} ];
            In NonLinOmegaC; Integration Int; Jacobian Vol;  }

        Galerkin { [ sigma[ (- {a} + {a}[1]) / $DTime - {ur}] * Dof{a} / $DTime , {ur} ];
            In NonLinOmegaC; Integration Int; Jacobian Vol;  }
        Galerkin { [ - sigma[ (- {a} + {a}[1]) / $DTime - {ur}] * {a}[1] / $DTime ,  {ur} ];
            In NonLinOmegaC; Integration Int; Jacobian Vol;  }

        Galerkin { [ sigma[ (- {a} + {a}[1]) / $DTime - {ur}] * Dof{ur} , {ur} ];
            In NonLinOmegaC; Integration Int; Jacobian Vol;  }

        // Galerkin { [ - sigmae[ (- {a} + {a}[1]) / $DTime - {ur}], {a} ];
        //     In NonLinOmegaC; Integration Int; Jacobian Vol;  }
        // Galerkin { [ - sigmae[ (- {a} + {a}[1]) / $DTime - {ur}], {ur} ];
        //     In NonLinOmegaC; Integration Int; Jacobian Vol;  }

        // Galerkin { [ djde[ (- {a} + {a}[1]) / $DTime - {ur} ] * Dof{a}/$DTime , {a} ];
        //     In NonLinOmegaC; Integration Int; Jacobian Vol;  } // Dof appears linearly
        // Galerkin { [ - djde[ (- {a} + {a}[1]) / $DTime - {ur} ] * {a}/$DTime , {a} ];
        //     In NonLinOmegaC ; Integration Int; Jacobian Vol;  }
        // Galerkin { [ djde[ (- {a} + {a}[1]) / $DTime - {ur} ] * Dof{ur} , {a} ];
        //     In NonLinOmegaC; Integration Int; Jacobian Vol;  } // Dof appears linearly
        // Galerkin { [ - djde[ (- {a} + {a}[1]) / $DTime - {ur} ] * {ur} , {a} ];
        //     In NonLinOmegaC ; Integration Int; Jacobian Vol;  }

        // Galerkin { [ djde[ (- {a} + {a}[1]) / $DTime - {ur} ] * Dof{a}/$DTime , {ur} ];
        //     In NonLinOmegaC; Integration Int; Jacobian Vol;  } // Dof appears linearly
        // Galerkin { [ - djde[ (- {a} + {a}[1]) / $DTime - {ur} ] * {a}/$DTime , {ur} ];
        //     In NonLinOmegaC ; Integration Int; Jacobian Vol;  }
        // Galerkin { [ djde[ (- {a} + {a}[1]) / $DTime - {ur} ] * Dof{ur} , {ur} ];
        //     In NonLinOmegaC; Integration Int; Jacobian Vol;  } // Dof appears linearly
        // Galerkin { [ - djde[ (- {a} + {a}[1]) / $DTime - {ur} ] * {ur} , {ur} ];
        //     In NonLinOmegaC ; Integration Int; Jacobian Vol;  }

        // Linear OmegaC
        Galerkin { [ sigma[] * Dof{a} / $DTime , {a} ];
            In LinOmegaC; Integration Int; Jacobian Vol;  }
        Galerkin { [ - sigma[] * {a}[1] / $DTime ,  {a} ];
            In LinOmegaC; Integration Int; Jacobian Vol;  }
        Galerkin { [ sigma[] * Dof{ur} , {a} ];
            In LinOmegaC; Integration Int; Jacobian Vol;  }
        Galerkin { [ sigma[] * Dof{a} / $DTime , {ur} ];
            In LinOmegaC; Integration Int; Jacobian Vol;  }
        Galerkin { [ - sigma[] * {a}[1] / $DTime ,  {ur} ];
            In LinOmegaC; Integration Int; Jacobian Vol;  }
        Galerkin { [ sigma[] * Dof{ur} , {ur} ];
            In LinOmegaC; Integration Int; Jacobian Vol;  }
        // Global term
        // Galerkin { [ - hsVal[] * (directionApplied[] /\ Normal[]), {a} ];
        //     In Gamma_h ; Integration Int ; Jacobian Sur; }
        GlobalTerm { [ Dof{I}  , {U} ]; In Electrodes; }
    }
  }
}

Resolution {
  { Name MagDynATime;
    System {
      { Name A; NameOfFormulation MagDynA; }
    }
    Operation {
      //options for PETsC
      // SetGlobalSolverOptions["-ksp_view -pc_type none -ksp_type gmres -ksp_monitor_singular_value -ksp_gmres_restart 1000"];
      // SetGlobalSolverOptions["-ksp_type bcgsl"];
      // SetGlobalSolverOptions["-ksp_type preonly -pc_type lu -pc_factor_mat_solver_type mumps"];
      SetGlobalSolverOptions["-ksp_type preonly -pc_type lu -pc_factor_mat_solver_type mkl_pardiso"];  
      // SetGlobalSolverOptions["-ksp_type gcr -pc_type gamg"];  

      // create directory to store result files
      CreateDirectory["res"];

      // set a runtime variable to count the number of linear system solves (to
      // compare the performance of adaptive vs. non-adaptive time stepping
      // scheme)
      Evaluate[ $syscount = 0 ];
      
      // initialize relaxation factor
      Evaluate[$relaxFactor = 1];

      Evaluate[$iter = 0];

      // initialize the solution (initial condition)
      InitSolution[A];

      // enter implicit Euler time-stepping loop
      TimeLoopTheta[time0, time1, dt, 1] {

        // compute first solution guess and residual at step $TimeStep
        Generate[A]; Solve[A]; Evaluate[ $syscount = $syscount + 1 ];
        Generate[A]; GetResidual[A, $res0]; Evaluate[ $res = $res0, $iter = 0 ];
        Print[{$iter, $res, $res / $res0},
              Format "Residual %03g: abs %14.12e rel %14.12e"];

        // iterate until convergence
        While[$res > tol_abs && $res / $res0 > tol_rel &&
              $res / $res0 <= 1 && $iter < iter_max]{
          Solve[A]; Evaluate[ $syscount = $syscount + 1 ];
          Generate[A]; GetResidual[A, $res]; Evaluate[ $iter = $iter + 1 ];
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
  { Name MagDynA; NameOfFormulation MagDynA;
    Quantity {
      // { Name a; Value{ Local{ [ {a} ] ;
      //     In Omega; Jacobian Vol; } } }
      // { Name b; Value{ Local{ [ {d a} ] ;
      //     In Omega; Jacobian Vol; } } }
      // { Name mur; Value{ Local{ [ 1.0/(nu[{d a}] * mu0) ] ;
      //     In MagnAnhyDomain; Jacobian Vol; } } }
      { Name h; Value {
          Term { [ nu[] * {d a} ] ; In MagnLinDomain; Jacobian Vol; }
          Term { [ nu[{d a}] * {d a} ] ; In MagnAnhyDomain; Jacobian Vol; }
          }
      }
      // { Name e; Value{ Local{ [ - Dt[{a}] - {ur} ] ;
      //     In OmegaC; Jacobian Vol; } } }
      // { Name ur; Value{ Local{ [ {ur} ] ;
      //     In OmegaC; Jacobian Vol; } } }
      { Name j; Value{ Local{ [ sigmae[ - Dt[{a}] - {ur} ] ] ;
          In OmegaC; Jacobian Vol; } } }
      { Name norm_j; Value{ Local{ [ Norm[sigmae[ - Dt[{a}] - {ur} ]] ] ;
          In OmegaC; Jacobian Vol; } } }
      // { Name I; Value{ Term{ [ {I} ] ;
      //     In OmegaC; } } }
      // { Name U; Value{ Term{ [ {U} ] ;
      //     In OmegaC; } } }
      // Not axisym, so surface integral to give (total) magnetization per unit length.
      // Here, the average is computed. ATTENTION: Factor 2 (for end junctions) is not introduced
      // { Name m_avg; Value{ Integral{ [ 0.5 * XYZ[]
      //     /\ sigmae[ (- {a} + {a}[1]) / $DTime - {ur} ] / (SurfaceArea[]) ] ;
      //     In OmegaC; Integration Int; Jacobian Vol; } } }
      // { Name m_avg_y_tesla; Value{ Integral{ [ mu0*0.5 * Vector[0,1,0] * (XYZ[]
      //     /\ sigmae[ (- {a} + {a}[1]) / $DTime - {ur} ]) / (SurfaceArea[]) ] ;
      //     In OmegaC; Integration Int; Jacobian Vol; } } }
      // { Name m_avg_x_tesla; Value{ Integral{ [ mu0*0.5 * Vector[1,0,0] * (XYZ[]
      //     /\ sigmae[ (- {a} + {a}[1]) / $DTime - {ur} ]) / (SurfaceArea[]) ] ;
      //     In OmegaC; Integration Int; Jacobian Vol; } } }
      // { Name hsVal; Value{ Term { [ hsVal[] ]; In Omega; } } }
      // { Name bsVal; Value{ Term { [ mu0*hsVal[] ]; In Omega; } } }
      // { Name power;
      //     Value{
      //         Integral{ [ ({d a} - {d a}[1]) / $DTime * nu[{d a}] * {d a} ] ;
      //             In MagnAnhyDomain ; Integration Int ; Jacobian Vol; }
      //         Integral{ [ ({d a} - {d a}[1]) / $DTime * nu[] * {d a} ] ;
      //             In MagnLinDomain ; Integration Int ; Jacobian Vol; }
      //         Integral{ [sigma[ (- {a} + {a}[1]) / $DTime - {ur}]
      //             * ((- {a} + {a}[1]) / $DTime - {ur} ) * ((- {a} + {a}[1]) / $DTime - {ur} )] ;
      //             In OmegaC ; Integration Int ; Jacobian Vol; }
      //     }
      // }
      // { Name dissPowerGlobal;
      //     Value{
      //         Term{ [ {U}*{I} ] ; In OmegaC;}
      //     }
      // }
      // { Name dissPower;
      //     Value{
      //         Integral{ [sigma[ (- {a} + {a}[1]) / $DTime - {ur}]
      //             * ((- {a} + {a}[1]) / $DTime - {ur} ) * ((- {a} + {a}[1]) / $DTime - {ur} )] ;
      //             In OmegaC ; Integration Int ; Jacobian Vol; }
      //     }
      // }
  }
}
}

PostOperation {
  { Name MagDynA ; NameOfPostProcessing MagDynA ; LastTimeStepOnly visu ;
    Operation {
      Echo["General.Verbosity=3;", File "res/option.pos"];
      Print[ h, OnElementsOf Omega , File "res/h.pos", Name "h [Am⁻1]" ];
      Print[ j, OnElementsOf OmegaC , File "res/j.pos", Name "j [Am⁻²]" ];
      Print[ norm_j, OnElementsOf OmegaC , File "res/norm_j.pos", Name "|j| [Am⁻²]" ];
      // Print[ Losses[OmegaC],  OnGlobal, Format TimeTable,
      //   File > "res/losses_total.txt", SendToServer "Output/Losses [W]"] ;
      // Print[ Losses[NonLinOmegaC], OnGlobal, Format TimeTable,
      //   File > "res/losses_filaments.txt"] ;
      // Print[ Losses[LinOmegaC], OnGlobal, Format TimeTable,
      //   File > "res/losses_matrix.txt"] ;
      // Print[I1, OnRegion Cut, Format TimeTable, File "res/I1.pos"];
      // Print[V1, OnRegion Cut, Format TimeTable, File "res/V1.pos"];
      // Print[Z1, OnRegion Cut, Format TimeTable, File "res/Z1.pos"];
      Echo["General.Verbosity=5;", File "res/option.pos"];
    }
  }
}

DefineConstant[
  R_ = {"MagDynHTime", Name "GetDP/1ResolutionChoices", Visible 0},
  C_ = {"-solve -bin -v 3 -v2", Name "GetDP/9ComputeCommand", Visible 0},
  P_ = { "", Name "GetDP/2PostOperationChoices", Visible 0}
];
