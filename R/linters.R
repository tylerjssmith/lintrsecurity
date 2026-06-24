#' Flag system() calls inside lifecycle hooks
#' ...
#' @export
system_in_onload_linter <- function() {
  lintr::make_linter_from_xpath(
    xpath   = "...",
    message = "..."
  )
}

#' Flag network calls inside lifecycle hooks
#' ...
#' @export
download_in_onload_linter <- function() {
  lintr::make_linter_from_xpath(
    xpath   = "...",
    message = "..."
  )
}

#' All lintrsecurity linters
#'
#' Returns all stable lintrsecurity linters as a named list suitable for
#' passing to \code{lintr::lint()} or \code{lintr::lint_package()}.
#'
#' @return A named list of linter functions.
#' @export
lintrsecurity_linters <- function() {
  list(
    system_in_onload_linter   = system_in_onload_linter(),
    download_in_onload_linter = download_in_onload_linter()
  )
}
