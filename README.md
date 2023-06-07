
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ppmtools

<!-- badges: start -->
[![R-CMD-check](https://github.com/rstudio/ppmtools/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/rstudio/ppmtools/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

ppmtools is a package of tools for working with R and Posit Package
Manager.

## Installation

You can install the development version of ppmtools from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("rstudio/ppmtools")
```

## Example

Configure R to install packages from Posit Package Manager. By default,
this will set your CRAN repository to use Posit Public Package Manager
([packagemanager.posit.co](https://packagemanager.posit.co)).

``` r
library(ppmtools)
configure()  
#> ── Configuring R to use Posit Package Manager ──────────────────────────────────
#> ℹ Using Package Manager v2023.04.0-6 at <https://packagemanager.posit.co>
#> ℹ Detected Package Manager binary distribution as 'windows'
#> ℹ Only one compatible repository on server, using 'cran'.
#> ℹ Updated CRAN repository URL to https://packagemanager.posit.co/cran/latest
#> ✔ Configuration complete
```