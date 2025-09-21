#' Rounding of Numbers
#'
#' @description
#'   Rounds a numeric vector to a specified number of decimal places, consistently rounding halves away from zero.
#' 
#' @param x A numeric vector.
#' @param digits An integer specifying the number of decimal places. Negative values can be used to round to a power of ten (e.g., `-2` rounds to the nearest hundred).
#'
#' @details
#'   This function provides an alternative to `base::round()`. While `base::round()` implements "round half to even" (e.g., `2.5` rounds to `2`, `3.5` rounds to `4`), `awayfromzero()` consistently rounds halves away from zero (e.g., `2.5` rounds to `3`, `-2.5` rounds to `-3`).
#'   When `digits` is negative, the number is rounded to a power of ten; for instance, `digits = -2` rounds to the nearest hundred.
#' 
#' @returns A numeric vector with the rounded values, having the same length as `x`.
#'
#' @note
#'   The "round half away from zero" rule was formally adopted in the IEEE 754-2008 standard primarily for decimal (base-10) floating-point formats, not typically for binary floating-point numbers as used in most computing environments.
#'
#' @export
#'
#' @examples
#' # awayfromzero() consistently rounds .5 away from zero
#' awayfromzero(.5 + -2:4)
#' ## -2 -1  1  2  3  4  5
#'
#' # For comparison, base::round() rounds .5 to the nearest even number
#' round(.5 + -2:4)
#' ## -2  0  0  2  2  4  4
#'
#' # A naive implementation without tolerance can fail, as 0.035 might be
#' # stored as 0.034999...
#' naive_round <- function(x, digits) {
#'     floor(x * 10^digits + 0.5) / 10^digits
#' }
#' naive_round(0.005 + 1:5/100, digits = 2)	# Note the error at 0.035
#' ## 0.02 0.03 0.03 0.05 0.06
#'
#' # awayfromzero() handles this correctly due to its internal tolerance
#' awayfromzero(0.005 + 1:5/100, digits = 2)
#' ## 0.02 0.03 0.04 0.05 0.06
#' 
#' # For large numbers, the all.equal() function may require a manually adjusted tolerance
#' isTRUE(all.equal(12345678.4, 12345678.5))
#' ## TRUE
#' isTRUE(all.equal(12345678.4, 12345678.5, tolerance = 1e-10))
#' ## FALSE
#' 
#' # awayfromzero() correctly rounds such numbers without needing a manually adjusted tolerance
#' # The internal tolerance adapts to the number's magnitude.
#' awayfromzero(12345678.4, digits = 0)
#' ## 12345678
#' awayfromzero(12345678.5, digits = 0)
#' ## 12345679
#' 
#' # It also correctly handles accumulated precision errors.
#' # The theoretical sum of 0.3 repeated 25 times is 7.5.
#' # Due to floating-point errors, the actual result is slightly less than 7.5.
#' x <- 0
#' for(i in 1:25) x <- x + 0.3
#' print(x, digits = 22)
#' ## 7.499999999999999111822
#'
#' # awayfromzero() correctly rounds this to 8, as expected.
#' awayfromzero(x, digits = 0)
#' ## 8
#' 
#' # For comparison, base::round() is susceptible to this accumulated error.
#' round(x)
#' ## 7
#'
awayfromzero <- function(x, digits = 0){
	# Argument check
	if (!is.numeric(digits) || length(digits) != 1 || !is.finite(digits)) {
		stop("'digits' must be a single finite numeric value.", call. = FALSE)
	}
	digits <- as.integer(digits)

	# Escape for NA, NaN, Inf, -Inf
	non_finite_idx <- !is.finite(x)
	if(all(non_finite_idx)) return(x)

	# Work on finite values
	x_finite <- x[!non_finite_idx]
	scaler <- 10^digits
	x_shift <- abs(x_finite) * scaler

	# Separate integer and fractional parts
	int_part <- floor(x_shift)
	frac_part <- x_shift - int_part

	# Dynamic tolerance based on each x
	tolerance <- 8 * .Machine$double.eps * pmax(1, x_shift)

	# Round away from zero at halfway points
	is_halfway <- abs(frac_part - 0.5) < tolerance
	x_rounded <- ifelse(is_halfway, int_part + 1, floor(x_shift + 0.5))

	# Restore sign and scale
	x[!non_finite_idx] <- sign(x_finite) * x_rounded / scaler
	return(x)
}
