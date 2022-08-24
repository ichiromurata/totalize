#' Rounding of Numbers
#'
#' @description
#'   Rounds the values in its first argument to the specified number of decimal places.
#' 
#'   指定された桁位置で四捨五入を行います。
#'
#' @param x a numeric vector.
#' @param digits integer indicating the number of decimal places to be used. Negative values are allowed.
#' @param tolerance numeric >= 0. If the difference of 2 floating point values is smaller than tolerance they are regarded as equal.
#'
#' @details
#'   This function is a complement of the `base::round()`, which rounds to even when rounding off a 5, where this function rounds away from 0.
#'   Rounding to a negative number of digits means rounding to a power of ten, so for example `round(x, digits = -2)` rounds to the nearest hundred.
#' 
#'   `base::round()`関数は「偶数丸め」と呼ばれる丸めを行いますが、この関数は四捨五入を行います。
#'   負の数は絶対値が大きくなる方に丸めます。（`awayfromzero(-3.5)`は`-4`になります）
#'
#' @returns a numeric vector the same length as `x`.
#'
#' @section Warning:
#'   It's worth considering to select `tolerance` carefully, especially when rounding large numbers. (See examples)
#'
#' @note
#'   This rounding rule has been added in IEEE 754-2008 version. (But only for decimal(10) based formats.)
#'
#' @export
#'
#' @examples
#' awayfromzero(.5 + -2:4) # round away from 0 when rounding off a 5
#' ## -2 -1  1  2  3  4  5
#'
#' round(.5 + -2:4) # IEEE / IEC default rounding (to even)
#' ## -2  0  0  2  2  4  4
#'
#' # A tolerance is necessary when testing the number .5 (because of the limitation of floating point expression)
#' # No tolerance version
#' no_tolerance <- function(x, digits) {
#'     floor(x * 10^digits + 0.5) / 10^digits
#' }
#' no_tolerance(0.005 + 1:5/100, digits = 2)	# It goes wrong at 0.035
#' ## 0.02 0.03 0.03 0.05 0.06
#'
#' awayfromzero(0.005 + 1:5/100, digits = 2)
#' ## 0.02 0.03 0.04 0.05 0.06
#' 
#' # When significant >= 8 the relative error becomes too small and always rounded up (Not desired)
#' awayfromzero(12345678.4, digits = 0)
#' ## 12345679 (!?)
#' 
#' # So a smaller tolerance should be used
#' awayfromzero(12345678.4, digits = 0, tolerance = 2e-10)
#' ## 12345678
#' 
#' # But the smallest tolerance isn't appropriate usually (Can't handle accumulated error)
#' x <- 0
#' for(i in 1:25) x <- x + 0.3		# 0.3 * 25 = 7.5
#' awayfromzero(x, digits = 0, tolerance = .Machine$double.eps)
#' ## 7
#' 
#' # This happens also on base::round()
#' round(x)
#' ## 7
#'
awayfromzero <- function(x, digits = 0, tolerance = sqrt(.Machine$double.eps)){
	x_shift <- abs(x) * 10^digits
	x_plushalf <- x_shift + 0.5
	x_roundup <- ceiling(x_shift)
	
	for(i in seq_along(x)){
		if(isTRUE(all.equal(x_plushalf[i], x_roundup[i], tolerance=tolerance))){
			x_shift[i] <- x_roundup[i]
		}
		else{
			x_shift[i] <- floor(x_plushalf[i])
		}
	}
	
	sign(x) * x_shift / 10^digits
}
