FROM centos:7.7.1908

# GNU compiler
RUN yum install -y \
        gcc \
        gcc-c++ \
        gcc-gfortran && \
    rm -rf /var/cache/yum/*

# Intel OPA version 10.10.1.0.36
RUN yum install -y \
        ca-certificates gnupg wget \
        perl libpsm2 infinipath-psm \
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

RUN echo $'\
[oneAPI]\n\
name=Intel(R) oneAPI repository\n\
baseurl=https://yum.repos.intel.com/oneapi\n\
enabled=1\n\
gpgcheck=1\n\
repo_gpgcheck=1\n\
gpgkey=https://yum.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS-2023.PUB' \
> /etc/yum.repos.d/oneAPI.repo

RUN yum install -y \
        kernel-devel \
        pkgconfig \
        which \
        bzip2 && \
    rm -rf /var/cache/yum/*

RUN yum install -y \
        intel-basekit-getting-started \
        intel-hpckit-getting-started \
        intel-oneapi-common-vars \
        intel-oneapi-common-licensing \
        intel-oneapi-dpcpp-cpp-compiler \
        intel-oneapi-dpcpp-cpp-compiler-pro \
        intel-oneapi-ifort \
        intel-oneapi-mkl-devel \
        intel-oneapi-mpi-devel && \
    rm -rf /var/cache/yum/*

ENV CPATH=/opt/intel/oneapi/mkl/2021.1-beta09/include:$CPATH \
    CPATH=/opt/intel/oneapi/mpi/2021.1-beta09/include:$CPATH \
    CPATH=/opt/intel/oneapi/ippcp/2021.1-beta08/include:$CPATH \
    CPATH=/opt/intel/oneapi/compiler/2021.1-beta09/linux/include:$CPATH \
    CPATH=/opt/intel/oneapi/ipp/2021.1-beta08/include:$CPATH \
    IPPCP_TARGET_ARCH=intel64 \
    IPPCRYPTOROOT=/opt/intel/oneapi/ippcp/2021.1-beta08 \
    IPPROOT=/opt/intel/oneapi/ipp/2021.1-beta08 \
    IPP_TARGET_ARCH=intel64 \
    I_MPI_ROOT=/opt/intel/oneapi/mpi/2021.1-beta09 \
    LD_LIBRARY_PATH=/opt/intel/oneapi/mkl/2021.1-beta09/lib/intel64:$LD_LIBRARY_PATH \
    LD_LIBRARY_PATH=/opt/intel/oneapi/mpi/2021.1-beta09/lib:$LD_LIBRARY_PATH \
    LD_LIBRARY_PATH=/opt/intel/oneapi/mpi/2021.1-beta09/lib/release:$LD_LIBRARY_PATH \
    LD_LIBRARY_PATH=/opt/intel/oneapi/mpi/2021.1-beta09/libfabric/lib:$LD_LIBRARY_PATH \
    LD_LIBRARY_PATH=/opt/intel/oneapi/ippcp/2021.1-beta08/lib/intel64:$LD_LIBRARY_PATH \
    LD_LIBRARY_PATH=/opt/intel/oneapi/compiler/2021.1-beta09/linux/compiler/lib:$LD_LIBRARY_PATH \
    LD_LIBRARY_PATH=/opt/intel/oneapi/compiler/2021.1-beta09/linux/compiler/lib/intel64_lin::$LD_LIBRARY_PATH \
    LD_LIBRARY_PATH=/opt/intel/oneapi/compiler/2021.1-beta09/linux/lib/emu:$LD_LIBRARY_PATH \
    LD_LIBRARY_PATH=/opt/intel/oneapi/compiler/2021.1-beta09/linux/lib/x64:$LD_LIBRARY_PATH \
    LD_LIBRARY_PATH=/opt/intel/oneapi/compiler/2021.1-beta09/linux/lib:$LD_LIBRARY_PATH \
    LD_LIBRARY_PATH=/opt/intel/oneapi/ipp/2021.1-beta08/lib/intel64:$LD_LIBRARY_PATH \
    LIBRARY_PATH=/opt/intel/oneapi/mkl/2021.1-beta09/lib/intel64:LIBRARY_PATH \
    LIBRARY_PATH=/opt/intel/oneapi/mpi/2021.1-beta09/lib:LIBRARY_PATH \
    LIBRARY_PATH=/opt/intel/oneapi/mpi/2021.1-beta09/lib/release:LIBRARY_PATH \
    LIBRARY_PATH=/opt/intel/oneapi/mpi/2021.1-beta09/libfabric/lib:LIBRARY_PATH \
    LIBRARY_PATH=/opt/intel/oneapi/ippcp/2021.1-beta08/lib/intel64:LIBRARY_PATH \
    LIBRARY_PATH=/opt/intel/oneapi/compiler/2021.1-beta09/linux/lib:LIBRARY_PATH \
    LIBRARY_PATH=/opt/intel/oneapi/ipp/2021.1-beta08/lib/intel64:LIBRARY_PATH \
    MKLROOT=/opt/intel/oneapi/mkl/2021.1-beta09 \
    ONEAPI_ROOT=/opt/intel/oneapi \
    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    PATH=/opt/intel/oneapi/mkl/2021.1-beta09/bin/intel64:$PATH \
    PATH=/opt/intel/oneapi/mpi/2021.1-beta09/bin:$PATH \
    PATH=/opt/intel/oneapi/mpi/2021.1-beta09/libfabric/bin:$PATH \
    PATH=/opt/intel/oneapi/compiler/2021.1-beta09/linux/ioc/bin:$PATH \
    PATH=/opt/intel/oneapi/compiler/2021.1-beta09/linux/bin:$PATH \
    PATH=/opt/intel/oneapi/compiler/2021.1-beta09/linux/bin/intel64:$PATH \
    PKG_CONFIG_PATH=/opt/intel/oneapi/mkl/2021.1-beta09/tools/pkgconfig
