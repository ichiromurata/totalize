#' Aggregate values by groups and make their total
#'
#' @description
#'   Aggregate values by groups and make their total.
#'   If there are 2 or more groups, the total of each group (subtotals) and the whole total will be made.
#'   `totalize` calculate values using a simple function such as `sum`, `mean`, and more.
#'   `totalize_weightedmean` is the convenience version for calculating weighted mean.
#'
#' @param data A data.frame.
#' @param row Grouping column name(s) to be arranged by row.
#' @param col Grouping column name(s) to be arranged by column.
#' @param val A column name to be aggregated. If not specified, data counts will be returned.
#' @param weight A column name to be a weight for calculating weighted mean.
#' @param FUN Function to be applied for each group.
#' @param asDF If `TRUE`, a data.frame will be returned.
#' @param drop Whether to drop or retain unused factors in data. This is only for the data.frame result.
#' @param label_abbr Grouping item names in the result matrix will be abbreviated to this length.
#' @param ... Further arguments passed to `FUN`.
#'
#' @details
#'   Parameters `row`, `col`, `val`, and `weight` accept direct names of the input data.
#'   This means you don't need to give these names as character vector (See examples). 
#'   These parameters also accept column index numbers of the input data.
#'
#' @return
#'   A matrix for `asDF=FALSE`, while `asDF=TRUE` returns a data.frame. 
#'   Since matrix representation shows all combinations of row and column groups, unused combinations in data are shown as `NA`.
#'   A data.frame result can drop unused combinations.
#' 
#' @export
#'
#' @examples
#' totalize(CO2, conc, c(Type, Treatment))
#' totalize(CO2, conc, c(Type, Treatment), uptake, FUN=mean)
#' 
#' # Show unused combinations
#' totalize(esoph, agegp, c(alcgp, tobgp), ncases)
#' totalize(esoph, agegp, c(alcgp, tobgp), ncases, asDF=TRUE, drop=TRUE)
#' 
#' # Weighted mean calculation (Creating random weights for example) 
#' transform(CO2, weight=rnorm(nrow(CO2), 10, 1)) |> totalize_weightedmean(Type, Treatment, val=uptake, weight=weight)
#' 
totalize <- function(data, row, col=NULL, val=NULL, FUN=sum, asDF=FALSE, drop=FALSE, label_abbr=NA, ...){
	# Argument check
	if(asDF==FALSE && drop==TRUE){
		warning("'drop=TRUE' is not valid for matrix representation.", call.=FALSE)
		drop <- FALSE
	}
	# Handling column selection
	dataenv <- stats::setNames(as.list(seq_along(data)), names(data))
	row_idx <- eval(substitute(row), dataenv, enclos=parent.frame())
	by_idx <- eval(substitute(c(row, col)), dataenv, enclos=parent.frame())
	val_idx <- eval(substitute(val), dataenv, enclos=parent.frame())
	
	by_df <- data[by_idx]
	val_df <- if(is.null(val_idx)) list(n=rep(1L, nrow(data))) else data[val_idx]
	
	# All combinations of choosing some columns in `by_df`
	comb <- lapply(seq_along(by_idx), utils::combn, x=length(by_idx), simplify=FALSE)
	# Aggregate all items in some columns
	subtotalList <- lapply(comb, function(cbList){
		tmptotal <- lapply(cbList, function(cb) {
			labels <- by_df
			for(i in cb) labels[[i]] <- "all"
			stats::aggregate(val_df, labels, FUN=FUN, ..., drop=drop)
			})
		do.call(rbind, tmptotal)
		})
	subtotals <- do.call(rbind, subtotalList)
	# Aggregate by each columns (ordinary aggregation)
	crosscells <- stats::aggregate(val_df, by_df, FUN=FUN, ..., drop=drop)
	
	result <- rbind(crosscells, subtotals)
	
	# Add "all" level
	for(i in seq_along(by_idx)){
		add_all <- if(is.factor(by_df[[i]])) append("all", levels(by_df[[i]])) else append("all", unique(by_df[[i]]))
		result[[i]] <- factor(result[[i]], levels=add_all)
	}
	
	result <- result[order(interaction(result[seq_along(by_idx)], lex.order=TRUE)), ]
	row.names(result) <- NULL
	
	if(asDF == FALSE){
		result <- to_matrix(result, seq_along(row_idx), length(result), label_abbr)
	}
	
	result
}

to_matrix <- function(data, row, val, label_abbr=NA){
	rowlabel <- levels(interaction(data[row], sep="|", lex.order=TRUE))
	col <- seq_along(data)[-c(row, val)]
	collabel <- if(length(col) > 0) levels(interaction(data[col], sep="|", lex.order=TRUE)) else names(data[val])
	
	if(!is.na(label_abbr)){
		rowlabel <- abbreviate(rowlabel, label_abbr)
		collabel <- abbreviate(collabel, label_abbr)
	}
	
	dnames <- list(rowlabel, collabel)
	names(dnames) <- c(paste(names(data[row]), collapse=","), paste(names(data[col]), collapse=","))
	
	matrix(data[[val]][order(interaction(data[c(col, row)], lex.order=TRUE))], nrow=length(rowlabel), dimnames=dnames)
}
