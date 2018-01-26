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
          place= as.character(c(rep("pre",L1[y]-L2[y]),
                   rep("token",R1[y]-L1[y]+1),
                   rep("post",R2[y]-R1[y]))))))%>%
  rbindlist(idcol='eg') %>%
  mutate(rw=as.integer(as.character(rw)))
}}


#' @export
#' @rdname queryCorpus
GetContexts <- function(search,corp,LW,RW){
  if (is.data.frame(corp)) x <- list(corp)

  conts <- list()
  found <- vector()

  searchTerms <- unlist(lapply(search, CQLtoRegex))

  for (i in 1:length(searchTerms)){
    conts[[i]] <- lapply(corp,extractContext,search=searchTerms[i],LW,RW)
    names(conts[[i]]) <- c(1:length(conts[[i]]))
    #Some conts will be empty. Name before filtering. Length = texts in corpus.

    conts[[i]] <- conts[[i]] %>%
      compact()

    if (length(conts[[i]]) >0 ) {found[i] <- i

    conts[[i]] <- rbindlist(conts[[i]],idcol='doc_id')%>%
      mutate(doc_id=as.integer(doc_id))

        } else
    {found[i] <- 0}
    }#End for loop.

  found <- found [found>0]#Filter to found terms.

  if (sum(found) >0){

  conts <- conts[c(found)]
  names(conts) <- search[found]
  conts <- rbindlist (conts,idcol="search_found")%>%
    data.table()

  BOW <- corp %>%
    rbindlist()%>%
    .[, rw := rowid(doc_id)] %>%
    inner_join(conts)%>%
    data.table() %>%
    select(search_found,doc_id,eg,sentence_id,token_id ,place,token:tupEnd)
    #Perhaps add sort.
  contexts <- FlattenContexts(BOW)
  out <- list("BOW" = BOW, "contexts" = contexts)
  return(out)
     } else
      {return("SEARCH TERM(S) NOT FOUND IN CORPUS")}
}


  #conts[df, nomatch=0L, on = c('doc_id','rw')]%>%
  #select(search_found,doc_id,eg,sentence_id,token_id ,place,token:tupEnd)
