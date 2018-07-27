#' Summarize results of corpuslingr::clr_search_contexts()
#'
#' These functions aggregate search results by frequency, BOW, and KWIC.
#' @name summarize_context
#' @param charList A dataframe
#' @return A dataframes
#' @import data.table
#'


#' @export
#' @rdname summarize_context
clr_context_kwic <- function (x,include=c('doc_id','lemma')) {#meta parameter

  kwic_table <- as.data.table(x$KWIC)
  kwic_table <- kwic_table[, list(kwic = paste(aContext, "<mark>", token, "</mark>", zContext, collapse=" ")), by=list(doc_id,eg,token,lemma)]

  kwic_table <- kwic_table[order(as.numeric(doc_id))]

  if (!setequal(intersect(include, colnames(kwic_table)), include)) {
    setDT (x$meta)
    kwic_table <- kwic_table[x$meta, on=c("doc_id"), nomatch=0]}

  kwic_table[, c(include,'kwic'), with = FALSE]
  }



#' @export
#' @rdname summarize_context
clr_context_bow <- function (x,content_only=TRUE, agg_var=c('lemma','pos')) {

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
