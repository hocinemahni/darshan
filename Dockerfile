# ------------------------------------------------------------------------------
# Dockerfile : Instrumentation d'une application MPI avec Darshan (Ubuntu 22.04)
# ------------------------------------------------------------------------------

FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

# 1) Dépendances système + TeX Live complet
RUN apt-get update -y && \
    apt-get install -y \
        git build-essential wget curl cmake \
        python3 python3-pip \
        openmpi-bin libopenmpi-dev \
        zlib1g-dev libbz2-dev libcurl4-openssl-dev bzip2 \
        gnuplot ghostscript \
        texlive texlive-base texlive-latex-base texlive-latex-recommended \
        texlive-latex-extra texlive-fonts-recommended texlive-fonts-extra \
        latexmk \
        perl cpanminus \
        libpod-simple-perl libpod-markdown-perl libcapture-tiny-perl \
        libfile-which-perl libyaml-tiny-perl libconfig-tiny-perl && \
    cpanm Pod::Select && \
    rm -rf /var/lib/apt/lists/*

# 2) Récupérer Darshan
ARG DARSHAN_TAG=darshan-3.4.3
RUN git clone https://github.com/darshan-hpc/darshan.git /opt/darshan && \
    cd /opt/darshan && git checkout "${DARSHAN_TAG}" && ./prepare.sh

# 3) Compiler runtime
RUN cd /opt/darshan/darshan-runtime && \
    ./configure --prefix=/opt/darshan-install \
                --with-mem-align=8 \
                CC="mpicc" \
                --with-log-path=/tmp \
                --with-jobid-env=DOCKER_JOBID \
                --disable-cuserid --disable-groupname && \
    make -j && make install

# 4) Compiler utilitaires
RUN cd /opt/darshan/darshan-util && \
    ./configure --prefix=/opt/darshan-install \
                --with-zlib --enable-shared CFLAGS='-fPIC -O3' && \
    make -j && make install

# 5) Rendre les libs visibles globalement
RUN cp /opt/darshan-install/lib/libdarshan* /usr/local/lib/ && \
    ldconfig

# ENV
ENV PATH="/opt/darshan-install/bin:${PATH}"
ENV LD_LIBRARY_PATH="/opt/darshan-install/lib:${LD_LIBRARY_PATH:-}"

# 6) Exemple MPI
COPY my_mpi_io.c /usr/local/src/
WORKDIR /usr/local/src
RUN mpicc my_mpi_io.c -o my_mpi_io

CMD ["/bin/bash"]
