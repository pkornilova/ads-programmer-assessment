
# descriptiveStats package 

<!-- badges: start -->
[![Lifecycle: stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
[![check-standard](https://github.com/pkornilova/ads-programmer-assessment/actions/workflows/check-standard.yaml/badge.svg)](https://github.com/pkornilova/ads-programmer-assessment/actions/workflows/check-standard.yaml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
<!-- badges: end -->


The goal of descriptiveStats is to provide functions to calculate summary statistics:
mean, median, mode, first quartile (Q1), third quartile (Q3) and interquartile range (IQR). 
All functions include built-in input validation to handle common data quality issues such as
missing values, empty vectors, and non-numeric values. 

---
## Installation

You can install the development version of descriptiveStats from [GitHub](https://github.com/) with:

``` r
install.packages("devtools")
devtools::install_github("pkornilova/ads-programmer-assessment", subdir = ""question_1/descriptive_stats"")
```
---

## Usage
### Calculate Descriptive Statistics

This is an example which shows you how to use the package:

``` r
library(descriptiveStats)
x <- c(10,10,20,30,40,50,60)
calc_mean(x)
#> [1] 31.43
calc_median(x)
#> [2] 30
calc_mode(x)
#> [3] 10
calc_q1(x)
#> [4] 10
calc_q3(x)
#> [5] 50
calc_iqr(x)
#> [6] 40
```
---

### Input Validation 
The package will return informative errors and warnings for edge cases and invalid inputs:
``` r
# Non-numeric values 
calc_mean(c("a", "b", "c"))
#> Error: Input vector must contain only numeric values

# Empty 
# calc_mean(c())
#> Error: "Input vector is empty"

# Missing values (NAs)
calc_mean(c(NA,10,20,30))
#> Warning: "Input vector contains missing or underfined values (NA) or NaN. Removing NA & NaN."
#> [1] 20

# Vectors with length of 1 
calc_mean(c(10))
#> Warning: Input vector has single value: summary statistics may not be meaningful
#> [1] 10
```
---

## Functions

### Statistics Functions

| Function       | Description                          |
|----------------|--------------------------------------|
| `calc_mean()`  | Calculate the arithmetic mean        |
| `calc_median()`| Calculate the median                 |
| `calc_mode()`  | Calculate the mode                   |
| `calc_q1()`    | Calculate the first quartile (Q1)    |
| `calc_q3()`    | Calculate the third quartile (Q3)    |
| `calc_iqr()`   | Calculate the interquartile range    |

### Helper Functions

| Function              | Description                               |
|-----------------------|-------------------------------------------|
| `check_na()`          | Check for and handle NA values            |
| `check_empty()`       | Check if input vector is empty            |
| `check_numeric()`     | Check if input vector is numeric          |
| `check_single_value()`| Check if length of vector equals 1        |
| `validate_vector()`   | Combine all the checks above in 1 function|

---

## Reporting Issues

Please report bugs and feature requests on the
[GitHub Issues](https://github.com/username/descriptiveStats/issues) page.

When reporting a bug please include:
- A minimal reproducible example
- Your R version (`R.version`)
- Your package version (`packageVersion("descriptiveStats")`)
- Your operating system

---
## Contributing

Contributions are welcome. Please follow these steps:

1. Fork the repository
2. Create a feature branch
```bash
git checkout -b feature/my-new-feature
```
3. Make your changes and add tests
4. Run checks
```r
devtools::check()
devtools::test()
```
5. Submit a pull request

---

## License

This package is licensed under the MIT License.
See [LICENSE](LICENSE) for details.

---

## Author

Polina Kornilova
