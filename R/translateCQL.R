#' Translate user search input to regex
#'
#' These functions convert CQL search to regex.
#' @name translateCQL
#' @param x Gram/lexical pattern to be searched for
#' @return A list of character strings
#' @import magrittr

#' @export
#' @rdname translateCQL
buildSearch <- function(x){

  pos <- "[A-Za-z0-9-]+"; form <- "[A-Za-z0-9-]+"; lemma <- "[A-Za-z0-9-]+"
  if (length(grep("_", x)==1)) {pos=gsub(".*_|>.*","",x)}
  if (length(grep("x", pos)==1)) {pos=gsub("x","[A-Z]{1,10}",pos)}
  #Add replace tilde ~
  if (length(grep("&", x)==1)) {lemma=gsub(".*<|&.*","",x)}
  if (length(grep("!", x)==1)) {form=gsub(".*<|!.*","",x)}
  sub('(?<=<).*(?=>)', paste(form,lemma,pos,sep=","), x, perl=TRUE)}


#' @export
#' @rdname translateCQL
nounPhrase <- "(?:(?:<_DT> )?(?:<_Jx> )*)?(?:((<_Nx> )+|<_PRP> ))"


#' @export
#' @rdname translateCQL
keyPhrase <- "(<_JJ> )*(<_N[A-Z]{1,10}> )+((<_IN> )(<_JJ> )*(<_N[A-Z]{1,10}> )+)?"


#' @export
#' @rdname translateCQL
CQLtoRegex <- function(x) {

  if (length(x) > 1) {x <- paste(x,collapse=" |")}

  x <- gsub("<_NXP>",nounPhrase,x)

  unlist(strsplit(x," ")) %>%
    lapply(buildSearch) %>%
    paste(collapse="")%>%
    gsub(">","> ",.)}

