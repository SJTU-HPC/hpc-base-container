FROM centos:7

SHELL ["/bin/bash", "--login", "-c"]

RUN yum install -y cpio wget
RUN yum groupinstall -y 'Development Tools'

WORKDIR /usr/local/src

# Install Intel Cluster Studio License
RUN mkdir -p /opt/intel/licenses
RUN wget http://spack.pi.sjtu.edu.cn/mirror/intel-parallel-studio/intel.lic /opt/intel/licenses

# Configure Intel Cluster Studio (TODO: replace with docker heredoc)
RUN echo $'ACCEPT_EULA=accept\n\
CONTINUE_WITH_OPTIONAL_ERROR=yes\n\
PSET_INSTALL_DIR=/opt/intel\n\
CONTINUE_WITH_INSTALLDIR_OVERWRITE=yes\n\
COMPONENTS=;intel-clck__x86_64;intel-icc__x86_64;intel-ifort__x86_64;intel-mkl-core-c__x86_64;intel-mkl-cluster-c__noarch;intel-mkl-gnu-c__x86_64;intel-mkl-core-f__x86_64;intel-mkl-cluster-f__noarch;intel-mkl-gnu-f__x86_64;intel-mkl-f__x86_64;intel-imb__x86_64;intel-mpi-sdk__x86_64\n\
PSET_MODE=install\n\
ACTIVATION_LICENSE_FILE=/opt/intel/licenses/intel.lic\n\
ACTIVATION_TYPE=license_server\n\
AMPLIFIER_SAMPLING_DRIVER_INSTALL_TYPE=kit\n\
AMPLIFIER_DRIVER_ACCESS_GROUP=vtune\n\
AMPLIFIER_DRIVER_PERMISSIONS=666\n\
AMPLIFIER_LOAD_DRIVER=no\n\
AMPLIFIER_C_COMPILER=none\n\
AMPLIFIER_KERNEL_SRC_DIR=none\n\
AMPLIFIER_MAKE_COMMAND=/usr/bin/make\n\
AMPLIFIER_INSTALL_BOOT_SCRIPT=no\n\
AMPLIFIER_DRIVER_PER_USER_MODE=no\n\
SIGNING_ENABLED=yes\n\
ARCH_SELECTED=INTEL64\n '\
>> intel.cfg


# Install Intel Cluster Studio License
RUN wget http://spack.pi.sjtu.edu.cn/mirror/intel-parallel-studio/intel-parallel-studio-cluster.2019.5.tgz
RUN tar xzvpf intel-parallel-studio-cluster.2019.5.tgz
RUN ls
RUN cd parallel_studio_xe_2019_update5_cluster_edition && ./install.sh --ignore-cpu -s ../intel.cfg

# Setup MPI environment PATH
RUN echo -e "source /opt/intel/bin/compilervars.sh intel64 \nsource /opt/intel/mkl/bin/mklvars.sh intel64 \nsource /opt/intel/impi/2019.5.281/intel64/bin/mpivars.sh release" >> /etc/profile.d/intel.sh \
    && echo -e "/opt/intel/lib/intel64 \n/opt/intel/mkl/lib/intel64 \n/opt/intel/impi/2019.5.281/intel64/lib \n/opt/intel/impi/2019.5.281/intel64/lib/release \n/opt/intel/impi/2019.5.281/intel64/libfabric/lib \n/opt/intel/impi/2019.5.281/intel64/libfabric/lib/prov" > /etc/ld.so.conf.d/intel.conf \
    && ldconfig
