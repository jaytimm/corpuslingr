#' Get search in context
#'
#' These functions enable corpus search of gram constructions in context.
#'
#' @name clr_search_gramx
#' @param search Gram/lexical pattern to be searched for
#' @param corp List of annotated texts to be searched
#' @return A dataframe including instantiations of pattern search.
#' @import data.table



#' @export
#' @rdname clr_search_gramx
clr_search_gramx <- function(search,
                             corp) {

x <- corp

if ("meta" %in% names(x)) x <- x$corpus

searchTerms <-  clr_cql_regex(search)

found <- lapply(x, function(z) {
  z <- subset(z, pos != 'SYM') #Fix for funky tweets.
  y <- paste(z$tup, collapse=" ")

  locations <- gregexpr(pattern= searchTerms, y, ignore.case=TRUE)
  if (-1 %in% locations){} else {
  as.data.frame(regmatches(y,locations))}
    })

found <- Filter(length,found)

if (length(found)==0) stop("SEARCH TERM(S) NOT FOUND.  See corpuslingr::clr_search_egs for example CQL & syntax.")

found <- rbindlist(found, idcol='doc_id')
colnames(found)[2] <- 'eg'

found[, eg := gsub(" $","",eg)]
found[, token := gsub("<(\\S+)~\\S+~\\S+>","\\1",eg)]
found[, tag := gsub("<\\S+~(\\S+)>","\\1",eg)]
found[, lemma := gsub("\\S+~(\\S+)~\\S+","\\1",eg)]

found <- found[, c('doc_id','token','tag','lemma'), with = FALSE]

if (!"meta" %in% names(corp)) {return(found)} else {
  setDT (corp$meta)
  found[corp$meta, on=c("doc_id"), nomatch=0]}
}
