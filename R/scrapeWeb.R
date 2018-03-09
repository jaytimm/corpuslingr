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
clr_web_gnews <- function(x,language='en',country='us',type='tops',search=NULL) {

  ned <- country
  hl2 <- ""
  base <- "https://news.google.com/news/rss/"
  q <- "search/section/q"
  section <- "headlines/section/topic/"

  if (language == 'es') {
    ned <- paste(language,country,sep="_")
    language <- 'es-419'}

  if (language == 'es-419' & country == 'us') hl2 = "&hl=US"

  hl1 <- paste0("&hl=", language)
  ned <- paste0("?ned=",ned)
  gl <- paste0("&gl=",country)

  if(type=='topstories') rss <- paste0(base,ned,hl1,gl,hl2)

  if(type=='topic') rss <- paste0(base,section,toupper(topic),ned,hl1,gl,hl2)

  if(type=='term') {
    search1 <- paste("/",gsub(" ","",search),sep="")
    rss <- paste0(base,q,search1,search1,hl1,gl,ned) }

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
clr_web_scrape <- function(y,link_var='links') {

  raws <- sapply(y[link_var], function (x) {
    tryCatch(RCurl::getURL(x, .encoding='UTF-8', ssl.verifypeer = FALSE), error=function(e) NULL)})

  cleaned <- lapply(raws, function(z) {
    x <- lapply(z, boilerpipeR::ArticleExtractor)
    x <- gsub("\\\n"," ",x, perl=TRUE)
    gsub("\\\"","\"",x, perl=TRUE)
      })

  names(cleaned) <- y[[link_var]]
  tif <- melt(unlist(cleaned),value.name='text')
  setDT(tif, keep.rownames = TRUE)[]
  colnames(tif)[1] <- 'links'
  tif <- merge(y,tif,by.x=c(link_var),by.y=c('links'))
  tif$text <- as.character(tif$text)
  tif$text <- enc2utf8(tif$text)

  tif <- tif[nchar(tif$text)>250,]
  tif <- tif[complete.cases(tif),]
  tif$doc_id <- paste('doc',seq.int(nrow(tif)),sep="")
  tif$date <- as.Date(tif$date, "%d %b %Y")
  tif <- tif[, c(ncol(tif),1:(ncol(tif)-1))]
  return(tif)
}
