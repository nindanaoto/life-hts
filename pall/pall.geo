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
Point(1) = {0, -R_air, 0, LcAir};
Point(2) = {0, -R_inf, 0, LcInf};
Point(3) = {R_air, 0, 0, LcAir};
Point(4) = {R_inf, 0, 0, LcInf};
Point(5) = {0, R_air, 0, LcAir};
Point(6) = {0, R_inf, 0, LcInf};
Point(7) = {-R_air, 0, 0, LcAir};
Point(8) = {-R_inf, 0, 0, LcInf};

Point(17) = {0, -R_Su, 0, LcCyl}; //Su
Point(18) = {R_Su, 0, 0, LcCyl};
Point(19) = {0, R_Su, 0, LcCyl};
Point(20) = {-R_Su, 0, 0, LcCyl};

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

Line Loop(30) = {6, 8, 2, 4}; // Outer shell
Line Loop(31) = {5, 7, 1, 3}; // Air
Line Loop(34) = {17, 18, 19, 20}; // Su

Plane Surface(40) = {30,31}; //AIR_OUT
Plane Surface(41) = {31,34}; //AIR
Plane Surface(44) = {34}; //SU

Physical Surface("Spherical shell", AIR_OUT) = {40};
Physical Surface("Air", AIR) = {41};
Physical Surface("Super Conductor", MATERIAL) = {44};

Physical Line("Exterior boundary", SURF_OUT) = {30};
Physical Line("Super conductor domain outer boundary", BND_MATERIAL) = {34};

Physical Point("Arbitrary Point", ARBITRARY_POINT) = {2};

Cohomology(1){{AIR,AIR_OUT},{}};