SetFactory("OpenCASCADE");
// Include cross data
Include "multicore_data.pro";

// Interactive settings
//R = W/2; // Radius
// Mesh size
DefineConstant [meshFactor = {10, Name "Input/2Mesh/2Coarsening factor at infinity (-)"}];
DefineConstant [LcCyl = meshMult*0.0003]; // Mesh size in cylinder [m]
DefineConstant [LcLayer = LcCyl]; // Mesh size in the region close to the cylinder [m]
DefineConstant [LcWire = meshFactor*LcCyl]; // Mesh size in wire [m]
DefineConstant [LcAir = meshFactor*LcCyl]; // Mesh size in air shell [m]
DefineConstant [LcInf = meshFactor*LcCyl]; // Mesh size in external air shell [m]
DefineConstant [transfiniteQuadrangular = {0, Choices{0,1}, Name "Input/2Mesh/3Regular quadrangular mesh?"}];
DefineConstant [NumCore = 10];
DefineConstant [CoreGapAngle = 2*Pi/NumCore - Angle_Su];

Point(100) = {0, 0, 0, LcCyl};
Point(1) = {0, -R_air, 0, LcAir};
Point(2) = {0, -R_inf, 0, LcInf};
Point(3) = {R_air, 0, 0, LcAir};
Point(4) = {R_inf, 0, 0, LcInf};
Point(5) = {0, R_air, 0, LcAir};
Point(6) = {0, R_inf, 0, LcInf};
Point(7) = {-R_air, 0, 0, LcAir};
Point(8) = {-R_inf, 0, 0, LcInf};

Point(9) = {0, -R_wire, 0, LcCyl}; //wire
Point(10) = {R_wire, 0, 0, LcCyl};
Point(11) = {0, R_wire, 0, LcCyl};
Point(12) = {-R_wire, 0, 0, LcCyl};

Point(13) = {0, -R_CuNi, 0, LcCyl}; //Cu-Ni
Point(14) = {R_CuNi, 0, 0, LcCyl};
Point(15) = {0, R_CuNi, 0, LcCyl};
Point(16) = {-R_CuNi, 0, 0, LcCyl};

// Point(17) = {0, -R_Fe2, 0, LcCyl}; //Fe2
// Point(18) = {R_Fe2, 0, 0, LcCyl};
// Point(19) = {0, R_Fe2, 0, LcCyl};
// Point(20) = {-R_Fe2, 0, 0, LcCyl};

// Su cores
Point(31) = {R_Su_Outer*Cos(CoreGapAngle/2), R_Su_Outer*Sin(CoreGapAngle/2), 0, LcCyl};
Point(32) = {R_Su_Outer*Cos(CoreGapAngle/2+Angle_Su), R_Su_Outer*Sin(CoreGapAngle/2+Angle_Su), 0, LcCyl};
Point(33) = {R_Su_Inner*Cos(CoreGapAngle/2+Angle_Su), R_Su_Inner*Sin(CoreGapAngle/2+Angle_Su), 0, LcCyl};
Point(34) = {R_Su_Inner*Cos(CoreGapAngle/2), R_Su_Inner*Sin(CoreGapAngle/2), 0, LcCyl};

Point(35) = {R_Su_Outer*Cos(CoreGapAngle*3/2+Angle_Su), R_Su_Outer*Sin(CoreGapAngle*3/2+Angle_Su), 0, LcCyl};
Point(36) = {R_Su_Outer*Cos(CoreGapAngle*3/2+Angle_Su*2), R_Su_Outer*Sin(CoreGapAngle*3/2+Angle_Su*2), 0, LcCyl};
Point(37) = {R_Su_Inner*Cos(CoreGapAngle*3/2+Angle_Su*2), R_Su_Inner*Sin(CoreGapAngle*3/2+Angle_Su*2), 0, LcCyl};
Point(38) = {R_Su_Inner*Cos(CoreGapAngle*3/2+Angle_Su), R_Su_Inner*Sin(CoreGapAngle*3/2+Angle_Su), 0, LcCyl};

Point(39) = {R_Su_Outer*Cos(CoreGapAngle*5/2+Angle_Su*2), R_Su_Outer*Sin(CoreGapAngle*5/2+Angle_Su*2), 0, LcCyl};
Point(40) = {R_Su_Outer*Cos(CoreGapAngle*5/2+Angle_Su*3), R_Su_Outer*Sin(CoreGapAngle*5/2+Angle_Su*3), 0, LcCyl};
Point(41) = {R_Su_Inner*Cos(CoreGapAngle*5/2+Angle_Su*3), R_Su_Inner*Sin(CoreGapAngle*5/2+Angle_Su*3), 0, LcCyl};
Point(42) = {R_Su_Inner*Cos(CoreGapAngle*5/2+Angle_Su*2), R_Su_Inner*Sin(CoreGapAngle*5/2+Angle_Su*2), 0, LcCyl};

