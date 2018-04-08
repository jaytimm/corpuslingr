#' Get search in context
#'
#' These functions enable corpus search of gram constructions in context.
#' @name queryCorpus
#' @param search Gram/lexical pattern to be searched for
#' @param LW Size of context in number of words to left of the target
#' @param RW Size of context in number of words to right of the target
#' @param corp List of annotated texts to be searched
#' @return A list of dataframes
#' @import data.table

##Need to add something like: if (!col %in% colnames(out)) stop("Ordering column not preserved by function")


#' @export
#' @rdname queryCorpus
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


#' @export
#' @rdname queryCorpus
clr_search_gramx <- function(search,corp, include_meta=FALSE){

x <- corp

if ("meta" %in% names(x)) x <- x$corpus

searchTerms <-  clr_cql_regex(search)

found <- lapply(x, function(z) {
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

if (include_meta == FALSE) {return(found)} else {

  found[corp$meta, on=c("doc_id"), nomatch=0]}

}


#' @export
#' @rdname queryCorpus
clr_search_context <- function(search,corp,LW,RW, include_meta=FALSE){

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

  if (include_meta == FALSE) {
  out <- list("BOW" = BOW, "KWIC" = KWIC)} else {
    out <- list("BOW" = BOW, "KWIC" = KWIC, "meta" = corp$meta)}

  return(out)
}


#' @export
#' @rdname queryCorpus
clr_search_keyphrases <- function (corp,n=5, key_var ='lemma', flatten=TRUE, jitter=TRUE, remove_nums = TRUE) { #add agg_var.

  x <- corp
  if ("meta" %in% names(x)) x <- x$corpus

  keys <- corpuslingr::clr_search_gramx(x,search= clr_ref_keyphrase)

  doc <-  keys[, list(docf=length(unique(doc_id))),by=key_var]
  txt <-  keys[, list(txtf=length(tag)),by=c('doc_id',key_var)]

  freqs <- rbindlist(x)
  freqs <- freqs[, list(textLength=length(get(key_var))),by=doc_id]

  k1 <- doc[txt, on = key_var]

  setkey(k1,doc_id); setkey(freqs, doc_id)
  k1 <- freqs[k1]

  k1[, docsInCorpus := nrow(freqs)]

  if (remove_nums==TRUE) {
    k1 <- k1[grepl("[0-9]", k1[[key_var]])==FALSE,]}

  k1[, tf_idf := (txtf/textLength)*log(docsInCorpus/(docf+1))]

  if (jitter==TRUE) {
    set.seed(99)
    k1[, tf_idf := jitter(tf_idf)]}

  k1 <- k1[,.SD[order(-tf_idf)[1:n]],by=doc_id]
  colnames(k1)[3] <- 'keyphrases'

  if (flatten == TRUE) {
    k1 <- k1[, list(keyphrases=paste(keyphrases, collapse=" | ")), by=list(doc_id)]
  }

  k1[order(as.numeric(doc_id))]

}
