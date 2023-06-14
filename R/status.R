#' Status API
#'
#' Fetch various properties from the Package Manager /status endpoint
#'
#' @param url The Package Manager URL.  Defaults to value of `options("ppm.url")`.
#'
#' @export
status <- function(url = ppm_url()) {
  jsonlite::fromJSON(construct_api_url("status", url = url))
}
