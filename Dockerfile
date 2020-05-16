FROM rocker/tidyverse

MAINTAINER "Gregory Jefferis" jefferis@gmail.com

## System libraries
RUN apt-get update \
    && apt-get install -y \
       libglu1-mesa-dev 
       
RUN install2.r natmanager
RUN r -e "natmanager::install('core')" 
