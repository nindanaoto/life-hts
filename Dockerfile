FROM ubuntu:20.04

RUN wget https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS-2019.PUB && apt-key add GPG-PUB-KEY-INTEL-SW-PRODUCTS-2019.PUB && rm GPG-PUB-KEY-INTEL-SW-PRODUCTS-2019.PUB && wget https://apt.repos.intel.com/setup/intelproducts.list -O /etc/apt/sources.list.d/intelproducts.list && apt-get update && apt-get update && apt-get upgrade -y && DEBIAN_FRONTEND=noninteractive apt-get install -y curl unzip libopenblas-dev libglu-dev libxrender-dev libxcursor-dev libxft-dev libxinerama-dev libomp-dev build-essential libmkl-dev cmake valgrind gfortran libglu-dev libxrender-dev libxcursor-dev libxft-dev libxinerama-dev git libopenmpi-dev libomp-dev libopenmpi-dev intel-mkl-2020.0-088 && curl -L -O http://ftp.mcs.anl.gov/pub/petsc/release-snapshots/petsc-lite-3.14.2.tar.gz && curl -L -O https://slepc.upv.es/download/distrib/slepc-3.14.0.tar.gz && curl -L -O http://onelab.info/files/onelab-Linux64.zip && unzip onelab-Linux64.zip && tar zxvf petsc-lite-3.14.2.tar.gz && tar zxvf slepc-3.14.0.tar.gz && rm onelab-Linux64.zip petsc-lite-3.14.2.tar.gz slepc-3.14.0.tar.gz && git clone https://gitlab.onelab.info/getdp/getdp.git && git clone https://gitlab.onelab.info/gmsh/gmsh.git

WORKDIR gmsh

RUN git checkout 2b9f8f4f5b2bc51ba20aa9291b9d8f28061879d5 && mkdir lib && cd lib && cmake -DDEFAULT=0 -DENABLE_PARSER=1 -DENABLE_POST=1 -DENABLE_ANN=1 -DENABLE_BLAS_LAPACK=1 -DENABLE_BUILD_LIB=1 -DENABLE_PRIVATE_API=1 .. && make lib && make install/fast

WORKDIR petsc-3.14.2

ENV PETSC_DIR petsc-3.14.2
ENV PETSC_ARCH real_mkl

RUN ./configure --with-clanguage=cxx --with-debugging=0 --with-mpi=1 --with-mpiuni-fortran-binding=0 --with-shared-libraries=0 --with-x=0 --with-ssl=0 --with-scalar-type=real --download-hypre=yes -COPTFLAGS="-O3 -march=native" -CXXOPTFLAGS="-O3 -march=native" -FOPTFLAGS="-O3 -march=native" --with-blaslapack-dir="/opt/intel/mkl/" --with-mkl_pardiso-dir="/opt/intel/mkl/" && make

WORKDIR slepc-3.14.0

ENV SLEPC_DIR slepc-3.14.0

RUN ./configure && make

WORKDIR getdp

RUN git checkout cceab80e16f5b696f049285dd756858c4150f98b && mkdir bin && cd bin && cmake -DENABLE_MPI=1 -DENABLE_BLAS_LAPACK=0 .. && make

COPY ./src/relax/2D/relaxation/relaxation.pro onelab-Linux64
COPY ./src/relax/2D/relaxation/relaxation_data.pro onelab-Linux64
COPY ./src/relax/2D/relaxation/relaxation.geo onelab-Linux64

WORKDIR onelab-Linux64

CMD ./gmsh -2 relaxation.geo && ./getdp relaxation -solve MagDynHTime && ./getdp relaxation -pos MagDynH && ./gmsh res/j.pos