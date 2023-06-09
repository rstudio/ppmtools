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

#' List all sources
#'
#' @inheritParams status
#'
#' @return A tibble of source names
#' @import dplyr
#' @importFrom tidyjson spread_all
#' @export
list_sources <- function(url = ppm_url()) {
  type <- name <- NULL # check
  r <- httr::GET(file.path(url, "__api__", "sources", fsep="/"))
  httr::stop_for_status(r)
  httr::content(r)$Sources %>%
    spread_all %>%
    #filter(hidden == all | hidden == FALSE, type == "R") %>%
    select(id, name) %>%
    as_tibble
}

#' List packages
#'
#' Specify either source_name or repo_name.
#'
#' @param repo_name The repository name
#' @param source_name The source name
#' @param search A search string to perform a substring match against package names
#' @param fields Package properties to retrieve
#' @param max_rows Maximum number of packages to return.
#' @inheritParams status
#'
#' @return A tibble containing one row per package and one column per field
#' @import dplyr
#' @importFrom tidyjson spread_all
#' @export
list_packages <- function(repo_name, source_name, search = "", fields = c("name", "version"), max_rows = 100, url = ppm_url()) {
  if (!missing(repo_name) && !missing(source_name)) {
    stop("Specify either repo_name or source_name, not both")
  }

  if (!missing(source_name)) {
    id <- ppm_get_source_id(source_name, url)
    type <- "sources"
  } else {
    id <- ppm_get_repo_id(repo_name, url)
    type <- "repos"
  }
  result_count <- 0
  total_results <- 1
  result_page <- 1
  while (result_count < max_rows && result_count < total_results) {
    r <- httr::GET(file.path(url, "__api__", type, id, "packages", fsep = "/"),
                   query = list(`_limit` = max_rows,
                                `_page` = result_page,
                                name_like = search))
    httr::stop_for_status(r)
    rs <- httr::content(r) %>%
                spread_all %>%
                select(any_of(fields)) %>%
                as_tibble
    if (result_page == 1) {
      results <- rs
      total_results <- as.numeric(httr::headers(r)$`x-total-count`)
    } else {
      if (nrow(rs) > max_rows-result_count) {
        rs <- rs[1:(max_rows-result_count),]
      }
      results <- results %>%
        bind_rows(rs)
    }
    result_count <- result_count + nrow(rs)
    result_page <- result_page + 1
  }
  results
}
