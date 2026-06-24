#' lintrsecurity: Security-Focused Linters for R Code
#'
#' Provides linters for use with the 'lintr' package that detect
#' security-relevant patterns in R source code, including dangerous constructs
#' in package lifecycle hooks, calls to system execution functions, and network
#' calls that may exfiltrate data or fetch malicious payloads.
#'
#' @section Using lintrsecurity:
#' Add security linters to your lintr workflow:
#'
#' ```r
#' lintr::lint_package(
#'   linters = c(
#'     lintr::linters_with_defaults(),
#'     lintrsecurity::lintrsecurity_linters()
#'   )
#' )
#' ```
#'
#' @seealso
#' \itemize{
#'   \item \url{https://github.com/tylerjssmith/lintrsecurity}
#'   \item \code{\link{lintrsecurity_linters}} for the full linter list
#' }
#'
#' @keywords internal
"_PACKAGE"
