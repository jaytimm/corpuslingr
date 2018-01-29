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
clr_get_freq <- function (x,agg_var=c('lemma','token')) {
  if(!is.data.frame(x)){x <- x$KWIC}

  freqs <- as.data.table(x)
  freqs$lemma <- toupper(freqs$lemma)
  freqs$token <- toupper(freqs$token)

  freqs <-  freqs[, list(txtf=.N,docf=length(unique(doc_id))),by=aggBy]
  freqs <- setorderv(freqs,c('txtf',aggBy),c(-1,rep(1,length(aggBy))))
  return(freqs)
    }



#' @export
#' @rdname summarizeSearch
clr_context_kwic <- function (x,include=c('doc_id','lemma')) {
  if(!is.data.frame(x)){x <- x$KWIC}

  kwic_table <- as.data.table(x)
  kwic_table <- kwic_table[, list(kwic = paste(aContext, "<mark>", token, "</mark>", zContext, collapse=" ")), by=list(doc_id,eg,token,lemma)]

  kwic_table[, c(include,'kwic'), with = FALSE]
  }


#' @export
#' @rdname summarizeSearch
clr_context_bow <- function (x,content_only=TRUE, agg_var=c('lemma','pos')) {
  if(!is.data.frame(x)){x <- x$BOW}

  if (contentOnly==TRUE) {
    bow <- x[x$pos %in% c("ADJ","NOUN","VERB","ADV","PROPN","ENTITY") | !x$lemma %in% corpusdatr::stops, ]}

  bow[,c('lemma','token','searchLemma','searchToken')] <- lapply(bow[,c('lemma','token','searchLemma','searchToken')], toupper)

  bow <- bow[place!='token', list(cofreq=length(eg)), by=aggBy]
  bow <- setorderv(bow,c('cofreq',aggBy),c(-1,rep(1,length(aggBy))))

  return(bow)}