Point(43) = {R_Su_Outer*Cos(CoreGapAngle*7/2+Angle_Su*3), R_Su_Outer*Sin(CoreGapAngle*7/2+Angle_Su*3), 0, LcCyl};
Point(44) = {R_Su_Outer*Cos(CoreGapAngle*7/2+Angle_Su*4), R_Su_Outer*Sin(CoreGapAngle*7/2+Angle_Su*4), 0, LcCyl};
Point(45) = {R_Su_Inner*Cos(CoreGapAngle*7/2+Angle_Su*4), R_Su_Inner*Sin(CoreGapAngle*7/2+Angle_Su*4), 0, LcCyl};
Point(46) = {R_Su_Inner*Cos(CoreGapAngle*7/2+Angle_Su*3), R_Su_Inner*Sin(CoreGapAngle*7/2+Angle_Su*3), 0, LcCyl};

Point(47) = {R_Su_Outer*Cos(CoreGapAngle*9/2+Angle_Su*4), R_Su_Outer*Sin(CoreGapAngle*9/2+Angle_Su*4), 0, LcCyl};
Point(48) = {R_Su_Outer*Cos(CoreGapAngle*9/2+Angle_Su*5), R_Su_Outer*Sin(CoreGapAngle*9/2+Angle_Su*5), 0, LcCyl};
Point(49) = {R_Su_Inner*Cos(CoreGapAngle*9/2+Angle_Su*5), R_Su_Inner*Sin(CoreGapAngle*9/2+Angle_Su*5), 0, LcCyl};
Point(50) = {R_Su_Inner*Cos(CoreGapAngle*9/2+Angle_Su*4), R_Su_Inner*Sin(CoreGapAngle*9/2+Angle_Su*4), 0, LcCyl};

Point(51) = {R_Su_Outer*Cos(CoreGapAngle/2), R_Su_Outer*-Sin(CoreGapAngle/2), 0, LcCyl};
Point(52) = {R_Su_Outer*Cos(CoreGapAngle/2+Angle_Su), R_Su_Outer*-Sin(CoreGapAngle/2+Angle_Su), 0, LcCyl};
Point(53) = {R_Su_Inner*Cos(CoreGapAngle/2+Angle_Su), R_Su_Inner*-Sin(CoreGapAngle/2+Angle_Su), 0, LcCyl};
Point(54) = {R_Su_Inner*Cos(CoreGapAngle/2), R_Su_Inner*-Sin(CoreGapAngle/2), 0, LcCyl};

Point(55) = {R_Su_Outer*Cos(CoreGapAngle*3/2+Angle_Su), R_Su_Outer*-Sin(CoreGapAngle*3/2+Angle_Su), 0, LcCyl};
Point(56) = {R_Su_Outer*Cos(CoreGapAngle*3/2+Angle_Su*2), R_Su_Outer*-Sin(CoreGapAngle*3/2+Angle_Su*2), 0, LcCyl};
Point(57) = {R_Su_Inner*Cos(CoreGapAngle*3/2+Angle_Su*2), R_Su_Inner*-Sin(CoreGapAngle*3/2+Angle_Su*2), 0, LcCyl};
Point(58) = {R_Su_Inner*Cos(CoreGapAngle*3/2+Angle_Su), R_Su_Inner*-Sin(CoreGapAngle*3/2+Angle_Su), 0, LcCyl};

Point(59) = {R_Su_Outer*Cos(CoreGapAngle*5/2+Angle_Su*2), R_Su_Outer*-Sin(CoreGapAngle*5/2+Angle_Su*2), 0, LcCyl};
Point(60) = {R_Su_Outer*Cos(CoreGapAngle*5/2+Angle_Su*3), R_Su_Outer*-Sin(CoreGapAngle*5/2+Angle_Su*3), 0, LcCyl};
Point(61) = {R_Su_Inner*Cos(CoreGapAngle*5/2+Angle_Su*3), R_Su_Inner*-Sin(CoreGapAngle*5/2+Angle_Su*3), 0, LcCyl};
Point(62) = {R_Su_Inner*Cos(CoreGapAngle*5/2+Angle_Su*2), R_Su_Inner*-Sin(CoreGapAngle*5/2+Angle_Su*2), 0, LcCyl};

