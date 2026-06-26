#' Lint a package for security issues, ignoring nolint exclusions
#'
#' A security-focused wrapper around \code{lintr::lint_package()} that
#' disables all \code{# nolint} exclusion mechanisms. This is the recommended
#' way to audit a package for security issues, since a malicious contributor
#' may use \code{# nolint} comments to evade detection.
#'
#' @param path Path to the package directory. Defaults to current directory.
#' @param linters Named list of linters to apply. Defaults to
#'   \code{lintrsecurity_linters()}.
#'
#' @details
#' The exclusion sentinel is randomly generated at runtime rather than fixed,
#' so attacker code cannot predict and match the string to re-enable
#' \code{# nolint} suppression during an audit.
#'
#' lintr's \code{# nolint} mechanism allows package authors to suppress lint
#' findings on specific lines. In a development context this is legitimate --
#' a package wrapping system administration tools may have genuine reasons for
#' \code{system()} calls in lifecycle hooks.
#'
#' However, in a security audit context, \code{# nolint} suppression is an
#' evasion technique. A malicious contributor aware of \code{lintrsecurity}
#' could add \code{# nolint: onload_calls_system_linter} to hide dangerous
#' patterns from automated detection. \code{audit_package()} prevents this by
#' overriding all exclusion patterns with an unpredictable random string that
#' cannot appear in R source code.
#'
#' The presence of \code{# nolint} comments on flagged lines is itself a
#' signal worth investigating and is recorded in the \code{nolint_suppressed}
#' column of the returned data frame.
#'
#' @return A data frame of security findings with columns from
#'   \code{lintr::lint_package()} plus \code{nolint_suppressed}, a logical
#'   column indicating whether the flagged line contains a \code{# nolint}
#'   comment. Findings where \code{nolint_suppressed} is \code{TRUE} warrant
#'   priority manual review, as they indicate the package author was aware the
#'   pattern would be flagged and chose to suppress the warning.
#'
#' @examples
#' \dontrun{
#' # Audit the current package
#' findings <- audit_package()
#'
#' # Audit a specific package directory
#' findings <- audit_package("/path/to/somepackage")
#'
#' # Review findings where nolint suppression was attempted
#' findings[findings$nolint_suppressed, ]
#' }
#'
#' @seealso \code{\link{lintrsecurity_linters}}
#' @export
audit_package <- function(
  path    = ".",
  linters = lintrsecurity_linters()
) {
  sentinel <- paste0(
    "LINTRSECURITY_",
    paste(sample(c(letters, LETTERS, 0:9), 32L, replace = TRUE), collapse = "")
  )

  # Write a temporary .lintr config that overrides exclusion patterns
  # with an unpredictable sentinel that cannot appear in R source code.
  # This prevents # nolint comments from suppressing security findings.
  lintr_config <- file.path(path, ".lintr")
  config_existed <- file.exists(lintr_config)
  original_config <- if (config_existed) readLines(lintr_config) else NULL

  writeLines(
    c(
      sprintf('exclude: "%s"',       sentinel),
      sprintf('exclude_next: "%s"',  sentinel),
      sprintf('exclude_start: "%s"', sentinel),
      sprintf('exclude_end: "%s"',   sentinel)
    ),
    con = lintr_config
  )
  on.exit({
    if (config_existed) {
      writeLines(original_config, lintr_config)
    } else {
      file.remove(lintr_config)
    }
  }, add = TRUE)

  lints <- lintr::lint_dir(
    path           = path,
    linters        = linters,
    parse_settings = TRUE
  )

  if (length(lints) == 0L) {
    message("No security findings.")
    return(invisible(data.frame()))
  }

  df <- as.data.frame(lints)

  df$nolint_suppressed <- grepl("# nolint", df$line, fixed = TRUE)

  if (any(df$nolint_suppressed)) {
    message(
      sum(df$nolint_suppressed),
      " finding(s) had nolint suppression on the flagged line. ",
      "These warrant priority review."
    )
  }

  df
}
