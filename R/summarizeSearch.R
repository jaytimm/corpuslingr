#' Summarize results of corpuslingr::GetContexts()
#'
#' These functions aggregate search results by frequency, BOW, and KWIC.
#' @name summarizeSearch
#' @param charList A dataframe
#' @return A dataframes
#' @import magrittr dplyr


#' @export
#' @rdname summarizeSearch
GetSearchFreqs <- function (x,aggBy='lemma') {
    x%>%
      filter(place=="targ")%>%
      select(search_found,eg,doc_id,aggBy)%>%
      select(targ = !! quo(names(.)[[4]]), everything())%>%
      group_by(search_found,eg,doc_id)%>%
      #mutate(targ=summarize(paste0(targ, collapse = " ")))%>%
      summarize_at(vars(targ),funs(paste(., collapse = " ")))%>%
      group_by(search_found,targ)%>%
      mutate(termDocFreq=length(unique(doc_id)))%>%
      group_by(search_found,targ,termDocFreq)%>%
      summarize(termTextFreq=n())%>%
      ungroup()%>%
      arrange(search_found,desc(termTextFreq))}


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

