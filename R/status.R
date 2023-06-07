#' Status API
#'
#' Fetch various properties from the Package Manager /status endpoint
#'
#' @param url The Package Manager URL.  Defaults to value of `options("ppm.url")`.
#'
#' @export
status <- function(url = ppm_url()) {
  r <- httr::GET(file.path(url, "__api__", "status", fsep="/"))
  httr::stop_for_status(r)
  httr::content(r)
}
