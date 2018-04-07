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
clr_desc_corpus <- function (corp, doc ='id',sent='sid', tok='word',upos='upos',genre=NULL) {

  x <- corp
  if ("meta" %in% names(x)) x <- x$corpus
  if (!is.data.frame(x)) {x <- rbindlist(x)}
  x <- as.data.table(x)

  byText <- x[upos!="PUNCT", list(textLength=.N,textType=length(unique(get(tok))),textSent=length(unique(get(sent)))), by=doc]

  byText <- byText[order(as.numeric(gsub('[A-Za-z]+','',get(doc))))]

  corpus <- x[upos!="PUNCT", list(n_docs=length(unique(get(doc))),textLength=.N,textType=length(unique(get(tok))),textSent=length(unique(paste(get(doc),get(sent), sep=""))))]

  if (is.null(genre) == FALSE){
  x <- x[corp$meta, on=c("doc_id"), nomatch=0]

  byGenre <- x[upos!="PUNCT", list(n_docs=length(unique(get(doc))),textLength=.N,textType=length(unique(get(tok))),textSent=length(unique(paste(get(doc),get(sent), sep="")))), by=genre]

  out <- list("text" = byText, "corpus" = corpus, "genre" = byGenre)
  return(out)

    } else{
  out <- list("text" = byText, "corpus" = corpus)
  return(out)}
}


#While we are here, we could add ++descriptives; namely, baayen lexical richness stuff.
