# Posit Package Manager API calls for Repositories

#' Get a repos ID from the repository name
#'
#' @param repo_name The repository name
#' @inheritParams status
#' @export
ppm_get_repo_id <- function(repo_name, url = ppm_url()) {
  r <- httr::GET(file.path(url, "__api__", "repos", fsep="/"))
  id <- unlist(sapply(httr::content(r), function(x) if(x$name == repo_name) x$id))
  if (is.null(id)) {
    stop("Repository ", dQuote(repo_name), " not found")
  }
  id
}

#' List all available snapshot dates for a repository
#'
#' @param repo_name The repository name
#' @inheritParams status
#'
#' @return A tibble of snapshot dates
#' @import dplyr
#' @importFrom lubridate as_date ymd_hms
#' @importFrom tidyjson spread_all
#' @export
list_snapshots <- function(repo_name, url = ppm_url()) {
  repo_id <- ppm_get_repo_id(repo_name, url)
  r <- httr::GET(file.path(url, "__api__", "repos", repo_id, "transaction-dates", fsep="/"))
  httr::content(r) %>%
    spread_all %>%
    select(date) %>%
    mutate(date=as_date(ymd_hms(date))) %>%
    as_tibble %>%
    distinct
}

#' List all repositories on server
#'
#' @param all If TRUE include hidden repositories. Defaults to FALSE.
#' @inheritParams status
#'
#' @return A tibble of repository names
#' @import dplyr
#' @importFrom tidyjson spread_all
#' @export
list_repos <- function(all = FALSE, url = ppm_url()) {
  hidden <- type <- name <- NULL # check
  r <- httr::GET(file.path(url, "__api__", "repos", fsep="/"))
  httr::content(r) %>%
    spread_all %>%
    filter(hidden == all | hidden == FALSE, type == "R") %>%
    select(id, name, hidden) %>%
    as_tibble
}
