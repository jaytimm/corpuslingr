#' Summarize results of corpuslingr::GetContexts()
#'
#' These functions aggregate search results by frequency, BOW, and KWIC.
#' @name describeCorpus
#' @return A dataframe
#' @import data.table
#'
#'
#' @export
#' @rdname describeCorpus
GetDocDesc <- function (x) {

  if (!is.data.frame(x)) {x <- rbindlist(x)}
  x <- as.data.table(x)

  byText <- x[pos!="PUNCT", list(textLength=length(token),textType=length(unique(token)),textSent=length(unique(sentence_id))), by=list(doc_id)]

  corpus <- x[pos!="PUNCT", list(n_docs=length(unique(doc_id)),textLength=length(token),textType=length(unique(token)),textSent=length(unique(paste(doc_id,sentence_id, sep=""))))]

  out <- list("text" = byText, "corpus" = corpus)
  return(out)
}


#While we are here, we could add ++descriptives; namely, baayen lexical richness stuff.
