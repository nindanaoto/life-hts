// SetFactory("OpenCASCADE");
// Include cross data
Include "Coarsed3dmulticore_data.pro";

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
infp0 = newp; Point(infp0) = {0, -R_inf, 0, LcInf};
infp1 = newp; Point(infp1) = {R_inf, 0, 0, LcInf};
infp2 = newp; Point(infp2) = {0, R_inf, 0, LcInf};
infp3 = newp; Point(infp3) = {-R_inf, 0, 0, LcInf};

infl0 = newl; Circle(infl0) = {infp0, centerp, infp1};
infl1 = newl; Circle(infl1) = {infp1, centerp, infp2};
infl2 = newl; Circle(infl2) = {infp2, centerp, infp3};
infl3 = newl; Circle(infl3) = {infp3, centerp, infp0};

infll = newll; Line Loop(infll) = {infl0, infl1, infl2, infl3};

//Air
airp0 = newp; Point(airp0) = {0, -R_air, 0, LcAir};
airp1 = newp; Point(airp1) = {R_air, 0, 0, LcAir};
airp2 = newp; Point(airp2) = {0, R_air, 0, LcAir};
airp3 = newp; Point(airp3) = {-R_air, 0, 0, LcAir};

airl0 = newl; Circle(airl0) = {airp0, centerp, airp1};
airl1 = newl; Circle(airl1) = {airp1, centerp, airp2};
airl2 = newl; Circle(airl2) = {airp2, centerp, airp3};
airl3 = newl; Circle(airl3) = {airp3, centerp, airp0};

airll = newll; Line Loop(airll) = {airl0, airl1, airl2, airl3};

//Wire
wirep0 = newp; Point(wirep0) = {0, -R_wire, 0, LcAir};
wirep1 = newp; Point(wirep1) = {R_wire, 0, 0, LcAir};
wirep2 = newp; Point(wirep2) = {0, R_wire, 0, LcAir};
wirep3 = newp; Point(wirep3) = {-R_wire, 0, 0, LcAir};

wirel0 = newl; Circle(wirel0) = {wirep0, centerp, wirep1};
wirel1 = newl; Circle(wirel1) = {wirep1, centerp, wirep2};
wirel2 = newl; Circle(wirel2) = {wirep2, centerp, wirep3};
wirel3 = newl; Circle(wirel3) = {wirep3, centerp, wirep0};

wirell = newll; Line Loop(wirell) = {wirel0, wirel1, wirel2, wirel3}; 

//Cu-Ni
cunip0 = newp; Point(cunip0) = {0, -R_CuNi, 0, LcFe};
cunip1 = newp; Point(cunip1) = {R_CuNi, 0, 0, LcFe};
cunip2 = newp; Point(cunip2) = {0, R_CuNi, 0, LcFe};
cunip3 = newp; Point(cunip3) = {-R_CuNi, 0, 0, LcFe};

cunil0 = newl; Circle(cunil0) = {cunip0, centerp, cunip1};
cunil1 = newl; Circle(cunil1) = {cunip1, centerp, cunip2};
cunil2 = newl; Circle(cunil2) = {cunip2, centerp, cunip3};
cunil3 = newl; Circle(cunil3) = {cunip3, centerp, cunip0};

cunill = newll; Line Loop(cunill) = {cunil0, cunil1, cunil2, cunil3}; 

