test_that("example1 works", {
	test_mtx <- totalize(CO2, conc, c(Type, Treatment))
	ans_mtx <- structure(c(84L, 12L, 12L, 12L, 12L, 12L, 12L, 12L, 42L, 6L, 
6L, 6L, 6L, 6L, 6L, 6L, 42L, 6L, 6L, 6L, 6L, 6L, 6L, 6L, 42L, 
6L, 6L, 6L, 6L, 6L, 6L, 6L, 21L, 3L, 3L, 3L, 3L, 3L, 3L, 3L, 
21L, 3L, 3L, 3L, 3L, 3L, 3L, 3L, 42L, 6L, 6L, 6L, 6L, 6L, 6L, 
6L, 21L, 3L, 3L, 3L, 3L, 3L, 3L, 3L, 21L, 3L, 3L, 3L, 3L, 3L, 
3L, 3L), dim = 8:9, dimnames = list(conc = c("all", "95", "175", 
"250", "350", "500", "675", "1000"), `Type,Treatment` = c("all|all", 
"all|nonchilled", "all|chilled", "Quebec|all", "Quebec|nonchilled", 
"Quebec|chilled", "Mississippi|all", "Mississippi|nonchilled", 
"Mississippi|chilled")))
	
	expect_equal(test_mtx, ans_mtx)
})

test_that("example2 works", {
	test_mtx <- totalize(CO2, conc, c(Type, Treatment), uptake, FUN=mean)
	ans_mtx <- structure(c(27.213095238095239, 12.258333333333333, 22.283333333333331, 
28.875, 30.666666666666668, 30.875, 31.949999999999999, 33.583333333333336, 
30.642857142857142, 13.283333333333333, 25.116666666666667, 32.466666666666669, 
35.133333333333333, 35.100000000000001, 36.016666666666666, 37.383333333333333, 
23.783333333333331, 11.233333333333333, 19.449999999999999, 25.283333333333335, 
26.199999999999999, 26.649999999999999, 27.883333333333333, 29.783333333333331, 
33.542857142857144, 14.066666666666666, 27.083333333333332, 35.93333333333333, 
38.083333333333336, 38.133333333333333, 39.5, 42, 35.333333333333336, 
15.266666666666666, 30.033333333333331, 37.399999999999999, 40.366666666666667, 
39.600000000000001, 41.5, 43.166666666666664, 31.752380952380953, 
12.866666666666667, 24.133333333333333, 34.466666666666669, 35.799999999999997, 
36.666666666666664, 37.5, 40.833333333333336, 20.883333333333333, 
10.449999999999999, 17.483333333333334, 21.816666666666666, 23.25, 
23.616666666666667, 24.399999999999999, 25.166666666666668, 25.952380952380953, 
11.300000000000001, 20.199999999999999, 27.533333333333335, 29.899999999999999, 
30.599999999999998, 30.533333333333335, 31.600000000000001, 15.814285714285713, 
9.5999999999999996, 14.766666666666667, 16.100000000000001, 16.599999999999998, 
16.633333333333333, 18.266666666666666, 18.733333333333334), dim = 8:9, dimnames = list(
    conc = c("all", "95", "175", "250", "350", "500", "675", 
    "1000"), `Type,Treatment` = c("all|all", "all|nonchilled", 
    "all|chilled", "Quebec|all", "Quebec|nonchilled", "Quebec|chilled", 
    "Mississippi|all", "Mississippi|nonchilled", "Mississippi|chilled"
    )))
	
	expect_equal(test_mtx, ans_mtx)
})

