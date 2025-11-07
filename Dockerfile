# ------------------------------------------------------------------------------
# Dockerfile : Instrumentation d'une application MPI avec Darshan (Ubuntu 22.04)
# ------------------------------------------------------------------------------

FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && \
    apt-get install -y \
        git build-essential wget curl cmake \
        python3 python3-pip \
        openmpi-bin libopenmpi-dev \
        zlib1g-dev libbz2-dev libcurl4-openssl-dev bzip2 \
        gnuplot \
        perl cpanminus \
        libpod-simple-perl \
        libpod-markdown-perl \
        libcapture-tiny-perl \
        libfile-which-perl \
        libyaml-tiny-perl \
        libconfig-tiny-perl \
        texlive \
        texlive-latex-base \
        texlive-latex-recommended \
        texlive-fonts-recommended && \
    cpanm Pod::Select && \
    rm -rf /var/lib/apt/lists/*

ARG DARSHAN_TAG=darshan-3.4.3
RUN git clone https://github.com/darshan-hpc/darshan.git /opt/darshan && \
    cd /opt/darshan && git checkout ${DARSHAN_TAG} && ./prepare.sh

RUN cd /opt/darshan/darshan-runtime && \
    ./configure --prefix=/opt/darshan-install \
                --with-mem-align=8 \
                CC="mpicc" \
                --with-log-path=/tmp \
                --with-jobid-env=DOCKER_JOBID \
                --disable-cuserid \
                --disable-groupname && \
    make -j && make install

RUN cd /opt/darshan/darshan-util && \
    ./configure --prefix=/opt/darshan-install \
                --with-zlib \
                --enable-shared \
                CFLAGS='-fPIC -O3' && \
    make -j && make install

RUN cp /opt/darshan-install/lib/libdarshan* /usr/local/lib/ && ldconfig

ENV PATH="/opt/darshan-install/bin:${PATH}"
ENV LD_LIBRARY_PATH="/opt/darshan-install/lib:${LD_LIBRARY_PATH:-}"

COPY my_mpi_io.c /usr/local/src/
WORKDIR /usr/local/src
RUN mpicc my_mpi_io.c -o my_mpi_io

CMD ["/bin/bash"]
