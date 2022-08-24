#' Put totalized vector into a matrix table
#'
#' @description
#'   Put totalized vector into a matrix table.
#'
#' @param data totalized vector.
#' @param row grouping index vector to be arranged by row. the others are to be arranged by column.
#' @param namelength optional. dimnames would be abbrevieated to this length.
#'
#'
#' @export
#'
#' @examples
#' totalize(esoph, "ncases", c("agegp", "alcgp", "tobgp")) |> tomatrix(c(1, 2))
#' 
tomatrix <- function(data, row, namelength=7){
	labels <- attr(data, "groups")
	
	col <- setdiff(seq_along(labels), row)
	rowlabel <- interaction(expand.grid(labels[row]), sep="|")
	collabel <- interaction(expand.grid(labels[col]), sep="|")
	
	if(!missing(namelength)){
		rowlabel <- abbreviate(rowlabel, namelength)
		collabel <- abbreviate(collabel, namelength)
	}
	
	dnames <- list(rowlabel, collabel)
	names(dnames) <- c(paste(names(labels)[row], collapse=","), paste(names(labels)[col], collapse=","))
	
	# 要素の数の連番でソート用のインデックスを作る
	labels_order <- lapply(labels, seq_along)
	orderidx <- do.call(order, expand.grid(labels_order)[rev(c(row, col))])
	
	matrix(data[orderidx], nrow=length(rowlabel), dimnames=dnames)
}

#' Convert totalized vector to data frame
#'
#' @description
#'   Convenient function to get a data frame.
#'
#' @param data totalized vector.
#'
#' @export
#'
toDF <- function(data){
	df <- expand.grid(attr(data, "groups"))
	df[[attr(data, "value")]] <- data
	df
}

