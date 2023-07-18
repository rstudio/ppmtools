#' Create Git Builder
#'
#' Create a new git builder for a git source
#'
#' @param source
#' @param git_url
#' @param branch
#' @param credential
#' @param subdir
#' @param wait
#' @param build_trigger
#' @param url The Package Manager URL.  Defaults to value of `options("ppm.url")`.
#'
#' @export
create_git_builder <- function(source, git_url, branch, credential, subdir, wait, build_trigger, url = ppm_url()) {
  if (!requireNamespace("httr", quietly = TRUE)) {
    cli::cli_abort("Creating git builders requries the 'httr' package.  Install package to continue.")
  }
  # POST /sources/:id/git-builder
  body <- list(url = git_url,
               ref = branch,
               key = credential,
               subdir = subdir,
               wait = wait,
               build_trigger_type = build_trigger)

  r <- httr::POST(construct_api_url("sources", ppm_get_source_id(source), "git-builder", url = url),
                  body = body,
                  httr::add_headers(Authorization = paste("Bearer", ppm_api_token("sources:write"), sep=" ")))

  httr::stop_for_status(r)

}

rerun_git_builder <- function() {

}


#' Retrieve logs from a Git package build
#'
#' @param transaction_id The ID of the git builder transaction
#' @inheritParams status
#'
#' @return Log output
#'
#' @note Requires PPM v2023.08 or higher
#' @export
git_builder_logs <- function(transaction_id, url=ppm_url()) {
  ppm_api_token <- getOption("ppm.api_token")

  r <- httr::GET(construct_api_url("git-package-build", transaction_id, url = url),
                  httr::add_headers(Authorization = paste("Bearer", ppm_api_token("sources:write"), sep=" ")))
  httr::stop_for_status(r)
  httr::content(r)
}
