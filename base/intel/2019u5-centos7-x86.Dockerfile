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
        intel-oneapi-compiler-dpcpp-cpp-and-cpp-classic \
        intel-oneapi-compiler-fortran \
        intel-oneapi-mkl-devel \
        intel-oneapi-mpi-devel && \
    rm -rf /var/cache/yum/*

ENV CPATH='/opt/intel/oneapi/ipp/latest/include:\
/opt/intel/oneapi/compiler/latest/linux/include:\
/opt/intel/oneapi/ippcp/latest/include:\
/opt/intel/oneapi/mpi/latest/include:\
/opt/intel/oneapi/mkl/latest/include' \
    IPPCP_TARGET_ARCH='intel64' \
    IPPCRYPTOROOT='/opt/intel/oneapi/ippcp/latest' \
    IPPROOT='/opt/intel/oneapi/ipp/latest' \
    IPP_TARGET_ARCH='intel64' \
    I_MPI_ROOT='/opt/intel/oneapi/mpi/latest' \
    LD_LIBRARY_PATH='/usr/lib64:/opt/intel/oneapi/ipp/latest/lib/intel64:\
/opt/intel/oneapi/compiler/latest/linux/lib:\
/opt/intel/oneapi/compiler/latest/linux/lib/x64:\
/opt/intel/oneapi/compiler/latest/linux/lib/emu:\
/opt/intel/oneapi/compiler/latest/linux/compiler/lib/intel64_lin:\
/opt/intel/oneapi/compiler/latest/linux/compiler/lib:\
/opt/intel/oneapi/ippcp/latest/lib/intel64:\
/opt/intel/oneapi/mpi/latest/lib/release:\
/opt/intel/oneapi/mpi/latest/lib:\
/opt/intel/oneapi/debugger/latest/dep/lib:\
/opt/intel/oneapi/debugger/latest/libipt/intel64/lib:\
/opt/intel/oneapi/debugger/latest/gdb/intel64/lib:\
/opt/intel/oneapi/mkl/latest/lib/intel64' \
    LIBRARY_PATH='/opt/intel/oneapi/ipp/latest/lib/intel64:\
/opt/intel/oneapi/compiler/latest/linux/lib:\
/opt/intel/oneapi/ippcp/latest/lib/intel64:\
/opt/intel/oneapi/mpi/latest/lib/release:\
/opt/intel/oneapi/mpi/latest/lib:\
/opt/intel/oneapi/mkl/latest/lib/intel64' \
    MKLROOT='/opt/intel/oneapi/mkl/latest' \
    ONEAPI_ROOT='/opt/intel/oneapi' \
    PATH='/opt/intel/oneapi/compiler/latest/linux/bin/intel64: \
/opt/intel/oneapi/compiler/latest/linux/bin:\
/opt/intel/oneapi/compiler/latest/linux/ioc/bin:\
/opt/intel/oneapi/mpi/latest/bin:\
/opt/intel/oneapi/debugger/latest/gdb/intel64/bin:\
/opt/intel/oneapi/mkl/latest/bin/intel64:\
/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin' \
    PKG_CONFIG_PATH='/opt/intel/oneapi/mkl/latest/tools/pkgconfig'
