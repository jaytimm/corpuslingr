#' Summarize results of corpuslingr::GetContexts()
#'
#' These functions aggregate search results by frequency, BOW, and KWIC.
#' @name summarizeSearch
#' @param charList A dataframe
#' @return A dataframes
#' @import magrittr dplyr DT

#' @export
#' @rdname summarizeSearch
FlattenContexts <- function(x) {

  pats <- x[place=='token', list(lemma=paste(lemma, collapse=" "),tag=paste(tag, collapse=" "),pos=paste(pos, collapse=" ")), by=list(doc_id,eg)]

  out <- x[, list(context=paste(token, collapse=" ")), by=list(doc_id,eg,place)]%>%
    dcast.data.table(., doc_id+eg ~ place, value.var = "context")%>%
    left_join(pats)

  refcols <- c('doc_id','eg','lemma','tag','pos')
  out[, c(refcols, setdiff(names(out), refcols))]
  }


#' @export
#' @rdname summarizeSearch
GetSearchFreqs <- function (x,aggBy=c('lemma','token')) {
    freqs <- data.table(x$contexts)%>%
    .[, list(txtf=length(eg),docf=length(unique(doc_id))),by=aggBy]%>%
    setorderv(.,c('txtf',aggBy),c(-1,rep(1,length(aggBy))))
    return(freqs)
    }


#' @export
#' @rdname summarizeSearch
GetKWIC <- function (x) {

    data.table(x$contexts)%>%
    .[, list(kwic = paste(aContext,"<mark>",token,"</mark>",zContext,collapse=" ")), by=list(doc_id,eg,token,lemma)]%>%
    select(doc_id,token,lemma,kwic)%>%
    DT::datatable(class = 'cell-border stripe', rownames = FALSE,width="100%", escape=FALSE)
  }


#' @export
#' @rdname summarizeSearch
GetBOW <- function (x,contentOnly=TRUE, aggBy=c('lemma','pos')) {

  if (contentOnly==TRUE) {
    bow <- filter(x$BOW,pos %in% c("ADJ","NOUN","VERB","ADV","PROPN","ENTITY"),!lemma %in% corpusdatr::stops)
  } else
      {bow <- x$BOW}

  bow <- data.table(bow)%>%
    .[place!='token', list(cofreq=length(eg)), by=aggBy]%>%
    setorderv(.,c('cofreq',aggBy),c(-1,rep(1,length(aggBy))))

 return(bow)}


