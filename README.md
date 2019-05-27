# Life-HTS
Liège university Finite Element models for High-Temperature Superconductors - 2019

http://www.life-hts.uliege.be

## Description

This project contains files for modeling systems containing high-temperature superconductors (HTS) with the GetDP software (http://getdp.info/), using Gmsh as mesh generator (http://gmsh.info/).

Features:
* Power law model for HTS.
* Simple anhysteretic model for soft ferromagnetic materials (FM).
* Two dual formulations (h-conform and b-conform) in 1D, 2D and 3D.
* A coupled formulation for systems with HTS and FM.

Models:
* Bulk cylindrical HTS subjected to an external field parallel to its axis (2D axisymmetric).
* Thin HTS tape with imposed current intensity (2D).
* Bulk cube HTS subjected to an external field along a principal direction (3D).
* Stacked bulk cylinders: HTS with FM on top of it, subjected to an external field parallel to their axis (2D axisymmetric).


A complete description of the models can be found in the following paper:
* (To be completed when published)

## Run a simulation

* Download and install current versions of GetDP and Gmsh (see http://getdp.info/ and http://gmsh.info/ for full instructions). Below, it is assumed that these programs can be launched from the command line using `getdp` and `gmsh` (with aliases).

* Clone or download this repository.

* Choose a model, enter the corresponding directory. Run Gmsh for meshing and GetDP for resolution. Below, an example is given for the `cylinder` problem:

```
gmsh cylinder.geo -2
getdp cylinder -solve MagDyn -verbose 3
getdp cylinder -pos MagDyn -verbose 3
gmsh res/b.pos
```
The first command generates a mesh of dimension 2 (the cylinder model is axisymmetric). To mesh the cube geometry, the command is thus `gmsh cube.geo -3`.

The second command performs the time integration and the third command processes the results to generate output files (the verbosity level 3 will give information about each nonlinear iteration within each time step, it can be decreased if less information is needed).

As an example, the last command will open the output file containing the magnetic flux density distribution in the Gmsh interface.
