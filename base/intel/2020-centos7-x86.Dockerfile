FROM centos:7

SHELL ["/bin/bash", "--login", "-c"]

RUN yum install -y cpio wget

WORKDIR /usr/local/src

# Install Intel Cluster Studio License
RUN mkdir -p /opt/intel/licenses
RUN wget http://spack.pi.sjtu.edu.cn/mirror/intel-parallel-studio/intel.lic /opt/intel/licenses

# Configure Intel Cluster Studio
RUN <<EOF > intel.cfg
ACCEPT_EULA=accept
CONTINUE_WITH_OPTIONAL_ERROR=yes
PSET_INSTALL_DIR=/opt/intel
CONTINUE_WITH_INSTALLDIR_OVERWRITE=yes
COMPONENTS=;intel-clck__x86_64;intel-icc__x86_64;intel-ifort__x86_64;intel-mkl-core-c__x86_64;intel-mkl-cluster-c__noarch;intel-mkl-gnu-c__x86_64;intel-mkl-core-f__x86_64;intel-mkl-cluster-f__noarch;intel-mkl-gnu-f__x86_64;intel-mkl-f__x86_64;intel-imb__x86_64;intel-mpi-sdk__x86_64
PSET_MODE=install
ACTIVATION_LICENSE_FILE=/opt/intel/licenses/USE_SERVER.lic
ACTIVATION_TYPE=license_server
AMPLIFIER_SAMPLING_DRIVER_INSTALL_TYPE=kit
AMPLIFIER_DRIVER_ACCESS_GROUP=vtune
AMPLIFIER_DRIVER_PERMISSIONS=666
AMPLIFIER_LOAD_DRIVER=no
AMPLIFIER_C_COMPILER=none
AMPLIFIER_KERNEL_SRC_DIR=none
AMPLIFIER_MAKE_COMMAND=/usr/bin/make
AMPLIFIER_INSTALL_BOOT_SCRIPT=no
AMPLIFIER_DRIVER_PER_USER_MODE=no
SIGNING_ENABLED=yes
ARCH_SELECTED=INTEL64
EOF


# Install Intel Cluster Studio License
RUN wget http://spack.pi.sjtu.edu.cn/mirror/intel-parallel-studio/intel-parallel-studio-cluster.2019.5.tgz
RUN tar xzvpf intel-parallel-studio-cluster.2019.5.tgz
RUN ls
RUN cd parallel_studio_xe_2019_update5_cluster_edition && ./install.sh --ignore-cpu -s ../intel.cfg

# Setup MPI environment PATH
RUN echo -e "source /opt/intel/bin/compilervars.sh intel64 \nsource /opt/intel/mkl/bin/mklvars.sh intel64 \nsource /opt/intel/impi/2019.5.281/intel64/bin/mpivars.sh release" >> /etc/profile.d/intel.sh \
    && echo -e "/opt/intel/lib/intel64 \n/opt/intel/mkl/lib/intel64 \n/opt/intel/impi/2019.5.281/intel64/lib \n/opt/intel/impi/2019.5.281/intel64/lib/release \n/opt/intel/impi/2019.5.281/intel64/libfabric/lib \n/opt/intel/impi/2019.5.281/intel64/libfabric/lib/prov" > /etc/ld.so.conf.d/intel.conf \
    && ldconfig
