#' Prepare character string for annotation
#'
#' Function cleans raw texts
#' @name prepText
#' @param x A list of character strings
#' @param hyphenate if TRUE, trick spacy into preserving hyphenated words
#' @return A list of character strings
#' @import magrittr


#' @export
#' @rdname prepText
PrepText <- function (x, hyphenate=TRUE) {
#This should work on a single text file.?
  lapply(x, function(y){
    txt <- y %>%
      gsub("(?<=[\\s])\\s*|^\\s+|\\s+$", "",., perl=TRUE)%>%
      gsub('--(.)','-- \\1',., perl=TRUE)%>%
      gsub('(.)--','\\1 --',., perl=TRUE)

    if (hyphenate==TRUE) {
        txt <- gsub("(\\w)-(\\w)",'\\1xxx\\2',txt, perl=TRUE)}
    return(txt)})
}
