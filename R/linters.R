#' Flag system call inside .onLoad or .onAttach hook
#'
#' `system()` or `system2()` calls inside `.onLoad` or `.onAttach` hooks (often
#' found in `R/zzz.R`) execute arbitrary shell commands whenever a package is
#' loaded (e.g., via `library()`) or attached to the R search path.
#'
#' @details
#' Shell commands may be used to control every aspect of a system up to
#' the privileges of the user running R. For example, they can download and run
#' malicious code, or exfiltrate credentials and other data. You should ensure
#' you understand what shell command is being executed and why. See MITRE ATT&CK
#' \href{https://attack.mitre.org/techniques/T1059/001/}{T1059.001 (PowerShell on Windows)}
#' and \href{https://attack.mitre.org/techniques/T1059/004/}{T1059.004 (Unix Shell)}.
#'
#' @return A linter function of class \code{linter}.
#'
#' @examples
#' \dontrun{
#' lintr::lint(
#'   text = '.onLoad <- function(libname, pkgname) { system("id") }',
#'   linters = onload_calls_system_linter()
#' )
#' }
#'
#' @export
onload_calls_system_linter <- function() {
  lintr::make_linter_from_xpath(
    xpath = "//expr[
      LEFT_ASSIGN
      and expr[1]/SYMBOL[text() = '.onLoad' or text() = '.onAttach']
      and expr[FUNCTION]/descendant::SYMBOL_FUNCTION_CALL[
        text() = 'system' or text() = 'system2'
      ]
    ]",
    lint_message = paste(
      "system() or system2() calls inside .onLoad or .onAttach hooks",
      "(often found in R/zzz.R) execute arbitrary shell commands whenever a",
      "package is loaded (e.g., via library()) or attached to the R search",
      "path. Shell commands may be used to control every aspect of a system up",
      "to the privileges of the user running R. For example, they may download",
      "and run malicious code, or exfiltrate credentials and other data."
    ),
    type = "warning"
  )()
}

#' Flag httr::POST() call inside .onLoad or .onAttach hook
#'
#' `httr::POST()` calls inside `.onLoad` or `.onAttach` make HTTP POST requests,
#' sending data to an external system whenever a package is loaded (e.g., via
#' `library()`) or attached to the R search path.
#'
#' @details
#' HTTP POST requests may be used to send data to external systems. For example,
#' they can send the contents of the `~/.ssh` directory to an attacker. See
#' MITRE ATT&CK
#' \href{https://attack.mitre.org/techniques/T1552/001/}{MITRE ATT&CK T1552 (Unsecured Credentials: Credentials In Files)}.
#'
#' @return A linter function of class \code{linter}.
#'
#' @examples
#' \dontrun{
#' lintr::lint(
#'   text = '.onLoad <- function(libname, pkgname) { httr::POST() }',
#'   linters = onload_calls_httr_POST_linter()
#' )
#' }
#'
#' @export
onload_calls_httr_POST_linter <- function() {
  lintr::make_linter_from_xpath(
    xpath = "//expr[
      LEFT_ASSIGN
      and expr[1]/SYMBOL[text() = '.onLoad' or text() = '.onAttach']
      and expr[FUNCTION]/descendant::expr[
        SYMBOL_PACKAGE[text() = 'httr']
        and NS_GET
        and SYMBOL_FUNCTION_CALL[text() = 'POST']
      ]
    ]",
    lint_message = paste(
      "httr::POST() calls inside .onLoad or .onAttach make HTTP POST",
      "requests, sending data to an external system whenever a package is",
      "loaded (e.g., via library()) or attached to the R search path.",
      "HTTP POST requests may be used to send data to external systems. For",
      "example, they can send the contents of the ~/.ssh directory to an",
      "attacker."
    ),
    type = "warning"
  )()
}

#' All lintrsecurity linters
#'
#' Returns all stable lintrsecurity linters as a named list suitable for
#' passing to \code{lintr::lint()} or \code{lintr::lint_package()}.
#'
#' @return A named list of linter objects.
#' @export
lintrsecurity_linters <- function() {
  list(
    onload_calls_system_linter    = onload_calls_system_linter(),
    onload_calls_httr_POST_linter = onload_calls_httr_POST_linter()
  )
}
