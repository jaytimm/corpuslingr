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
  starts <- unlist(as.vector(locations[[1]]))
  stops <- starts + attr(locations[[1]],"match.length") -1

  if (-1 %in% starts){} else {

  L1 <- match(starts,x$tupBeg)  #Get search  boundaries.
  R1 <- match(stops,x$tupEnd)
  L2 <- ifelse((L1-LW) < 1, 1,L1-LW)
  R2 <- ifelse((R1+RW) > nrow(x), nrow(x),R1+RW)

  lapply(1:length(R2), function(y)
    cbind(
          x[L2[y]:R2[y],1:ncol(x)],
          place= as.character(c(rep("pre",L1[y]-L2[y]),
                   rep("targ",R1[y]-L1[y]+1),
                   rep("post",R2[y]-R1[y]))))
    )}}



#' @export
#' @rdname queryCorpus
GetContexts <- function(search,corp,LW,RW){

  #if (is.data.frame(corp)) x <- list(corp)
  conts <- list()
  found <- vector()

  searchTerms <- unlist(lapply(search, CQLtoRegex))

  for (i in 1:length(searchTerms)){
    conts[[i]] <- lapply(corp,extractContext,search=searchTerms[i],LW,RW)%>%
      #If >1 texts if df, search will cross text boundaries.
      compact()%>%
      lapply(.,rbindlist,idcol="id")%>%
      rbindlist()

  if (length(conts[[i]]) >0 ) {
    conts[[i]] <- conts[[i]]%>%
      mutate(eg=group_indices(.,doc_id,id))%>%
      select(-id)

    found[i] <- i
    } else
    {found[i] <- 0}
    }

  found <- found [found>0]

  if (sum(found) >0){

  conts <- conts[c(found)]
  names(conts) <- search[found]
  rbindlist (conts,idcol="search_found")

     } else
      {return("SEARCH TERM(S) NOT FOUND IN CORPUS")}
}
