FROM centos:7

SHELL ["/bin/bash", "--login", "-c"]

RUN yum install -y cpio

WORKDIR /usr/local/src

# install Intel Compiler and Intel MPI
COPY intel_license_file.lic /opt/intel/licenses/USE_SERVER.lic
ADD intel19.01_silent.cfg .
ADD parallel_studio_xe_2019_update1_cluster_edition_online.tgz .

RUN cd parallel_studio_xe_2019_update1_cluster_edition_online \
    && ./install.sh --ignore-cpu -s /usr/local/src/intel19.01_silent.cfg

RUN echo -e "source /opt/intel/bin/compilervars.sh intel64 \nsource /opt/intel/mkl/bin/mklvars.sh intel64 \nsource /opt/intel/impi/2019.1.144/intel64/bin/mpivars.sh release" >> /etc/profile.d/intel.sh \
    && echo -e "/opt/intel/lib/intel64 \n/opt/intel/mkl/lib/intel64 \n/opt/intel/impi/2019.1.144/intel64/lib \n/opt/intel/impi/2019.1.144/intel64/lib/release \n/opt/intel/impi/2019.1.144/intel64/libfabric/lib \n/opt/intel/impi/2019.1.144/intel64/libfabric/lib/prov" > /etc/ld.so.conf.d/intel.conf \
    && ldconfig
