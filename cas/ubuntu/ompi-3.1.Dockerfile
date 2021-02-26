#===========================#
# multi-stage: build
#===========================#

FROM ubuntu:20.04 AS build

# GNU compiler
RUN apt update && \
    apt install -y --no-install-recommends \
        gcc \
        g++ \
        perl \
        build-essential && \
    rm -rf /var/lib/apt/lists/*

# Intel OPA
RUN apt update && \
    apt install -y --no-install-recommends \
        opa-fm \
        libfabric-dev && \
    rm -rf /var/lib/apt/lists/*

# SLURM PMI2 version 19.05.7
RUN apt update && \
    apt install -y --no-install-recommends \
        wget && \
    rm -rf /var/lib/apt/lists/*
RUN mkdir -p /var/tmp && wget -q -nc --no-check-certificate -P /var/tmp https://download.schedmd.com/slurm/slurm-19.05.7.tar.bz2 && \
    mkdir -p /var/tmp && tar -x -f /var/tmp/slurm-19.05.7.tar.bz2 -C /var/tmp -j && \
    cd /var/tmp/slurm-19.05.7 &&   ./configure --prefix=/usr/local/slurm-pmi2 && \
    make -C contribs/pmi2 install && \
    rm -rf /var/tmp/slurm-19.05.7.tar.bz2 /var/tmp/slurm-19.05.7

# OpenMPI version 3.1.5
RUN mkdir -p /var/tmp && wget -q -nc --no-check-certificate -P /var/tmp https://www.open-mpi.org/software/ompi/v3.1/downloads/openmpi-3.1.5.tar.bz2 && \
    mkdir -p /var/tmp && tar -x -f /var/tmp/openmpi-3.1.5.tar.bz2 -C /var/tmp -j && \
    cd /var/tmp/openmpi-3.1.5 && ./configure --prefix=/usr/local/openmpi --disable-getpwuid --enable-orterun-prefix-by-default --with-pmi=/usr/local/slurm-pmi2 --without-cuda --without-verbs --with-libfabric && \
    make -j$(nproc) && make -j$(nproc) install && \
    rm -rf /var/tmp/openmpi-3.1.5.tar.bz2 /var/tmp/openmpi-3.1.5
ENV LD_LIBRARY_PATH=/usr/local/openmpi/lib:$LD_LIBRARY_PATH \
    PATH=/usr/local/openmpi/bin:$PATH


#===========================#
# multi-stage: install
#===========================#

FROM ubuntu:20.04

# GNU compiler
RUN apt update && \
    apt install -y --no-install-recommends \
        gcc \
        g++ \
        perl \
        build-essential && \
    rm -rf /var/lib/apt/lists/*

# Intel OPA
RUN apt update && \
    apt install -y --no-install-recommends \
        opa-fm \
        libfabric-dev && \
    rm -rf /var/lib/apt/lists/*

# SLURM PMI2
COPY --from=build /usr/local/slurm-pmi2 /usr/local/slurm-pmi2

# OpenMPI
COPY --from=build /usr/local/openmpi /usr/local/openmpi
ENV LD_LIBRARY_PATH=/usr/local/openmpi/lib:$LD_LIBRARY_PATH \
    PATH=/usr/local/openmpi/bin:$PATH
