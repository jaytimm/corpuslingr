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


#' @export
#' @rdname queryCorpus
extractContext <- function(x,search,LW,RW) {
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
SimpleSearch <- function(search,corp){

searchTerms <- unlist(lapply(search, CQLtoRegex))

#Will need to split dataframe.
found <- lapply(corp, function(z) {
  y <- paste(z$tup, collapse=" ")

  locations <- gregexpr(pattern= searchTerms, y, ignore.case=TRUE)
  if (-1 %in% locations){} else {
  as.data.frame(regmatches(y,locations))}
    })

found <- Filter(length,found)

if(length(found)>0) {

found <- rbindlist(found, idcol='doc_id')
colnames(found)[2] <- 'eg'

found$token <- gsub("<([A-Za-z0-9-]+),\\S+>","\\1",found$eg)
found$tag <- gsub("<\\S+,([A-Za-z0-9-]+)>","\\1",found$eg)
found$lemma <- gsub("\\S+,([A-Za-z0-9-]+),\\S+","\\1",found$eg)

return(found)

} else
{return("SEARCH TERM(S) NOT FOUND IN CORPUS")}
}


#' @export
#' @rdname queryCorpus
GetContexts <- function(search,corp,LW,RW){

  searchTerms <-  CQLtoRegex(search)

  found <- lapply(corp,extractContext,search=searchTerms,LW,RW)
  found <- Filter(length,found)

  if (length(found) >0 ) {

  found <- rbindlist(found,idcol='doc_id') #found locations. Joined to single df corpus.

  BOW <- rbindlist(corp)
  BOW <- BOW[, rw := rowid(doc_id)]  #Add row number
  BOW <- BOW[found, on=c("doc_id","rw"), nomatch=0]

  KWIC <- FlattenContexts(BOW)

  tmp <- KWIC[, c('doc_id','eg','token','lemma','tag','pos'), with = FALSE]

  SetNames(tmp, old = c('token','lemma','tag','pos'), new = c('searchToken', 'searchLemma','searchTag','searchPos'))

  setkey(tmp,doc_id,eg)
  setkey(BOW,doc_id,eg)

  BOW <- tmp[BOW]

  out <- list("BOW" = BOW, "KWIC" = KWIC)
  return(out)

     } else
      {return("SEARCH TERM(S) NOT FOUND IN CORPUS")}
}
