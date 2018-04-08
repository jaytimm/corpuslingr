#' Summarize results of corpuslingr::GetContexts()
#'
#' These functions aggregate search results by frequency, BOW, and KWIC.
#' @name summarizeSearch
#' @param charList A dataframe
#' @return A dataframes
#' @import data.table
#'


clr_flatten_contexts <- function(x) {

  pats <- x[place=='token', list(lemma=paste(lemma, collapse=" "),tag=paste(tag, collapse=" "),pos=paste(pos, collapse=" ")), by=list(doc_id,eg)]

  out <- x[, list(context=paste(token, collapse=" ")), by=list(doc_id,eg,place)]
  out <- dcast.data.table(out, doc_id+eg ~ place, value.var = "context")
  setkey(pats,doc_id,eg)
  setkey(out,doc_id,eg)
  pats[out]
  }




#' @export
#' @rdname summarizeSearch
clr_get_freq <- function (x,agg_var=c('lemma','token'), toupper=FALSE) {

  if (!is.data.frame(x)) x <- x$KWIC
    freqs <- as.data.table(x)

  if (toupper==TRUE){
    freqs$lemma <- toupper(freqs$lemma)
    freqs$token <- toupper(freqs$token)}

  if ('doc_id' %in% agg_var){
    agg_var2 <- agg_var[agg_var != "doc_id"]

    doc <-  freqs[, list(docf=length(unique(doc_id))),by=agg_var2]
    txt <-  freqs[, list(txtf=.N),by=agg_var]

    setkeyv(doc,agg_var2)
    setkeyv(txt,agg_var2)
    freqs <- doc[txt]
    freqs <- freqs[, c(agg_var,'txtf','docf'), with = FALSE]

    } else{

    freqs <-  freqs[, list(txtf=.N,docf=length(unique(doc_id))),by=agg_var]}

  freqs <- setorderv(freqs,c('txtf',agg_var),c(-1,rep(1,length(agg_var))))

  return(freqs)
    }




#' @export
#' @rdname summarizeSearch
clr_context_kwic <- function (x,include=c('doc_id','lemma')) {#meta parameter

  kwic_table <- as.data.table(x$KWIC)
  kwic_table <- kwic_table[, list(kwic = paste(aContext, "<mark>", token, "</mark>", zContext, collapse=" ")), by=list(doc_id,eg,token,lemma)]

  kwic_table <- kwic_table[order(as.numeric(doc_id))]

  if (!setequal(intersect(include, colnames(kwic_table)), include)) {
    kwic_table <- kwic_table[x$meta, on=c("doc_id"), nomatch=0]}

  kwic_table[, c(include,'kwic'), with = FALSE]
  }




#' @export
#' @rdname summarizeSearch
clr_context_bow <- function (x,content_only=TRUE, agg_var=c('lemma','pos')) {

  bow <- x$BOW

  if (content_only==TRUE) {
    bow <- bow[bow$pos %in% c("ADJ","NOUN","VERB","ADV","PROPN","ENTITY") & !bow$lemma %in% corpuslingr::clr_ref_stops, ]}

  bow[,c('lemma','token','searchLemma','searchToken')] <- lapply(bow[,c('lemma','token','searchLemma','searchToken')], toupper)

  if (!setequal(intersect(agg_var, colnames(bow)), agg_var)) {
    bow <- bow[x$meta, on=c("doc_id"), nomatch=0]}

  bow <- bow[place!='token', list(cofreq=.N), by=agg_var]
  bow <- setorderv(bow,c('cofreq',agg_var),c(-1,rep(1,length(agg_var))))

  return(bow)}
