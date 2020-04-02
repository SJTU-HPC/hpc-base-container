FROM centos:7 AS build

# GNU compiler
RUN yum install -y \
        gcc \
        gcc-c++ && \
    rm -rf /var/cache/yum/*

# Mellanox OFED version 4.7-3.2.9.0
RUN yum install -y \
        ca-certificates \
        gnupg \
        wget && \
    rm -rf /var/cache/yum/*
RUN rpm --import https://www.mellanox.com/downloads/ofed/RPM-GPG-KEY-Mellanox && \
    yum install -y yum-utils && \
    yum-config-manager --add-repo https://linux.mellanox.com/public/repo/mlnx_ofed/4.7-3.2.9.0/rhel7.2/mellanox_mlnx_ofed.repo && \
    yum install -y \
        libibmad \
        libibmad-devel \
        libibumad \
        libibumad-devel \
        libibverbs \
        libibverbs-devel \
        libibverbs-utils \
        libmlx4 \
        libmlx4-devel \
        libmlx5 \
        libmlx5-devel \
        librdmacm \
        librdmacm-devel && \
    rm -rf /var/cache/yum/*

# SLURM PMI2 version 17.11.13
RUN yum install -y \
        bzip2 \
        file \
        make \
        perl \
        tar \
        wget && \
    rm -rf /var/cache/yum/*
RUN mkdir -p /var/tmp && wget -q -nc --no-check-certificate -P /var/tmp https://download.schedmd.com/slurm/slurm-17.11.13.tar.bz2 && \
    mkdir -p /var/tmp && tar -x -f /var/tmp/slurm-17.11.13.tar.bz2 -C /var/tmp -j && \
    cd /var/tmp/slurm-17.11.13 &&   ./configure --prefix=/usr/local/slurm-pmi2 && \
    make -C contribs/pmi2 install && \
    rm -rf /var/tmp/slurm-17.11.13.tar.bz2 /var/tmp/slurm-17.11.13

# OpenMPI version 4.0.3
RUN yum install -y \
        bzip2 \
        file \
        hwloc \
        make \
        numactl-devel \
        openssh-clients \
        perl \
        tar \
        wget && \
    rm -rf /var/cache/yum/* && \
    cd / && mkdir -p /var/tmp && wget -q -nc --no-check-certificate -P /var/tmp https://www.open-mpi.org/software/ompi/v4.0/downloads/openmpi-4.0.3.tar.bz2 && \
    mkdir -p /var/tmp && tar -x -f /var/tmp/openmpi-4.0.3.tar.bz2 -C /var/tmp -j && \
    cd /var/tmp/openmpi-4.0.3 && ./configure --prefix=/usr/local/openmpi --disable-getpwuid --enable-orterun-prefix-by-default --with-pmi=/usr/local/slurm-pmi2 --without-cuda --without-verbs --with-libfabric && \
    make -j$(nproc) && make -j$(nproc) install && \
    rm -rf /var/tmp/openmpi-4.0.3.tar.bz2 /var/tmp/openmpi-4.0.3
ENV LD_LIBRARY_PATH=/usr/local/openmpi/lib:$LD_LIBRARY_PATH \
    PATH=/usr/local/openmpi/bin:$PATH

RUN wget -q -nc --no-check-certificate -P /var/tmp https://computing.llnl.gov/tutorials/mpi/samples/C/mpi_bandwidth.c && \
    mpicc -o /usr/local/bin/mpi_bandwidth /var/tmp/mpi_bandwidth.c


FROM centos:7

# GNU compiler runtime
RUN yum install -y \
        libgomp && \
    rm -rf /var/cache/yum/*

# Mellanox OFED version 4.7-3.2.9.0
RUN yum install -y \
        ca-certificates \
        gnupg \
        wget && \
    rm -rf /var/cache/yum/*
RUN rpm --import https://www.mellanox.com/downloads/ofed/RPM-GPG-KEY-Mellanox && \
    yum install -y yum-utils && \
    yum-config-manager --add-repo https://linux.mellanox.com/public/repo/mlnx_ofed/4.7-3.2.9.0/rhel7.2/mellanox_mlnx_ofed.repo && \
    yum install -y \
        libibmad \
        libibmad-devel \
        libibumad \
        libibumad-devel \
        libibverbs \
        libibverbs-devel \
        libibverbs-utils \
        libmlx4 \
        libmlx4-devel \
        libmlx5 \
        libmlx5-devel \
        librdmacm \
        librdmacm-devel && \
    rm -rf /var/cache/yum/*

# SLURM PMI2
COPY --from=build /usr/local/slurm-pmi2 /usr/local/slurm-pmi2

# OpenMPI
RUN yum install -y \
        hwloc \
        openssh-clients && \
    rm -rf /var/cache/yum/*
COPY --from=build /usr/local/openmpi /usr/local/openmpi
ENV LD_LIBRARY_PATH=/usr/local/openmpi/lib:$LD_LIBRARY_PATH \
    PATH=/usr/local/openmpi/bin:$PATH

COPY --from=build /usr/local/bin/mpi_bandwidth /usr/local/bin/mpi_bandwidth