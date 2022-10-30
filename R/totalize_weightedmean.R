#' @rdname totalize
#' @export
totalize_weightedmean <- function(data, row, col=NULL, val, weight, asDF=FALSE, drop=FALSE, label_abbr=NA){
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
	weight_idx <- eval(substitute(weight), dataenv, enclos=parent.frame())
	
	data[[val_idx]] <- data[[val_idx]] * data[[weight_idx]]
	x <- totalize(data, by_idx, val=val_idx, asDF=TRUE, drop=drop)
	w <- totalize(data, by_idx, val=weight_idx, asDF=TRUE, drop=drop)
	
	resultval_idx <- length(x)
	x[[resultval_idx]] <- x[[resultval_idx]] / w[[resultval_idx]]
	
	if(asDF == FALSE){
		x <- to_matrix(x, seq_along(row_idx), resultval_idx, label_abbr)
	}
	
	x
}

