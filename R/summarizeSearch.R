#' Summarize results of corpuslingr::GetContexts()
#'
#' These functions aggregate search results by frequency, BOW, and KWIC.
#' @name summarizeSearch
#' @param charList A dataframe
#' @return A dataframes
#' @import magrittr dplyr

#' @export
#' @rdname summarizeSearch
FlattenContexts <- function(x) {

  pats <- x[place=='token', list(lemma=paste(lemma, collapse=" "),gram=paste(tag, collapse=" ")), by=list(search_found,doc_id,eg)]

  x[, list(context=paste(token, collapse=" ")), by=list(search_found,doc_id,eg,place)]%>%
    dcast.data.table(., search_found+doc_id+eg ~ place, value.var = "context")%>%
    left_join(pats)#%>% ##Use data.table instead?
    #select(search_found,doc_id,eg,lemma,gram,pre,token,post)
  } #This will break LW=0,eg.



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
  x%>%
    group_by(search_found,eg,doc_id,place)%>%
    summarize(context = paste(token, collapse= " ")) %>%
    spread(place,context) %>%
    replace_na(list(pre="",post=""))%>%
    rowwise()%>%
    mutate(cont = paste(pre,"<mark>",targ,"</mark>",post,collapse=" "))%>%
    select(search_found,doc_id,targ,cont)}

#' @export
#' @rdname summarizeSearch
GetBOW <- function (x,contentOnly=TRUE) {

  output <- x%>%
      filter (place!="targ" ) %>%
      group_by(search_found,lemma, pos) %>%
      summarize(n=n())%>%
      arrange(desc(n))

  if (contentOnly==TRUE) {
      output%>%
        filter(pos %in% c("ADJ","NOUN","VERB","ADV","PROPN","ENTITY"),!lemma %in% corpusdatr::stops)
  } else {return(output)}
}

#GetKWIC <- function {} Need to add pre/post if LW/RW =0.

