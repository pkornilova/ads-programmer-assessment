
check_na <- function (x) {
  if (anyNA(x)) {
    warning(" Input vector contains missing values (NA). Removing NA.", call. = FALSE)
    x <- x[!is.na(x)]
  }
  if (length(x) == 0) {
    stop("Input vector containted only missing values (NA). No valid data to compute.", call. = FALSE)
  }
  return (x)
}

check_na(c(NA,NA))

check_numeric <- function(x) {
  if(!is.numeric(x)) {
    stop("Input vector contains non-numeric values", call.= FALSE)
  }
  return (x)
}

check_empty <- function(x) {
  if(length(x)==0) {
    stop("Input vector is empty", call. = FALSE)
  }
  return (x)
}

check_single_value <- function(x) {
  if (length(x) == 1) {
    warning("Input vector has single value: summary statistics may not be meaningful", call. = FALSE)
  }
  return (x)
}
check_single_value(c(5))

validate_vector <- function(x) {
  x |>
    check_empty()   |>
    check_na()      |>
    check_numeric() |>
    check_single_value()
}


calc_mean <- function(x){
  x <- validate_vector(x)
  mean_val = round(mean(x), 2)
  return(mean_val)
}

test <- c(1,2,5,7,8,11)
test1 <- c(2,NA,16,5,NA)
t2 <- c(NA,NA,NA)
t3 <- c(3)
t4 <- c()
t5 <- c(3,5,6,"M","N")

calc_mean(test)
calc_mean(test1)
calc_mean(t2)
calc_mean(t3)
calc_mean(t4)
calc_mean(t5)


calc_median <- function(x){
  x <- validate_vector(x)
  median_val = round(median(x),2)
  return(median_val)
}

calc_median(test)
calc_median(test1)
calc_median(t2)
calc_median(t3)
calc_median(t4)
calc_median(t5)

calc_mode <- function(x) {
  x <- validate_vector(x)

  freq_table <- table(x)
  max_freq <- max(freq_table)

  if(all(freq_table == max_freq)){
    warning("No mode found - all values in the input vector appear equally", call. = FALSE)
    return(numeric(0))
  }

  modes <- as.numeric(names(which(freq_table == max_freq)))
  if (length(modes) > 1) warning ("Multiple modes found: ", paste(modes, collapse = ", "), call. = FALSE)

  return(modes)
}

mode_t1 = c(2,2,3,3,1)
mode_t2 = c(2)
mode_t3 = c(1,2,3,4,5,7.5)

calc_mode(mode_t1)
calc_mode(mode_t2)
calc_mode(mode_t3)






