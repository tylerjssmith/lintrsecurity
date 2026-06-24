#' Flag system() calls inside lifecycle hooks
#' ...
#' @export
onload_calls_system_linter <- function() {
  lintr::make_linter_from_xpath(
    xpath        = "...",
    lint_message = "...",
    type         = "warning"
  )
}

#' Flag network calls inside lifecycle hooks
#' ...
#' @export
onload_calls_download_linter <- function() {
  lintr::make_linter_from_xpath(
    xpath        = "...",
    lint_message = "...",
    type         = "warning"
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
    onload_calls_system_linter   = onload_calls_system_linter(),
    onload_calls_download_linter = onload_calls_download_linter()
  )
}
