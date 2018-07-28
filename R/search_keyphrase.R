#' Extract key phrases from an annotated corpus.
#'
#' Function enable corpus search of gram constructions in context.
#' @name search_keyphrase
#' @param search Gram/lexical pattern to be searched for
#' @param LW Size of context in number of words to left of the target
#' @param RW Size of context in number of words to right of the target
#' @param corp List of annotated texts to be searched
#' @return A list of dataframes
#' @import data.table



#' @export
#' @rdname search_keyphrase
clr_search_keyphrases <- function (corp,n=5,
                                   key_var ='lemma',
                                   flatten=TRUE, jitter=TRUE,
                                   remove_nums = TRUE,
                                   include='doc_id',
                                   min_docf = 0) { #add agg_var.

  x <- corp
  if ("meta" %in% names(x)) x <- x$corpus

  keys <- corpuslingr::clr_search_gramx(x,search= clr_ref_keyphrase)

  doc <-  keys[, list(docf=length(unique(doc_id))),by=key_var]
  txt <-  keys[, list(txtf=length(tag)),by=c('doc_id',key_var)]

  freqs <- rbindlist(x)
  freqs <- freqs[, list(textLength=length(get(key_var))),by=doc_id]

  k1 <- doc[txt, on = key_var]

  setkey(k1,doc_id); setkey(freqs, doc_id)
  k1 <- freqs[k1]

  k1[, docsInCorpus := nrow(freqs)]

  if (remove_nums==TRUE) {
    k1 <- k1[grepl("[0-9]", k1[[key_var]])==FALSE,]}

  k1[, tf_idf := (txtf/textLength)*log(docsInCorpus/(docf+1))]

  if (jitter==TRUE) {
    set.seed(99)
    k1[, tf_idf := jitter(tf_idf)]}

  k1 <- k1[,.SD[order(-tf_idf)[1:n]],by=doc_id]
  colnames(k1)[3] <- 'keyphrases'

  k1 <- k1[order(as.numeric(doc_id))]
  k1 <- subset(k1, docf >= min_docf)

  if (flatten == TRUE) {
    k1 <- k1[, list(keyphrases=paste(keyphrases, collapse=" | ")), by=list(doc_id)]}

  if (!setequal(intersect(include, colnames(k1)), include)) {
    setDT (corp$meta)
    k1 <- k1[corp$meta, on=c("doc_id"), nomatch=0]}

  k1 <- k1[, c(include,'keyphrases'), with = FALSE]
  k1
}
