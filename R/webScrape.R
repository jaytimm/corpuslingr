#' Access GoogleNews quickly
#'
#' These functions enable easy access to GoogleNews rss feed, and subsequent scraping.
#' @name webScrape
#' @param search Search topic for GoogleNews.  Defaults to NULL, which amounts to "Top Stories"
#' @param n Number of articles to get; max = 30.
#' @return A dataframe of meta for articles collected.
#' @import XML RCurl boilerpipeR tidyverse
#' @export
#' @rdname webScrape


#' @export
#' @rdname webScrape
GetGoogleNewsMeta <- function(x,search=NULL,n=30) {

  rss <- paste("https://news.google.com/news?hl=en&q=",gsub(" ","",search),"&ie=utf-8&num=",n,"&output=rss",sep="")

  doc <- RCurl::getURL(rss, ssl.verifypeer = FALSE)%>%
    xmlParse()

  titles <- XML::xpathSApply(doc,'//item/title',xmlValue)
  source <- gsub("^.* - ","",titles)
  titles <-  gsub(" - .*$","",titles)
  links <- XML::xpathSApply(doc,'//item/link',xmlValue)%>%
    gsub("^.*url=","",.)
  pubdates <- XML::xpathSApply(doc,'//item/pubDate',xmlValue)

  date <- gsub("^.+, ","",pubdates)
  date <- gsub(" [0-9]*:.+$","", date)

  as.data.frame(cbind(source,titles,links,pubdates,date))%>%
    mutate(source=as.character(source), titles=as.character(titles), links=as.character(links), pubdates=as.character(pubdates),date=as.character(date))%>%
    filter(source!="This RSS feed URL is deprecated")
  }
  #Add an id, perhaps.


#' @export
#' @rdname webScrape
GetWebTexts <- function(y) {

  raws <- sapply(y, function (x) {
    tryCatch(RCurl::getURL(x, .encoding='UTF-8', ssl.verifypeer = FALSE), error=function(e) NULL)})
  names(raws) <- y
  raws <- Filter(length,raws)

  output <- lapply(raws, function(z) {
    lapply(z, boilerpipeR::ArticleExtractor)%>%
    gsub("(?<=[\\s])\\s*|^\\s+|\\s+$", "",., perl=TRUE)%>%
    gsub("\\\n"," ",., perl=TRUE)#%>%
    #gsub("\\\"","\"",., perl=TRUE)
      })

  output <- output[!sapply(output, is.na)]
  Filter(nchar,output)
}