// Su cores
sulls[] = {}; //line loops of filaments
suss[] = {};
For i In {0:(NumCore-1)}
    sup0~{i} = newp; Point(sup0~{i}) = {R_Su_Outer*Cos((2 * i + 1)*CoreGapAngle/2 + i * Angle_Su), R_Su_Outer*Sin((2 * i + 1)*CoreGapAngle/2 + i * Angle_Su), 0, LcCyl};
    sup1~{i} = newp; Point(sup1~{i}) = {(R_Su_Outer-Outer_Depression)*Cos((2 * i + 1)*CoreGapAngle/2 + (i + 1/2) * Angle_Su), (R_Su_Outer-Outer_Depression)*Sin((2 * i + 1)*CoreGapAngle/2 + (i + 1/2) * Angle_Su), 0, LcCyl};
    sup2~{i} = newp; Point(sup2~{i}) = {R_Su_Outer*Cos((2 * i + 1)*CoreGapAngle/2 + (i + 1) * Angle_Su), R_Su_Outer*Sin((2 * i + 1)*CoreGapAngle/2 + (i + 1) * Angle_Su), 0, LcCyl};
    sup3~{i} = newp; Point(sup3~{i}) = {R_Su_Inner*Cos((2 * i + 1)*CoreGapAngle/2 + (i + 1) * Angle_Su), R_Su_Inner*Sin((2 * i + 1)*CoreGapAngle/2 + (i + 1) * Angle_Su), 0, LcCyl};
    sup4~{i} = newp; Point(sup4~{i}) = {(R_Su_Inner-Inner_Projection)*Cos((2 * i + 1)*CoreGapAngle/2 + (i + 1/2) * Angle_Su), (R_Su_Inner-Inner_Projection)*Sin((2 * i + 1)*CoreGapAngle/2 + (i + 1/2) * Angle_Su), 0, LcCyl};
    sup5~{i} = newp; Point(sup5~{i}) = {R_Su_Inner*Cos((2 * i + 1)*CoreGapAngle/2 + i * Angle_Su), R_Su_Inner*Sin((2 * i + 1)*CoreGapAngle/2 + i * Angle_Su), 0, LcCyl};

    sul0~{i} = newl; Spline(sul0~{i}) = {sup0~{i},sup1~{i},sup2~{i}};
    sul1~{i} = newl; Line(sul1~{i}) = {sup2~{i},sup3~{i}};
    sul2~{i} = newl; Spline(sul2~{i}) = {sup3~{i},sup4~{i},sup5~{i}};
    sul3~{i} = newl; Line(sul3~{i}) = {sup5~{i},sup0~{i}};

    sull~{i} = newll; Line Loop(sull~{i}) = {sul0~{i},sul1~{i},sul2~{i},sul3~{i}};
    sulls[] += sull~{i};

    sus~{i} = news; Plane Surface(sus~{i}) = {sull~{i}};
    suss[] += sus~{i};

EndFor

//Fe
feinps[] = {};
feoutps[] = {};
For i In {0:(NumCore-1)}
    feoutp~{i} = newp; Point(feoutp~{i}) = {R_Fe * Cos(i * (CoreGapAngle+Angle_Su)), R_Fe*Sin(i * (CoreGapAngle+Angle_Su)), 0, LcAir};
    feoutps[] += feoutp~{i};
    feinp~{i} = newp; Point(feinp~{i}) = {(R_Fe-Fe_Depression) * Cos((i+1/2) * (CoreGapAngle+Angle_Su)), (R_Fe-Fe_Depression)*Sin((i+1/2) * (CoreGapAngle+Angle_Su)), 0, LcAir};
    feinps[] += feinp~{i};
EndFor


fels[] = {};
For i In {0:(NumCore-2)}
    fel~{i} = newl; Spline(fel~{i}) = {feoutp~{i}, feinp~{i},feoutp~{i+1}};
    fels[] += fel~{i};
EndFor

fel~{NumCore-1} = newl; Spline(fel~{NumCore-1}) = {feoutp~{NumCore-1}, feinp~{NumCore-1},feoutp~{0}};
fels[] += fel~{i};

fell = newll; Line Loop(fell) = {fels[]};

infs = news; Plane Surface(infs) = {infll,airll}; //AIR_OUT
airs = news; Plane Surface(airs) = {airll,wirell}; //AIR
cunis = news; Plane Surface(cunis) = {wirell,cunill}; //CUNI
fes = news; Plane Surface(fes) = {cunill,fell,sulls[]}; //FE
cus = news; Plane Surface(cus) = {fell}; //CU