test_that("example3 works", {
	test_mtx <- totalize(esoph, agegp, c(alcgp, tobgp), ncases)
	ans_mtx <- structure(c(200, 1, 9, 46, 76, 55, 13, 78, 0, 2, 14, 25, 31, 
6, 58, 1, 4, 13, 23, 12, 5, 33, 0, 3, 8, 12, 10, 0, 31, 0, 0, 
11, 16, 2, 2, 29, 0, 1, 1, 12, 11, 4, 9, 0, 0, 1, 2, 5, 1, 10, 
0, 1, 0, 3, 4, 2, 5, 0, 0, 0, 3, 2, NA, 5, 0, 0, 0, 4, 0, 1, 
75, 0, 4, 20, 22, 25, 4, 34, 0, 0, 6, 9, 17, 2, 17, 0, 3, 4, 
6, 3, 1, 15, 0, 1, 5, 4, 5, 0, 9, 0, 0, 5, 3, NA, 1, 51, 0, 0, 
12, 24, 13, 2, 19, 0, 0, 3, 9, 6, 1, 19, 0, 0, 6, 8, 4, 1, 6, 
NA, 0, 1, 3, 2, NA, 7, 0, 0, 2, 4, 1, NA, 45, 1, 4, 13, 18, 6, 
3, 16, 0, 2, 4, 5, 3, 2, 12, 1, 0, 3, 6, 1, 1, 7, 0, 2, 2, 2, 
1, NA, 10, 0, NA, 4, 5, 1, NA), dim = c(7L, 25L), dimnames = list(
    agegp = c("all", "25-34", "35-44", "45-54", "55-64", "65-74", 
    "75+"), `alcgp,tobgp` = c("all|all", "all|0-9g/day", "all|10-19", 
    "all|20-29", "all|30+", "0-39g/day|all", "0-39g/day|0-9g/day", 
    "0-39g/day|10-19", "0-39g/day|20-29", "0-39g/day|30+", "40-79|all", 
    "40-79|0-9g/day", "40-79|10-19", "40-79|20-29", "40-79|30+", 
    "80-119|all", "80-119|0-9g/day", "80-119|10-19", "80-119|20-29", 
    "80-119|30+", "120+|all", "120+|0-9g/day", "120+|10-19", 
    "120+|20-29", "120+|30+")))
	
	expect_equal(test_mtx, ans_mtx)
})

