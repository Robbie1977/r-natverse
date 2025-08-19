FROM rocker/tidyverse:latest

LABEL maintainer="Robert Court <rcourt@ed.ac.uk>"

## System libraries - install comprehensive Java and HDF5 support
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
  cmake \
  git \
  libglu1-mesa-dev \
  libhdf5-dev \
  libhdf5-serial-dev \
  libhdf5-hl-cpp-100t64 \
  hdf5-helpers \
  hdf5-tools \
  libzmq3-dev \
  openjdk-11-jdk \
  openjdk-11-jre \
  ca-certificates-java

# Configure Java environment and reconfigure R for Java
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH="$JAVA_HOME/bin:$PATH"
RUN update-ca-certificates -f && \
    R CMD javareconf

# Install IRkernel for potential Jupyter notebook support
RUN R -e "install.packages('IRkernel')"

# Set environment variables for HDF5
ENV HDF5_USE_FILE_LOCKING=FALSE

RUN mkdir -p /tmp/src && cd /tmp/src \
  && git clone --depth 5 https://github.com/jefferis/cmtk \
  && cd cmtk/core && mkdir build && cd build \
  && cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr/local \
           -DCMAKE_CXX_FLAGS="-Wno-error=deprecated-declarations -std=c++14" .. \
  && make all install \
  && cd / \
  && rm -rf /tmp/src 


RUN apt-get update -qq && apt-get install -y --no-install-recommends \
  pkg-config libcurl4-openssl-dev libssl-dev libxml2-dev

# Dependencies needed for R libraries
RUN apt-get update  -qq \
   && apt-get install -y --no-install-recommends libcairo2-dev libxt-dev \
   libpq-dev \
   libudunits2-dev libgdal-dev libgeos-dev libproj-dev \
   libglpk-dev

# Install the R libraries with improved dependency handling
RUN R -e "install.packages(c('tidyverse', 'data.table', 'RSQLite', 'remotes', 'reticulate', 'igraph', 'plotly'), lib='/usr/local/lib/R/site-library', dependencies = T)"

# Install rJava first with proper Java configuration
RUN R -e "install.packages('rJava', lib='/usr/local/lib/R/site-library', dependencies = T)"

# Install hdf5r explicitly with comprehensive HDF5 support
RUN R -e "install.packages('hdf5r', lib='/usr/local/lib/R/site-library', dependencies = T, configure.args='--with-hdf5=/usr/lib/x86_64-linux-gnu/hdf5/serial')"

# Install core natverse packages using proper natmanager approach
RUN install2.r natmanager || true
RUN install2.r natmanager && r -e "try(natmanager::selfupdate())"

# Install natverse packages with fallback approaches
RUN R -e "natmanager::install('core')" || R -e "remotes::install_github('natverse/nat')"
RUN R -e "natmanager::install('natverse')" || R -e "remotes::install_github('natverse/natverse')"

# Diagnostic step to verify installation
RUN R -e "library(nat.h5reg); dr_h5reg()" || echo "nat.h5reg diagnostic failed but continuing..."

# NB we use the natverse GITHUB PAT for the update process also
RUN r -e "natverse::natverse_update(update = TRUE, upgrade = 'always', auth_token=natmanager::check_pat(create = F))" || true

RUN apt-get autoclean -y \
  && rm -rf /var/lib/apt/lists/*
  
