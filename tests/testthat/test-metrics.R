test_that("package count for missing data should return zero", {
  expect_equal(get_package_count("boguspackagename"), 0)
})

test_that("package count should be > 0", {
  expect_gt(get_package_count("tidyverse"), 1)
})

test_that("more days have more downloads", {
  expect_gt(get_package_count("dplyr", days = 90),
            get_package_count("dplyr", days = 30))
})

test_that("package daily counts work", {
  package_list <- c("ggplot2", "dplyr", "shiny")
  package_daily_counts_2 <- get_package_count_history(package_list, start_date = today() - days(2))
  expect_equal(nrow(package_daily_counts_2), 6)
  expect_equal(unique(package_daily_counts_2$package), package_list)
})
