# r-natverse

<!-- badges: start -->
<!-- badges: end -->

The [natverse](http://natverse.org) is a suite of tools for
neuroanatomical analysis primarily written in [R](https://www.r-project.org/).
The goal of **r-natverse** is to provide a batteries included **natverse**
installation as a single [Docker](https://www.docker.com/) image with all the necessary
dependencies including R itself and the [RStudio](https://www.rstudio.com/) 
graphical interface. This is the quickest way to get started with the natverse.

## Quick start
1. Install [Docker](https://docs.docker.com/get-docker/)
2. In the terminal 
```
docker pull natverse/r-natverse
docker run -p 127.0.0.1:8787:8787 \
  -e DISABLE_AUTH=true \
	-v "$HOME":/home/rstudio \
	natverse/r-natverse
```
3. Open http://127.0.0.1:8787 in your browser!
4. Find out how to use the **natverse** at http://natverse.org/learn

For more details about accessing your files and 
user/security issues read the sections below.

## Introduction 

The *r-natverse* docker image could be useful for
end users hoping to carry out neuroanatomical analysis or for those
running natverse based services. The base images are provided by
https://hub.docker.com/r/rocker and in particular we are currently
using the [tidyverse](https://hub.docker.com/r/rocker/tidyverse)
series which are versioned i.e. tied to a particular R version and
the state of the MRAN (CRAN snapshot) matching the last date that
version was current.

Docker operates on the basis of *images* which can be downloaded and used to run
a *container* on your local machine. The container allows you to run software
which has been installed in a standardised way. Containers typically provide multiple
pieces of software. **r-natverse** provides both R and the RStudio GUI.

## Getting the r-natverse docker image

You must first have [docker installed](https://docs.docker.com/get-docker/) on your machine.

### Straight from Docker

You can get the pre-built image straight from Docker:

```
docker pull natverse/r-natverse
```

### Building

You can also build the container from a local checkout:

```
git clone jefferis/r-natverse
cd r-natverse
make
```

## Run

Once you have the image, you can run a container. There are a range of different
ways to do this, but the key points are whether you will run the basic R command
line tool or run the full-featured RStudio GUI. You also need to consider whether
you would like to link the container to your regular file system (so that you 
can access your files outside the container). Finally there may be questions
about which *user* your docker images 

For more information about users and volumes go to https://www.rocker-project.org.

### RStudio
It is normally recommended to run your Rstudio server with a password. You can 
do this by replacing `<MYPASSWORD>` in the following command. 
```
docker run -e PASSWORD="<MYPASSWORD>" -p 8787:8787 \
	-v "$HOME":/home/rstudio \
	natverse/r-natverse
```

You could also set a password via an environment variable. See 
https://www.rocker-project.org/use/managing_users/ for more details of users/
security.

The -v option links the docker container to your local file system. In 
particular on most systems `$HOME` will point to your home directory. Inside the
container, the RStudio application will run as the `rstudio` user, so your files
will appear at `/home/rstudio`, which should be the starting path in RStudio.
See https://www.rocker-project.org/use/shared_volumes/ for more details.

### R

You can run the command line version of base R like so: 

```
docker run -ti -v "$HOME":/home/rstudio \
  natverse/r-natverse R
```

## Limitations

The main limitations of using the containerised natverse distribution

* interactive 3D display: support for the the RGL package is not available by 
  default. There is a fall-back to the WebGL plotly 3D graphics but this still 
  has some limitations. See [here](http://natverse.org/nat/articles/plotly.html) 
  for details.
* speed: performance of Docker containers is surprisingly good in my 
  experience (some even benchmarks can even be better than the host system).
  However there may be limitations in how much memory can be addressed or the
  number of cores available for parallel processing.
