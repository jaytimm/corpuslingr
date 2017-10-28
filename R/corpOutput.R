#' Annotate a corpus of texts using the `spacyr` package
#'
#' These functions modify the output of `spacyr'
#' @name corpOutput
#' @param charList A list of texts as character strings
#' @return A list of dataframes
#' @import spacyr tidyverse data.table
#' @export
#' @rdname corpOutput
#'

#' @export
#' @rdname corpOutput
##Still need to add meta
GetSearchFreqs <- function (x) {
  lapply(1:length(x), function(y){
    x[[y]]%>%
      filter(place=="targ")%>%
      select(eg,doc_id,token)%>%
      group_by(eg,doc_id)%>%
      summarize(targ = paste(token, collapse= " ")) %>%
      mutate(targ=toupper(targ))%>%
      group_by(targ) %>%
      mutate(docFreq=length(unique(doc_id)))%>%
      group_by(targ,docFreq)%>%
      summarize(textFreq=n()) %>%
      arrange(desc(textFreq))  })}

#' @export
#' @rdname corpOutput
GetKWIC <- function (x) {
  lapply(1:length(x), function(y){
    x[[y]]%>%
    group_by(eg,doc_id,place)%>%
    summarize(context = paste(token, collapse= " ")) %>%
    spread(place,context) %>%
    replace_na(list(pre="",post=""))%>%
    rowwise()%>%
    mutate(cont = paste(pre,"<mark>",targ,"</mark>",post,collapse=" "))%>%
    select(doc_id,targ,cont)})}

#' @export
#' @rdname corpOutput
GetBOW <- function (x) {
  lapply(1:length(x), function(y){
    x[[y]]%>%
      filter (place!="target" ) %>%
      group_by(lemma, pos) %>%
      summarize(n=n())%>%
      arrange(desc(n)) })} #Perhaps remove stops,punctuation.

#GetKWIC <- function {} Need to add pre/post if LW/RW =0.
