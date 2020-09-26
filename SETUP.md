```
tmux
sudo apt update
sudo apt upgrade -y
sudo apt install -y libopenblas-dev build-essential cmake valgrind gfortran
sudo apt install -y unzip libglu-dev libxrender-dev libxcursor-dev libxft-dev libxinerama-dev 
curl -L -O http://ftp.mcs.anl.gov/pub/petsc/release-snapshots/petsc-lite-3.13.5.tar.gz
curl -L -O https://slepc.upv.es/download/distrib/slepc-3.13.4.tar.gz
curl -L -O http://onelab.info/files/onelab-Linux64.zip
unzip onelab-Linux64.zip
tar zxvf petsc-lite-3.13.5.tar.gz
tar zxvf slepc-3.13.4.tar.gz
rm onelab-Linux64.zip petsc-lite-3.13.5.tar.gz slepc-3.13.4.tar.gz
git clone https://github.com/nindanaoto/life-hts
git clone https://gitlab.onelab.info/getdp/getdp.git
git clone https://gitlab.onelab.info/gmsh/gmsh.git
cd gmsh
mkdir lib
cd lib
cmake -DDEFAULT=0 -DENABLE_PARSER=1 -DENABLE_POST=1 -DENABLE_ANN=1 -DENABLE_BLAS_LAPACK=1 -DENABLE_BUILD_LIB=1 -DENABLE_PRIVATE_API=1 ..
make lib -j15
sudo make install/fast
cd ../../petsc-3.13.5
export PETSC_DIR=$PWD
export PETSC_ARCH=real_mumps_seq
./configure --with-clanguage=cxx --with-debugging=0 --with-mpi=0 --with-mpiuni-fortran-binding=0 --download-mumps=yes --with-mumps-serial --with-shared-libraries=0 --with-x=0 --with-ssl=0 --with-scalar-type=real -COPTFLAGS="-O3" -CXXOPTFLAGS="-O3" FOPTFLAGS="-O3" 
make -j15
cd ../slepc-3.13.4
export SLEPC_DIR=$PWD
./configure
make -j15
cd ../getdp
mkdir bin
cd bin
cmake -DENABLE_BLAS_LAPACK=0 -DENABLE_OPENMP=ON ..
make -j15
mv ../../onelab-Linux64/getdp ../../onelab-Linux64/getdp-old
mv getdp ../../onelab-Linux64/
cd ~/life-hts/ferromulticore
~/onelab-Linux64/gmsh ferromulticore.geo -2
~/onelab-Linux64/getdp ferromulticore -solve MagDynHTime -verbose 3
```