FROM rocker/r-ver

MAINTAINER "Gregory Jefferis" jefferis@gmail.com

## System libraries
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
  cmake \
  git
  
RUN mkdir -p /tmp/src && cd /tmp/src \
  && git clone --depth 5 https://github.com/jefferis/cmtk \
  && cd cmtk/core && mkdir build && cd build \
  && cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr/local .. \
  && make all install \
  && cd / \
  && rm -rf /tmp/src \
  && apt-get autoclean -y \
  && rm -rf /var/lib/apt/lists/*

CMD ["R"]
