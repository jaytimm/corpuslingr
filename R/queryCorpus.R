#' Get search in context
#'
#' These functions enable corpus search of gram constructions in context.
#' @name queryCorpus
#' @param search Gram/lexical pattern to be searched for
#' @param LW Size of context in number of words to left of the target
#' @param RW Size of context in number of words to right of the target
#' @param corp List of annotated texts to be searched
#' @return A list of dataframes
#' @importFrom data.table rbindlist
#' @import magrittr dplyr


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

  lapply(1:length(R2), function(y) #Using data.table here.
    as.data.frame(cbind(rw = c(L2[y]:R2[y]), #Row numbers.
          place= as.character(c(rep("aContext",L1[y]-L2[y]),
                   rep("token",R1[y]-L1[y]+1),
                   rep("zContext",R2[y]-R1[y]))))))%>%
  rbindlist(idcol='eg') %>%
  mutate(rw=as.integer(as.character(rw)))
}}


#' @export
#' @rdname queryCorpus
SimpleSearch <- function(search,corp){

searchTerms <- unlist(lapply(search, CQLtoRegex))

conts <- lapply(corp, function(z) {
  y <- paste(z$tup, collapse=" ")

  locations <- gregexpr(pattern= searchTerms, y, ignore.case=TRUE)
  if (-1 %in% locations){} else {
  as.data.frame(regmatches(y,locations))}
    })

names(conts) <- c(1:length(conts))

conts <- Filter(length,conts)

if(length(conts)>0){

rbindlist(conts, idcol='doc_id') %>%
    data.table() %>%
    {colnames(.)[2] = "eg"; .}%>%
    mutate(token=gsub("<(\\w+),\\S+>","\\1",eg),
           tag=gsub("<\\S+,(\\w+)>","\\1",eg),
           lemma =gsub("\\S+,(\\w+),\\S+","\\1",eg))

} else
{return("SEARCH TERM(S) NOT FOUND IN CORPUS")}
}


#' @export
#' @rdname queryCorpus
GetContexts <- function(search,corp,LW,RW){
  if (is.data.frame(corp)) x <- list(corp)

  searchTerms <-  CQLtoRegex(search)

  conts <- lapply(corp,extractContext,search=searchTerms,LW,RW)

  names(conts) <- c(1:length(conts))
  conts <- Filter(length,conts)

  if (length(conts) >0 ) {

  conts <- rbindlist(conts,idcol='doc_id')%>%
    mutate(doc_id=as.integer(doc_id))

  BOW <- corp %>%
    rbindlist()%>%
    .[, rw := rowid(doc_id)] %>%
    inner_join(conts)%>%
    data.table() %>%
    select(doc_id,eg,sentence_id,token_id ,place,token:tupEnd)
    #Perhaps add sort.

  contexts <- FlattenContexts(BOW)
  out <- list("BOW" = BOW, "contexts" = contexts)
  return(out)

     } else
      {return("SEARCH TERM(S) NOT FOUND IN CORPUS")}
}
