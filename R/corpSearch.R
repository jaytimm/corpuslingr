#' Get search in context
#'
#' These functions enable corpus search of gram constructions in context.
#' @name corpSearch
#' @param search Gram/lexical pattern to be searched for
#' @param LW Size of context in number of words to left of the target
#' @param RW Size of context in number of words to right of the target
#' @param corp List of annotated texts to be searched
#' @return A list of dataframes
#' @import magittr dplyr data.table


buildSearch <- function(x){

  pos <- "\\\\w*"; form <- "\\\\w*"; lemma <- "\\\\w*"
  if (length(grep("_", x)==1)) {pos=gsub(".*_|>.*","",x)}
  if (length(grep("x", pos)==1)) {pos=gsub("x","[A-Z]{1,3}",pos)}
  if (length(grep("&", x)==1)) {lemma=gsub(".*<|&.*","",x)}
  if (length(grep("!", x)==1)) {form=gsub(".*<|!.*","",x)}
  sub('(?<=<).*(?=>)', paste(form,lemma,pos,sep="_"), x, perl=TRUE)}

#' @export
#' @rdname corpSearch
nounPhrase <- "(?:(?:<_DT> )?(?:<_Jx> )*)?(?:((<_Nx> )+|<_PRP> ))"

#' @export
#' @rdname corpSearch
keyPhrase <- "(<_JJ> )*(<_N[A-Z]{1,3}> )+((<_IN> )(<_JJ> )*(<_N[A-Z]{1,3}> )+)?"


CQLtoRegex <- function(x) {
  x <- gsub("<_NXP>",nounPhrase,x)

  unlist(strsplit(x," ")) %>%
    lapply(buildSearch) %>%
    paste(collapse="")%>%
    gsub(">","> ",.)}


#' @export
#' @rdname corpSearch
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
#' @rdname corpSearch
GetContexts <- function(search,corp,LW,RW){

  conts <- list()
  found <- vector()
  searchTerms <- unlist(lapply(search, CQLtoRegex))

  for (i in 1:length(searchTerms)){
    conts[[i]] <- lapply(corpus,extractContext,search=searchTerms[i],LW,RW)%>%
      compact()%>%
      lapply(.,rbindlist,idcol="id")%>%
      rbindlist()

  if (length(conts[[i]]) >0 ) {
    conts[[i]] <- conts[[i]][, eg := .GRP, by = .(doc_id,id)]%>%
      select(-id)

    found[i] <- i
    } else
    {found[i] <- 0}
    }

  found <- found [found>0]

  if (sum(found) >0){

  conts <- conts[c(found)]
  names(conts) <- search[found]
  return(conts)

     } else
      {return("NO SEARCH TERMS FOUND IN CORPUS")}
}
