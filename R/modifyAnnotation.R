#' Modify text annotations for more robust corpus search
#'
#' These functions modify the output of `spacyr'
#' @name corpAnnotate
#' @param x A list of dataframes
#' @return A list of dataframes
#' @import magrittr dplyr


#' @export
#' @rdname annotationModify
buildTuple <- function(x){
  x$tup <- paste("<",x$token,"_",x$lemma,"_",x$tag,">",sep="")
  text <- paste(x$tup,collapse=" ")
  tup_bounds <- unlist(as.vector(gregexpr(pattern=" ", text)[[1]]))
  x$tupBeg <- append(1,tup_bounds+1)
  x$tupEnd <- append(tup_bounds,nchar(text)+1)
  return(x)}



#' @export
#' @rdname annotationModify
ModifyAnnotation <- function(x){

NUMS <- c('PERCENT','ORDINAL','MONEY','DATE','CARDINAL')

if (is.data.frame(x)) x <- list(x)

annotation <- lapply(x, function(y){
  out <- y %>%
    mutate(token=gsub("\\s*","",token),
           lemma=gsub("\\s*","",lemma))%>%
    mutate(lemma=ifelse(pos=="PROPN"|pos=="ENTITY",token,lemma))%>%
    mutate(lemma=gsub("xxx","-",lemma),
           token=gsub("xxx","-",token))%>%
    mutate(tag = ifelse(tag=="ENTITY" & !entity_type %in% NUMS ,paste("NN",entity_type,sep=""),tag))%>%
    mutate(tag = ifelse(tag=="ENTITY",entity_type,tag))%>%
    filter(pos != "SPACE")%>%
    buildTuple() %>%
    mutate(token=gsub("_"," ",token),
           lemma=gsub("_"," ",lemma))

  class(out) <- c("spacyr_parsed", "data.frame")
  return(out)})#A list of dataframes.

if (length(out) >1) {
annotation <- mapply (`[<-`, annotation, 'doc_id', value = as.integer(c(1:length(annotation))), SIMPLIFY = FALSE)}

return(annotation)
}
