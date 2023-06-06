#' Detect the PPM distribution matching this system
#'
#' Attempts to detect the Package Manager binary distribution that
#' corresponds to the local operating system where R is running.
#'
#' @returns A string containing the Package Manager distribution name
#'
#' @export
detect_distro <- function() {
  # Windows and macOS are easy to find based on the Sys.info()
  OS <- Sys.info()["sysname"]
  if (OS == "Windows") {
    "windows"
  } else if (OS == "Darwin") {
    "macos"
  } else {
    osv <- utils::osVersion
    if (grepl("Ubuntu 18", osv)) return("bionic")
    if (grepl("Ubuntu 20", osv)) return("focal")
    if (grepl("Ubuntu 22", osv)) return("jammy")
    if (grepl("Red Hat .* 7\\.", osv)) return("rhel7")
    if (grepl("Red Hat .* 8\\.", osv)) return("rhel8")
    if (grepl("Red Hat .* 9\\.", osv)) return("rhel9")
    if (grepl("Rocky .* 8", osv)) return("rhel8")
    if (grepl("Rocky .* 9", osv)) return("rhel9")
    if (grepl("SUSE Linux Enterprise .* 15", osv)) return("sles154")
    if (grepl("openSUSE .* 15", osv)) return("opensuse154")
    if (grepl("CentOS .* 7", osv)) return("centos7")
    if (grepl("CentOS .* 8", osv)) return("rhel8")
    cli::cli_alert_warning("Could not detect system distribution.  Specify explicitly using the `distro` argument.")
    "unknown"
  }
}

#' List binary distributions
#'
#' Retrieve a list of available distributions for binary R packages from Package Manager.
#'
#' @inheritParams status
#'
#' @return A tibble of distribution names and a display name
#' @import dplyr tidyjson
#' @export
#'
#' @examples
#' distros <- list_distributions()
list_distributions <- function(url = ppm_url()) {
  hidden <- name <- display <- NULL # check
  status(url)$distros %>%
    spread_all %>%
    filter(hidden == FALSE) %>%
    select(name, display) %>%
    as_tibble
}