Point(63) = {R_Su_Outer*Cos(CoreGapAngle*7/2+Angle_Su*3), R_Su_Outer*-Sin(CoreGapAngle*7/2+Angle_Su*3), 0, LcCyl};
Point(64) = {R_Su_Outer*Cos(CoreGapAngle*7/2+Angle_Su*4), R_Su_Outer*-Sin(CoreGapAngle*7/2+Angle_Su*4), 0, LcCyl};
Point(65) = {R_Su_Inner*Cos(CoreGapAngle*7/2+Angle_Su*4), R_Su_Inner*-Sin(CoreGapAngle*7/2+Angle_Su*4), 0, LcCyl};
Point(66) = {R_Su_Inner*Cos(CoreGapAngle*7/2+Angle_Su*3), R_Su_Inner*-Sin(CoreGapAngle*7/2+Angle_Su*3), 0, LcCyl};

Point(67) = {R_Su_Outer*Cos(CoreGapAngle*9/2+Angle_Su*4), R_Su_Outer*-Sin(CoreGapAngle*9/2+Angle_Su*4), 0, LcCyl};
Point(68) = {R_Su_Outer*Cos(CoreGapAngle*9/2+Angle_Su*5), R_Su_Outer*-Sin(CoreGapAngle*9/2+Angle_Su*5), 0, LcCyl};
Point(69) = {R_Su_Inner*Cos(CoreGapAngle*9/2+Angle_Su*5), R_Su_Inner*-Sin(CoreGapAngle*9/2+Angle_Su*5), 0, LcCyl};
Point(70) = {R_Su_Inner*Cos(CoreGapAngle*9/2+Angle_Su*4), R_Su_Inner*-Sin(CoreGapAngle*9/2+Angle_Su*4), 0, LcCyl};


Point(25) = {0, -R_Fe, 0, LcCyl}; //Fe1
Point(26) = {R_Fe, 0, 0, LcCyl};
Point(27) = {0, R_Fe, 0, LcCyl};
Point(28) = {-R_Fe, 0, 0, LcCyl};

Circle(1) = {1, 100, 3};
Circle(2) = {2, 100, 4};
Circle(3) = {3, 100, 5};
Circle(4) = {4, 100, 6};
Circle(5) = {5, 100, 7};
Circle(6) = {6, 100, 8};
Circle(7) = {7, 100, 1};
Circle(8) = {8, 100, 2};

Circle(9) = {9, 100,10}; //wires
Circle(10) = {10,100,11}; //wires
Circle(11) = {11,100,12}; //wires
Circle(12) = {12,100, 9}; //wires

Circle(13) = {13, 100,14}; //Cu-Ni
Circle(14) = {14,100,15}; //Cu-Ni
Circle(15) = {15,100,16}; //Cu-Ni
Circle(16) = {16,100, 13}; //Cu-Ni

// Circle(17) = {17, 100,18}; //Fe2
// Circle(18) = {18,100,19}; //Fe2
// Circle(19) = {19,100,20}; //Fe2
// Circle(20) = {20,100, 17}; //Fe2

// Circle(21) = {21, 100,22}; //Su
// Circle(22) = {22,100,23}; //Su
// Circle(23) = {23,100,24}; //Su
// Circle(24) = {24,100, 21}; //Su

Line(31) = {31,32};
Line(32) = {32,33};
Line(33) = {33,34};
Line(34) = {34,31};
Line(35) = {35,36};
Line(36) = {36,37};
Line(37) = {37,38};
Line(38) = {38,35};
Line(39) = {39,40};
Line(40) = {40,41};
Line(41) = {41,42};
Line(42) = {42,39};
Line(43) = {43,44};
Line(44) = {44,45};
Line(45) = {45,46};
Line(46) = {46,43};
Line(47) = {47,48};
Line(48) = {48,49};
Line(49) = {49,50};
Line(50) = {50,47};
Line(51) = {51,52};
Line(52) = {52,53};
Line(53) = {53,54};
Line(54) = {54,51};
Line(55) = {55,56};
Line(56) = {56,57};
Line(57) = {57,58};
Line(58) = {58,55};
Line(59) = {59,60};
Line(60) = {60,61};
Line(61) = {61,62};
Line(62) = {62,59};
Line(63) = {63,64};
Line(64) = {64,65};
Line(65) = {65,66};
Line(66) = {66,63};
Line(67) = {67,68};
Line(68) = {68,69};
Line(69) = {69,70};
Line(70) = {70,67};

