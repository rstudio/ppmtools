# Internal utilities

#' @export
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

json_extract <- function(object, fields) {
  as.data.frame(sapply(fields, function(x) sapply(object, '[[', x)))
}

#' Build a PPM API URL
#'
#' Builds an appropriately formated URL to call the PPM API given the
#' necessary components.
#'
#' @param ... url path components following but not including "/__api__/"
#' @param url base URL
#' @param query list of query parameters to be added to URL
#'
#' @return A complete URL string
#' @noRd
construct_api_url <- function(..., url, query) {
  result <- file.path(url, "__api__", ..., fsep = "/")
  if (!missing(query) && is.list(query) && length(query) > 0) {
    query_string <- paste0(names(unlist(query)), "=", unlist(query), collapse="&")
    result <- paste0(result, "?", query_string)
  }
  result
}
