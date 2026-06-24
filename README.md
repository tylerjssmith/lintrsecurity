# lintrsecurity

`lintrsecurity` provides linters for use with the 
[`lintr`](https://lintr.r-lib.org/) package to detect security-relevant patterns
in R source code. The package is intended to support secure R package 
development and supply chain security research.

## Background

## Installation

You can install the development version of `lintrsecurity` as follows:

``` r
pak::pak('tylerjssmith/lintrsecurity')
```

## Usage

The security-focused linters are used in `lintr` calls. For example, to scan a 
package or script including both the `lintr` defaults and the `lintrsecurity` 
linters, run the following:

``` r
library(lintr)
library(lintrsecurity)

linters = c(
  lintr::linters_with_defaults(),
  lintrsecurity::lintrsecurity_linters()
)

# scan package
lintr::lint_package(<path_to_package>, 
  linters = linters)

# script
lintr::lint(<path_to_script>, 
  linters = linters)
```




