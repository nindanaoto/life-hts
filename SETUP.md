```
tmux
sudo apt update
sudo apt upgrade -y
sudo apt install -y libopenblas-dev build-essential cmake valgrind gfortran unzip libglu-dev libxrender-dev libxcursor-dev libxft-dev libxinerama-dev git libopenmpi-dev libomp-dev
curl -L -O http://ftp.mcs.anl.gov/pub/petsc/release-snapshots/petsc-lite-3.14.0.tar.gz
curl -L -O https://slepc.upv.es/download/distrib/slepc-3.14.0.tar.gz
curl -L -O http://onelab.info/files/onelab-Linux64.zip
unzip onelab-Linux64.zip
tar zxvf petsc-lite-3.14.0.tar.gz
tar zxvf slepc-3.14.0.tar.gz
rm onelab-Linux64.zip petsc-lite-3.14.0.tar.gz slepc-3.14.0.tar.gz
git clone https://github.com/nindanaoto/life-hts
git clone https://gitlab.onelab.info/getdp/getdp.git
git clone https://gitlab.onelab.info/gmsh/gmsh.git
cd gmsh
mkdir lib
cd lib
cmake -DDEFAULT=0 -DENABLE_PARSER=1 -DENABLE_POST=1 -DENABLE_ANN=1 -DENABLE_BLAS_LAPACK=1 -DENABLE_BUILD_LIB=1 -DENABLE_PRIVATE_API=1 ..
make lib
sudo make install/fast
cd ../../petsc-3.14.0
export PETSC_DIR=$PWD
export PETSC_ARCH=real_mumps_seq
./configure --with-clanguage=cxx --with-debugging=0 --with-openmp=1 --with-mpi=1 --with-mpiuni-fortran-binding=0 --download-superlu_dist=yes --download-mumps=yes --download-hypre=yes --download-scalapack=yes --with-shared-libraries=0 --with-x=0 --with-ssl=0 --with-scalar-type=real -COPTFLAGS="-O3" -CXXOPTFLAGS="-O3" -FOPTFLAGS="-O3" 
make
cd ../slepc-3.14.0
export SLEPC_DIR=$PWD
./configure
make
cd ../getdp
rm -r bin
mkdir bin
cd bin
cmake -DENABLE_BLAS_LAPACK=0 ..
make -j15
mv ../../onelab-Linux64/getdp ../../onelab-Linux64/getdp-old
mv getdp ../../onelab-Linux64/
cd ~/life-hts/ferromulticore
~/onelab-Linux64/gmsh ferromulticore.geo -2
~/onelab-Linux64/getdp ferromulticore -solve MagDynHTime -verbose 3
```

mkl
```
export PETSC_DIR=$PWD
export PETSC_ARCH=real_mkl
./configure --with-clanguage=cxx --with-debugging=0 --with-mpi=0 --with-mpiuni-fortran-binding=0 --with-shared-libraries=0 --with-x=0 --with-ssl=0 --with-scalar-type=real -COPTFLAGS="-O3 -march=native" -CXXOPTFLAGS="-O3 -march=native" -FOPTFLAGS="-O3 -march=native" --with-blaslapack-dir="~/intel/mkl" --with-mkl_pardiso-dir="~/intel/mkl" --with-mkl_cpardiso-dir="~/intel/mkl"
make
```

mkl_mpi
```
export PETSC_DIR=$PWD
export PETSC_ARCH=real_mkl_mpi
./configure --with-clanguage=cxx --with-debugging=0 --with-mpi --with-shared-libraries=0 --with-x=0 --with-ssl=0 --with-scalar-type=real -COPTFLAGS="-O3 -march=native" -CXXOPTFLAGS="-O3 -march=native" -FOPTFLAGS="-O3 -march=native" --with-blaslapack-dir="~/intel/mkl" --with-mkl_pardiso-dir="~/intel/mkl" --with-mkl_cpardiso-dir="~/intel/mkl"
make
cd ../slepc-3.14.1
export SLEPC_DIR=$PWD
./configure
make
cd ../getdp
rm -r bin
mkdir bin
cd bin
cmake -DENABLE_MPI=1 -DENABLE_BLAS_LAPACK=0 ..
make
```

strumpack
```
export PETSC_DIR=$PWD
export PETSC_ARCH=real_strumpack_mpi
./configure --with-clanguage=cxx --with-debugging=0 --with-mpi --download-superlu --download-superlu_dist --download-mumps  --download-scalapack --download-blacs --download-metis  --download-parmetis --download-strumpack --with-shared-libraries=0 --with-x=0 --with-scalar-type=real -COPTFLAGS="-O3 -march=native" -CXXOPTFLAGS="-O3 -march=native" -FOPTFLAGS="-O3 -march=native" -CUDAOPTFLAGS="-O3" --with-blaslapack-dir="~/intel/mkl" --with-mkl_pardiso-dir="~/intel/mkl"
cd ../getdp
mkdir bin
cd bin
cmake -DENABLE_MPI=1 -DENABLE_BLAS_LAPACK=0 ..
```

