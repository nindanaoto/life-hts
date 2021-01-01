SetFactory("OpenCASCADE");
// Include cross data
Include "cube_data.pro";

// Geometrical and meshing parameters
DefineConstant [LcCube = meshMult*0.0003]; // Mesh size in cylinder [m]
DefineConstant [LcAir = meshMult*0.005]; // Mesh size in cylinder [m]

materialVol = 123;
Block(materialVol) = {0, 0, 0, a/2, a/2, a/2};

f_c() = Boundary{Volume{materialVol};};
l_c() = Boundary{Surface{f_c()};};
p_c() = PointsOf{Line{l_c()};};
Characteristic Length{p_c()} = LcCube;

Transfinite Surface(1);
Transfinite Surface(2);
Transfinite Surface(3);
Transfinite Surface(4);
Transfinite Surface(5);
Transfinite Surface(6);
Transfinite Volume(materialVol);
//*
Recombine Surface(1);
Recombine Surface(2);
Recombine Surface(3);
Recombine Surface(4);
Recombine Surface(5);
Recombine Surface(6);
// */

//Block(2) = {-R_inf, -R_inf, -R_inf, 2*R_inf, 2*R_inf, 2*R_inf};
Sphere(2) = {0, 0, 0, R_inf, 0, Pi/2, Pi/2};
f_s() = Boundary{Volume{2};};
l_s() = Boundary{Surface{f_s()};};
p_s() = PointsOf{Line{l_s()};};
Characteristic Length{p_s()} = LcAir;

//Surface Loop(111) = {1, 2, 4, 3, 5, 6};
//Surface Loop(112) = {7};
//Volume(101) = {111};
//volAir = Volume(101);
volAir = BooleanDifference{ Volume{2}; Delete; }{ Volume{materialVol};};


Physical Volume("Material", MATERIAL) = {materialVol};
Physical Volume("Air", AIR) = {volAir};
Physical Surface("Boundary material", BND_MATERIAL) = {f_c(1), f_c(3), f_c(5)};
Physical Surface("Boundary air", SURF_OUT) = {f_s(0)};
Physical Surface("Symmetry h cross n = 0", SURF_SYM_ht0) = {f_s(2)};
Physical Surface("Symmetry b x n = 0", SURF_SYM_bn0) = {f_s(1), f_s(3)};
Physical Surface("Symmetry h cross n = 0, material", SURF_SYM_MAT_ht0) = {f_c(4)};
Physical Surface("Symmetry b x n = 0, material", SURF_SYM_MAT_bn0) = {f_c(2), f_c(0)};
