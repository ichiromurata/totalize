#' Aggregate values of each group and total group
#'
#' @description
#'   Aggregate values of each group and total group.
#'
#' @param data a data frame.
#' @param target a single column name.
#' @param by a character vector of column names for grouping.
#' @param FUN function to be applied for `target`.
#' @param drop whether to drop or retain unused factors in `by`.
#' @param ... further arguments passed to `FUN`.
#'
#' @details
#'   `FUN` is applied not only to each of the groups but also a sum of the groups.
#'
#' @return
#'   A numeric vector consists of the results of `FUN` applied to each group and sum of the groups. 
#'   For `drop = FALSE`, NA will be created for unused grouping. This helps to make a matrix.
#'
#'   The returned value has 3 attributes. `name` is concatenated grouping names, `value` is the column name to which `FUN` has applied,
#'   and `groups` is a list of grouping names with "all" category added.
#' 
#' @export
#'
#' @examples
#' totalize(CO2, "uptake", c("Type", "Treatment", "conc"), FUN=mean) |> tomatrix(3)
#' 
#' totalize(esoph, "ncases", c("agegp", "alcgp", "tobgp")) |> tomatrix(c(1, 2))
#' 
totalize <- function(data, target, by, FUN=sum, drop=FALSE, ...){
	# byの変数の中からi個選ぶパターンを網羅したリスト
	comb <- lapply(seq_len(length(by)), utils::combn, x=length(by), simplify=FALSE)
	# byの変数のうち1つ以上を使わない場合の小計
	subtotalList <- lapply(comb, function(cbList){
		tmptotal <- lapply(cbList, function(cb) {
			labels <- data[by]
			for(i in cb) labels[[i]] <- "all"
			sapply(split(data[[target]], interaction(labels, drop=drop, sep="|")), FUN=EmptyHandlingFunc, FUN, ...)
			})
		do.call(c, tmptotal)
		})
	subtotals <- do.call(c, subtotalList)
	# byの変数をすべて使う集計
	crosscells <- sapply(split(data[[target]], interaction(data[by], drop=drop, sep="|")), FUN=EmptyHandlingFunc, FUN, ...)
	
	result <- c(subtotals, crosscells)
	
	labels <- lapply(data[by], function(x) {if(is.factor(x)) c("all", levels(x)) else c("all", unique(x))})
	labels_sorted <- do.call(paste, c(expand.grid(labels), sep="|"))
	result <- result[labels_sorted]
	
	attr(result, "value") <- target
	attr(result, "groups") <- labels
	result
}


EmptyHandlingFunc <- function(x, FUN, ...){
	if(length(x) == 0) return(NA)
	FUN(x, ...)
}
