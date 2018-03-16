#' Translate user search input to regex
#'
#' These functions convert CQL search to regex.
#' @name translateCQL
#' @param x Gram/lexical pattern to be searched for
#' @return A list of character strings

#' @export
#' @rdname translateCQL
clr_build_search <- function(x){

  pos <- "\\\\S+"; form <- "\\\\S+"; lemma <- "\\\\S+"
  framed <- gsub("([A-Za-z~*_]+)","<\\1>",x)

  stp <- gsub("([^A-Za-z~*_]+)","",x) #Strip any add regex.

  if (stp %in% clr_search_syntax$pos) {pos <- clr_search_syntax$regex[match(stp,clr_search_syntax$pos)]}

  if (length(grep("~", x)==1)) {
    pos <- clr_search_syntax$regex[match(sub(".*~","",stp),clr_search_syntax$pos)]
    stp <- gsub("~.*$","",stp)}

  if (stp == toupper(stp) & !stp %in% clr_search_syntax$pos) {lemma <- stp}
  if (stp != toupper(stp) & !stp %in% clr_search_syntax$pos) {form <- stp}

  #Wildcard
  form <- gsub("\\*","[a-z_]\\*",form) #Hypens ?
  lemma <- gsub("\\*","\\\\S+",lemma)
  #Negation.

  sub('(?<=<).*(?=>)', paste(form,lemma,pos,sep="~"), framed, perl=TRUE)
  }


#' @export
#' @rdname translateCQL
clr_nounphrase <- "(?:(?:<~DT> )?(?:<~Jx> )*)?(?:((<~Nx> )+|<~PRP> ))"


#' @export
#' @rdname translateCQL
clr_keyphrase <- "(<~JJ> )*(<~N[A-Z]{1,10}> )+((<~IN> )(<~JJ> )*(<~N[A-Z]{1,10}> )+)?"


#' @export
#' @rdname translateCQL
clr_cql_regex <- function(x) {

#"I hope| desire" -- space is non-intuitive.

  if (length(x) > 1) {x <- paste(x,collapse=" |")}

  y <- unlist(strsplit(x," "))
  y <- lapply(y,clr_build_search)
  y <- paste(y, collapse="")
  gsub(">","> ",y)}

