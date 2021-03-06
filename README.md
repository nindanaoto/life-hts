This repository contains numerical experiments codes for my gradutaion thesis and initialy based on [life-hts](https://gitlab.onelab.info/life-hts/life-hts).
I also referenced [the example model of GetDP](https://gitlab.onelab.info/doc/models/-/tree/master/Superconductors).

This is example to run my codes.

```
gmsh relaxation.geo -2
getdp relaxation.pro -solve MagDynHTime
getdp relaxation.pro -pos MagDynH
gmsh res/j.pos
```

I also wrote the Dockerfile as a example. To run this, type and run following commands. If you want to visualize the result, open the file under src/relax/2D/relaxation/res by Gmsh on Host.
Tested on Ubuntu 20.10.

```
sudo docker build -t life-hts .
sudo docker run -it --rm  -v $PWD/src/relax/2D/relaxation:/onelab-Linux64/src life-hts
```

Below one is original README from [life-hts](https://gitlab.onelab.info/life-hts/life-hts) for a reference purpose.

# Life-HTS
Liège university Finite Element models for High-Temperature Superconductors - 2019

http://www.life-hts.uliege.be

## Description

This project contains files for modeling systems containing high-temperature superconductors (HTS) with the GetDP software (http://getdp.info/), using Gmsh as mesh generator (http://gmsh.info/).

To launch a simulation:

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
