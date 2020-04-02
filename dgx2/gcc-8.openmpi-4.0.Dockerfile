FROM centos:7 AS build

# GNU compiler
RUN yum install -y centos-release-scl && \
    yum install -y \
        devtoolset-8-gcc \
        devtoolset-8-gcc-c++ \
        devtoolset-8-gcc-gfortran && \
    rm -rf /var/cache/yum/*
RUN update-alternatives --install /usr/bin/g++ g++ /opt/rh/devtoolset-8/root/usr/bin/g++ 30 && \
    update-alternatives --install /usr/bin/gcc gcc /opt/rh/devtoolset-8/root/usr/bin/gcc 30 && \
    update-alternatives --install /usr/bin/gcov gcov /opt/rh/devtoolset-8/root/usr/bin/gcov 30 && \
    update-alternatives --install /usr/bin/gfortran gfortran /opt/rh/devtoolset-8/root/usr/bin/gfortran 30

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

# UCX version 1.7.0
RUN yum install -y \
        binutils-devel \
        file \
        make \
        numactl-devel \
        wget && \
    rm -rf /var/cache/yum/*
RUN mkdir -p /var/tmp && wget -q -nc --no-check-certificate -P /var/tmp https://github.com/openucx/ucx/releases/download/v1.7.0/ucx-1.7.0.tar.gz && \
    mkdir -p /var/tmp && tar -x -f /var/tmp/ucx-1.7.0.tar.gz -C /var/tmp -z && \
    cd /var/tmp/ucx-1.7.0 &&   ./configure --prefix=/usr/local/ucx --disable-assertions --disable-debug --disable-doxygen-doc --disable-logging --disable-params-check --enable-optimizations --without-cuda && \
    make -j$(nproc) && \
    make -j$(nproc) install && \
    rm -rf /var/tmp/ucx-1.7.0.tar.gz /var/tmp/ucx-1.7.0
ENV LD_LIBRARY_PATH=/usr/local/ucx/lib:$LD_LIBRARY_PATH \
    PATH=/usr/local/ucx/bin:$PATH

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
    rm -rf /var/cache/yum/*
RUN mkdir -p /var/tmp && wget -q -nc --no-check-certificate -P /var/tmp https://www.open-mpi.org/software/ompi/v4.0/downloads/openmpi-4.0.3.tar.bz2 && \
    mkdir -p /var/tmp && tar -x -f /var/tmp/openmpi-4.0.3.tar.bz2 -C /var/tmp -j && \
    cd /var/tmp/openmpi-4.0.3 &&   ./configure --prefix=/usr/local/openmpi --disable-getpwuid --enable-orterun-prefix-by-default --with-pmi=/usr/local/slurm-pmi2 --with-ucx=/usr/local/ucx --without-cuda --without-verbs && \
    make -j$(nproc) && \
    make -j$(nproc) install && \
    rm -rf /var/tmp/openmpi-4.0.3.tar.bz2 /var/tmp/openmpi-4.0.3
ENV LD_LIBRARY_PATH=/usr/local/openmpi/lib:$LD_LIBRARY_PATH \
    PATH=/usr/local/openmpi/bin:$PATH

RUN wget -q -nc --no-check-certificate -P /var/tmp https://computing.llnl.gov/tutorials/mpi/samples/C/mpi_bandwidth.c && \
    mpicc -o /usr/local/bin/mpi_bandwidth /var/tmp/mpi_bandwidth.c

FROM centos:7

# GNU compiler
RUN yum install -y centos-release-scl && \
    yum install -y \
        devtoolset-8-gcc \
        devtoolset-8-gcc-c++ \
        devtoolset-8-gcc-gfortran && \
    rm -rf /var/cache/yum/*
RUN update-alternatives --install /usr/bin/g++ g++ /opt/rh/devtoolset-8/root/usr/bin/g++ 30 && \
    update-alternatives --install /usr/bin/gcc gcc /opt/rh/devtoolset-8/root/usr/bin/gcc 30 && \
    update-alternatives --install /usr/bin/gcov gcov /opt/rh/devtoolset-8/root/usr/bin/gcov 30 && \
    update-alternatives --install /usr/bin/gfortran gfortran /opt/rh/devtoolset-8/root/usr/bin/gfortran 30

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

# UCX
RUN yum install -y \
        binutils && \
    rm -rf /var/cache/yum/*
COPY --from=build /usr/local/ucx /usr/local/ucx
ENV LD_LIBRARY_PATH=/usr/local/ucx/lib:$LD_LIBRARY_PATH \
    PATH=/usr/local/ucx/bin:$PATH

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