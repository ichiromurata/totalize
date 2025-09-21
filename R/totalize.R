#' Aggregate values by groups and add their group total
#'
#' @description
#'   Aggregate values by specified groups and adds their group totals.
#'   If two or more grouping variables are provided, `totalize` calculates subtotals for each group and an overall grand total.
#'   It performs these calculations using standard R functions (e.g., `sum`, `mean`).
#'
#' @param data A data.frame.
#' @param row The name(s) or index number(s) of the column(s) to be used for row grouping.
#' @param col The name(s) or index number(s) of the column(s) to be used for column grouping.
#' @param val The name(s) or index number(s) of the column(s) containing values to be aggregated. If not specified, data counts will be returned.
#' @param FUN A scalar function to be applied to each group (e.g., `sum`, `mean`).
#' @param asDF If `TRUE`, the result will be returned as a data.frame.
#' @param drop Whether to drop or retain unused factor levels in the data. This parameter is only relevant when `asDF = TRUE`.
#' @param label_abbr The length which row and column names in the result matrix will be abbreviated to. This parameter is only relevant when `asDF = FALSE`.
#' @param ... Further arguments passed to `FUN`.
#'
#' @details
#'   The `row`, `col`, and `val` parameters support 'non-standard evaluation' (NSE).
#'   This means you can provide column names directly without quoting them (see examples).
#'   These parameters also accept column index numbers from the input data.
#'
#' @return
#'   A matrix (or a list of matrices) when `asDF=FALSE`. If `asDF = TRUE`, a data.frame is returned. 
#'   Matrix representation displays all possible combinations of row and column groups, with `NA` for combinations not present in the data.
#'   A data.frame result can exclude these unused combinations.
#' 
#' @export
#'
#' @examples
#' totalize(CO2, conc, c(Type, Treatment))
#' totalize(CO2, conc, c(Type, Treatment), uptake, FUN=mean)
#' 
#' # Unused combinations
#' totalize(esoph, agegp, c(alcgp, tobgp), ncases)
#' totalize(esoph, agegp, c(alcgp, tobgp), ncases, asDF=TRUE, drop=TRUE)
#' 
#' # Multiple values get into multiple matrices
#' totalize(esoph, agegp, alcgp, val=c(ncases, ncontrols))
#' 
#' # Weighted mean calculation (Creating random weights for example)
#' CO2_Weight <- transform(CO2, weight=rnorm(nrow(CO2), 10, 1))
#' CO2_Weight <- transform(CO2_Weight, uptake_w = uptake * weight)
#' totalize(CO2_Weight, Type, Treatment, val=c(uptake_w, weight), asDF=TRUE) |>
#'   transform(uptake_w_mean = uptake_w / weight)
#' 
#' # NA handling
#' totalize(penguins, species, island)
#' totalize(penguins, species, island, body_mass, FUN=sum, na.rm=TRUE)
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
	val_df <- if(is.null(val_idx)) data.frame(n=rep(1L, nrow(data))) else data[val_idx]
	
	# "all" prefix for subtotal labels
	all_labels <- paste("all", names(by_df), sep="_")

	# All combinations of grouping columns
	subtotal_list <- vector("list", length(by_idx))
	for (k in seq_along(by_idx)) {
		combs <- utils::combn(length(by_idx), k, simplify = FALSE)
		subtotal_list[[k]] <- lapply(combs, function(cb) {
			by_tmp <- by_df
			for (i in cb) {
				by_tmp[[i]] <- all_labels[i]
			}
			lapply(val_df, function(eachVal) {
				tapply(eachVal, interaction(by_tmp, sep = "|"), FUN = FUN, ...)
			})
		})
	}
	subtotals <- lapply(seq_along(val_df), function(v_idx) {
		unlist(lapply(subtotal_list, function(k_list) lapply(k_list, `[[`, v_idx)))
	})
	
	# Aggregate each cells
	crosscells <- lapply(val_df, function(eachVal) {
		tapply(eachVal, interaction(by_df, sep="|"), FUN=FUN, ...)
	})

	# Combine each combinations and crosscells
	result <- lapply(seq_along(val_df), function(v_idx) {
		c(crosscells[[v_idx]], subtotals[[v_idx]])
	})

	label_grid <- expand.grid(lapply(rev(seq_along(by_idx)), function(i) {
		lev <- if (is.factor(by_df[[i]])) levels(by_df[[i]]) else sort(unique(by_df[[i]]))
		c(all_labels[i], lev)
	}))
	# Reverse columns so that the last column varies the fastest
	label_grid <- label_grid[rev(seq_along(by_idx))]
	# Ordering result
	result <- lapply(result, `[`, levels(interaction(label_grid, sep = "|", lex.order = TRUE)))

	if(asDF){
		result_df <- data.frame(label_grid, result, row.names = NULL)
		names(result_df) <- c(names(by_df), names(val_df))
		if (drop) {
			na_rows <- Reduce(`&`, lapply(result_df[names(val_df)], is.na))
			result_df <- result_df[!na_rows, ]
			row.names(result_df) <- NULL
		}
		return(result_df)
	} else {
		rowLabel <- levels(interaction(label_grid[seq_along(row_idx)], sep="|", lex.order=TRUE))
		colLabel <- if (!missing(col)) {
			levels(interaction(label_grid[-seq_along(row_idx)], sep="|", lex.order=TRUE))
		} else {
			names(val_df)
		}

		if(is.numeric(label_abbr)){
			rowLabel <- abbreviate(rowLabel, label_abbr)
			colLabel <- abbreviate(colLabel, label_abbr)
		}

		dnames <- list(rowLabel, colLabel)
		names(dnames) <- c(paste(names(data[row_idx]), collapse=","), paste(names(data[setdiff(by_idx, row_idx)]), collapse=","))
		result_mtx <- lapply(result, matrix, nrow=length(rowLabel), byrow=TRUE, dimnames=dnames)

		if(length(result_mtx) == 1){
			result_mtx <- result_mtx[[1]]
		} else {
			names(result_mtx) <- names(val_df)
		}
		return(result_mtx)
	}	
}
