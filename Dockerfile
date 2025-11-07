# ------------------------------------------------------------------------------
# Dockerfile : Instrumentation d'une application MPI avec Darshan
# ------------------------------------------------------------------------------

FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

# 1) Installation des paquets nécessaires
RUN apt-get update -y && \
    apt-get install -y \
        git \
        build-essential \
        wget \
        curl \
        cmake \
        python3 \
        python3-pip \
        openmpi-bin \
        libopenmpi-dev \
        zlib1g-dev \
        libbz2-dev \
        libcurl4-openssl-dev \
        bzip2 && \
    rm -rf /var/lib/apt/lists/*

# 2) Cloner le dépôt Darshan et se positionner sur le tag
ARG DARSHAN_TAG=darshan-3.4.3
RUN git clone https://github.com/darshan-hpc/darshan.git /opt/darshan && \
    cd /opt/darshan && \
    git checkout "${DARSHAN_TAG}" && \
    ./prepare.sh

# 3) Compiler et installer Darshan (runtime)
RUN cd /opt/darshan/darshan-runtime && \
    ./configure --prefix=/opt/darshan-install \
                --with-mem-align=8 \
                CC="mpicc" \
                --with-log-path=/tmp \
                --with-jobid-env=DOCKER_JOBID \
                --disable-cuserid \
                --disable-groupname && \
    make -j && \
    make install

# 4) Compiler et installer Darshan 
RUN cd /opt/darshan/darshan-util && \
    ./configure --prefix=/opt/darshan-install \
                --with-zlib \
                --enable-shared \
                CFLAGS='-fPIC -O3' && \
    make -j && \
    make install

# 5) Variables d'environnement pour Darshan
ENV PATH="/opt/darshan-install/bin:${PATH}"
# le :- évite l'avertissement BuildKit si LD_LIBRARY_PATH est vide
ENV LD_LIBRARY_PATH="/opt/darshan-install/lib:${LD_LIBRARY_PATH:-}"

# 6) Copie et compilation d'un exemple MPI
COPY my_mpi_io.c /usr/local/src/
WORKDIR /usr/local/src
RUN mpicc my_mpi_io.c -o my_mpi_io

# 7) Commande par défaut : bash interactif
CMD ["/bin/bash"]
