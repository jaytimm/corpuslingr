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
buildTuple <- function(x){
  x$tup <- paste("<",x$token,",",x$lemma,",",x$tag,">",sep="")
  text <- paste(x$tup,collapse=" ")
  tup_bounds <- unlist(as.vector(gregexpr(pattern=" ", text)[[1]]))
  x$tupBeg <- append(1,tup_bounds+1)
  x$tupEnd <- append(tup_bounds,nchar(text)+1)
  return(x)}


#' @export
#' @rdname corpAnnotate
PrepAnnotation <- function(x){

annotation <- lapply(x, function(y){
  out <- y %>%
    mutate(token=gsub("\\s*","",token),lemma=gsub("^-|-$|\\s*","",lemma))%>%
    mutate(lemma=ifelse(pos=="PROPN",token,lemma))%>%
    buildTuple()

  class(out) <- c("spacyr_parsed", "data.frame")
  return(out)})

annotation <- mapply (`[<-`, annotation, 'doc_id', value = as.integer(c(1:length(annotation))), SIMPLIFY = FALSE)

return(annotation)
}
