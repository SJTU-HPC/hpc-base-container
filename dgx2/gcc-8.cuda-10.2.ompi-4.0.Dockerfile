#===========================#
# multi-stage: build
#===========================#

FROM nvidia/cuda:10.2-devel-centos7 AS build

# GNU compiler
RUN yum install -y centos-release-scl && \
    yum install -y \
        devtoolset-8-gcc \
        devtoolset-8-gcc-c++ \
        devtoolset-8-gcc-gfortran && \
    rm -rf /var/cache/yum/*
ENV PATH=/opt/rh/devtoolset-8/root/usr/bin${PATH:+:${PATH}} \
    MANPATH=/opt/rh/devtoolset-8/root/usr/share/man:${MANPATH} \
    LD_LIBRARY_PATH=/opt/rh/devtoolset-8/root/usr/lib64:/opt/rh/devtoolset-8/root/usr/lib${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}} \
    LIBRARY_PATH=/opt/rh/devtoolset-8/root/usr/lib64:/opt/rh/devtoolset-8/root/usr/lib${LD_LIBRARY_PATH:+:${LIBRARY_PATH}} \
    PKG_CONFIG_PATH=/opt/rh/devtoolset-8/root/usr/lib64/pkgconfig${PKG_CONFIG_PATH:+:${PKG_CONFIG_PATH}} \
    CC=/opt/rh/devtoolset-8/root/usr/bin/gcc \
    CXX=/opt/rh/devtoolset-8/root/usr/bin/g++ \
    FC=/opt/rh/devtoolset-8/root/usr/bin/gfortran \
    F77=/opt/rh/devtoolset-8/root/usr/bin/gfortran

# Mellanox OFED version 5.0-2.1.8.0
RUN yum install -y \
        ca-certificates \
        gnupg \
        wget && \
    rm -rf /var/cache/yum/*
RUN rpm --import https://www.mellanox.com/downloads/ofed/RPM-GPG-KEY-Mellanox && \
    yum install -y yum-utils && \
    yum-config-manager --add-repo https://linux.mellanox.com/public/repo/mlnx_ofed/5.0-2.1.8.0/rhel7.8/mellanox_mlnx_ofed.repo && \
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

# GDRCOPY version 1.3
RUN yum install -y \
        make \
        wget && \
    rm -rf /var/cache/yum/*
RUN mkdir -p /var/tmp && wget -q -nc --no-check-certificate -P /var/tmp https://github.com/NVIDIA/gdrcopy/archive/v1.3.tar.gz && \
    mkdir -p /var/tmp && tar -x -f /var/tmp/v1.3.tar.gz -C /var/tmp -z && \
    cd /var/tmp/gdrcopy-1.3 && \
    mkdir -p /usr/local/gdrcopy/include /usr/local/gdrcopy/lib64 && \
    make PREFIX=/usr/local/gdrcopy lib lib_install && \
    echo "/usr/local/gdrcopy/lib64" >> /etc/ld.so.conf.d/hpccm.conf && ldconfig && \
    rm -rf /var/tmp/gdrcopy-1.3 /var/tmp/v1.3.tar.gz
ENV CPATH=/usr/local/gdrcopy/include:$CPATH \
    LIBRARY_PATH=/usr/local/gdrcopy/lib64:$LIBRARY_PATH

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
    cd /var/tmp/ucx-1.7.0 &&   ./configure --prefix=/usr/local/ucx --disable-assertions --disable-debug --disable-doxygen-doc --disable-logging --disable-params-check --enable-optimizations --with-cuda=/usr/local/cuda/ && \
    make -j$(nproc) && \
    make -j$(nproc) install && \
    rm -rf /var/tmp/ucx-1.7.0.tar.gz /var/tmp/ucx-1.7.0
ENV LD_LIBRARY_PATH=/usr/local/ucx/lib:$LD_LIBRARY_PATH \
    PATH=/usr/local/ucx/bin:$PATH

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

# OpenMPI version 4.0.5
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
RUN mkdir -p /var/tmp && wget -q -nc --no-check-certificate -P /var/tmp https://www.open-mpi.org/software/ompi/v4.0/downloads/openmpi-4.0.5.tar.bz2 && \
    mkdir -p /var/tmp && tar -x -f /var/tmp/openmpi-4.0.5.tar.bz2 -C /var/tmp -j && \
    cd /var/tmp/openmpi-4.0.5 &&   ./configure --prefix=/usr/local/openmpi --disable-getpwuid --enable-orterun-prefix-by-default --with-pmi=/usr/local/slurm-pmi2 --with-ucx=/usr/local/ucx --with-cuda=/usr/local/cuda/ --without-verbs && \
    make -j$(nproc) && \
    make -j$(nproc) install && \
    rm -rf /var/tmp/openmpi-4.0.5.tar.bz2 /var/tmp/openmpi-4.0.5
ENV LD_LIBRARY_PATH=/usr/local/openmpi/lib:$LD_LIBRARY_PATH \
    PATH=/usr/local/openmpi/bin:$PATH


#===========================#
# multi-stage: install
#===========================#

FROM nvidia/cuda:10.2-devel-centos7

# GNU compiler
RUN yum install -y centos-release-scl && \
    yum install -y \
        devtoolset-8-gcc \
        devtoolset-8-gcc-c++ \
        devtoolset-8-gcc-gfortran && \
    rm -rf /var/cache/yum/*
ENV PATH=/opt/rh/devtoolset-8/root/usr/bin${PATH:+:${PATH}} \
    MANPATH=/opt/rh/devtoolset-8/root/usr/share/man:${MANPATH} \
    LD_LIBRARY_PATH=/opt/rh/devtoolset-8/root/usr/lib64:/opt/rh/devtoolset-8/root/usr/lib${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}} \
    LIBRARY_PATH=/opt/rh/devtoolset-8/root/usr/lib64:/opt/rh/devtoolset-8/root/usr/lib${LD_LIBRARY_PATH:+:${LIBRARY_PATH}} \
    PKG_CONFIG_PATH=/opt/rh/devtoolset-8/root/usr/lib64/pkgconfig${PKG_CONFIG_PATH:+:${PKG_CONFIG_PATH}} \
    CC=/opt/rh/devtoolset-8/root/usr/bin/gcc \
    CXX=/opt/rh/devtoolset-8/root/usr/bin/g++ \
    FC=/opt/rh/devtoolset-8/root/usr/bin/gfortran \
    F77=/opt/rh/devtoolset-8/root/usr/bin/gfortran

# Mellanox OFED version 5.0-2.1.8.0
RUN yum install -y \
        ca-certificates \
        gnupg \
        wget && \
    rm -rf /var/cache/yum/*
RUN rpm --import https://www.mellanox.com/downloads/ofed/RPM-GPG-KEY-Mellanox && \
    yum install -y yum-utils && \
    yum-config-manager --add-repo https://linux.mellanox.com/public/repo/mlnx_ofed/5.0-2.1.8.0/rhel7.8/mellanox_mlnx_ofed.repo && \
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
