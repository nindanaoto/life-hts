// ---- Geometry parameters ----
DefineConstant[
changeGeometry = {0, Choices{0,1}, Name "Input/1Geometry/1Show geometry?"},
R_inf = {0.06, Visible changeGeometry, Name "Input/1Geometry/Outer radius (m)"}, // Outer shell radius [m]
R_air = {0.04, Max R_inf, Visible changeGeometry, Name "Input/1Geometry/Inner radius (m)"}, // Inner shell radius [m]
W_tape = {12e-3, Max R_air/2, Visible changeGeometry, Name "Input/1Geometry/Cylinder diameter (m)"}, // Width of the tape [m]
H_tape = {1e-6, Max R_air/2, Visible changeGeometry, Name "Input/1Geometry/Bottom cylinder height (m)"}, // Height of the tape [m]
meshLayerWidthTape = {0.001} // Width of the control mesh layer around the cylinder
];

// ---- Mesh parameters ----
DefineConstant [meshMult = {4, Name "Input/2Mesh/1Mesh size multiplier (-)"}]; // Multiplier [-] of a default mesh size distribution

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
BND_MATERIAL = 25000;
BND_MATERIAL_SIDE = 26000;
CUT = 26001;
RIGHT = 23001;
LEFT = 23002;
RIGHT_SURF_OUT = 14001;