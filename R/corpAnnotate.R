#' Annotate a corpus of texts using the `spacyr` package
#'
#' These functions modify the output of `spacyr'
#' @name corpAnnotate
#' @param charList A list of texts as character strings
#' @return A list of dataframes
#' @import spacyr tidyverse data.table
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
SpacyrAnnotate <- function(charList){

annotation <- lapply(charList, function(y){
  spacyr::spacy_parse(y,tag=TRUE)%>%
  mutate(token=gsub("\\s*","",token),lemma=gsub("^-|-$|\\s*","",lemma))%>%#Needs explanation.
  mutate(lemma=ifelse(pos=="PROPN",token,lemma))%>%
  buildTuple()%>%
  rename(sid=sentence_id,tid=token_id)})

names(annotation) <- c(1:length(annotation))
annotation <- mapply (`[<-`, annotation, 'doc_id', value = as.integer(names(annotation)), SIMPLIFY = FALSE)

return(annotation)
}
