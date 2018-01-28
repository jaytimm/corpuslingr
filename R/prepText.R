#' Prepare character string for annotation
#'
#' Function cleans raw texts
#' @name prepText
#' @param x A list of character strings
#' @param hyphenate if TRUE, trick spacy into preserving hyphenated words
#' @return A list of character strings

#' @export
#' @rdname prepText
PrepCorpus <- function (x, hyphenate=TRUE) {
  x <- gsub("^ *|(?<= ) | *$", "", x, perl = TRUE)


    if (hyphenate==TRUE) {
        x <- gsub("([:aplha])-([:aplha])",'\\1xxx\\2',x, perl=TRUE)}
}
