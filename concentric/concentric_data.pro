// ---- Geometry parameters ----
DefineConstant[
changeGeometry = {0, Choices{0,1}, Name "Input/1Geometry/1Show geometry?"},
R_wire = {0.000337, Visible changeGeometry, Name "Input/1Geometry/Wire radius (m)"}, // Wire radius [m]
R_CuNi = {0.000322, Visible changeGeometry, Name "Input/1Geometry/CuNi radius (m)"}, // Cu-Ni inner radius [m]
R_Fe2 = {0.000261, Visible changeGeometry, Name "Input/1Geometry/Fe2 radius (m)"}, // Fe2 inner radius [m]
R_Su = {0.000216, Visible changeGeometry, Name "Input/1Geometry/Su radius (m)"}, // Su inner radius [m]
R_Fe1 = {0.000157, Visible changeGeometry, Name "Input/1Geometry/Fe1 radius (m)"}, // Fe1 inner radius [m]
R_inf = {0.001, Visible changeGeometry, Name "Input/1Geometry/Outer radius (m)"}, // Outer shell radius [m]
R_air = {0.0007, Max R_inf, Visible changeGeometry, Name "Input/1Geometry/Inner radius (m)"}, // Inner shell radius [m]
W_tape = {216e-6, Max R_air/2, Visible changeGeometry, Name "Input/1Geometry/Cylinder diameter (m)"}, // Width of the tape [m]
H_tape = {216e-6, Max R_air/2, Visible changeGeometry, Name "Input/1Geometry/Bottom cylinder height (m)"}, // Height of the tape [m]
meshLayerWidthTape = {0.001} // Width of the control mesh layer around the cylinder
];

// ---- Mesh parameters ----
DefineConstant [meshMult = {0.1, Name "Input/2Mesh/1Mesh size multiplier (-)"}]; // Multiplier [-] of a default mesh size distribution

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
FE1 = 23002;
SU = 23003;
FE2 = 23004;
CU = 23005;
BND_MATERIAL = 25000;
BND_SU_OUTER = 25001;
BND_SU_INNER = 25002;
BND_MATERIAL_SIDE = 26000;
CUT = 23006;