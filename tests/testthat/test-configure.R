test_that("basic configure works", {
  # ensure ppm.url is unset
  options(ppm.url=NULL)
  configure()
  expect_match(getOption("repos"), "^https://packagemanager.posit.co")
})

test_that("configure uses ppm.url", {
  options(ppm.url="https://p3m.dev")
  configure()
  expect_match(getOption("repos"), "^https://p3m.dev")
})

test_that("missing HTTPUserAgent is fixed on Linux", {
  skip_on_os("windows")
  skip_on_os("mac")
  options(HTTPUserAgent=NULL)
  configure()
  expect_false(is.null(getOption("HTTPUserAgent")))
})

