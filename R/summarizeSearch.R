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
  pats[out, on=c("doc_id","eg"), nomatch=0]
  }



#' @export
#' @rdname summarizeSearch
clr_get_freq <- function (x,agg_var=c('lemma','token'), toupper=FALSE) {

  if (!is.data.frame(x)) x <- x$KWIC
    setDT(x)

  if (toupper==TRUE){
    x[, lemma := toupper(lemma)]
    x[, token := toupper(token)]}


  if ('doc_id' %in% agg_var){
    agg_var2 <- agg_var[agg_var != "doc_id"]

    doc <-  x[, list(docf=length(unique(doc_id))),by=agg_var2]
    x <-  x[, list(txtf=.N),by=agg_var]

    x[doc, ('docf') := mget('docf'), on = agg_var2]
    setcolorder (x, c(agg_var,'txtf','docf'))

    } else{

      x <- x[, list(txtf=.N,docf=length(unique(doc_id))),by=agg_var]}

  setorderv(x,c('txtf',agg_var),c(-1,rep(1,length(agg_var))))[]
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


#txt[doc, (include) := mget('docf'), on = agg_var2]


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
  setorderv(bow,c('cofreq',agg_var),c(-1,rep(1,length(agg_var))))[]
}
