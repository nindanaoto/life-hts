// ---- Geometry parameters ----
R_air = 0.04; // Inner shell radius [m]
R_inf = 0.06; // Outer shell radius [m]
W_tape = 12e-3; // Width of the tape [m]
H_tape = 1e-6; // Height of the tape [m]
meshLayerWidthTape = 0.001; // Height of tape 2 [m]
// ---- Mesh parameters ----
DefineConstant [meshMult = 4]; // Multiplier [-] of a default mesh size distribution

// ---- Formulation definitions (dummy values) ----
h_formulation = 2;
a_formulation = 6;
coupled_formulation = 5;

// ---- Constant definition for regions ----
AIR = 1000;
AIR_OUT = 2000;
SURF_SHELL = 3000;
CUT = 9000;
ARBITRARY_POINT = 11000;
SURF_SYM = 13000;
SURF_SYM_MAT = 13500;
SURF_OUT = 14000;
MATERIAL = 23000;
BND_MATERIAL = 25000;
BND_MATERIAL_SIDE = 26000;
