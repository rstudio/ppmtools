# PPM Sources API wrappers

#' Get a source ID from the source name
#'
#' Retrieves the internal source ID for the given source name.
#'
#' @param source_name The source name
#' @inheritParams status
#' @noRd
ppm_get_source_id <- function(source_name, url) {
  r <- list_sources(url)
  id <- r[r$name == source_name, "id"]
  if (length(id) == 0) {
    stop("Source ", dQuote(source_name), " not found")
  }
  id
}

#' List all sources
#'
#' @inheritParams status
#'
#' @return A data.frame of source names and ids
#' @export
list_sources <- function(url = ppm_url()) {
  r <- jsonlite::fromJSON(file.path(url, "__api__", "sources", fsep="/"))
  merge(r$Sources, source_types, by.x = "type", by.y = "id")[,c("id", "name", "typename", "lang", "last_sync")]
}

source_types <- data.frame(
  id = 0:10,
  typename = c("local", #0
           "cran", #1
           "curated-cran", #2
           "git", #3
           "pypi-legacy", #4
           "bioc-internal", #5
           "cran-snapshot", #6
           "bioc", #7
           "local-python", #8
           "pypi", #9
           "curated-pypi" #10
           ),
  lang = c("R", "R", "R", "R", "Python", "BioC", "R", "BioC", "Python", "Python", "Python")
)
