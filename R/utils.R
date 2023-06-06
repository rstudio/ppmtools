# Internal utilities

P3M <- "https://packagemanager.posit.co"

# Fetch the ppm URL or error
ppm_url <- function() {
  u <- getOption("ppm.url", P3M)
  if (is.null(u) || length(u) != 1) {
    stop("PPM URL unset.  Provide url as argument to function or set options('ppm.url').")
  }
  u
}

construct_repo_url <- function(repo_name, distro, snapshot = "latest", url) {
  if (distro %in% c("windows", "macos")) {
    file.path(url, repo_name, snapshot, fsep="/")
  } else {
    file.path(url, repo_name, "__linux__", distro, snapshot, fsep="/")
  }
}
