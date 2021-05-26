# USAGE
# -----
#
# To build an image (in your build dir you must have amgcl-master.zip):
#
#   docker build --build-arg UID=`id -u` --build-arg GID=`id -g` -t red . 
#
# To launch a container (and mount the current dir):
#
#   docker run -ti --name red -v $PWD:/home/red/project red

FROM ubuntu:20.04
SHELL ["/bin/bash", "-c"]

ENV USER red
ENV HOME /home/$USER

ARG N_CORES=4
ARG UID=1000
ARG GID=1000

ENV MPI_DIR=/opt/ompi
ENV PATH $MPI_DIR/bin:$HOME/.local/bin:$PATH
ENV LD_LIBRARY_PATH $MPI_DIR/lib
ARG MPI_VERSION=3.1.4

ENV MAKE_DIR=/opt/make
ARG MAKE_VERSION=4.3
ENV PATH $MAKE_DIR/bin:$PATH

####
## If you need to install a specific version of boost (old code, not sure)
####
# ARG BOOST_DIR=/usr/local/boost
# ARG BOOST_VERSION=1.55.0
# ENV PATH $BOOST_DIR/bin:$PATH
# ENV LD_LIBRARY_PATH=$BOOST_DIR/lib:$LD_LIBRARY_PATH

WORKDIR /tmp
####
## Basic dependencies for MPI and some dev tools
## P.S. if you install boost from source, remove libboost-all-dev package
####
RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get -qq update \
    && apt-get install -yq \
      build-essential python3-dev libboost-all-dev \
      neovim cmake wget git unzip \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

####
## Install new Make (>=4.3 at the time this file was written) from source
####
RUN wget http://ftp.gnu.org/gnu/make/make-$MAKE_VERSION.tar.gz \
    && tar xf make-$MAKE_VERSION.tar.gz \
    && cd make-$MAKE_VERSION \
    && ./configure --prefix=$MAKE_DIR \
    && make -j$N_CORES  && make -j$N_CORES install \
    && rm -rf /tmp/*

####
## Install OpenMPI
####
RUN tarball=v${MPI_VERSION%.*}/openmpi-$MPI_VERSION.tar.bz2 \
    && wget -nc -q https://download.open-mpi.org/release/open-mpi/$tarball \
    && tar xf openmpi-$MPI_VERSION.tar.bz2 \
    && cd openmpi-$MPI_VERSION \
    && ./configure --prefix=$MPI_DIR \
    && make -j$N_CORES all && make -j$N_CORES install \
    && rm -rf /tmp/*

####
## If you need to install a specific version of boost (old code, not sure)
####
# RUN tarball=$BOOST_VERSION/boost_${BOOST_VERSION//./_}.tar.bz2 \
#     && wget -nc -q https://sourceforge.net/projects/boost/files/boost/$tarball \
#     && tarball=${tarball#*/} && tar xf $tarball \
#     && cd ${tarball%%.*} \
#     && ./bootstrap.sh --prefix=$BOOST_DIR \
#     && ./b2 --with=all -j$N_CORES install

WORKDIR $HOME
####
## Download Eigen & Set up your .bashrc here
####
RUN git clone https://gitlab.com/libeigen/eigen.git \
    && echo "# >>> RESERVED-CONFS >>>" >> .bashrc \
    && echo "export SFLOW_BOOST_DIR=/usr/include/boost" >> .bashrc \
    && echo "export SFLOW_AMGCL_DIR=~/amgcl-master" >> .bashrc \
    && echo "export SFLOW_EIGEN_DIR=~/eigen" >> .bashrc \
    && echo "# <<< RESERVED-CONFS <<<" >> .bashrc

####
## Add non-root user to the container
####
RUN groupadd -g $GID $USER \
    && useradd -u $UID -g $USER $USER \
    && chown -R $USER:$USER $HOME

####
## Better to clone amgcl from the git repo, however, the current version of
## of CMakeLists.txt (or other parts of the implementation) does(/do) not
## allow using other versions than the one being copied below.
## P.S. if you use docker of version < 19.03.1, then $USER must be hardcoded
####
# COPY --chown=$USER amgcl-master.zip PoreFlow-0-1-7.zip .
COPY --chown=red amgcl-master.zip .
RUN unzip amgcl-master.zip \
    && rm amgcl-master.zip

USER $USER
#ENTRYPOINT ["/bin/bash"]
