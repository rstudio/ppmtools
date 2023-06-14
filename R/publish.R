#' Publish a package to Posit Package Manager
#'
#' @param source_name The Package Manager source to publish the package to
#' @inheritParams status
#' @param pkg The package
#' @param args Additional args passed to `pkgbuild::build`
#' @param binary Build and publish binary package instead of source?
#' @export
publish <- function(source_name, url = ppm_url(), pkg = ".", args = NULL, binary = FALSE) {
  if (!requireNamespace("devtools", quietly = TRUE)) {
    cli::cli_abort("Package publishing requires the devtools package.  Install package to continue.")
  }
  pkg <- devtools::as.package(pkg)

  source_id <- ppm_get_source_id(source_name, url)
  if (is.null(source_id)) {
    cli::cli_abort("Source '{source_name}' not found.")
  }

  built_path <- pkgbuild::build(pkg$path, tempdir(), manual = TRUE, args = args, binary = binary)

  cli::cat_rule("Publish to Package Manager", col = "cyan")
  cli::cli_inform(c(
    "i" = "Path {.file {built_path}}"
  ))
  cli::cat_line()

  cli::cli_inform("Ready to publish {pkg$package} ({pkg$version}) to {url} ?")

  if (utils::menu(c("Yes", "No")) != 1) {
    return(invisible())
  }

  if (binary) {
    distro <- detect_distro()
    upload_binary_ppm(pkg, built_path, url, source_id, distro)
  } else {
    upload_ppm(pkg, built_path, url, source_id)
  }
}

upload_ppm <- function(pkg, built_path, url, source_id) {
  ppm_api_token <- getOption("ppm.api_token")

  ppm_publish_url <- construct_api_url("sources", source_id, "packages", url = url)

  pkg <- devtools::as.package(pkg)

  cli::cli_alert_info("Uploading package to Package Manager")
  body <- list(
    file0 = httr::upload_file(built_path, "application/octet-stream"),
    overwrite = "true"
  )
  r <- httr::POST(ppm_publish_url, body = body,
                  httr::add_headers(Authorization = paste("Bearer", ppm_api_token, sep=" ")))

  httr::stop_for_status(r)
  cli::cli_alert_success("Package successfully published.")

  invisible(TRUE)
}

upload_binary_ppm <- function(pkg, built_path, url, source_id, distro) {
  ppm_api_token <- getOption("ppm.api_token")

  ppm_publish_url <- construct_api_url("sources", source_id, "binaries", url = url)

  pkg <- devtools::as.package(pkg)

  cli::cli_alert_info("Uploading package to Package Manager")
  body <- list(
    file0 = httr::upload_file(built_path, "application/octet-stream"),
    overwrite = "true",
    distro = distro
  )
  r <- httr::POST(ppm_publish_url, body = body,
                  httr::add_headers(Authorization = paste("Bearer", ppm_api_token, sep=" ")))

  httr::stop_for_status(r)
  cli::cli_alert_success("Package successfully published.")

  invisible(TRUE)
}