Circle(25) = {25, 100,26}; //Fe
Circle(26) = {26,100,27}; //Fe
Circle(27) = {27,100,28}; //Fe
Circle(28) = {28,100, 25}; //Fe

Line Loop(30) = {6, 8, 2, 4}; // Outer shell
Line Loop(31) = {5, 7, 1, 3}; // Air
Line Loop(32) = {9, 10, 11, 12}; // Wire
Line Loop(33) = {13, 14, 15, 16}; // Cu-Ni
// Line Loop(34) = {17, 18, 19, 20}; // Fe2
Line Loop(36) = {25, 26, 27, 28}; // Fe

//Su cores
Line Loop(50) = {31,32,33,34};
Line Loop(51) = {35,36,37,38};
Line Loop(52) = {39,40,41,42};
Line Loop(53) = {43,44,45,46};
Line Loop(54) = {47,48,49,50};
Line Loop(55) = {51,52,53,54};
Line Loop(56) = {55,56,57,58};
Line Loop(57) = {59,60,61,62};
Line Loop(58) = {63,64,65,66};
Line Loop(59) = {67,68,69,70};

Plane Surface(40) = {30,31}; //AIR_OUT
Plane Surface(41) = {31,32}; //AIR
Plane Surface(42) = {32,33}; //CUNI
Plane Surface(43) = {33,36,50,51,52,53,54,55,56,57,58,59}; //FE
Plane Surface(46) = {36}; //CU

Plane Surface(50) = {50};
Plane Surface(51) = {51};
Plane Surface(52) = {52};
Plane Surface(53) = {53};
Plane Surface(54) = {54};
Plane Surface(55) = {55};
Plane Surface(56) = {56};
Plane Surface(57) = {57};
Plane Surface(58) = {58};
Plane Surface(59) = {59};

Physical Surface("Spherical shell", AIR_OUT) = {40};
Physical Surface("Air", AIR) = {41};
Physical Surface("Cu-Ni", CUNI) = {42};
Physical Surface("Fe", FE) = {43};
Physical Surface("Super Conductor Core 0", SU0) = {50};
Physical Surface("Super Conductor Core 1", SU1) = {51};
Physical Surface("Super Conductor Core 2", SU2) = {52};
Physical Surface("Super Conductor Core 3", SU3) = {53};
Physical Surface("Super Conductor Core 4", SU4) = {54};
Physical Surface("Super Conductor Core 5", SU5) = {55};
Physical Surface("Super Conductor Core 6", SU6) = {56};
Physical Surface("Super Conductor Core 7", SU7) = {57};
Physical Surface("Super Conductor Core 8", SU8) = {58};
Physical Surface("Super Conductor Core 9", SU9) = {59};
Physical Surface("Cu", CU) = {46};

Cohomology(1){{AIR,AIR_OUT,FE,CUNI,CU,SU1,SU2,SU3,SU4,SU5,SU6,SU7,SU8,SU9},{CU}};
Cohomology(1){{AIR,AIR_OUT,FE,CUNI,CU,SU0,SU2,SU3,SU4,SU5,SU6,SU7,SU8,SU9},{CU}};
Cohomology(1){{AIR,AIR_OUT,FE,CUNI,CU,SU0,SU1,SU3,SU4,SU5,SU6,SU7,SU8,SU9},{CU}};
Cohomology(1){{AIR,AIR_OUT,FE,CUNI,CU,SU0,SU1,SU2,SU4,SU5,SU6,SU7,SU8,SU9},{CU}};
Cohomology(1){{AIR,AIR_OUT,FE,CUNI,CU,SU0,SU1,SU2,SU3,SU5,SU6,SU7,SU8,SU9},{CU}};
Cohomology(1){{AIR,AIR_OUT,FE,CUNI,CU,SU0,SU1,SU2,SU3,SU4,SU6,SU7,SU8,SU9},{CU}};
Cohomology(1){{AIR,AIR_OUT,FE,CUNI,CU,SU0,SU1,SU2,SU3,SU4,SU5,SU7,SU8,SU9},{CU}};
Cohomology(1){{AIR,AIR_OUT,FE,CUNI,CU,SU0,SU1,SU2,SU3,SU4,SU5,SU6,SU8,SU9},{CU}};
Cohomology(1){{AIR,AIR_OUT,FE,CUNI,CU,SU0,SU1,SU2,SU3,SU4,SU5,SU6,SU7,SU9},{CU}};
Cohomology(1){{AIR,AIR_OUT,FE,CUNI,CU,SU0,SU1,SU2,SU3,SU4,SU5,SU6,SU7,SU8},{CU}};