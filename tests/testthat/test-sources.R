test_that("can get source id from source name", {
  expect_equal(ppm_get_source_id("cran", P3M), 1)
  expect_equal(ppm_get_source_id("pypi", P3M), 211)
})

