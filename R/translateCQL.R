#' Translate user search input to regex
#'
#' These functions convert CQL search to regex.
#' @name translateCQL
#' @param x Gram/lexical pattern to be searched for
#' @return A list of character strings

#' @export
#' @rdname translateCQL
clr_build_search <- function(x){

  default <- '<\\S+~\\S+~\\S+>'

  #Simple wildcard:
  if (x=="*") default else {

    pos <- "\\\\S+"; form <- "\\\\S+"; lemma <- "\\\\S+"

  #Prefixes, suffixes, 'infixes' -- kill non-regex *:
    x <- gsub ('\\*([A-Za-z-])', 'XWILD\\1',x) #NO!
    x <- gsub ('([A-Za-z-])\\*', '\\1XWILD',x)

  #Bracket off search from potential regex:
    framed <- gsub("([A-Za-z~_$-]+)","<\\1>",x)

  #Strip potential regex:
    stp <- gsub("([^A-Za-z~_$-]+)","",x)

  #Swap out search syntax with regex:
    if (stp %in% clr_ref_pos_syntax$pos) {
      pos <- clr_ref_pos_syntax$regex[match(stp,clr_ref_pos_codes$pos)]}

  #LEMMA~POS
    if (length(grep("~", x)==1)) {
      pos <- clr_ref_pos_syntax$regex[match(sub(".*~","",stp),clr_ref_pos_codes$pos)]
      stp <- gsub("~.*$","",stp)}

  #Assign ALLCAPS/NON-POS to lemma
    if (stp == toupper(stp) & !stp %in% clr_ref_pos_codes$pos) {lemma <- stp}

  #Assign noncaps/non-pos to form
    if (stp != toupper(stp) & !stp %in% clr_ref_pos_codes$pos) {form <- stp}

  #Add regex to prefix/suffix/infix
    form <- gsub("XWILD","[a-z-]*",form)
    lemma <- gsub("XWILD","[a-z-]*",lemma)

  #Negation.
    if (stp == 'NEG') {
      lemma <- 'not'
      pos <- "\\\\S+"}

  #Wildcards with proper regex:
    if (length(grep("\\(\\*|\\*\\{",x))==1) {sub("\\*", default,x)
    } else{

  #Add search terms as regex to frame
      sub('(?<=<).*(?=>)', paste(form,lemma,pos,sep="~"), framed, perl=TRUE)
    }
  }
}



#' @export
#' @rdname translateCQL
clr_ref_nounphrase <- "(?:(?:DET )?(?:ADJ )*)?(?:((NOUNX )+|PRON ))"


#' @export
#' @rdname translateCQL
clr_ref_keyphrase <- "(ADJ )*(NOUNX )+((PREP )(ADJ )*(NOUNX )+)?"


#' @export
#' @rdname translateCQL
clr_cql_regex <- function(x) {

  if (length(x) > 1) {x <- paste(x,collapse=" |")}

  x <- gsub("NPHR",clr_ref_nounphrase,x)
  x <- gsub("KPHR",clr_ref_keyphrase,x)

  y <- unlist(strsplit(x," "))
  y <- lapply(y,clr_build_search)
  y <- paste(y, collapse="")
  gsub(">","> ",y)}

