# PPM Sources API wrappers

#' Get a source ID from the source name
#'
#' Retrieves the internal source ID for the given source name.
#'
#' @param source_name The source name
#' @inheritParams status
#' @export
ppm_get_source_id <- function(source_name, url = ppm_url()) {
  r <- httr::GET(file.path(url, "__api__", "sources", fsep="/"))
  httr::stop_for_status(r)
  id <- unlist(sapply(httr::content(r)$Sources, function(x) if(x$name == source_name) x$id))
  if (is.null(id)) {
    stop("Source ", dQuote(source_name), " not found")
  }
  id
}

#' List packages
#'
#' Specify either source_name or repo_name.
#'
#' @param source_name The source name
#' @param repo_name The repository name
#' @param fields Package properties to retrieve
#' @inheritParams status
#'
#' @return A tibble containing one row per package and one column per field
#' @import dplyr
#' @importFrom tidyjson spread_all
#' @export
list_packages <- function(source_name, repo_name, fields = c("name", "version"), url = ppm_url()) {
  if (!missing(source_name) && !missing(repo_name)) {
    stop("Specify either source_name or repo_name, not both")
  }
  if (!missing(source_name)) {
    source_id <- ppm_get_source_id(source_name, url)
    r <- httr::GET(file.path(url, "__api__", "sources", source_id, "packages", fsep = "/"))
  } else {
    repo_id <- ppm_get_repo_id(repo_name, url)
    r <- httr::GET(file.path(url, "__api__", "repos", repo_id, "packages", fsep = "/"))
  }
  httr::stop_for_status(r)
  httr::content(r) %>%
    spread_all %>%
    select(any_of(fields)) %>%
    as_tibble
}
