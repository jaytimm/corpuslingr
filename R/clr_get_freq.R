#' Summarize results of corpuslingr::GetContexts()
#'
#' These functions aggregate search results by frequency, BOW, and KWIC.
#' @name clr_get_freq
#' @param charList A dataframe
#' @return A dataframes
#' @import data.table
#'


#' @export
#' @rdname clr_get_freq
clr_get_freq <- function (x,
                          agg_var=c('lemma','token'),
                          toupper=FALSE) {

  if (is.data.frame(x)) {y <- as.data.table(x)} else {
   y <- as.data.table (x$KWIC)}

  if (toupper==TRUE){
    y[, lemma := toupper(lemma)]
    y[, token := toupper(token)]}


  if ('doc_id' %in% agg_var){
    agg_var2 <- agg_var[agg_var != "doc_id"]

    doc <-  y[, list(docf=length(unique(doc_id))),by=agg_var2]
    y <-  y[, list(txtf=.N),by=agg_var]

    y[doc, ('docf') := mget('docf'), on = agg_var2]
    setcolorder (y, c(agg_var,'txtf','docf'))

    } else{

      y <- y[, list(txtf=.N,docf=length(unique(doc_id))),by=agg_var]}

  setorderv(y,c('txtf',agg_var),c(-1,rep(1,length(agg_var))))[]
}
