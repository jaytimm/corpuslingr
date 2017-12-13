#' Summarize results of corpuslingr::GetContexts()
#'
#' These functions aggregate search results by frequency, BOW, and KWIC.
#' @name describeCorpus
#' @return A dataframe
#' @import magrittr dplyr
#' 
#' 
#' @export
#' @rdname describeCorpus
GetDocDesc <- function (x) {
x %>%
  bind_rows()%>%
  filter(pos!= "PUNCT")%>%
  group_by(doc_id)%>%
  summarize(docN=n(),docType=length(unique(token)),docSent=length(unique(sentence_id)))}
