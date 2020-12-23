SetFactory("OpenCASCADE");
// Include cross data
Include "pall_data.pro";

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
Point(1) = {0, -AirRadius, 0, LcAir};
Point(2) = {0, -InfRadius, 0, LcInf};
Point(3) = {AirRadius, 0, 0, LcAir};
Point(4) = {InfRadius, 0, 0, LcInf};
Point(5) = {0, AirRadius, 0, LcAir};
Point(6) = {0, InfRadius, 0, LcInf};
Point(7) = {-AirRadius, 0, 0, LcAir};
Point(8) = {-InfRadius, 0, 0, LcInf};

Point(17) = {0, -SuRadius, 0, LcCyl}; //Su
Point(18) = {SuRadius, 0, 0, LcCyl};
Point(19) = {0, SuRadius, 0, LcCyl};
Point(20) = {-SuRadius, 0, 0, LcCyl};

Point(21) = {0, -MatrixRadius, 0, LcLayer}; //Transition Layer
Point(22) = {MatrixRadius, 0, 0, LcLayer};
Point(23) = {0, MatrixRadius, 0, LcLayer};
Point(24) = {-MatrixRadius, 0, 0, LcLayer};

Circle(1) = {1, 100, 3};
Circle(2) = {2, 100, 4};
Circle(3) = {3, 100, 5};
Circle(4) = {4, 100, 6};
Circle(5) = {5, 100, 7};
Circle(6) = {6, 100, 8};
Circle(7) = {7, 100, 1};
Circle(8) = {8, 100, 2};

Circle(17) = {17, 100,18}; //Fe2
Circle(18) = {18,100,19}; //Fe2
Circle(19) = {19,100,20}; //Fe2
Circle(20) = {20,100, 17}; //Fe2

Circle(21) = {21, 100,22}; //Su
Circle(22) = {22,100,23}; //Su
Circle(23) = {23,100,24}; //Su
Circle(24) = {24,100, 21}; //Su

Curve Loop(30) = {6, 8, 2, 4}; // Outer shell
Curve Loop(31) = {5, 7, 1, 3}; // Air
Curve Loop(34) = {21, 22, 23, 24}; // Su
Curve Loop(35) = {17, 18, 19, 20}; // Su

Plane Surface(40) = {30,31}; //AIR_OUT
Plane Surface(41) = {31,34}; //AIR
Plane Surface(42) = {34,35}; //Transition Layer
Plane Surface(44) = {35}; //SU

Physical Surface("Spherical shell", INF) = {40};
Physical Surface("Air", AIR) = {41};
Physical Surface("Matrix", MATRIX) = {42};
Physical Surface("Super Conductor", FILAMENT) = {44};

Physical Line("Super conductor domain outer boundary", BND_FILAMENT) = {17, 18, 19, 20};
Physical Line("Matrix boundary", BND_MATRIX) = {21, 22, 23, 24};

Cohomology(1){{AIR,INF},{}};

General.ExpertMode = 1; // Don't complain for hybrid structured/unstructured mesh
Mesh.Algorithm = 6; // Use Frontal 2D algorithm
Mesh.Optimize = 1; // Optimize 3D tet mesh