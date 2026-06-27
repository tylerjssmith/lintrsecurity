test_that("onload_calls_httr_POST_linter returns no lint for non-httr::POST calls", {
  code1 = '
  .onLoad <- function(libname, pkgname) {
    packageStartupMessage()
  }
  '
  code2 = '
  .onAttach <- function(libname, pkgname) {
    packageStartupMessage()
  }
  '
  expect_no_lint(code1, lintrsecurity::onload_calls_httr_POST_linter())
  expect_no_lint(code2, lintrsecurity::onload_calls_httr_POST_linter())
})


test_that("onload_calls_httr_POST_linter returns lints for httr::POST calls in hooks", {
  code1 = '
  .onLoad <- function(libname, pkgname) {
    httr::POST()
  }
  '
  code2 = '
  .onAttach <- function(libname, pkgname) {
    httr::POST()
  }
  '
  expect_lint(code1, "httr::POST\\(\\) inside \\.onLoad or \\.onAttach sends",
    lintrsecurity::onload_calls_httr_POST_linter())
  expect_lint(code2, "httr::POST\\(\\) inside \\.onLoad or \\.onAttach sends",
    lintrsecurity::onload_calls_httr_POST_linter())
})


test_that("onload_calls_httr_POST_linter returns no lint for calls outside of hooks", {
  code1 = '
  httr::POST()
  '
  code2 = '
  other_function(
    httr::POST()
  )
  '
  expect_no_lint(code1, lintrsecurity::onload_calls_httr_POST_linter())
  expect_no_lint(code2, lintrsecurity::onload_calls_httr_POST_linter())
})
