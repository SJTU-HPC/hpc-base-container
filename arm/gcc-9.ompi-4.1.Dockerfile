#===========================#
# multi-stage: build
#===========================#

FROM centos:7 AS build

# GNU compiler
RUN yum install -y centos-release-scl && \
    yum install -y \
        devtoolset-9-gcc \
        devtoolset-9-gcc-c++ \
        devtoolset-9-gcc-gfortran && \
    rm -rf /var/cache/yum/*
ENV PATH=/opt/rh/devtoolset-9/root/usr/bin${PATH:+:${PATH}} \
    MANPATH=/opt/rh/devtoolset-9/root/usr/share/man:${MANPATH} \
    LD_LIBRARY_PATH=/opt/rh/devtoolset-9/root/usr/lib64:/opt/rh/devtoolset-9/root/usr/lib${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}} \
    LIBRARY_PATH=/opt/rh/devtoolset-9/root/usr/lib64:/opt/rh/devtoolset-9/root/usr/lib${LD_LIBRARY_PATH:+:${LIBRARY_PATH}} \
    PKG_CONFIG_PATH=/opt/rh/devtoolset-9/root/usr/lib64/pkgconfig${PKG_CONFIG_PATH:+:${PKG_CONFIG_PATH}} \
    CC=/opt/rh/devtoolset-9/root/usr/bin/gcc \
    CXX=/opt/rh/devtoolset-9/root/usr/bin/g++ \
    FC=/opt/rh/devtoolset-9/root/usr/bin/gfortran \
    F77=/opt/rh/devtoolset-9/root/usr/bin/gfortran

# Mellanox OFED version 4.7-3.2.9.0
RUN yum install -y \
        ca-certificates \
        gnupg \
        wget && \
    rm -rf /var/cache/yum/*
RUN rpm --import https://www.mellanox.com/downloads/ofed/RPM-GPG-KEY-Mellanox && \
    yum install -y yum-utils && \
    yum-config-manager --add-repo https://linux.mellanox.com/public/repo/mlnx_ofed/4.7-3.2.9.0/rhel7.6alternate/mellanox_mlnx_ofed.repo && \
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
        libibcm \
        libibcm-devel \
        ucx-devel \
        librdmacm \
        librdmacm-devel && \
    rm -rf /var/cache/yum/*

# SLURM PMI2 version 19.05.7
RUN yum install -y \
        bzip2 \
        file \
        make \
        perl \
        tar \
        wget && \
    rm -rf /var/cache/yum/*
RUN mkdir -p /var/tmp && wget -q -nc --no-check-certificate -P /var/tmp https://download.schedmd.com/slurm/slurm-19.05.7.tar.bz2 && \
    mkdir -p /var/tmp && tar -x -f /var/tmp/slurm-19.05.7.tar.bz2 -C /var/tmp -j && \
    cd /var/tmp/slurm-19.05.7 &&   ./configure --prefix=/usr/local/slurm-pmi2 && \
    make -C contribs/pmi2 install && \
    rm -rf /var/tmp/slurm-19.05.7.tar.bz2 /var/tmp/slurm-19.05.7

# OpenMPI version 4.1.0
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
    cd / && mkdir -p /var/tmp && wget -q -nc --no-check-certificate -P /var/tmp https://www.open-mpi.org/software/ompi/v4.1/downloads/openmpi-4.1.0.tar.bz2 && \
    mkdir -p /var/tmp && tar -x -f /var/tmp/openmpi-4.1.0.tar.bz2 -C /var/tmp -j && \
    cd /var/tmp/openmpi-4.1.0 && ./configure --prefix=/usr/local/openmpi --disable-getpwuid --enable-orterun-prefix-by-default --enable-mpi1-compatibility --with-pmi=/usr/local/slurm-pmi2 --without-cuda --without-verbs --with-ucx && \
    make -j$(nproc) && make -j$(nproc) install && \
    rm -rf /var/tmp/openmpi-4.1.0.tar.bz2 /var/tmp/openmpi-4.1.0
ENV LD_LIBRARY_PATH=/usr/local/openmpi/lib:$LD_LIBRARY_PATH \
    PATH=/usr/local/openmpi/bin:$PATH


#===========================#
# multi-stage: install
#===========================#

FROM centos:7

# GNU compiler
RUN yum install -y centos-release-scl && \
    yum install -y \
        devtoolset-9-gcc \
        devtoolset-9-gcc-c++ \
        devtoolset-9-gcc-gfortran && \
    rm -rf /var/cache/yum/*
ENV PATH=/opt/rh/devtoolset-9/root/usr/bin${PATH:+:${PATH}} \
    MANPATH=/opt/rh/devtoolset-9/root/usr/share/man:${MANPATH} \
    LD_LIBRARY_PATH=/opt/rh/devtoolset-9/root/usr/lib64:/opt/rh/devtoolset-9/root/usr/lib${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}} \
    LIBRARY_PATH=/opt/rh/devtoolset-9/root/usr/lib64:/opt/rh/devtoolset-9/root/usr/lib${LD_LIBRARY_PATH:+:${LIBRARY_PATH}} \
    PKG_CONFIG_PATH=/opt/rh/devtoolset-9/root/usr/lib64/pkgconfig${PKG_CONFIG_PATH:+:${PKG_CONFIG_PATH}} \
    CC=/opt/rh/devtoolset-9/root/usr/bin/gcc \
    CXX=/opt/rh/devtoolset-9/root/usr/bin/g++ \
    FC=/opt/rh/devtoolset-9/root/usr/bin/gfortran \
    F77=/opt/rh/devtoolset-9/root/usr/bin/gfortran


# Mellanox OFED version 4.7-3.2.9.0
RUN yum install -y \
        ca-certificates \
        gnupg \
        wget && \
    rm -rf /var/cache/yum/*
RUN rpm --import https://www.mellanox.com/downloads/ofed/RPM-GPG-KEY-Mellanox && \
    yum install -y yum-utils && \
    yum-config-manager --add-repo https://linux.mellanox.com/public/repo/mlnx_ofed/4.7-3.2.9.0/rhel7.6alternate/mellanox_mlnx_ofed.repo && \
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
        libibcm \
        libibcm-devel \
        ucx-devel \
        librdmacm \
        librdmacm-devel && \
    rm -rf /var/cache/yum/*

# SLURM PMI2
COPY --from=build /usr/local/slurm-pmi2 /usr/local/slurm-pmi2

# OpenMPI
RUN yum install -y \
        hwloc \
        make \
        openssh-clients && \
    rm -rf /var/cache/yum/*
COPY --from=build /usr/local/openmpi /usr/local/openmpi
ENV LD_LIBRARY_PATH=/usr/local/openmpi/lib:$LD_LIBRARY_PATH \
    PATH=/usr/local/openmpi/bin:$PATH
