#' Annotate a corpus of texts using the `spacyr` package
#'
#' These functions modify the output of `spacyr'
#' @name corpOutput
#' @param charList A list of texts as character strings
#' @return A list of dataframes



#' @export
#' @rdname corpOutput
##Still need to add meta
GetSearchFreqs <- function (x) {#Potentially add 'groupBy' parameter.
  lapply(1:length(x), function(y){
    x[[y]]%>%
      filter(place=="targ")%>%
      select(eg,doc_id,token)%>%
      group_by(eg,doc_id)%>%
      summarize(targ = paste(token, collapse= " ")) %>% #Could add lempat and grampat here as well.
      mutate(targ=toupper(targ))%>%
      group_by(targ) %>%
      mutate(termDocFreq=length(unique(doc_id)))%>%
      group_by(targ,termDocFreq)%>%
      summarize(termTextFreq=n()) %>%
      arrange(desc(termTextFreq))  })}

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
        filter(pos %in% c("ADJ","NOUN","VERB","ADV","PROPN"),!lemma %in% corpusdatr::stops)})
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
