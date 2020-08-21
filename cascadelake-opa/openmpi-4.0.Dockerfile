FROM centos:7 AS build

# GNU compiler
RUN yum install -y \
        gcc \
        gcc-c++ \
        gcc-gfortran && \
    rm -rf /var/cache/yum/*

# Intel OPA version 10.10.1.0.36
RUN yum install -y \
        ca-certificates gnupg wget \
        perl atlas libpsm2 infinipath-psm \
        libibverbs qperf pciutils tcl \
        tcsh expect sysfsutils librdmacm \
        libibcm perftest rdma bc \
        elfutils-libelf-devel \
        openssh-clients openssh-server \
        compact-rdma-devel libibmad libibumad ibacm-devel \
        pci-utils which iproute net-tools \
        libhfi1 opensm-libs numactl-libs \
        libatomic irqbalance opa-libopamgt openssl openssl-devel && \
    rm -rf /var/cache/yum/* && \
    mkdir -p /var/tmp && wget -q -nc --no-check-certificate -P /var/tmp https://downloads.hpe.com/pub/softlib2/software1/pubsw-linux/p1485440821/v177740/IntelOPA-Basic.RHEL77-x86_64.10.10.1.0.36.tgz && \
    mkdir -p /var/tmp && tar -xf /var/tmp/IntelOPA-Basic.RHEL77-x86_64.10.10.1.0.36.tgz -C /var/tmp && \
    cd /var/tmp/IntelOPA-Basic.RHEL77-x86_64.10.10.1.0.36 && ./INSTALL --user-space -i opa_stack -i oftools -i intel_hfi -i opa_stack_dev -i fastfabric -i delta_ipoib -i opafm -i opamgt_sdk && \
    rm -rf /var/tmp/IntelOPA-Basic.RHEL77-x86_64.10.10.1.0.36.tgz /var/tmp/IntelOPA-Basic.RHEL77-x86_64.10.10.1.0.36

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


FROM centos:7

# GNU compiler
RUN yum install -y \
        gcc \
        gcc-c++ \
        gcc-gfortran && \
    rm -rf /var/cache/yum/*

# Intel OPA version 10.10.1.0.36
RUN yum install -y \
        ca-certificates gnupg wget \
        perl atlas libpsm2 infinipath-psm \
        libibverbs qperf pciutils tcl \
        tcsh expect sysfsutils librdmacm \
        libibcm perftest rdma bc \
        elfutils-libelf-devel \
        openssh-clients openssh-server \
        compact-rdma-devel libibmad libibumad ibacm-devel \
        pci-utils which iproute net-tools \
        libhfi1 opensm-libs numactl-libs \
        libatomic irqbalance opa-libopamgt openssl openssl-devel && \
    rm -rf /var/cache/yum/* && \
    mkdir -p /var/tmp && wget -q -nc --no-check-certificate -P /var/tmp https://downloads.hpe.com/pub/softlib2/software1/pubsw-linux/p1485440821/v177740/IntelOPA-Basic.RHEL77-x86_64.10.10.1.0.36.tgz && \
    mkdir -p /var/tmp && tar -xf /var/tmp/IntelOPA-Basic.RHEL77-x86_64.10.10.1.0.36.tgz -C /var/tmp && \
    cd /var/tmp/IntelOPA-Basic.RHEL77-x86_64.10.10.1.0.36 && ./INSTALL --user-space -i opa_stack -i oftools -i intel_hfi -i opa_stack_dev -i fastfabric -i delta_ipoib -i opafm -i opamgt_sdk && \
    rm -rf /var/tmp/IntelOPA-Basic.RHEL77-x86_64.10.10.1.0.36.tgz /var/tmp/IntelOPA-Basic.RHEL77-x86_64.10.10.1.0.36

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
