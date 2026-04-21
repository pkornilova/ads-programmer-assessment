#' Calculate mean to 2 dp
#'
#' @param vals A numeric vector of any length
#'
#' @returns Mean value of a numeric vector
#' @export
#'
#' @examples
#' x < - c(10,20,30,40,50)
#' calc_mean(x) # return 30
#' # Edge cases - return error
#' try(calc_mean(c())) # empty vector
#' try(calc_mean(c("a", "b", 5))) # character vector
#' try(calc_mean(c(NA,NA,NA))) # removes NA and vector is empty
#' # Throws a warning, input length equals 1
#' try(calc_mean(c(4))) # return 4
calc_mean <- function(vals){
  #Checks input for edge cases (NA vals, empty and character vectors)
  check_vals <- validate_vector(vals)
  mean_val = round(mean(check_vals), 2)
  return(mean_val)
}

#' Calculate median to 2 dp
#'
#' @param vals A numeric vector of any length
#'
#' @returns Median value of the numeric vector
#' @export
#'
#' @examples
#' calc_median(c(1, 2, 3, 4, 5)) # return 3
#' calc_median(c(1, 2, 3, 4)) # return 2.5
#' # Edge cases - return error
#' try(calc_median(c())) # empty vector
#' try(calc_median(c("a", "b", 5))) # character vector
#' try(calc_median(c(NA,NA,NA))) # removes NA and vector is empty
#' # Throws a warning, input length equals 1
#' try(calc_median(c(4))) # return 4
calc_median <- function(vals){
  check_vals <- validate_vector(vals)
  median_val = round(median(check_vals),2)
  return(median_val)
}

#' Calculate mode
#'
#' @param vals A numeric vector of any length
#'
#' @returns Mode value in the numeric vector, multiple modes
#'  or return 0 when no mode is found
#'
#' @examples
#' calc_mode(2,4,5,7,8,10) # return 0 and warning that no mode is found
#' calc_mode(2,2,3,4,4,5,7) # return two modes (2 & 4) and a message
#' calc_mode(3,5,63,17,3,99) # return 3
#' # Edge cases - return error
#' try(calc_mode(c())) # empty vector
#' try(calc_mode(c("a", "b", 5))) # character vector
#' try(calc_mode(c(NA,NA,NA))) # removes NA and vector is empty
#' # Throws a warning, input length equals 1
#' try(calc_mode(c(4))) # return 4
calc_mode <- function(vals) {
  check_vals <- validate_vector(vals)
  unique_vals <- unique(check_vals)
  # For input vector with 1 value, return value as mode
  if (length(unique_vals) == 1) {
    return(unique_vals)
  }
  #Count frequency of each unique value in the input, handle ties and no mode
  tab <- tabulate(match(check_vals,unique_vals))

  if (all(tab == max(tab))) {
    warning("No mode found - all values in the input vector appear equally",
            call. = FALSE)
    return(0)
  }
  mode <- unique_vals[tab == max(tab)]

  if (length(mode) > 1) {
    message ("Multiple modes found: ", paste(mode, collapse = ", "),
             call. = FALSE)
    }
  return(mode)
}


