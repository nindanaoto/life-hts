// ---- Geometry parameters ----
DefineConstant[
changeGeometry = {0, Choices{0,1}, Name "Input/1Geometry/1Show geometry?"},
SuRadius = {1e-4, Visible changeGeometry, Name "Input/1Geometry/Su radius (m)"}, // Su radius [m]
MatrixRadius = {1.1e-4, Visible changeGeometry, Name "Input/1Geometry/Matrix radius (m)"}, // S radius [m]
InfRadius = {4e-4, Visible changeGeometry, Name "Input/1Geometry/Infinity radius (m)"}, // Air radius [m]
AirRadius = { 3e-4, Max InfRadius, Visible changeGeometry, Name "Input/1Geometry/Air radius (m)"}, // Inner shell radius [m]
ConductingMatrix = {1},
meshLayerWidthTape = {0.001} // Width of the control mesh layer around the cylinder
];

// ---- Mesh parameters ----
DefineConstant [meshMult = {0.03, Name "Input/2Mesh/1Mesh size multiplier (-)"}]; // Multiplier [-] of a default mesh size distribution

// ---- Constant definition for regions ----
AIR = 1000;
INF = 2000;
MATRIX = 3000;
FILAMENT = 23000;
BND_FILAMENT = 25001;
BND_MATRIX = 25002;
CUT = 25003;