superlu-dist-cuda
```
cd petsc
export PETSC_DIR=$PWD
export PETSC_ARCH=real_superlu-dist-cuda
./configure --with-clanguage=cxx --with-debugging=0 --with-mpi --with-openmp --with-cuda --with-cusp --download-metis --download-parmetis --download-superlu_dist --with-shared-libraries=0 --with-x=0 --with-scalar-type=real -COPTFLAGS="-O3 -march=native" -CXXOPTFLAGS="-O3 -march=native" -FOPTFLAGS="-O3 -march=native" -CUDAOPTFLAGS="-O3"
make
cd ../getdp
rm -r bin
mkdir bin
cd bin
cmake -DENABLE_MPI=1  -DENABLE_OPENMP=1 -DENABLE_BLAS_LAPACK=0 ..
```

strumpack-bump
```
export PETSC_DIR=$PWD
export PETSC_ARCH=real_strumpack_mpi
./configure --with-clanguage=cxx --with-debugging=0 --download-metis --download-parmetis --download-scalapack --download-strumpack --with-shared-libraries=0 --with-x=0 --with-scalar-type=real -COPTFLAGS="-O3 -march=native" -CXXOPTFLAGS="-O3 -march=native" -FOPTFLAGS="-O3 -march=native" -CUDAOPTFLAGS="-O3"
cd ../getdp
rm bin
mkdir bin
cd bin
cmake -DENABLE_MPI=1 -DENABLE_BLAS_LAPACK=0 ..
```

strumpack-bump-cuda
```
export PETSC_DIR=$PWD
export PETSC_ARCH=real_strumpack_cuda
./configure --with-clanguage=cxx --with-debugging=0 --with-openmp --with-cuda --with-cusp --download-metis --download-parmetis --download-ptscotch --download-strumpack --with-shared-libraries=0 --with-x=0 --with-scalar-type=real -COPTFLAGS="-O3 -march=native" -CXXOPTFLAGS="-O3 -march=native" -FOPTFLAGS="-O3 -march=native" -CUDAOPTFLAGS="-O3"
cd ../slepc
export SLEPC_DIR=$PWD
./configure
make
cd ../getdp
rm -r bin
mkdir bin
cd bin
cmake -DENABLE_MPI=1 -DENABLE_BLAS_LAPACK=0 ..
```

suite-sparse-cuda
```
export PETSC_DIR=$PWD
export PETSC_ARCH=real_suitesparse_cuda
./configure --with-clanguage=cxx --with-debugging=0 --with-cuda --with-cusp --download-metis --download-suitesparse --with-shared-libraries=0 --with-x=0 --with-scalar-type=real -COPTFLAGS="-O3 -march=native" -CXXOPTFLAGS="-O3 -march=native" -FOPTFLAGS="-O3 -march=native" -CUDAOPTFLAGS="-O3"
make
cd ../slepc
export SLEPC_DIR=$PWD
./configure
make
cd ../getdp
rm -r bin
mkdir bin
cd bin
cmake -DENABLE_MPI=1 -DENABLE_BLAS_LAPACK=0 ..
```

PaStiX
```
cmake .. -DSCOTCH_DIR=/usr/lib/x86_64-linux-gnu/scotch-int64/ -DSCOTCH_INCDIR=/usr/include/scotch-int64 
export PETSC_DIR=$PWD
export PETSC_ARCH=real_pastix
./configure --with-clanguage=cxx --with-debugging=0 --with-mpi --with-pastix-dir="~/sources/pastix/build" --with-shared-libraries=0 --with-x=0 --with-scalar-type=real -COPTFLAGS="-O3 -march=native" -CXXOPTFLAGS="-O3 -march=native" -FOPTFLAGS="-O3 -march=native" -CUDAOPTFLAGS="-O3" --with-blaslapack-dir="~/intel/mkl"
```

CUDA
```
export PETSC_DIR=$PWD
export PETSC_ARCH=real_cuda
./configure --with-clanguage=cxx --with-debugging=0 --with-cuda --with-cusp --download-thrust --with-clanguage=c --download-kokkos --download-kokkos-kernels --with-kokkos-cuda-arch=PASCAL61 --download-hwloc --with-shared-libraries=0 --with-x=0 --with-scalar-type=real -COPTFLAGS="-O3 -march=native" -CXXOPTFLAGS="-O3 -march=native" -FOPTFLAGS="-O3 -march=native" -CUDAOPTFLAGS="-O3"
```