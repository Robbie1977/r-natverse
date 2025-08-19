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

# Install natverse packages with fallback approaches and rate limit handling
RUN R -e "natmanager::install('core')" || R -e "remotes::install_github('natverse/nat')"

# Try to install key packages individually to avoid rate limits
RUN R -e "remotes::install_github('natverse/nat.h5reg')" || echo "nat.h5reg install failed"
RUN R -e "remotes::install_github('natverse/nat.jrcbrains')" || echo "nat.jrcbrains install failed"

# Only try full natverse if essential packages succeeded
RUN R -e "if(require('nat.h5reg', quietly=TRUE)) natmanager::install('natverse')" || echo "Full natverse install skipped due to dependencies"

# Diagnostic step to verify installation
RUN R -e "library(nat.h5reg); dr_h5reg()" || echo "nat.h5reg diagnostic failed but continuing..."

# Only try update if we have a working natverse installation
RUN R -e "if(require('natverse', quietly=TRUE)) natverse::natverse_update(update = FALSE)" || echo "natverse update skipped"

RUN apt-get autoclean -y \
  && rm -rf /var/lib/apt/lists/*
  
