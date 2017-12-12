#' Annotate a corpus of texts using the `spacyr` package
#'
#' These functions modify the output of `spacyr'
#' @name corpOutput
#' @param charList A list of texts as character strings
#' @return A list of dataframes
#' @import magrittr dplyr


#' @export
#' @rdname corpOutput
GetSearchFreqs <- function (x,aggBy='lemma') {
  lapply(1:length(x), function(y){
    x[[y]]%>%
      filter(place=="targ")%>%
      select(eg,doc_id,aggBy)%>%
      select(targ = !! quo(names(.)[[3]]), everything())%>%
      group_by(eg,doc_id)%>%
      #mutate(targ=summarize(paste0(targ, collapse = " ")))%>%
      summarize_at(vars(targ),funs(paste(., collapse = " ")))%>%
      group_by(targ)%>%
      mutate(termDocFreq=length(unique(doc_id)))%>%
      group_by(targ,termDocFreq)%>%
      summarize(termTextFreq=n())%>%
      ungroup()%>%
      arrange(desc(termTextFreq))})}


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
GetBOW <- function (x,contentOnly) {
  output <- lapply(1:length(x), function(y){
    x[[y]]%>%
      filter (place!="targ" ) %>%
      group_by(lemma, pos) %>%
      summarize(n=n())%>%
      arrange(desc(n)) })

  if (contentOnly==TRUE) {
    lapply(1:length(output), function(z){
      output[[z]]%>%
        filter(pos %in% c("ADJ","NOUN","VERB","ADV","PROPN","ENTITY"),!lemma %in% corpusdatr::stops)})
  } else {return(output)}
}

#GetKWIC <- function {} Need to add pre/post if LW/RW =0.


#' @export
#' @rdname corpOutput
GetDocDesc <- function (x) {
x %>%
  bind_rows()%>%
  filter(pos!= "PUNCT")%>%
  group_by(doc_id)%>%
  summarize(docN=n(),docType=length(unique(token)),docSent=length(unique(sentence_id)))}
