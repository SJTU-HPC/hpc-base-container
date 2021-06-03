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

