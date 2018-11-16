#' Summarize results of corpuslingr::clr_search_contexts()
#'
#' A function for accessing/aggregating BOW object returned from corpuslingr::clr_search_contexts().
#' @name clr_context_bow
#' @param charList A dataframe
#' @return A dataframes
#' @import data.table
#'


#' @export
#' @rdname clr_context_bow
clr_context_bow <- function (x,
                             content_only=TRUE, 
                             agg_var=c('lemma','pos')) {
  

  bow <- as.data.table(x$BOW)

  if (content_only==TRUE) {
    bow <- bow[bow$pos %in% c("ADJ","NOUN","VERB","ADV","PROPN","ENTITY") & !bow$lemma %in% corpuslingr::clr_ref_stops, ]}

  bow[,c('lemma','token','searchLemma','searchToken')] <- lapply(bow[,c('lemma','token','searchLemma','searchToken')], toupper)

  if (!setequal(intersect(agg_var, colnames(bow)), agg_var)) {
    setDT (x$meta)
    bow <- bow[x$meta, on=c("doc_id"), nomatch=0]}

  bow <- bow[place!='token', list(cofreq=.N), by=agg_var]
  setorderv(bow,c('cofreq',agg_var),c(-1,rep(1,length(agg_var))))[]
}
