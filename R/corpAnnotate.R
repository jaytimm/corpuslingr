#' Annotate a corpus of texts using the `spacyr` package
#'
#' These functions modify the output of `spacyr'
#' @name corpAnnotate
#' @param x A list of dataframes
#' @return A list of dataframes
#' @import tidyverse data.table
#' @export
#' @rdname corpAnnotate
#'

#' @export
#' @rdname corpAnnotate
buildTuple <- function(x,form,lem,POS){
  x$tup <- paste("<",x[,form],",",x[,lem],",",x[,POS],">",sep="")
  text <- paste(x$tup,collapse=" ")
  tup_bounds <- unlist(as.vector(gregexpr(pattern=" ", text)[[1]]))
  x$tupBeg <- append(1,tup_bounds+1)
  x$tupEnd <- append(tup_bounds,nchar(text)+1)
  return(x)}


#' @export
#' @rdname corpAnnotate
PrepAnnotation <- function(x,form,lem,POS){

annotation <- lapply(x, function(y){
  annotation <- y %>%
    mutate(token=gsub("\\s*","",token),lemma=gsub("^-|-$|\\s*","",lemma))%>%
    mutate(lemma=ifelse(pos=="PROPN",token,lemma))%>%
    buildTuple(form,lem,POS)

  class(annotation) <- c("spacyr_parsed", class(annotation)})

annotation <- mapply (`[<-`, annotation, 'doc_id', value = as.integer(c(1:length(annotation))), SIMPLIFY = FALSE)

return(annotation)
}
