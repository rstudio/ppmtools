test_that("repo_name to id works", {
  expect_equal(ppm_get_repo_id("cran", P3M), 2)
})

test_that("repo_name to id works with hidden repos", {
  expect_equal(ppm_get_repo_id("all", P3M), 1)
})

test_that("repo_name to id fails if not found", {
  expect_error(ppm_get_repo_id("bogus", P3M), regexp = "Repository \"bogus\" not found")
})
