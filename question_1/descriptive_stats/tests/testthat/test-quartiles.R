# ------- calc_q1 --------------------------------------------------------------
# Valid inputs
test_that("calc_q1() calculates 25th percentile correctly",{
  expect_equal(calc_q1(c(10,20,30,40,50,60)), 22.5)
  expect_equal(calc_q1(c(10.5,20.5,30.5,40.5,50.5,60.5)),23)

})

# Input vectors with single value
test_that("calc_q1() handles single value inputs",{
  expect_warning(calc_q1(c(10)), "single value")
  result <- suppressWarnings(calc_q1(c(10)))
  expect_equal(result,10)
})

# Edge cases - NAs, non-numeric, Inf, Boolean, vectors of large length
test_that("calc_q1() handles edge cases", {
  expect_error(calc_q1(c("a","b",5,6,7)), "Input vector must contain only numeric values")
  expect_error(
    suppressWarnings(calc_q1(c(NA, NA, NA))),
    "No valid data"
  )
  expect_error(calc_q1(c()), "empty")
  expect_warning(calc_q1(c(10, 20, NA, 30, 40, 50, 60)), "missing or underfined values")
  result <- suppressWarnings(calc_q1(c(10, 20, NA, 30, 40,50,60)))
  expect_equal(result, 22.5)
  expect_error(calc_q1(c(TRUE,TRUE,FALSE)), "Input vector must contain only numeric values")
  expect_error(calc_q1(c(1e309, 3,4,5)),"infinite values are not accepted")
  expect_equal(calc_q1(rep(1, 1000000)), 1)
})

# ------ calc_q3 ---------------------------------------------------------------

test_that("calc_q3() calculates 75th percentile correctly",{
  expect_equal(calc_q3(c(10,20,30,40,50,60)), 47.5)
  expect_equal(calc_q3(c(10.5,20.5,30.5,40.5,50.5,60.5)),48)
})

test_that("calc_q3() handles input vectors with a single value", {
  expect_warning(calc_q3(c(10)), "single value")
  result <- suppressWarnings(calc_q3(c(10)))
  expect_equal(result,10)
})

test_that("calc_q3() handles edge cases", {
  expect_error(calc_q3(c("a","b",5,6,7)), "Input vector must contain only numeric values")
  expect_error(
    suppressWarnings(calc_q3(c(NA, NA, NA))),
    "No valid data"
  )
  expect_error(calc_q3(c()), "empty")
  expect_warning(calc_q3(c(10, 20, NA, 30, 40, 50, 60)), "missing or underfined values")
  result <- suppressWarnings(calc_q3(c(10, 20, NA, 30, 40,50,60)))
  expect_equal(result, 47.5)
  expect_error(calc_q3(c(TRUE,TRUE,FALSE)), "Input vector must contain only numeric values")
  expect_error(calc_q3(c(1e309, 3,4,5)),"infinite values are not accepted")
  expect_equal(calc_q3(rep(1, 1000000)), 1)
})

#-----------------calc_iqr()---------------------------------------------------

# Valid inputs
test_that("calc_iqr() calculates IQR correctly",{
  expect_equal(calc_iqr(c(10,20,30,40,50,60)), 25)
  expect_equal(calc_iqr(c(10.5,20.5,30.5,40.5,50.5,60.5)),25)

})

# Input vectors with single value - warning trigerred from quartiles.R
test_that("calc_iqr() handles IQR = 0", {
  suppressWarnings(expect_warning(calc_iqr(c(10)), "IQR is 0"))
  result <- suppressWarnings(calc_iqr(c(10)))
  expect_equal(result,0)
})

# Input vectors with single value - warning triggered from utils.R
test_that( "calc_iqr handles input of a single value", {
  suppressWarnings(expect_warning(calc_iqr(c(10)), "Input vector has single value"))
  result <- suppressWarnings(calc_iqr(c(10)))
  expect_equal(result,0)
})

# Edge cases - NAs, non-numeric (char and Boolean), Inf, vectors with large length
test_that("calc_iqr() handles edge cases", {
  expect_error(calc_iqr(c("a","b",5,6,7)), "Input vector must contain only numeric values")
  expect_error(
    suppressWarnings(calc_iqr(c(NA, NA, NA))),
    "No valid data"
  )
  expect_error(calc_iqr(c()), "empty")
  expect_warning(calc_iqr(c(10, 20, NA, 30, 40, 50, 60)), "missing or underfined values")
  result <- suppressWarnings(calc_iqr(c(10, 20, NA, 30, 40,50,60)))
  expect_equal(result, 25)
  expect_error(calc_iqr(c(TRUE,TRUE,FALSE)), "Input vector must contain only numeric values")
  expect_error(calc_iqr(c(1e309, 3,4,5)),"infinite values are not accepted")
  expect_equal(calc_iqr(rep(1, 1000000)), 0)
})
