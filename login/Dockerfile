FROM --platform=linux/x86_64 centos:8
LABEL maintainer=ohtaman

RUN dnf install -y epel-release dnf-plugins-core  redhat-rpm-config \
    && dnf config-manager --set-enabled powertools \
    && dnf install -y make automake cmake gcc-c++ \
    && dnf install -y openssl-devel bzip2-devel libffi-devel zlib-devel \
    && dnf install -y hdf5-devel python3-virtualenv


# Install SSH Server and Client
RUN dnf install -y openssh-server openssh-clients \
    && ssh-keygen -N "" -f /etc/ssh/ssh_host_rsa_key \
    && ssh-keygen -l -f /etc/ssh/ssh_host_rsa_key
COPY ssh_config /etc/ssh/ssh_config
COPY sshd_config /etc/ssh/sshd_config


# Install OpenMPI
RUN dnf install -y mpich mpich-devel

# Install OpenPBS Server
COPY openpbs-client-20.0.1-0.x86_64.rpm /tmp/
RUN dnf install -y python3 libedit tcl tk \
    && rpm -ivh /tmp/openpbs-client-20.0.1-0.x86_64.rpm

COPY entrypoint.sh /entrypoint.sh
CMD /entrypoint.sh