# Life-HTS
Liège university Finite Element models for High-Temperature Superconductors - 2019

## Description

This project contains files for modeling systems containing high-temperature superconductors (HTS) with the GetDP software (http://getdp.info/), using Gmsh as mesh generator (http://gmsh.info/).

Features:
* Power law model for HTS,
* Simple anhysteretic model for soft ferromagnetic materials (FM),
* Two dual formulations (h-conform and b-conform) in 1D, 2D and 3D,
* A coupled formulation for systems with HTS and FM.

A complete description of the models can be found in the following paper:
* (To be completed)

## Run a simulation

* Download and install current versions of GetDP and Gmsh (see http://getdp.info/ and http://gmsh.info/ for full instructions). Below, it is assumed that these programs can be launched from the command line using `getdp` and `gmsh`. With Unix or Mac OS, you can create aliases in the `.bash_profile` file:
```
alias getdp='/Applications/getdp'
alias gmsh='/Applications/Gmsh.app/Contents/MacOS/gmsh'
```

* Clone or download this repository.

* Choose a model and enter the corresponding directory (example below: cylinder) and run the following commands:

```
gmsh cylinder.geo -2
getdp cylinder -solve MagDyn -verbose 3
getdp cylinder -pos MagDyn -verbose 3
gmsh res/b.pos
```
The first command generates a mesh of dimension 2 (the cylinder model is axisymmetric). To mesh the cube geometry, the command is thus `gmsh cube.geo -3`.

The second command performs the time integration and the third command processes the results to generate output files (the verbosity level 3 will give information about each nonlinear iteration within each time step, it can be decreased if less information is needed).

As an example, the last command will open the output file containing the magnetic flux density distribution in the Gmsh interface.
