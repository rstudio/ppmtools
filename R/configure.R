#' Configure your R session to use Posit Package Manager
#'
#' @inheritParams status
#' @param distro PPM package distribution from ppmtools::list_distributions().  If NULL (default), attempt to auto-detect.
#'
#' @export
configure <- function(url = ppm_url(), distro = NULL) {
  cli::cat_rule("Configuring R to use Posit Package Manager", col = "cyan")

  # Confirm R can access PPM
  ppm_ver <- tryCatch( status(url)$version,
            error = function(cond) {
              cli::cli_abort("Unable to access Package Manager at {.url {url}}: {cond}")
            })
  cli::cli_alert_info("Using Package Manager v{ppm_ver} at {.url {url}}")

  # If on Linux, confirm HTTPUserAgent is properly set to install binary packages
  if (.Platform$OS.type == "unix") {
    config <- verify_config(quiet = TRUE)
    if (!is.null(config)) {
      eval(parse(text=config))
      cli::cli_alert_success("Configured options to enable binary package installation.")
    }
  }

  # detect distribution if not specificed
  if (is.null(distro)) {
    distro <- detect_distro()
    cli::cli_alert_info("Detected Package Manager binary distribution as '{distro}'")
  } else {
    cli::cli_alert_info("Using specified binary distribution '{distro}'")
  }

  # Check for available repositories, and prompt if more than one available.
  repos <- list_repos()
  if (nrow(repos) == 1) {
    repo_name <- repos$name[1]
    cli::cli_alert_info("Only one compatible repository on server, using '{repo_name}'.")
  } else if (nrow(repos) > 1) {
    cli::cli_alert("Multiple repositories detected.  Select repository to use:")
    repo_name <- repos$name[utils::menu(repos$name)]
  }
  if (length(repo_name) != 1) {
    cli::cli_alert_warning("No repositories detected, leaving repos URL unchanged.")
    return(invisible())
  }

  # set options("repos") to the proper URL.
  repo_url <- construct_repo_url(repo_name = repo_name, distro = distro, url = url)
  if (length(repo_url)) {
    repos_opt <- getOption("repos")
    repos_opt["CRAN"] <- repo_url
    options(repos = repos_opt)
  }
  cli::cli_alert_info("Updated CRAN repository URL to {repo_url}")
  cli::cli_alert_success("Configuration complete")
}

#' Verify R is properly configured to use Posit Package Manager
#'
#' @param quiet If TRUE, silence most messages.
#'
#' @return Invisibly returns any necessary config commands to be executed, otherwise NULL.
#' @export
verify_config <- function(quiet = FALSE) {
  cli::cli_alert("Verifying configuration")
  local({
    if (.Platform$OS.type != "unix") {
      cli::cli_alert_success("Success!  No additional configuration required.")
      return(invisible())
    }
    dl_method <- getOption("download.file.method", "")
    dl_extra_args <- getOption("download.file.extra", "")
    user_agent <- getOption("HTTPUserAgent", "")
    if (dl_method == "") {
      dl_method <- if (isTRUE(capabilities("libcurl"))) "libcurl" else "internal"
    }
    default_ua <- sprintf("R (%s)", paste(getRversion(), R.version$platform, R.version$arch, R.version$os))
    instruction_template <- 'You must configure your HTTP user agent in R to install binary packages.
In your site-wide startup file (Rprofile.site) or user startup file (.Rprofile), add:
%s
Then restart your R session and run this diagnostic script again.
'
    cli::cli_inform(c(
      "i" = "R installation path: {R.home()}",
      "i" = "R version: {R.version.string}",
      "i" = "OS version: {utils::sessionInfo()$running}",
      "i" = "HTTPUserAgent: {user_agent}",
      "i" = "Download method: {dl_method}",
      "i" = "Download extra args: {dl_extra_args}"
    ))
    if (dl_method == "libcurl") {
      if (!grepl(default_ua, user_agent, fixed = TRUE) ||
          (getRversion() >= "3.6.0" && substr(user_agent, 1, 3) == "R (")) {
        config <- 'options(HTTPUserAgent = sprintf("R/%s R (%s)", getRversion(), paste(getRversion(), R.version["platform"], R.version["arch"], R.version["os"])))'
        if (!quiet) message(sprintf(instruction_template, config))
        return(invisible(config))
      }
    } else if (dl_method %in% c("curl", "wget")) {
      if (!grepl(sprintf("--header \"User-Agent: %s\"", default_ua), dl_extra_args, fixed = TRUE)) {
        ua_arg <- "sprintf(\"--header \\\"User-Agent: R (%s)\\\"\", paste(getRversion(), R.version[\"platform\"], R.version[\"arch\"], R.version[\"os\"]))"
        if (dl_extra_args == "") {
          config <- sprintf("options(download.file.extra = %s)", ua_arg)
        } else {
          config <- sprintf("options(download.file.extra = paste(%s, %s))", shQuote(dl_extra_args), ua_arg)
        }
        if (!quiet) message(sprintf(instruction_template, config))
        return(invisible(config))
      }
    }
    cli::cli_alert_success("Success! Your user agent is correctly configured.")
    return(invisible())
  })
}
