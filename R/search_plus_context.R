#' Get 'keyword-in-context' from an annotated corpus.
#'
#' Function(s) extract all instantiations of search pattern and NxN window of surrounding text from an annotated corpus.
#'
#' @name search_plus_context
#' @param search Gram/lexical pattern to be searched for
#' @param LW Size of context in number of words to left of the target
#' @param RW Size of context in number of words to right of the target
#' @param corp List of annotated texts to be searched
#' @return A list of dataframes
#' @import data.table


clr_extract_context <- function(x,search,LW,RW) {

  locations <- gregexpr(pattern= search, paste(x$tup, collapse=" "), ignore.case=TRUE)
  tupBeg <- unlist(as.vector(locations[[1]]))
  tupEnd <- tupBeg + attr(locations[[1]],"match.length") -1

  if (-1 %in% tupBeg){} else {

  L1 <- match(tupBeg,x$tupBeg)  #Get search  boundaries.
  R1 <- match(tupEnd,x$tupEnd)
  L2 <- ifelse((L1-LW) < 1, 1,L1-LW)
  R2 <- ifelse((R1+RW) > nrow(x), nrow(x),R1+RW)

  df_locs <- lapply(1:length(R2), function(y)
    as.data.frame(cbind(rw = c(L2[y]:R2[y]), #Row numbers.
          place= as.character(c(rep("aContext",L1[y]-L2[y]),
                   rep("token",R1[y]-L1[y]+1),
                   rep("zContext",R2[y]-R1[y]))))))

  df_locs <- rbindlist(df_locs,idcol='eg')
  df_locs$rw <- as.integer(as.character(df_locs$rw))

return(df_locs)
}}



clr_flatten_contexts <- function(x) {

  pats <- x[place=='token', list(lemma=paste(lemma, collapse=" "),tag=paste(tag, collapse=" "),pos=paste(pos, collapse=" ")),
    by=list(doc_id,eg)]
  out <- x[, list(context=paste(token, collapse=" ")), by=list(doc_id,eg,place)]
  out <- dcast.data.table(out, doc_id+eg ~ place, value.var = "context")
  out[is.na(out)] <- ""
  pats[out, on=c("doc_id","eg"), nomatch=0]
  }


#' @export
#' @rdname search_plus_context
clr_search_context <- function(search,corp,LW,RW){

  x <- corp
  if ("meta" %in% names(x)) x <- x$corpus

  searchTerms <-  clr_cql_regex(search)

  found <- lapply(x,clr_extract_context,search=searchTerms,LW,RW)
  found <- Filter(length,found)

  if (length(found)==0) stop("SEARCH TERM(S) NOT FOUND.  See corpuslingr::clr_search_egs for example CQL & syntax.")

  found <- rbindlist(found, idcol='doc_id') #found locations. Joined to single df corpus.

  BOW <- rbindlist(x)
  BOW[, rw := rowid(doc_id)]  #Add row number
  BOW <- BOW[found, on=c("doc_id","rw"), nomatch=0]

  KWIC <- clr_flatten_contexts(BOW)

  tmp <- KWIC[, c('doc_id','eg','token','lemma','tag','pos'), with = FALSE]

  setnames(tmp, old = c('token','lemma','tag','pos'), new = c('searchToken', 'searchLemma','searchTag','searchPos'))

  BOW <- tmp[BOW, on=c("doc_id","eg"), nomatch=0]

  if (!"meta" %in% names(corp)) {
  out <- list("BOW" = BOW, "KWIC" = KWIC)} else {
    out <- list("BOW" = BOW, "KWIC" = KWIC, "meta" = corp$meta)}

  return(out)
}
