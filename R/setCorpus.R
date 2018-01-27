#' Modify text annotations for more robust corpus search
#'
#' These functions modify the output of `spacyr'
#' @name setCorpus
#' @param x A list of dataframes
#' @return A list of dataframes
#' @import data.table


SetNames <- function(x, old, new) {
    old.intersect <- intersect(old, names(x))
    common.indices <- old %in% old.intersect
    new.intersect <- new[common.indices]
    setnames(x, old.intersect, new.intersect)
  }


#' @export
#' @rdname setCorpus
SetTuple <- function(x){
  text <- paste(x$tup,collapse=" ") #TIF
  tup_bounds <- unlist(as.vector(gregexpr(pattern=" ", text)[[1]]))
  x$tupBeg <- append(1,tup_bounds+1)
  x$tupEnd <- append(tup_bounds,nchar(text)+1)
  class(x) <- c("spacyr_parsed", "data.frame")
  return(x)}

#Could return tuple_tif here.

#' @export
#' @rdname setCorpus
SetSearchCorpus <- function (x, doc_var='doc_id', token_var='token', lemma_var='lemma', tag_var='tag', pos_var='pos',sentence_var='sentence_id', NER_as_tag = FALSE) { #demarc_var - ?

  SetNames(x, old = c(doc_var,token_var,lemma_var,tag_var, pos_var,sentence_var), new = c('doc_id', 'token','lemma','tag','pos','sentence_id'))
  x$doc_id <- gsub('\\D+','text',x$doc_id)

  x$lemma <- gsub("[[:space:]]+", "",x$lemma)
  x$token <- gsub("[[:space:]]+", "",x$token)

  x$lemma <- ifelse(x$pos=="PROPN"|x$pos=="ENTITY",x$token,x$lemma)

  x$lemma <- gsub("xxx", "-", x$lemma)
  x$token <- gsub("xxx", "-", x$token)

  x <- x[!(x$tag=='NN'| x$tag=='NFP' | x$pos == 'SPACE' | x$token =="" | x$token==" "),]

  if (NER_as_tag == TRUE) {}
  #x$tag = ifelse(x$tag=="ENTITY",paste("NN",x$entity_type,sep=""),x$tag)
  #x$tag = ifelse(x$tag=="ENTITY",x$entity_type,x$tag)

  x$tup <- paste("<",x$token,",",x$lemma,",",x$tag,">",sep="")
  list_dfs <- split(x, f = x$doc_id)
  lapply(list_dfs,SetTuple)
}

#Also - entity_consolidate() issue. Would occur previous to SetSearchCorpus().
