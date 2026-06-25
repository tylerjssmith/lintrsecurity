test_that("onload_calls_httr_POST_linter returns no lint correctly", {
  good1 = '
  .onLoad <- function(libname, pkgname) {
    packageStartupMessage()
  }
  '
  good2 = '
  .onAttach <- function(libname, pkgname) {
    packageStartupMessage()
  }
  '
  expect_no_lint(good1, lintrsecurity::onload_calls_httr_POST_linter())
  expect_no_lint(good2, lintrsecurity::onload_calls_httr_POST_linter())
})


test_that("onload_calls_httr_POST_linter returns lints correctly", {
  bad1 = '
  .onLoad <- function(libname, pkgname) {
    httr::POST()
  }
  '
  bad2 = '
  .onAttach <- function(libname, pkgname) {
    httr::POST()
  }
  '
  expect_lint(bad1, "httr::POST\\(\\) calls inside \\.onLoad",
    lintrsecurity::onload_calls_httr_POST_linter())
  expect_lint(bad2, "httr::POST\\(\\) calls inside \\.onLoad",
    lintrsecurity::onload_calls_httr_POST_linter())
})
