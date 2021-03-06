FROM deepnote/ir:4.0.3

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


RUN apt-get update -qq && apt-get install -y --no-install-recommends \
  pkg-config libcurl4-openssl-dev libssl-dev libxml2-dev

# Dependencies needed for R libraries
RUN apt-get update  -qq \
   && apt-get install -y --no-install-recommends libcairo2-dev libxt-dev \
   libpq-dev \
   libudunits2-dev libgdal-dev libgeos-dev libproj-dev

# Install the R libraries
RUN R -e "install.packages(c('tidyverse', 'data.table', 'RSQLite', 'remotes', 'reticulate', 'igraph', 'plotly'), lib='/usr/local/lib/R/site-library', dependencies = T)"

# try because otherwise the stop inside selfupdate can stop the build here
RUN install2.r natmanager || true
RUN install2.r natmanager && r -e "try(natmanager::selfupdate())"

RUN R -e "install.packages('plotly', lib='/usr/local/lib/R/site-library')"

RUN r -e "natmanager::install('core')" || true

# NB we use the natverse GITHUB PAT for the update process also
RUN r -e "natmanager::install('natverse')" || true
RUN r -e "natverse::natverse_update(update = TRUE, upgrade = 'always', auth_token=natmanager::check_pat(create = F))" || true

RUN apt-get autoclean -y \
  && rm -rf /var/lib/apt/lists/*
  
