
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ppmtools

<!-- badges: start -->
[![R-CMD-check](https://github.com/rstudio/ppmtools/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/rstudio/ppmtools/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

ppmtools is a package of tools for working with R and [Posit Package
Manager](https://posit.co/products/enterprise/package-manager/).

> **Warning**
>
> This package is currently a work-in-progress. Feel free to try it out
> and use it, but expect that any function names, arguments, or outputs
> may change in future updates. Feedback welcome anytime!

## Installation

You can install the development version of ppmtools from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("rstudio/ppmtools")
```

## Basic Configuration with Posit Public Package Manager

`ppmtools` can automatically configure R to install packages from Posit
Package Manager. By default, this will set your CRAN repository to use
Posit Public Package Manager
([packagemanager.posit.co](https://packagemanager.posit.co)).

``` r
library(ppmtools)
configure()
```

## Using Your Own Posit Package Manager server

If your organization uses professional Posit Package Manager, you can
easily configure `ppmtools` to use your internal server. Set
`options("ppm.url")` to the URL of your organization’s Package Manager
server before calling `configure()`.

``` r
library(ppmtools)
options(ppm.url = "http://packagemanager.mycompany.com")
configure()
```

## Publishing packages to Package Manager

To publish your own packages to a local Package Manager source, use the
`publish()` function.

Publishing packages requires an API Token for authentication. Obtain the
necessary credentials from your Package Manager administrator and set
the token in `options("ppm.api_token")`. Then use `publish()` with the
name of the local source to publish to.

``` r
options(ppm.api_token = "<PPM API TOKEN>")
publish("localR")
```

To also publish a binary built version of your package, enabling faster
installation for others without requiring a package build, add
`binary = TRUE` to your `publish()` command.

``` r
publish("localR", binary = TRUE)
```

## Package Manager APIs

Many of the commands for browsing the Package Manager remotely are
available via R functions. For example, to view the packages available
in a repository, use the `list_packages()` command:

``` r
list_packages(source="localR")
```

Browse all of the available functions in the package help using
`help(package="ppmtools")`.
