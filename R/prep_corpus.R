#' Clean 'text' column of corpus dataframe
#'
#' Function modifies & cleans 'text' column of corpus dataframe prior to annotation; addresses issues such as long-dashes, hyphenated words, and unwanted white space.
#' @name prep_corpus
#' @param x A dataframe corpus
#' @return A dataframe corpus
#' @import data.table


#' @export
#' @rdname prep_corpus
clr_prep_corpus <- function (x, hyphenate=TRUE) {
  setDT(x)
  x[, text := as.character(text)]
  x[, text := gsub("^ *|(?<= ) | *$", "", text, perl = TRUE)]
  x[, text := gsub("(--)([[:alpha:]])","\\1 \\2",text, perl=TRUE)]
  x[, text := gsub("([[:alpha:]])(--)","\\1 \\2",text, perl=TRUE)]

  if (hyphenate==TRUE) {
    x[, text := gsub("([[:alpha:]])-([[:alpha:]])",'\\1qq\\2',text, perl=TRUE)]
  }

  x}
