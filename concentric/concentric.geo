SetFactory("OpenCASCADE");
// Include cross data
Include "concentric_data.pro";

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

Point(17) = {0, -R_Fe2, 0, LcCyl}; //Fe2
Point(18) = {R_Fe2, 0, 0, LcCyl};
Point(19) = {0, R_Fe2, 0, LcCyl};
Point(20) = {-R_Fe2, 0, 0, LcCyl};

Point(21) = {0, -R_Su, 0, LcCyl}; //Su
Point(22) = {R_Su, 0, 0, LcCyl};
Point(23) = {0, R_Su, 0, LcCyl};
Point(24) = {-R_Su, 0, 0, LcCyl};

Point(25) = {0, -R_Fe1, 0, LcCyl}; //Fe1
Point(26) = {R_Fe1, 0, 0, LcCyl};
Point(27) = {0, R_Fe1, 0, LcCyl};
Point(28) = {-R_Fe1, 0, 0, LcCyl};

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

Circle(17) = {17, 100,18}; //Fe2
Circle(18) = {18,100,19}; //Fe2
Circle(19) = {19,100,20}; //Fe2
Circle(20) = {20,100, 17}; //Fe2

Circle(21) = {21, 100,22}; //Su
Circle(22) = {22,100,23}; //Su
Circle(23) = {23,100,24}; //Su
Circle(24) = {24,100, 21}; //Su

Circle(25) = {25, 100,26}; //Fe1
Circle(26) = {26,100,27}; //Fe1
Circle(27) = {27,100,28}; //Fe1
Circle(28) = {28,100, 25}; //Fe1

Line Loop(30) = {6, 8, 2, 4}; // Outer shell
Line Loop(31) = {5, 7, 1, 3}; // Air
Line Loop(32) = {9, 10, 11, 12}; // Wire
Line Loop(33) = {13, 14, 15, 16}; // Cu-Ni
Line Loop(34) = {17, 18, 19, 20}; // Fe2
Line Loop(35) = {21, 22, 23, 24}; // Su
Line Loop(36) = {25, 26, 27, 28}; // Fe1

Plane Surface(40) = {30,31}; //AIR_OUT
Plane Surface(41) = {31,32}; //AIR
Plane Surface(42) = {32,33}; //CUNI
Plane Surface(43) = {33,34}; //FE2
Plane Surface(44) = {34,35}; //SU
Plane Surface(45) = {35,36}; //FE1
Plane Surface(46) = {36}; //CU

Physical Surface("Spherical shell", AIR_OUT) = {40};
Physical Surface("Air", AIR) = {41};
Physical Surface("Cu-Ni", CUNI) = {42};
Physical Surface("Fe 2nd", FE2) = {43};
Physical Surface("Super Conductor", SU) = {44};
Physical Surface("Fe 1st", FE1) = {45};
Physical Surface("Cu", CU) = {46};