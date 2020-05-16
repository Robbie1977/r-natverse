FROM rocker/tidyverse

MAINTAINER "Gregory Jefferis" jefferis@gmail.com

## System libraries
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
  libglu1-mesa-dev \
  && install2.r natmanager \
  && r -e "natmanager::install('core')" \
  && r -e "natmanager::install('natverse')"
