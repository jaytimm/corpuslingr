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
  x$tup <- paste("<",x$token,",",x$lemma,",",x$tag,">",sep="")
  text <- paste(x$tup,collapse=" ")
  tup_bounds <- unlist(as.vector(gregexpr(pattern=" ", text)[[1]]))
  x$tupBeg <- append(1,tup_bounds+1)
  x$tupEnd <- append(tup_bounds,nchar(text)+1)
  return(x)}



#' @export
#' @rdname annotationModify
ModifyAnnotation <- function(x,nerToTag=TRUE){ #We shuld preserve og tag.

NUMS <- c('PERCENT','ORDINAL','MONEY','DATE','CARDINAL','TIME','QUANTITY')

if (is.data.frame(x)) x <- list(x)

annotation <- lapply(x, function(y){
  out <- y %>%
    mutate_at(vars(token,lemma),gsub("[[:space:]]+", "",.))%>%
    mutate(lemma=ifelse(pos=="PROPN"|pos=="ENTITY",token,lemma))%>%
    mutate_at(vars(token,lemma),gsub("xxx","-",.))

  if (nerToTag==TRUE) {
  out <- out%>%
    mutate(tag = ifelse(tag=="ENTITY" & !entity_type %in% NUMS ,paste("NN",entity_type,sep=""),tag))%>%
    mutate(tag = ifelse(tag=="ENTITY",entity_type,tag))}

  out <- out %>%
    filter(!tag %in% c("SP","NFP"),pos!="SPACE",token!="",token!=" ")%>%
    buildTuple() %>%
    mutate_at(vars(token,lemma),gsub("_"," ",.))

  class(out) <- c("spacyr_parsed", "data.frame")
  return(out)})

if (length(annotation) >1) {
annotation <- mapply (`[<-`, annotation, 'doc_id', value = as.integer(c(1:length(annotation))), SIMPLIFY = FALSE)}

return(annotation)
}
