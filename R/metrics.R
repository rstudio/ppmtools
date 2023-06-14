# metrics API

#' Get package download count metrics
#'
#' Returns the total number of times a package has been downloaded
#' from the server in the past n days
#'
#' @param package_name Package to get metrics for
#' @param days number of days to look back
#' @inheritParams status
#'
#' @return Count of package downloads
#' @export
#'
#' @examples
#' ggplot2_counts_90 <- get_package_count("ggplot2", days = 90)
#' dplyr_counts_90 <- get_package_count("dplyr", days = 90)
#' shiny_counts_90 <- get_package_count("shiny", days = 90)
get_package_count <- function(package_name, days = 30, url = ppm_url()) {
  query <- list(
    "_sourceType" = "r",
    "_days" = days,
    "_sort" = "count",
    "_order" = "desc",
    "_limit" = 10,
    "name_like" = package_name
  )
  data <- jsonlite::fromJSON(construct_api_url("metrics", "packages", url = url, query = query))

  if (length(data) == 0) {
    return(0)
  }

  package_data <- data[data$name == package_name,]

  if (nrow(package_data) == 0) {
    return(0)
  } else {
    return(package_data$count)
  }
}

#######################################################################

#' Get table of historic daily package counts
#'
#' @param package_names character vector of package names to include
#' @param start_date starting date to search
#' @inheritParams status
#'
#' @return A data.frame listing downloads for each package by date
#' @export
#' @importFrom lubridate as_date today days ymd
#'
#' @examples
#' \dontrun{package_daily_counts_7 <- get_package_count_history(
#'     c("ggplot2", "dplyr", "shiny"),
#'     start_date = lubridate::today() - lubridate::days(7))}

get_package_count_history <- function(package_names, start_date = "2023-01-01", url = ppm_url()) {

  # Empty table
  package_counts <- data.frame(package = character(),
                               downloads = numeric(),
                               date = ymd())

  # loop to add package counts
  for (p in package_names) {

    for (d in seq(ymd(start_date), today() - days(1), by = "day")) {

      # If _days is <1, it get converted to 1.
      # https://github.com/rstudio/package-manager/blob/main/src/api/metrics/packages.go
      # So need to make sure everything starts from yesterday (today() - days(1))
      #  and we need to skip calculating today's downloads

      # If start date is yesterday, just extract yesterday's counts
      if (as_date(d) == today() - days(1)){
        final_downloads <- get_package_count(p, days = 1, url = url)

      } else {
        # Calculate total downloads between start_date and today() - days(1)
        total_downloads <- get_package_count(p, as.numeric(difftime(today(),
                                                                    as_date(d),
                                                                    units = "days")),
                                             url = url)

        # Calculate downloads between start_date + 1 and today
        subtract_downloads <- get_package_count(p, as.numeric(difftime(today(),
                                                                       as_date(d) + days(1),
                                                                       units = "days")),
                                                url = url)

        # Get final counts
        final_downloads <- total_downloads - subtract_downloads
      }

      # Add results to package_counts table
      new_row <- data.frame(package = p,
                        downloads = final_downloads,
                        date = as_date(d))

      package_counts <- rbind(package_counts, new_row)
    }
  }

  return(package_counts)
}
