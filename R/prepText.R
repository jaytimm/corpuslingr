#' Prepare character string for annotation
#'
#' Function cleans raw texts
#' @name prepText
#' @param x A list of character strings
#' @param hyphenate if TRUE, trick spacy into preserving hyphenated words
#' @return A list of character strings

#' @export
#' @rdname prepText
clr_prep_corpus <- function (x, hyphenate=TRUE) {
  x <- gsub("^ *|(?<= ) | *$", "", x, perl = TRUE)


    if (hyphenate==TRUE) {
        x <- gsub("([[:alpha:]])-([[:alpha:]])",'\\1xxx\\2',x, perl=TRUE)}
}
