
#' Calculate first quartile (25th percentile) of input values
#'
#' @param vals A numeric vector of any length
#'
#' @returns A single numeric values that cuts of the first 25% of the data sorted in ascending order.
#' If a single value in the input, returns a warning and the value.
#' @export
#'
#' @examples
#' x <- c(10,20,30,40,50)
#' calc_q1(x) # return 20
#' # Edge cases - return error
#' try(calc_q1(c())) # empty vector
#' try(calc_q1(c("a", "b", 5))) # character vector
#' try(calc_q1(c(NA,NA,NA))) # removes NA and vector is empty
calc_q1 <- function(vals) {
  check_vals <- validate_vector(vals)

  q1 <- unname(quantile(check_vals,0.25))
  return(q1)
}

#' Calculate third quartile (75th percentile) of input values
#'
#' @param vals A numeric vector of any length
#'
#' @returns A single numeric value that cuts of the first 75% of the data sorted in ascending order.
#' If a single value in the input, returns a warning and the value.
#' @export
#'
#' @examples
#' x <- c(10,20,30,40,50)
#' calc_q3(x) # return 40
#' try(calc_q3(c())) # throws error, empty vector
#' try(calc_q3(c("a", "b", 5))) # return error character vector
#' try(calc_q3(c(NA,NA,NA))) # removes NA and vector is empty, throws error
calc_q3 <- function(vals) {
  check_vals <- validate_vector(vals)
  q3 <- unname(quantile(check_vals,0.75))
  return(q3)
}

#' Calculate interquartile range (Q3-Q1) of input vector
#'
#' @param vals A numeric vector of any length
#'
#' @returns A single numeric value of interquartile range of the input values.
#' If a single value in the input, returns a warning and the value.
#' @export
#'
#' @examples
#' x <- c(10,20,30,40,50)
#'calc_iqr(x) # return 20
#' try(calc_iqr(c())) # empty vector
#' try(calc_iqr(c("a", "b", 5))) # character vector
#' try(calc_iqr(c(NA,NA,NA))) # removes NA and vector is empty
calc_iqr <- function(vals){
  check_vals <- validate_vector(vals)
  if (length(check_vals) == 1) {
    warning("IQR is 0 - input vector contains only one unique value",
            call. = FALSE)
    return(0)
  }
  q1 <- calc_q1(check_vals)
  q3 <- calc_q3(check_vals)
  iqr_val = q3-q1
  return(iqr_val)
}