test_that("example4 works", {
	test_df <- totalize(esoph, agegp, c(alcgp, tobgp), ncases, asDF=TRUE, drop=TRUE)
	ans_df <- structure(list(agegp = structure(c(1L, 1L, 1L, 1L, 1L, 1L, 1L, 
1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 
1L, 1L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 
2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 3L, 3L, 3L, 3L, 3L, 3L, 
3L, 3L, 3L, 3L, 3L, 3L, 3L, 3L, 3L, 3L, 3L, 3L, 3L, 3L, 3L, 3L, 
3L, 3L, 4L, 4L, 4L, 4L, 4L, 4L, 4L, 4L, 4L, 4L, 4L, 4L, 4L, 4L, 
4L, 4L, 4L, 4L, 4L, 4L, 4L, 4L, 4L, 4L, 4L, 5L, 5L, 5L, 5L, 5L, 
5L, 5L, 5L, 5L, 5L, 5L, 5L, 5L, 5L, 5L, 5L, 5L, 5L, 5L, 5L, 5L, 
5L, 5L, 5L, 5L, 6L, 6L, 6L, 6L, 6L, 6L, 6L, 6L, 6L, 6L, 6L, 6L, 
6L, 6L, 6L, 6L, 6L, 6L, 6L, 6L, 6L, 6L, 6L, 6L, 7L, 7L, 7L, 7L, 
7L, 7L, 7L, 7L, 7L, 7L, 7L, 7L, 7L, 7L, 7L, 7L, 7L, 7L, 7L, 7L
), levels = c("all", "25-34", "35-44", "45-54", "55-64", "65-74", 
"75+"), class = c("ordered", "factor")), alcgp = structure(c(1L, 
1L, 1L, 1L, 1L, 2L, 2L, 2L, 2L, 2L, 3L, 3L, 3L, 3L, 3L, 4L, 4L, 
4L, 4L, 4L, 5L, 5L, 5L, 5L, 5L, 1L, 1L, 1L, 1L, 1L, 2L, 2L, 2L, 
2L, 2L, 3L, 3L, 3L, 3L, 3L, 4L, 4L, 4L, 4L, 5L, 5L, 5L, 5L, 5L, 
1L, 1L, 1L, 1L, 1L, 2L, 2L, 2L, 2L, 2L, 3L, 3L, 3L, 3L, 3L, 4L, 
4L, 4L, 4L, 4L, 5L, 5L, 5L, 5L, 1L, 1L, 1L, 1L, 1L, 2L, 2L, 2L, 
2L, 2L, 3L, 3L, 3L, 3L, 3L, 4L, 4L, 4L, 4L, 4L, 5L, 5L, 5L, 5L, 
5L, 1L, 1L, 1L, 1L, 1L, 2L, 2L, 2L, 2L, 2L, 3L, 3L, 3L, 3L, 3L, 
4L, 4L, 4L, 4L, 4L, 5L, 5L, 5L, 5L, 5L, 1L, 1L, 1L, 1L, 1L, 2L, 
2L, 2L, 2L, 2L, 3L, 3L, 3L, 3L, 4L, 4L, 4L, 4L, 4L, 5L, 5L, 5L, 
5L, 5L, 1L, 1L, 1L, 1L, 1L, 2L, 2L, 2L, 2L, 3L, 3L, 3L, 3L, 3L, 
4L, 4L, 4L, 5L, 5L, 5L), levels = c("all", "0-39g/day", "40-79", 
"80-119", "120+"), class = c("ordered", "factor")), tobgp = structure(c(1L, 
2L, 3L, 4L, 5L, 1L, 2L, 3L, 4L, 5L, 1L, 2L, 3L, 4L, 5L, 1L, 2L, 
3L, 4L, 5L, 1L, 2L, 3L, 4L, 5L, 1L, 2L, 3L, 4L, 5L, 1L, 2L, 3L, 
4L, 5L, 1L, 2L, 3L, 4L, 5L, 1L, 2L, 3L, 5L, 1L, 2L, 3L, 4L, 5L, 
1L, 2L, 3L, 4L, 5L, 1L, 2L, 3L, 4L, 5L, 1L, 2L, 3L, 4L, 5L, 1L, 
2L, 3L, 4L, 5L, 1L, 2L, 3L, 4L, 1L, 2L, 3L, 4L, 5L, 1L, 2L, 3L, 
4L, 5L, 1L, 2L, 3L, 4L, 5L, 1L, 2L, 3L, 4L, 5L, 1L, 2L, 3L, 4L, 
5L, 1L, 2L, 3L, 4L, 5L, 1L, 2L, 3L, 4L, 5L, 1L, 2L, 3L, 4L, 5L, 
1L, 2L, 3L, 4L, 5L, 1L, 2L, 3L, 4L, 5L, 1L, 2L, 3L, 4L, 5L, 1L, 
2L, 3L, 4L, 5L, 1L, 2L, 3L, 4L, 1L, 2L, 3L, 4L, 5L, 1L, 2L, 3L, 
4L, 5L, 1L, 2L, 3L, 4L, 5L, 1L, 2L, 3L, 5L, 1L, 2L, 3L, 4L, 5L, 
1L, 2L, 3L, 1L, 2L, 3L), levels = c("all", "0-9g/day", "10-19", 
"20-29", "30+"), class = c("ordered", "factor")), ncases = c(200, 
78, 58, 33, 31, 29, 9, 10, 5, 5, 75, 34, 17, 15, 9, 51, 19, 19, 
6, 7, 45, 16, 12, 7, 10, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 9, 2, 4, 3, 0, 1, 0, 1, 0, 
0, 4, 0, 3, 1, 0, 0, 0, 0, 0, 0, 4, 2, 0, 2, 46, 14, 13, 8, 11, 
1, 1, 0, 0, 0, 20, 6, 4, 5, 5, 12, 3, 6, 1, 2, 13, 4, 3, 2, 4, 
76, 25, 23, 12, 16, 12, 2, 3, 3, 4, 22, 9, 6, 4, 3, 24, 9, 8, 
3, 4, 18, 5, 6, 2, 5, 55, 31, 12, 10, 2, 11, 5, 4, 2, 0, 25, 
17, 3, 5, 13, 6, 4, 2, 1, 6, 3, 1, 1, 1, 13, 6, 5, 0, 2, 4, 1, 
2, 1, 4, 2, 1, 0, 1, 2, 1, 1, 3, 2, 1)), row.names = c(NA, -167L
), class = "data.frame")
	
	expect_equal(test_df, ans_df)
})

test_that("example5 works", {
	set.seed(1234L)
	test_mtx <- transform(CO2, weight=rnorm(nrow(CO2), 10, 1)) |> totalize_weightedmean(Type, Treatment, val=uptake, weight=weight)
	ans_mtx <- structure(c(27.120460529595913, 33.626115170265827, 20.783580420951875, 
30.623165297825235, 35.371341437946292, 25.84663890214361, 23.62083098486216, 
31.82454218453087, 15.883336691998933), dim = c(3L, 3L), dimnames = list(
    Type = c("all", "Quebec", "Mississippi"), Treatment = c("all", 
    "nonchilled", "chilled")))
	
	expect_equal(test_mtx, ans_mtx)
})
