// ---- Geometry parameters ----
DefineConstant[
changeGeometry = {0, Choices{0,1}, Name "Input/1Geometry/1Show geometry?"},
Pitch = {2e-3, Visible changeGeometry, Name "Input/1Geometry/Twist pitch (m)"},
R_wire = {0.000337, Visible changeGeometry, Name "Input/1Geometry/Wire radius (m)"}, 
R_CuNi = {0.000322, Visible changeGeometry, Name "Input/1Geometry/CuNi radius (m)"}, 
R_Su_Outer = {0.000261, Visible changeGeometry, Name "Input/1Geometry/Su outer radius (m)"}, 
R_Su_Inner = {0.000216, Visible changeGeometry, Name "Input/1Geometry/Su inner radius (m)"}, 
R_Fe = {0.000157, Visible changeGeometry, Name "Input/1Geometry/Fe radius (m)"}, 
R_inf = {0.001, Visible changeGeometry, Name "Input/1Geometry/Outer radius (m)"}, 
R_air = {0.0007, Max R_inf, Visible changeGeometry, Name "Input/1Geometry/Inner radius (m)"}, 
Angle_Su = {0.55, Visible changeGeometry, Name "Input/1Geometry/Su angle (rad)"}, 
Outer_Depression = {20e-6, Visible changeGeometry, Name "Input/1Geometry/Oute depression length (m)"}, 
Inner_Projection = {25e-6, Visible changeGeometry, Name "Input/1Geometry/Inner projection length (m)"}, 
Fe_Depression = {27e-6, Visible changeGeometry, Name "Input/1Geometry/Ferrite depression length (m)"}
ConductingMatrix = {1},
meshLayerWidthTape = {0.001} // Width of the control mesh layer around the cylinder
];

// ---- Mesh parameters ----
DefineConstant [meshMult = {0.03, Name "Input/2Mesh/1Mesh size multiplier (-)"}]; // Multiplier [-] of a default mesh size distribution

// ---- Constant definition for regions ----
AIR = 1000;
INF = 2000;
MATRIX = 3000;
FILAMENT0 = 23000;
FILAMENT1 = 23001;
FILAMENT2 = 23002;
FILAMENT3 = 23003;
FILAMENT4 = 23004;
FILAMENT5 = 23005;
FILAMENT6 = 23006;
FILAMENT7 = 23007;
FILAMENT8 = 23008;
FILAMENT9 = 23009;
FE = 23010;
CU = 23011;
BND_WIRE = 25002;
CUT = 25003;