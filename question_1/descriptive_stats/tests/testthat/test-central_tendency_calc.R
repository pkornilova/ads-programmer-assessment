# ----------- calc_mean()-------------------------------------------------------
# Valid inputs
test_that("calc_mean() calculates mean correctly", {
  expect_equal(calc_mean(c(10,20,30,40,50,60)), 35)
  expect_equal(calc_mean(c(10.5,20.5,30.5,40.5,50.5,60.5)), 35.5)
})

# Handles input vectors with single values
test_that("calc_mean() handles input vectors with single values", {
  expect_warning(calc_mean(c(10)), "single value")
  result <- suppressWarnings(calc_mean(c(10)))
  expect_equal(result,10)
})

# Edge cases - NAs, non-numeric, Inf, Boolean, empty vectors, vectors of large length
test_that("calc_mean() handles edge cases", {
  expect_error(calc_mean(c("a","b",5,6,7)), "Input vector must contain only numeric values")
  expect_error(
    suppressWarnings(calc_mean(c(NA, NA, NA))),
    "No valid data"
  )
  expect_error(calc_mean(c()), "empty")
  expect_warning(calc_mean(c(10, NA, 30, 40)), "missing or underfined values")
  result <- suppressWarnings(calc_mean(c(10, NA, 30, 40)))
  expect_equal(result, 26.67)
  expect_error(calc_mean(c(TRUE,TRUE,FALSE)), "Input vector must contain only numeric values")
  expect_error(calc_mean(c(1e309, 3,4,5)),"infinite values are not accepted")
  expect_equal(calc_mean(rep(1, 1000000)), 1)
})


# ------------calc_median()-----------------------------------------------------
# Valid input
test_that("calc_median() calculates median correctly", {
  expect_equal(calc_median(c(10,20,30,40,50,60)), 35)
  expect_equal(calc_median(c(10.5,20.5,30.5,40.5,50.5,60.5)), 35.5)
  expect_equal(calc_median(c(10,20,30,40)),25)
})

# Handles input vectors with single values
test_that("calc_median() handles single values in the input vector", {
  expect_warning(calc_median(c(10)), "single value")
  result <- suppressWarnings(calc_median(c(10)))
  expect_equal(result,10)
})

# Tests edge cases - NAs, non-numeric, Inf, empty vectors, vectors of large length
test_that("calc_median() handles edge cases", {
  expect_error(calc_median(c("a","b",5,6,7)), "Input vector must contain only numeric values")
  expect_error(
    suppressWarnings(calc_median(c(NA, NA, NA))),
    "No valid data"
  )
  expect_error(calc_median(c()), "empty")
  expect_warning(calc_median(c(10, NA, 30, 40)), "missing or underfined values")
  result <- suppressWarnings(calc_median(c(10, NA, 30, 40)))
  expect_equal(result,30)
  expect_error(calc_median(c(TRUE,TRUE,FALSE)), "Input vector must contain only numeric values")
  expect_error(calc_median(c(1e309, 3,4,5)),"infinite values are not accepted")
  expect_equal(calc_median(rep(1, 1000000)), 1)
})

#---------calc_mode()-----------------------------------------------------------
# Valid input
test_that("calc_mode() calculates mode correctly", {
  expect_equal(calc_mode(c(10,20,20,40,50,60)), 20)
  expect_warning(calc_mode(c(10)), "single value")
  result <- suppressWarnings(calc_mode(c(10)))
  expect_equal(result,10)
})

# Valid input - no mode across values
test_that("calc_mode produces a warning when no mode found", {
  expect_warning(calc_mode(c(1, 2, 3)), "No mode found")
  result <- suppressWarnings(calc_mode(c(1, 2, 3)))
  expect_equal(result, 0)
})

# Valid input - ties in multiple modes
test_that("calc_mode produces a message when multiple modes found", {
  expect_message(calc_mode(c(1, 1, 2, 2, 4, 5)), "Multiple modes found")
  result <- suppressMessages(calc_mode(c(1, 1, 2, 2, 4, 5)))
  expect_equal(result, c(1, 2))
})

# Test edge cases - NAs, non-numeric values, empty vectors, vectors of large length
test_that("calc_mode() handles edge cases", {
  expect_error(calc_mode(c("a","b",5,6,7)), "Input vector must contain only numeric values")
  expect_error(
    suppressWarnings(calc_mode(c(NA, NA, NA))),
    "No valid data"
  )
  expect_warning(calc_mode(c(10, NA, 30,40,30)), "missing or underfined values")
  result <- suppressWarnings(calc_mode(c(10, NA, 30, 40,30)))
  expect_equal(result, 30)
  expect_error(calc_mode(c()), "empty")
  expect_error(calc_mode(c(TRUE,TRUE,FALSE)), "Input vector must contain only numeric values")
  expect_error(calc_mode(c(1e309, 3,4,5)),"infinite values are not accepted")
  expect_equal(calc_mode(rep(1, 1000000)), 1)
})








