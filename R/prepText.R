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
  x$text <- gsub("^ *|(?<= ) | *$", "", x$text, perl = TRUE)


    if (hyphenate==TRUE) {
        x$text <- gsub("(\\w)-(\\w)",'\\1xxx\\2',x$text, perl=TRUE)}
}