suends[] = {};
subodys[] = {};
For i In {0:(NumCore-1)}
    suout~{i}[] =  Extrude{{0,0,SlicePitch},{0,0,SlicePitch},{0,0,SlicePitch},SliceAngle}{Surface{sus~{i}};}; 
    suends[] += suout~{i}[0];
    subodys[] += suout~{i}[1];
    affinecos = Cos(SliceAngle);
    affinesin = Sin(SliceAngle);
    affinetx = R_Su_Outer*(Cos((2 * i + 1)*CoreGapAngle/2 + i * Angle_Su) - Cos((2 * (i + 1) + 1)*CoreGapAngle/2 + (i + 1) * Angle_Su));
    affinety = R_Su_Outer*(Sin((2 * i + 1)*CoreGapAngle/2 + i * Angle_Su) - Sin((2 * (i + 1) + 1)*CoreGapAngle/2 + (i + 1) * Angle_Su));
    affinetz = 2*SlicePitch;
    Physical Volume(Sprintf("Super Conductor Core %g",i), FILAMENT0+i) = {suout~{i}[1]};
EndFor
infout[] = Extrude{{0,0,SlicePitch},{0,0,SlicePitch},{0,0,SlicePitch},SliceAngle}{Surface{infs};};
airout[] = Extrude{{0,0,SlicePitch},{0,0,SlicePitch},{0,0,SlicePitch},SliceAngle}{Surface{airs};};
cuniout[] = Extrude{{0,0,SlicePitch},{0,0,SlicePitch},{0,0,SlicePitch},SliceAngle}{Surface{cunis};};
feout[] = Extrude{{0,0,SlicePitch},{0,0,SlicePitch},{0,0,SlicePitch},SliceAngle}{Surface{fes};};
cuout[] = Extrude{{0,0,SlicePitch},{0,0,SlicePitch},{0,0,SlicePitch},SliceAngle}{Surface{cus};};

Physical Volume("Spherical shell", INF) = {infout[1]};
Physical Volume("Air", AIR) = {airout[1]};
Physical Volume("Ferrium", FE) = {cuniout[1],feout[1]};
Physical Volume("Cupper", CU) = {cuout[1]};

// Physical Line("Super conductor domain outer boundary", BND_FILAMENT) = {17, 18, 19, 20};
Printf("boundary surface = %g", cuniout[2]);
Physical Surface("Wire boundary", BND_WIRE) = {cuniout[2],cuniout[3],cuniout[4],cuniout[5]};

Cohomology(1){{AIR,INF},{}};

Mesh 3;

For i In {0:(NumCore-1)}
    Periodic Surface {suout~{i}[0]} = {sus~{i}} Affine {Cos(SliceAngle),-Sin(SliceAngle),0,0, Sin(SliceAngle),Cos(SliceAngle),0,0, 0,0,1,SlicePitch, 0,0,0,1};
EndFor

Periodic Surface {infout[0]} = {infs} Affine {Cos(SliceAngle),-Sin(SliceAngle),0,0, Sin(SliceAngle),Cos(SliceAngle),0,0, 0,0,1,SlicePitch, 0,0,0,1};
Periodic Surface {airout[0]} = {airs} Affine {Cos(SliceAngle),-Sin(SliceAngle),0,0, Sin(SliceAngle),Cos(SliceAngle),0,0, 0,0,1,SlicePitch, 0,0,0,1};
Periodic Surface {cuniout[0]} = {cunis} Affine {Cos(SliceAngle),-Sin(SliceAngle),0,0, Sin(SliceAngle),Cos(SliceAngle),0,0, 0,0,1,SlicePitch, 0,0,0,1};
Periodic Surface {feout[0]} = {fes} Affine {Cos(SliceAngle),-Sin(SliceAngle),0,0, Sin(SliceAngle),Cos(SliceAngle),0,0, 0,0,1,SlicePitch, 0,0,0,1};
Periodic Surface {cuout[0]} = {cus} Affine {Cos(SliceAngle),-Sin(SliceAngle),0,0, Sin(SliceAngle),Cos(SliceAngle),0,0, 0,0,1,SlicePitch, 0,0,0,1};