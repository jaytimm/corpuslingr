#' Annotate a corpus of texts using the `spacyr` package
#'
#' These functions modify the output of `spacyr'
#' @name corpAnnotate
#' @param x A list of dataframes
#' @return A list of dataframes
#' @import magrittr dplyr


#' @export
#' @rdname corpAnnotate
PrepText <- function (x, hyphenate=TRUE) {

  lapply(x, function(y){
    txt <- y %>%
      gsub("(?<=[\\s])\\s*|^\\s+|\\s+$", "",., perl=TRUE)%>%
      gsub('--(\\w)','-- \\1',., perl=TRUE)%>%
      gsub('(\\w)--','\\1 --',., perl=TRUE)

    if (hyphenate==TRUE) {
        txt <- gsub("(\\w)-(\\w)",'\\1xxx\\2',txt, perl=TRUE)}
    return(txt)})
}

#' @export
#' @rdname corpAnnotate
buildTuple <- function(x){
  x$tup <- paste("<",x$token,"_",x$lemma,"_",x$tag,">",sep="")
  text <- paste(x$tup,collapse=" ")
  tup_bounds <- unlist(as.vector(gregexpr(pattern=" ", text)[[1]]))
  x$tupBeg <- append(1,tup_bounds+1)
  x$tupEnd <- append(tup_bounds,nchar(text)+1)
  return(x)}



#' @export
#' @rdname corpAnnotate
ModifyAnnotation <- function(x){

annotation <- lapply(x, function(y){
  out <- y %>%
    mutate(token=gsub("\\s*","",token),
           lemma=gsub("\\s*","",lemma))%>%
    mutate(lemma=ifelse(pos=="PROPN"|pos=="ENTITY",token,lemma))%>%
    mutate(lemma=gsub("(\\w)xxx(\\w)",'\\1-\\2',lemma),
           token=gsub("(\\w)xxx(\\w)",'\\1-\\2',token))%>%
    mutate(tag = ifelse(tag=="ENTITY",paste('NE',substr(entity_type,1,2),sep=""),tag))%>%
    buildTuple()

  class(out) <- c("spacyr_parsed", "data.frame")
  return(out)})

annotation <- mapply (`[<-`, annotation, 'doc_id', value = as.integer(c(1:length(annotation))), SIMPLIFY = FALSE)

return(annotation)
}
