#' Check for missing values in the input vector(NA)
#'
#' @param x A numeric vector of any length
#'
#' @returns A numeric vector without NA and NaN values
#' @export
#'
#' @examples
#' check_na(c(5,7,NA)) # triggers NA warning and removes NA
#' try(check_na(c(NA,NA))) # throws an error
check_na <- function (x) {
  if (any(is.na(x))) {
    warning("Input vector contains missing or underfined values (NA) or NaN. Removing NA & NaN.", call. = FALSE)
    x <- x[!is.na(x)]
  }
  if (length(x) == 0) {
    stop("Input vector containted only missing values (NA) or NaN. No valid data to compute on.", call. = FALSE)
  }
  return (x)
}

#' Check for non-numeric (character, Boolean, infinite) values in the input vector
#'
#' @param x A numeric vector of any length
#'
#' @returns A numeric vector
#' @export
#'
#' @examples
#' check_numeric (c(5,5,6,7)) # returns c(5,5,6,7)
#' try(check_numeric(c(3,4,5,M,N))) # throws an error
#' try(check_numeric(c(Inf,-Inf))) # throws an error
#' try(check_numeric(c(TRUE,TRUE,FALSE)))# throws an error and avoids R conversion to 0 and 1
check_numeric <- function(x) {
  if(!is.numeric(x)) {
    stop("Input vector must contain only numeric values", call.= FALSE)
  }

  if (any(is.infinite(x))) {
    stop("Input must be numeric, infinite values are not accepted", call. = FALSE)
  }

  return (x)
}

#' Check if input vector is empty
#'
#' @param x Input vector of any length
#'
#' @returns Numeric vector
#' @export
#'
#' @examples
#' check_empty(c(12,4,5,6,7)) # returns c(12,4,5,6,7)
#' try(check_empty()) # throws an error
check_empty <- function(x) {
  if(length(x)==0) {
    stop("Input vector is empty", call. = FALSE)
  }
  return (x)
}

#' Checks the length of the vector
#'
#' @param x Input vector of any length
#'
#' @returns Numeric vector
#' @export
#'
#' @examples
#' check_single_value(c(23,44,5,68))
#' try(check_single_valuec((5))) # displays a warning
check_single_value <- function(x) {
  if (length(x) == 1) {
    warning("Input vector has single value: summary statistics may not be meaningful", call. = FALSE)
  }
  return (x)
}


#' Combine functions above to handle edge cases (NA, single value, character)
#'
#' @param x Input vector of any length
#'
#' @returns Numeric vector
#' @export
#'
#' @examples
#' validate_vector(c(5,4,55,88,23, NA, 32)) # returns c(5,4,55,88,23,32)
#' try(validate_vector(c(NA, "c", 6,2,3,1))) #throws error
validate_vector <- function(x) {
  x |>
    check_empty()   |>
    check_na()      |>
    check_numeric() |>
    check_single_value()
}

