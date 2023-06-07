#' Publish a package to Posit Package Manager
#'
#' @param sourceName The Package Manager source to publish the package to
#' @inheritParams status
#' @param pkg The package
#' @param args Additional args passed to `pkgbuild::build`
#' @param binary Build and publish binary package instead of source?
#' @export
publish_ppm <- function(sourceName, url = ppm_url(), pkg = ".", args = NULL, binary = FALSE) {
  pkg <- devtools::as.package(pkg)

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
    upload_binary_ppm(pkg, built_path, url, sourceName, distro)
  } else {
    upload_ppm(pkg, built_path, url, sourceName)
  }
}

upload_ppm <- function(pkg, built_path, url, sourceName) {
  ppm_api_token <- getOption("ppm.api_token")

  ppm_source_id <- ppm_get_source_id(sourceName, url)
  if (is.null(ppm_source_id)) {
    cli::cli_abort("Unrecognized source '{source}'")
  }

  ppm_publish_url <- file.path(url, "__api__", "sources", ppm_source_id, "packages", fsep="/")

  pkg <- devtools::as.package(pkg)

  cli::cli_inform(c(i = "Uploading package to Package Manager"))
  body <- list(
    file0 = httr::upload_file(built_path, "application/octet-stream"),
    overwrite = "true"
  )
  r <- httr::POST(ppm_publish_url, body = body,
                  httr::add_headers(Authorization = paste("Bearer", ppm_api_token, sep=" ")))

  httr::stop_for_status(r)
  cli::cli_inform("Package successfully published.")

  invisible(TRUE)
}

upload_binary_ppm <- function(pkg, built_path, url, sourceName, distro) {
  ppm_api_token <- getOption("ppm.api_token")

  ppm_source_id <- ppm_get_source_id(sourceName, url)
  if (is.null(ppm_source_id)) {
    cli::cli_abort("Unrecognized source '{source}'")
  }

  ppm_publish_url <- file.path(url, "__api__", "sources", ppm_source_id, "binaries", fsep="/")

  pkg <- devtools::as.package(pkg)

  cli::cli_inform(c(i = "Uploading package to Package Manager"))
  body <- list(
    file0 = httr::upload_file(built_path, "application/octet-stream"),
    overwrite = "true",
    distro = distro
  )
  r <- httr::POST(ppm_publish_url, body = body,
                  httr::add_headers(Authorization = paste("Bearer", ppm_api_token, sep=" ")))

  httr::stop_for_status(r)
  cli::cli_inform("Package successfully published.")

  invisible(TRUE)
}
