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
#' @return A data.frame containing one row per package and one column per field
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
  result_page <- 1
  results <- data.frame()
  while (nrow(results) < max_rows) {
    r <- jsonlite::fromJSON(file.path(url, "__api__", type, id, "packages",
                            paste0("?_limit=", max_rows,
                                   "&_page=", result_page,
                                   "&name_like=", search,
                                   "&exact_first=true"),
                            fsep = "/"))
    if (length(r) == 0) break;
    rs <- r[, fields]
    if (nrow(results) + nrow(rs) >= max_rows) {
      # truncate last page to only what's needed for max_rows
      results <- rbind(results, rs[1:(max_rows-nrow(results)),])
      break;
    }
    results <- rbind(results, rs)
    result_page <- result_page + 1
  }
  results
}
