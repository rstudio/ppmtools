test_that("can get source id from source name", {
  expect_equal(ppm_get_source_id("cran", P3M), 1)
  expect_equal(ppm_get_source_id("pypi", P3M), 211)
})

test_that("proper number of package results returned", {
  expect_equal(nrow(list_packages("cran", max_rows = 444)), 444)
  expect_equal(nrow(list_packages("cran", max_rows = 2001)), 2001)
  expect_equal(nrow(list_packages("cran", max_rows = 1234)), 1234)
})
