# Posit Package Manager API calls for Repositories

#' Get a repos ID from the repository name
#'
#' @param repo_name The repository name
#' @inheritParams status
#' @noRd
ppm_get_repo_id <- function(repo_name, url) {
  r <- list_repos(all = TRUE, url)
  id <- r[r$name == repo_name, "id"]
  if (length(id) == 0) {
    stop("Repository ", dQuote(repo_name), " not found")
  }
  id
}

#' List all available snapshot dates for a repository
#'
#' @param repo_name The repository name
#' @inheritParams status
#'
#' @return A vector of snapshot dates
#' @importFrom lubridate as_date ymd_hms
#' @export
list_snapshots <- function(repo_name, url = ppm_url()) {
  repo_id <- ppm_get_repo_id(repo_name, url)
  r <- jsonlite::fromJSON(file.path(url, "__api__", "repos", repo_id, "transaction-dates", fsep="/"))
  rev(unique(lubridate::as_date(lubridate::ymd_hms(r$date))))
}

#' List all repositories on server
#'
#' @param all If TRUE include hidden repositories. Defaults to FALSE.
#' @inheritParams status
#'
#' @return A data.frame of repositories
#' @export
list_repos <- function(all = FALSE, url = ppm_url()) {
  hidden <- type <- name <- NULL # check
  r <- jsonlite::fromJSON(file.path(url, "__api__", "repos", fsep="/"))
  r[r$hidden %in% c(FALSE, all) & r$type == "R", c("id", "name", "hidden")]
}
