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
  bind_rows(x)%>%
  filter(pos!= "PUNCT")%>%
  group_by(doc_id)%>%
  summarize(textLength=n(),textType=length(unique(token)),textSent=length(unique(sentence_id)))}
