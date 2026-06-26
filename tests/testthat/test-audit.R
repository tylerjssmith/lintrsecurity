test_that("audit_package() detects system() in .onLoad with nolint suppression", {
  path <- test_path("fixtures/onload_calls_system_nolint")

  # lintr::lint_package() respects # nolint -- no findings
  lints <- lintr::lint_package(
    path           = path,
    linters        = lintrsecurity::lintrsecurity_linters(),
    parse_settings = FALSE
  )
  expect_length(lints, 0L)

  # audit_package() ignores # nolint -- finds and flags suppression
  findings <- lintrsecurity::audit_package(
    path    = path,
    linters = lintrsecurity::lintrsecurity_linters()
  )
  expect_true(nrow(findings) > 0L)
  expect_true(all(findings$nolint_suppressed))
})


test_that("audit_package() detects system() in .onLoad without nolint suppression", {
  path <- test_path("fixtures/onload_calls_system_no_nolint")

  # lintr::lint_package() finds the pattern
  lints <- lintr::lint_package(
    path           = path,
    linters        = lintrsecurity::lintrsecurity_linters(),
    parse_settings = FALSE
  )
  expect_true(length(lints) > 0L)

  # audit_package() also finds it, suppression not attempted
  findings <- lintrsecurity::audit_package(
    path    = path,
    linters = lintrsecurity::lintrsecurity_linters()
  )
  expect_true(nrow(findings) > 0L)
  expect_false(any(findings$nolint_suppressed))
})


test_that("audit_package() restores original config if it existed", {
  path <- test_path("fixtures/onload_calls_system_no_nolint")

  findings <- lintrsecurity::audit_package(
    path    = path,
    linters = lintrsecurity::lintrsecurity_linters()
  )
  original_config = file.path(path, ".lintr")
  expect_true(file.exists(original_config))
  expect_identical(
    readLines(original_config),
    c(
      "# This file exists to test that audit_package() restores pre-existing",
      "# .lintr config files after auditing. Content is intentionally minimal.",
      "# Empty"
    )
  )
})


test_that("audit_package() removes temporary config if no original existed", {
  path <- test_path("fixtures/onload_calls_system_nolint")

  findings <- lintrsecurity::audit_package(
    path    = path,
    linters = lintrsecurity::lintrsecurity_linters()
  )
  expect_false(file.exists(file.path(path, ".lintr")))
})


test_that("audit_package() cleans up config even if linting errors", {
  path <- test_path("fixtures/onload_calls_system_nolint")
  # Force an error by passing an invalid linter
  tryCatch(
    lintrsecurity::audit_package(
      path    = path,
      linters = list(not_a_linter = function() "invalid")
    ),
    error = function(e) invisible(NULL)
  )
  expect_false(file.exists(file.path(path, ".lintr")))
})

