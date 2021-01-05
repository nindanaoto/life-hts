// ---- Geometry parameters ----
DefineConstant[
changeGeometry = {0, Choices{0,1}, Name "Input/1Geometry/1Show geometry?"},
R_wire = {0.000337, Visible changeGeometry, Name "Input/1Geometry/Wire radius (m)"}, // Wire radius [m]
R_CuNi = {0.000322, Visible changeGeometry, Name "Input/1Geometry/CuNi radius (m)"}, // Cu-Ni inner radius [m]
R_Su_Outer = {0.000261, Visible changeGeometry, Name "Input/1Geometry/Su outer radius (m)"}, // Fe2 inner radius [m]
R_Su_Inner = {0.000216, Visible changeGeometry, Name "Input/1Geometry/Su inner radius (m)"}, // Su inner radius [m]
R_Fe = {0.000157, Visible changeGeometry, Name "Input/1Geometry/Fe radius (m)"}, // Fe1 inner radius [m]
R_inf = {0.001, Visible changeGeometry, Name "Input/1Geometry/Outer radius (m)"}, // Outer shell radius [m]
R_air = {0.0007, Max R_inf, Visible changeGeometry, Name "Input/1Geometry/Inner radius (m)"}, // Inner shell radius [m]
Angle_Su = {0.55, Visible changeGeometry, Name "Input/1Geometry/Su angle (rad)"}, //Angle of Su block [rad]
W_tape = {12e-3, Max R_air/2, Visible changeGeometry, Name "Input/1Geometry/Cylinder diameter (m)"}, // Width of the tape [m]
H_tape = {1e-6, Max R_air/2, Visible changeGeometry, Name "Input/1Geometry/Bottom cylinder height (m)"}, // Height of the tape [m]
meshLayerWidthTape = {0.001} // Width of the control mesh layer around the cylinder
];

// ---- Mesh parameters ----
DefineConstant [meshMult = {0.04, Name "Input/2Mesh/1Mesh size multiplier (-)"}]; // Multiplier [-] of a default mesh size distribution

// ---- Formulation definitions (dummy values) ----
h_formulation = 2;
a_formulation = 6;
coupled_formulation = 5;

// ---- Constant definition for regions ----
AIR = 1000;
AIR_OUT = 2000;
SURF_SHELL = 3000;
ARBITRARY_POINT = 11000;
SURF_SYM = 13000;
SURF_SYM_MAT = 13500;
SURF_OUT = 14000;
MATERIAL = 23000;
CUNI = 23001;
FE = 23002;
CU = 23003;
SU0 = 23010;
SU1 = 23011;
SU2 = 23012;
SU3 = 23013;
SU4 = 23014;
SU5 = 23015;
SU6 = 23016;
SU7 = 23017;
SU8 = 23018;
SU9 = 23019;
BND_MATERIAL = 25000;
BND_MATERIAL_SIDE = 26000;
CUT = 26001;