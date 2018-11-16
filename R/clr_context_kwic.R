#' Summarize results of corpuslingr::clr_search_contexts()
#'
#' A function for accessing/aggregating BOW object returned from corpuslingr::clr_search_contexts().
#' @name clr_context_kwic
#' @param charList A dataframe
#' @return A dataframes
#' @import data.table
#'


#' @export
#' @rdname clr_context_kwic
clr_context_kwic <- function (x,
                              include = c('doc_id','lemma')) {#meta parameter

  kwic_table <- as.data.table(x$KWIC)
  kwic_table <- kwic_table[, list(kwic = paste(aContext, "<mark>", token, "</mark>", zContext, collapse=" ")), by=list(doc_id,eg,token,lemma)]

  kwic_table <- kwic_table[order(as.numeric(doc_id))]

  if (!setequal(intersect(include, colnames(kwic_table)), include)) {
    setDT (x$meta)
    kwic_table <- kwic_table[x$meta, on=c("doc_id"), nomatch=0]}

  kwic_table[, c(include,'kwic'), with = FALSE]
  }
