# r-natverse

<!-- badges: start -->
<!-- badges: end -->

The [natverse](http://natverse.org) is a suite of tools for
neuroanatomical analysis primarily written in [R](https://www.r-project.org/).
The goal of *r-natverse* is to provide a batteries included *natverse*
installation as a single docker image with all the necessary
dependencies including R itself. This could be helpful either for
end users hoping to carry out neuroanatomical analysis or for those
running natverse based services. The base images are provided by
https://hub.docker.com/r/rocker and in particular we are currently
using the [tidyverse](https://hub.docker.com/r/rocker/tidyverse)
series which are versioned i.e. tied to a particular R version and
the state of the MRAN (CRAN snapshot) matching the last date that
version was current.

