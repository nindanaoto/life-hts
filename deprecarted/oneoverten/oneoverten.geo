//SetFactory("OpenCASCADE");
// Include cross data
Include "oneoverten_data.pro";

// Interactive settings
//R = W/2; // Radius
// Mesh size
DefineConstant [meshFactor = {10, Name "Input/2Mesh/2Coarsening factor at infinity (-)"}];
DefineConstant [LcCyl = meshMult*0.0003]; // Mesh size in cylinder [m]
DefineConstant [LcLayer = LcCyl]; // Mesh size in the region close to the cylinder [m]
DefineConstant [LcWire = meshFactor*LcCyl]; // Mesh size in wire [m]
DefineConstant [LcFe = meshFactor/2*LcCyl]; // Mesh size in wire [m]
DefineConstant [LcAir = meshFactor*LcCyl]; // Mesh size in air shell [m]
DefineConstant [LcInf = meshFactor*LcCyl]; // Mesh size in external air shell [m]
DefineConstant [transfiniteQuadrangular = {0, Choices{0,1}, Name "Input/2Mesh/3Regular quadrangular mesh?"}];
DefineConstant [NumCore = 10];
DefineConstant [CoreGapAngle = 2*Pi/NumCore - Angle_Su];
DefineConstant [SliceAngle = 2*Pi/NumCore];
DefineConstant [SlicePitch = Pitch/NumCore];

centerp = newp; Point(centerp) = {0, 0, 0, LcAir};

//Outer Shell
infp0 = newp; Point(infp0) = {R_inf, 0, 0, LcInf};
infp1 = newp; Point(infp1) = {R_inf*Cos(SliceAngle), R_inf*Sin(SliceAngle),0, 0, LcInf};

infl = newl; Circle(infl) = {infp0, centerp, infp1};

//Air
airp0 = newp; Point(airp0) = {R_air, 0, 0, LcAir};
airp1 = newp; Point(airp1) = {R_air*Cos(SliceAngle), R_air*Sin(SliceAngle), 0, LcAir};

airl = newl; Circle(airl) = {airp0, centerp, airp1};

//Wire
wirep0 = newp; Point(wirep0) = {R_wire, 0, 0, LcAir};
wirep1 = newp; Point(wirep1) = {R_wire*Cos(SliceAngle), R_wire*Sin(SliceAngle), 0, LcAir};

wirel = newl; Circle(wirel) = {wirep0, centerp, wirep1};

//Cu-Ni
cunip0 = newp; Point(cunip0) = {R_CuNi, 0, 0, LcFe};
cunip1 = newp; Point(cunip1) = {R_CuNi*Cos(SliceAngle), R_CuNi*Sin(SliceAngle), 0, LcFe};

cunil = newl; Circle(cunil) = {cunip0, centerp, cunip1};

//loops
infl0 = newl; Line(infl0) = {airp0,infp0};
infl1 = newl; Line(infl1) = {airp1,infp1};
airl0 = newl; Line(airl0) = {wirep0,airp0};
airl1 = newl; Line(airl1) = {wirep1,airp1};
cunil0 = newl; Line(cunil0) = {cunip0,wirep0};
cunil1 = newl; Line(cunil1) = {cunip1,wirep1};

infll = newll; Line Loop(infll) = {infl0,infl,-infl1,-airl};
airll = newll; Line Loop(airll) = {airl0,airl,-airl1,-wirel};
cunill = newll; Line Loop(cunill) = {cunil0,wirel,-cunil1,-cunil};

// Su cores
sup0 = newp; Point(sup0) = {R_Su_Outer*Cos(CoreGapAngle/2), R_Su_Outer*Sin(CoreGapAngle/2), 0, LcCyl};
sup1 = newp; Point(sup1) = {(R_Su_Outer-Outer_Depression)*Cos(CoreGapAngle/2 + 1/2 * Angle_Su), (R_Su_Outer-Outer_Depression)*Sin(CoreGapAngle/2 + 1/2 * Angle_Su), 0, LcCyl};
sup2 = newp; Point(sup2) = {R_Su_Outer*Cos(CoreGapAngle/2 + Angle_Su), R_Su_Outer*Sin(CoreGapAngle/2 + Angle_Su), 0, LcCyl};
sup3 = newp; Point(sup3) = {R_Su_Inner*Cos(CoreGapAngle/2 + Angle_Su), R_Su_Inner*Sin(CoreGapAngle/2 + Angle_Su), 0, LcCyl};
sup4 = newp; Point(sup4) = {(R_Su_Inner-Inner_Projection)*Cos(CoreGapAngle/2 + 1/2 * Angle_Su), (R_Su_Inner-Inner_Projection)*Sin(CoreGapAngle/2 + 1/2 * Angle_Su), 0, LcCyl};
sup5 = newp; Point(sup5) = {R_Su_Inner*Cos(CoreGapAngle/2), R_Su_Inner*Sin(CoreGapAngle/2), 0, LcCyl};

sul0 = newl; Spline(sul0) = {sup0,sup1,sup2};
sul1 = newl; Line(sul1) = {sup2,sup3};
sul2 = newl; Spline(sul2) = {sup3,sup4,sup5};
sul3 = newl; Line(sul3) = {sup5,sup0};

sull = newll; Line Loop(sull) = {sul0,sul1,sul2,sul3};

//Cu
cuoutp0 = newp; Point(cuoutp0) = {R_Fe, 0, 0, LcAir};
cuinp = newp; Point(cuinp) = {(R_Fe-Fe_Depression) * Cos(1/2 * (CoreGapAngle+Angle_Su)), (R_Fe-Fe_Depression)*Sin(1/2 * (CoreGapAngle+Angle_Su)), 0, LcAir};
cuoutp1 = newp; Point(cuoutp1) = {R_Fe * Cos(CoreGapAngle+Angle_Su), R_Fe*Sin(CoreGapAngle+Angle_Su), 0, LcAir};

cul = newl; Spline(cul) = {cuoutp0, cuinp, cuoutp1};
cul0 = newl; Line(cul0) = {centerp,cuoutp0};
cul1 = newl; Line(cul1) = {centerp,cuoutp1};
fel0 = newl; Line(fel0) = {cuoutp0,cunip0};
fel1 = newl; Line(fel1) = {cuoutp1,cunip1};

cull = newll; Line Loop(cull) = {cul0,cul,-cul1};
fell = newll; Line Loop(fell) = {fel0,cunil,-fel1,-cul};

infs = news; Plane Surface(infs) = {infll}; //AIR_OUT
airs = news; Plane Surface(airs) = {airll}; //AIR
cunis = news; Plane Surface(cunis) = {cunill}; //CUNI
sus = news; Plane Surface(sus) = {sull}; //SU
fes = news; Plane Surface(fes) = {fell,sull}; //FE
cus = news; Plane Surface(cus) = {cull}; //CU

Periodic Curve {infl1,airl1,cunil1,fel1,cul1} = {infl0,airl0,cunil0,fel0,cul0} Rotate{{0,0,1},{0,0,1},SliceAngle};

Physical Surface("Spherical shell", INF) = {infs};
Physical Surface("Air", AIR) = {airs};
Physical Surface("Ferrium", FE) = {cunis,fes};
Physical Surface("Supper Conductor", SU) = {sus};
Physical Surface("Cupper", CU) = {cus};

Physical Line("Wire boundary", BND_WIRE) = {wirel};
Physical Line("Right Side",R_SIDE) = {infl0,airl0,cunil0,fel0,cul0};
Physical Line("Left Side",L_SIDE) = {infl1,airl1,cunil1,fel1,cul1};

Cohomology(1){{AIR,INF},{}};