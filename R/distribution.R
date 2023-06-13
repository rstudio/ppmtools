#' Detect the PPM distribution matching this system
#'
#' Attempts to detect the Package Manager binary distribution that
#' corresponds to the local operating system where R is running.
#'
#' @returns A string containing the Package Manager distribution name
#'
#' @export
detect_distro <- function() {
  osv <- utils::osVersion
  if (grepl("Windows", osv)) return("windows")
  if (grepl("macOS", osv)) return("macos")
  if (grepl("OS X", osv)) return("macos")
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

#' List binary distributions
#'
#' Retrieve a list of available distributions for binary R packages from Package Manager.
#'
#' @inheritParams status
#'
#' @return A data.frame of distribution names and a display name
#' @export
#'
#' @examples
#' distros <- list_distributions()
list_distributions <- function(url = ppm_url()) {
    result <- status(url)$distros
    result[result$hidden == FALSE, c("name", "display")]
}
