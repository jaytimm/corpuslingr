#' Modify text annotations for more robust corpus search
#'
#' These functions modify the output of `spacyr'
#' @name setCorpus
#' @param x A list of dataframes
#' @return A list of dataframes
#' @import data.table


#' @export
#' @rdname setCorpus
clr_prep_corpus <- function (x, text_var = 'text',hyphenate=TRUE) {
  x$text <- as.character(x$text)
  #Could set encoding as well.
  x$text <- gsub("^ *|(?<= ) | *$", "", x$text, perl = TRUE)

  x$text <- gsub("(--)([[:alpha:]])","\\1 \\2",x$text, perl=TRUE)
  x$text <- gsub("([[:alpha:]])(--)","\\1 \\2",x$text, perl=TRUE)

  if (hyphenate==TRUE) {
    x$text <- gsub("([[:alpha:]])-([[:alpha:]])",'\\1qq\\2',x$text, perl=TRUE)}
  return(x)}


clr_set_tuple <- function(x){
  text <- paste(x$tup,collapse=" ") #TIF
  tup_bounds <- unlist(as.vector(gregexpr(pattern=" ", text)[[1]]))
  x$tupBeg <- append(1,tup_bounds+1)
  x$tupEnd <- append(tup_bounds,nchar(text)+1)
  class(x) <- c("spacyr_parsed", "data.frame")
  return(x)}

#Could return tuple_tif here.

#' @export
#' @rdname setCorpus
clr_set_corpus <- function (y, doc_var='doc_id', token_var='token', lemma_var='lemma', tag_var='tag', pos_var='pos',sentence_var='sentence_id', ent_as_tag = FALSE) {

  x <- copy(y)

  setnames(x, old = c(doc_var,token_var,lemma_var,tag_var, pos_var,sentence_var), new = c('doc_id', 'token','lemma','tag','pos','sentence_id'))
  #x$doc_id <- gsub('\\D+','text',x$doc_id)

  x$lemma <- gsub("[[:space:]]+", "",x$lemma)
  x$token <- gsub("[[:space:]]+", "",x$token)

  x$lemma <- ifelse(x$pos=="PROPN"|x$pos=="ENTITY"|x$lemma=="-PRON-",x$token,x$lemma)

  x$lemma <- gsub("qq", "-", x$lemma)
  x$token <- gsub("qq", "-", x$token)

  x <- x[!(x$tag=='SP'| x$tag=='NFP' | x$pos == 'SPACE' | x$token =="" | x$token==" "),]

  if (ent_as_tag == TRUE) {
  x$tag = ifelse(x$tag=="ENTITY",paste0("NN",x$entity_type),x$tag)}


  x$tup <- paste("<",x$token,"~",x$lemma,"~",x$tag,">",sep="")

  list_dfs <- split(x, f = x$doc_id)
  list_dfs <- lapply(list_dfs,clr_set_tuple)
  list_dfs[order(as.numeric(names(list_dfs)))]
}

