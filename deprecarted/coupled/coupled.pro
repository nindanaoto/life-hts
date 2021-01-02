Include "coupled_data.pro";

Group {
  Air = Region[AIR];
  AirInf = Region[INF];
  LinOmegaC = Region[{CU,FE}];
  BndMatrix = Region[BND_WIRE];
  Filaments = Region[{FILAMENT0,FILAMENT1,FILAMENT2,FILAMENT3,FILAMENT4,FILAMENT5,FILAMENT6,FILAMENT7,FILAMENT8,FILAMENT9}];
  BndFilaments = Region[{BND_FILAMENT0,BND_FILAMENT1,BND_FILAMENT2,BND_FILAMENT3,BND_FILAMENT4,BND_FILAMENT5,BND_FILAMENT6,BND_FILAMENT7,BND_FILAMENT8,BND_FILAMENT9}];
  BndFe = Region[BND_FE];
  MagnAnhyDomain = Region[FE];
  MagnLinDomain = Region[{CU, Filaments, Air, AirInf}];
  Ferrite = Region[FE];
  Copper = Region[CU];

  OmegaC = Region[{LinOmegaC,Filaments}]; // conducting domain
  OmegaCC = Region[{Air, AirInf}]; // non-conducting domain
  BndOmegaC = Region[BndMatrix]; // boundary of conducting domain
  BndInH = Region[{BndFilaments,BND_CU}];
  BndInA = Region[{BndFe}];
  BndCouple = Region[{BndInH,BndInA}];
  Cut = Region[CUT]; // thick cut
  Omega = Region[{OmegaC, OmegaCC}]; // full domain

  OmegaCH = Region[{Copper,Filaments}];
  OmegaH = Region[{OmegaCC,Copper,Filaments}];
}

