FROM rocker/tidyverse

MAINTAINER "Gregory Jefferis" jefferis@gmail.com

## System libraries
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
  cmake \
  git \
  libglu1-mesa-dev \
  libhdf5-dev

RUN mkdir -p /tmp/src && cd /tmp/src \
  && git clone --depth 5 https://github.com/jefferis/cmtk \
  && cd cmtk/core && mkdir build && cd build \
  && cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr/local .. \
  && make all install \
  && cd / \
  && rm -rf /tmp/src 

# Java for rJava
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
  default-jdk \
  libbz2-dev \
  liblzma-dev \
  gcc-7 g++-7 gfortran-7 \
  build-essential \
  && R CMD javareconf \
  install2.r rJava

RUN r -e 'install.packages("igraph")'

RUN r -e 'if (!require("devtools")) install.packages("devtools")' \
&& r -e 'devtools::install_github("natverse/elmr")' \
&& r -e 'devtools::install_github("natverse/neuprintr")' 

# try because otherwise the stop inside selfupdate can stop the build here
RUN install2.r natmanager && r -e "try(natmanager::selfupdate())"

RUN r -e "natmanager::install('core')"

# NB we use the natverse GITHUB PAT for the update process also
RUN r -e "natmanager::install('natverse')" \
  && r -e "natverse::natverse_update(update = TRUE, upgrade = 'always', auth_token=natmanager::check_pat(create = F))"

RUN apt-get autoclean -y \
  && rm -rf /var/lib/apt/lists/*
  
RUN ln -s /usr/bin/python3 /usr/bin/python
