factor_asis <- function(x){
	factor(x, levels=x)
}

test_that("ordinary round", {
	test_vec <- awayfromzero(.5 + -2:4)
	ans_vec <- c(-2, -1, 1, 2, 3, 4, 5)
	
	expect_equal(test_vec, ans_vec)
})

test_that("need tolerance1", {
	test_vec <- awayfromzero(0.005 + 1:5/100, digits = 2)
	ans_vec <- c(0.02, 0.03, 0.04, 0.05, 0.06)
	
	expect_equal(test_vec, ans_vec)
})

test_that("need tolerance2", {
	test_vec <- awayfromzero(c(123456789.4, 123456789.5), digits = 0)
	ans_vec <- c(123456789, 123456790)
	
	expect_equal(test_vec, ans_vec)
})

test_that("accumulated error", {
	x <- 0
	for(i in 1:25) x <- x + 0.3
	test_vec <- awayfromzero(x, digits = 0)
	ans_vec <- 8
	
	expect_equal(test_vec, ans_vec)
})

test_that("Non-finite numbers", {
	test_vec <- awayfromzero(c(NA, NaN, Inf, -Inf))
	ans_vec <- c(NA, NaN, Inf, -Inf)
	
	expect_equal(test_vec, ans_vec)
})

test_that("Non-finite and finite numbers", {
	test_vec <- awayfromzero(c(NA, NaN, 8.5, Inf, -Inf, 1234.5))
	ans_vec <- c(NA, NaN, 9, Inf, -Inf, 1235)
	
	expect_equal(test_vec, ans_vec)
})

test_that("Negative digit", {
	test_vec <- awayfromzero(c(104, 105, 224, 225), digits = -1)
	ans_vec <- c(100, 110, 220, 230)
	
	expect_equal(test_vec, ans_vec)
})

test_that("Input structure", {
	test_mtx <- awayfromzero(matrix(0.005 + 1:9/100, nrow=3), digits = 2)
	ans_mtx <- matrix(2:10/100, nrow=3)
	
	expect_equal(test_mtx, ans_mtx)
})
