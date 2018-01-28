#' Access GoogleNews quickly
#'
#' These functions enable easy access to GoogleNews rss feed, and subsequent scraping.
#' @name scrapeWeb
#' @param search Search topic for GoogleNews.  Defaults to NULL, which amounts to "Top Stories"
#' @param n Number of articles to get; max = 30.
#' @return A dataframe of meta for articles collected.
#' @import data.table
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

  out[,c('source','titles','links','pubdates','date')] <- lapply(out[,c('source','titles','links','pubdates','date')], as.character)

  out[out$source != "This RSS feed URL is deprecated",]
}


#' @export
#' @rdname scrapeWeb
GetWebTexts <- function(y,link_var='links') {

  raws <- sapply(y[link_var], function (x) {
    tryCatch(RCurl::getURL(x, .encoding='UTF-8', ssl.verifypeer = FALSE), error=function(e) NULL)})

  cleaned <- lapply(raws, function(z) {
    x <- lapply(z, boilerpipeR::ArticleExtractor)
    x <- gsub("\\\n"," ",x, perl=TRUE)
    gsub("\\\"","\"",x, perl=TRUE)
      })

  names(cleaned) <- y[[link_var]]
  tif <- melt(unlist(cleaned),value.name='txt')
  setDT(tif, keep.rownames = TRUE)[]
  colnames(tif)[1] <- 'links'
  tif <- merge(y,tif,by.x=c(link_var),by.y=c('links'))
  tif$txt <- as.character(tif$txt)

  tif <- tif[nchar(tif$txt)>250,]
  tif <- tif[complete.cases(tif),]
  tif$doc_id <- paste('doc',seq.int(nrow(tif)),sep="")
  tif$date <- as.Date(tif$date, "%d %b %Y")
  tif <- tif[, c(ncol(tif),1:(ncol(tif)-1))]
  return(tif)
}
