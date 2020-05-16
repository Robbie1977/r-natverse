FROM rocker/tidyverse

MAINTAINER "Gregory Jefferis" jefferis@gmail.com

## System libraries
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
  libglu1-mesa-dev

RUN install2.r natmanager && r -e "natmanager::selfupdate()"

RUN r -e "natmanager::install('core')"

# NB we use the natverse GITHUB PAT for the update process also
RUN r -e "natmanager::install('natverse')" \
  && r -e "natverse::natverse_update(update = TRUE, upgrade = 'always', auth_token=natmanager::check_pat(create = F))"