Function {
  mu0 = 4*Pi*1e-7; // [Hm⁻¹]

  DefineConstant[
    cusigma = {6e7,
      Name "Input/4Materials/Copper conductivity [Sm⁻¹]"},
    fesigma = {1e7,
      Name "Input/4Materials/Ferrum conductivity [Sm⁻¹]"},
    Itot = {7, Step 100,
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
    epsNu = {1e-10,
      Name "Input/Solver/numerical epsiron of nu"} // To prevent division by 0 in nu [T]
  ];

  dt_max = adaptive ? dt_max : dt;

  mu[MagnLinDomain] =  mu0;
  nu[MagnLinDomain] = 1/mu0;
  sigma[Ferrite] = fesigma;
  rho[Copper] = 1/cusigma;

  // power law E(J) = rho(J) * J, with rho(j) = Ec/Jc * (|J|/Jc)^(n-1)
  rho[Filaments] = Ec / Jc * (Norm[$1]/Jc)^(n - 1);
  dEdJ[Filaments] =
    Ec / Jc * (Norm[$1]/Jc)^(n - 1) * TensorDiag[1, 1, 1] +
    Ec / Jc^3 * (n - 1) * (Norm[$1]/Jc)^(n - 3) *
      Tensor[CompX[$1]^2, CompX[$1] * CompY[$1], CompX[$1] * CompZ[$1],
             CompY[$1] * CompX[$1], CompY[$1]^2, CompY[$1] * CompZ[$1],
             CompZ[$1] * CompX[$1], CompZ[$1] * CompY[$1], CompZ[$1]^2];
  nu[MagnAnhyDomain] = 1/2 * ( (Norm[$1]+epsNu)#1 /mu0 - (mur0*m0/(mur0-1))#2
    + ( (#2 - #1/mu0)^2 + 4*m0*#1/((mur0-1)*mu0) )^(1/2) ) * 1/#1;
  dhdb[MagnAnhyDomain] = (1.0/$relaxFactor) *
    (1.0 / (2*(Norm[$1]+epsNu)#1)
        * (#1/mu0 - (mur0*m0/(mur0-1))#2
            + (( (#2 - #1/mu0)^2 + 4*m0*#1/((mur0-1)*mu0) )^(1/2))#3 ) * TensorDiag[1, 1, 1]
    + 1.0 / (2 * (#1)^3) * ( #2 - #3
        + #1/(#3*mu0) * ( (2-mur0)/(mur0-1) * m0 + #1/mu0 ) ) * SquDyadicProduct[$1]);
}

Jacobian {
  { Name Vol ;
    Case {
      { Region AirInf ; Jacobian VolCylShell{R_air, R_inf} ; }
      { Region All ; Jacobian Vol ; }
    }
  }
  { Name Sur ;
    Case{
      { Region All ; Jacobian Sur ; }
    }
  }
}

Integration {
  { Name Int ;
    Case {
      { Type Gauss ;
         Case {
                { GeoElement Point ; NumberOfPoints 1 ; }
                { GeoElement Line ; NumberOfPoints 3 ; }
                { GeoElement Line2 ; NumberOfPoints 4 ; } // Second-order element
                { GeoElement Triangle ; NumberOfPoints 3 ; }
                { GeoElement Triangle2 ; NumberOfPoints 12 ; }
                { GeoElement Quadrangle ; NumberOfPoints 4 ; }
                { GeoElement Quadrangle2 ; NumberOfPoints 4 ; } // Second-order element
                { GeoElement Tetrahedron ; NumberOfPoints  5 ; }
                { GeoElement Tetrahedron2 ; NumberOfPoints  5 ; } // Second-order element
                { GeoElement Pyramid ; NumberOfPoints  8 ; }
                { GeoElement Hexahedron ; NumberOfPoints  6 ; }
              }
      }
    }
  }
}

Constraint {
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
        Support OmegaCH; Entity EdgesOf[All, Not BndOmegaC]; }
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
  { Name a_space_2D; Type Form1P;
    BasisFunction {
        { Name psin; NameOfCoef an; Function BF_PerpendicularEdge;
            Support MagnAnhyDomain; Entity NodesOf[All]; }
        { Name psin2; NameOfCoef an2; Function BF_PerpendicularEdge_2E;
            Support MagnAnhyDomain; Entity EdgesOf[BndCouple]; } // Second order for stability of the coupling
    }
    // Constraint {
    //     { NameOfCoef an; EntityType NodesOf; NameOfConstraint a; }
    //     { NameOfCoef an2; EntityType EdgesOf; NameOfConstraint a2; }
    // }
  }
  { Name grad_v_space_2D; Type Form1P;
        BasisFunction {
            { Name zi; NameOfCoef Ui; Function BF_RegionZ;
                Support Region[MagnAnhyDomain]; Entity Region[OmegaC]; }
        }
        // GlobalQuantity {
        //     { Name U; Type AliasOf; NameOfCoef Ui; }
        //     { Name I; Type AssociatedWith; NameOfCoef Ui; }
        // }
        // Constraint {
        //     { NameOfCoef U;
        //         EntityType Region; NameOfConstraint Voltage; }
        //     { NameOfCoef I;
        //         EntityType Region; NameOfConstraint Current; }
        // }
    }
}

Formulation {
  { Name MagDynCoupled; Type FemEquation;
    Quantity {
      { Name h; Type Local; NameOfSpace HSpace; }
      { Name a; Type Local; NameOfSpace a_space_2D; }
      { Name ur; Type Local; NameOfSpace grad_v_space_2D; }
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
        In OmegaH; Integration Int; Jacobian Vol;  }
      
      // Galerkin { [ nu[] * Dof{d a} , {d a} ];
      //   In MagnAnhyDomain; Integration Int; Jacobian Vol; }
      Galerkin { [ nu[{d a}] * {d a} , {d a} ];
        In MagnAnhyDomain; Integration Int; Jacobian Vol; }
      Galerkin { [ dhdb[{d a}] * Dof{d a} , {d a} ];
        In MagnAnhyDomain; Integration Int; Jacobian Vol; }
      Galerkin { [ - dhdb[{d a}] * {d a} , {d a} ];
        In MagnAnhyDomain; Integration Int; Jacobian Vol; }


      //Galerkin { [ mu[] * DtHs[] , {h} ];
      //  In Omega; Integration Int; Jacobian Vol;  }

      Galerkin { [ rho[] * Dof{d h} , {d h} ];
        In Copper; Integration Int; Jacobian Vol;  }

      Galerkin { [ rho[{d h}] * {d h} , {d h} ];
        In Filaments; Integration Int; Jacobian Vol;  }
      Galerkin { [ dEdJ[{d h}] * Dof{d h} , {d h} ];
        In Filaments; Integration Int; Jacobian Vol;  }
      Galerkin { [ - dEdJ[{d h}] * {d h} , {d h} ];
        In Filaments ; Integration Int; Jacobian Vol;  }

       Galerkin { [ sigma[] * Dof{a} / $DTime , {a} ];
          In MagnAnhyDomain; Integration Int; Jacobian Vol;  }
      Galerkin { [ - sigma[] * {a}[1] / $DTime ,  {a} ];
          In MagnAnhyDomain; Integration Int; Jacobian Vol;  }
      Galerkin { [ sigma[] * Dof{ur} , {a} ];
          In MagnAnhyDomain; Integration Int; Jacobian Vol;  }
      Galerkin { [ sigma[] * Dof{a} / $DTime , {ur} ];
          In MagnAnhyDomain; Integration Int; Jacobian Vol;  }
      Galerkin { [ - sigma[] * {a}[1] / $DTime ,  {ur} ];
          In MagnAnhyDomain; Integration Int; Jacobian Vol;  }
      Galerkin { [ sigma[] * Dof{ur} , {ur} ];
          In MagnAnhyDomain; Integration Int; Jacobian Vol;  }

      // ---- SURFACE TERMS ----
      Galerkin { [ + Dof{a} /\ Normal[] /$DTime , {h}];
        In BndInH; Integration Int; Jacobian Sur; }
      Galerkin { [ - {a}[1] /\ Normal[] /$DTime , {h}];
        In BndInH; Integration Int; Jacobian Sur; }
      Galerkin { [ Dof{h} /\ Normal[] , {a}];
        In BndInH; Integration Int; Jacobian Sur; } // Sign for normal (should be -1 but normal is opposite)
      Galerkin { [ - Dof{a} /\ Normal[] /$DTime , {h}];
        In BndInA; Integration Int; Jacobian Sur; }
      Galerkin { [ + {a}[1] /\ Normal[] /$DTime , {h}];
        In BndInA; Integration Int; Jacobian Sur; }
      Galerkin { [ - Dof{h} /\ Normal[] , {a}];
        In BndInA; Integration Int; Jacobian Sur; } // Sign for normal (should be -1 but normal is opposite)

      GlobalTerm { [ Dof{V1} , {I1} ] ; In Cut ; }
    }
  }
}

Resolution {
  { Name MagDynCoupledTime;
    System {
      { Name A; NameOfFormulation MagDynCoupled; }
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
      // SetGlobalSolverOptions["-pc_type hmg -ksp_type fgmres -ksp_rtol 1.e-7"];
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
  { Name MagDynCoupled; NameOfFormulation MagDynCoupled;
    Quantity {
      { Name phi; Value{ Local{ [ {dInv h} ] ;
            In Omega; Jacobian Vol; } } }
      { Name h; Value{ Local{ [ {h} ] ;
	    In Omega; Jacobian Vol; } } }
      { Name j; Value{ Local{ [ {d h} ] ;
	    In OmegaC; Jacobian Vol; } } }
      { Name suj; Value{ Local{ [ {d h} ] ;
	    In Filaments; Jacobian Vol; } } }
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
  { Name MagDynCoupled ; NameOfPostProcessing MagDynCoupled ; LastTimeStepOnly visu ;
    Operation {
      // Echo["General.Verbosity=3;", File "res/option.pos"];
      // Print[ h, OnElementsOf Omega , Format TimeTable, File "res/h.pos", Name "h [Am⁻1]" ];
      // Print[ j, OnElementsOf OmegaC , Format TimeTable, File "res/j.pos", Name "j [Am⁻²]" ];
      Print[ suj, OnElementsOf Filaments , File "res/suj.pos", Name "j [Am⁻²]" ];
      // Print[ norm_j, OnElementsOf OmegaC , Format TimeTable, File "res/norm_j.pos", Name "|j| [Am⁻²]" ];
      // Print[ Losses[OmegaC],  OnGlobal, Format TimeTable,
      //   File > "res/losses_total.txt", SendToServer "Output/Losses [W]"] ;
      // Print[ Losses[Filaments], OnGlobal, Format TimeTable,
      //   File > "res/losses_filaments.txt"] ;
      // Print[ Losses[LinOmegaC], OnGlobal, Format TimeTable,
      //   File > "res/losses_matrix.txt"] ;
      // Print[I1, OnRegion Cut, Format TimeTable, File "res/I1.pos"];
      // Print[V1, OnRegion Cut, Format TimeTable, File "res/V1.pos"];
      // Print[Z1, OnRegion Cut, Format TimeTable, File "res/Z1.pos"];
      // Echo["General.Verbosity=5;", File "res/option.pos"];
    }
  }
}

DefineConstant[
  R_ = {"MagDynHTime", Name "GetDP/1ResolutionChoices", Visible 0},
  C_ = {"-solve -bin -v 3 -v2", Name "GetDP/9ComputeCommand", Visible 0},
  P_ = { "", Name "GetDP/2PostOperationChoices", Visible 0}
];
