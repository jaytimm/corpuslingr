#' Access GoogleNews quickly
#'
#' These functions enable easy access to GoogleNews rss feed, and subsequent scraping.
#' @name scrapeWeb
#' @param search Search topic for GoogleNews.  Defaults to NULL, which amounts to "Top Stories"
#' @param n Number of articles to get; max = 30.
#' @return A dataframe of meta for articles collected.
#' @importFrom XML xpathSApply xmlParse xmlValue
#' @importFrom boilerpipeR ArticleExtractor
#' @importFrom RCurl getURL



#' @export
#' @rdname scrapeWeb
GetGoogleNewsMeta <- function(x,search=NULL,n=30) {

  rss <- paste("https://news.google.com/news?hl=en&q=",gsub(" ","",search),"&ie=utf-8&num=",n,"&output=rss",sep="")

  doc <- RCurl::getURL(rss, ssl.verifypeer = FALSE)
  doc <- XML::xmlParse(doc)

  titles <- XML::xpathSApply(doc,'//item/title',xmlValue)
  source <- gsub("^.* - ","",titles)
  titles <-  gsub(" - .*$","",titles)
  links <- XML::xpathSApply(doc,'//item/link',xmlValue)
  links <- gsub("^.*url=","",links)
  pubdates <- XML::xpathSApply(doc,'//item/pubDate',xmlValue)

  date <- gsub("^.+, ","",pubdates)
  date <- gsub(" [0-9]*:.+$","", date)


  out <- as.data.frame(cbind(source,titles,links,pubdates,date))
  out$source <- as.character(out$source)
  out$titles <- as.character(out$titles)
  out$links <- as.character(out$links)
  out$pubdates <- as.character(out$pubdates)
  out$date <- as.character(out$date)

  out <- out[out$source!="This RSS feed URL is deprecated",]
}



#' @export
#' @rdname scrapeWeb
GetWebTexts <- function(y) {

  raws <- sapply(y, function (x) {
    tryCatch(RCurl::getURL(x, .encoding='UTF-8', ssl.verifypeer = FALSE), error=function(e) NULL)})

  names(raws) <- y
  raws <- Filter(length,raws)

  output <- lapply(raws, function(z) {
    x <- lapply(z, boilerpipeR::ArticleExtractor)
    x <- gsub("\\\n"," ",x, perl=TRUE)
    gsub("\\\"","\"",x, perl=TRUE)
      })

  output <- output[!sapply(output, is.na)]
  Filter(nchar,output)
}
