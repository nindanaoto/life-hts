// ---- Geometry parameters ----
R_air = 0.07; // Inner shell radius [m]
R_inf = 0.1; // Outer shell radius [m]
W = 0.025; // Diameter of the cylinder [m]
H_cylinder = 0.01; // Height of the cylinder [m]
meshLayerWidth = 0.005; // Height of tape 2 [m]
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
