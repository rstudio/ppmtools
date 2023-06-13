test_that("proper number of package results returned", {
  expect_equal(nrow(list_packages("cran", max_rows = 444)), 444)
  expect_equal(nrow(list_packages("cran", max_rows = 2001)), 2001)
  expect_equal(nrow(list_packages("cran", max_rows = 1234)), 1234)
})
