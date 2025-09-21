#' Aggregate values by groups and add their group total
#'
#' @description
#'   Aggregate values by groups and add their group total.
#'   If there are 2 or more groups, the total of each group (subtotals) and the whole total will be made.
#'   `totalize` calculate values using a simple function such as `sum`, `mean`, etc.
#'   `totalize_weightedmean` is a convenient version for calculating weighted mean.
#'
#' @param data A data.frame.
#' @param row Grouping column name(s) to be arranged by row.
#' @param col Grouping column name(s) to be arranged by column.
#' @param val A column name to be aggregated. If not specified, data counts will be returned.
#' @param weight A column name to be a weight for calculating weighted mean.
#' @param FUN A scalar function to be applied for each group.
#' @param asDF If `TRUE`, a data.frame will be returned.
#' @param drop Whether to drop or retain unused factors in data. This is only for `asDF=TRUE`.
#' @param label_abbr Grouping item names in the result matrix will be abbreviated to this length. This is only for `asDF=FALSE`
#' @param ... Further arguments passed to `FUN`.
#'
#' @details
#'   Parameters `row`, `col`, `val`, and `weight` handle column names with non-standard evaluation.
#'   This means you don't need to give these names as a character vector (See examples). 
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
	
	# Value must be single column
	if(length(val_idx) > 1){
		stop("Only one column can be specified for 'val'.", call.=FALSE)
	}

	by_df <- data[by_idx]
	val_df <- if(is.null(val_idx)) data.frame(n=rep(1L, nrow(data))) else data[val_idx]
	
	# All combinations of subtotals
	num_subcol <- length(by_idx)
	comb <- lapply(seq_len(num_subcol - 1), utils::combn, x=num_subcol)
	# Column totals
	subtotalList <- lapply(comb, function(cbMtx){
		tmptotal <- apply(cbMtx, MARGIN=2, function(cbArray) {
			by_tmp <- by_df
			for(i in cbArray){
				by_tmp[[i]] <- factor(paste("all", names(by_df[i]), sep="_"))
			}
			tapply(val_df[[1]], list(interaction(by_tmp, sep="|")), FUN=FUN, ...)
			}, simplify=FALSE)
		unlist(tmptotal)
		})
	subtotals <- unlist(subtotalList)
	# Total
	total <- FUN(val_df[[1]], ...)
	names(total) <- paste("all", names(by_df), sep="_", collapse="|")
	# Aggregate each cells
	crosscells <- tapply(val_df[[1]], interaction(by_df, sep="|", drop=drop), FUN=FUN, ...)
	
	result <- c(total, subtotals, crosscells)
	label_grid <- expand.grid(lapply(names(by_df), function(x) {
		c(paste("all", x, sep="_"), if(is.factor(by_df[[x]])) levels(by_df[[x]]) else unique(by_df[[x]]))
	}))
	result <- result[levels(interaction(label_grid, sep="|"))]

	if(asDF == TRUE){
		result <- data.frame(label_grid, result, row.names=NULL)
		names(result) <- c(names(by_df), names(val_df))
		if(drop){
			result <- result[!is.na(result[[ncol(result)]]), ]
			row.names(result) <- NULL
		}
	} else {
		rowlabel <- levels(interaction(label_grid[seq_along(row_idx)], sep="|"))
		collabel <- if(!missing(col)) levels(interaction(label_grid[-seq_along(row_idx)], sep="|")) else names(val_df)
		result <- matrix(result, nrow=length(rowlabel), dimnames=list(rowlabel, collabel))
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
