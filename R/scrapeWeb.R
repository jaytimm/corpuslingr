#' Access GoogleNews quickly
#'
#' These functions enable easy access to GoogleNews rss feed, and subsequent scraping.
#' @name scrapeWeb
#' @param language Language locale code
#' @param country Country two letter code
#' @param type Search type: topic, topstories, term
#' @param search if type = term/topic, the topic or term to be searched.  Sets to NULL when type = topstories.
#' @return A dataframe of meta for articles collected.
#' @import data.table
#' @importFrom xml2 xml_text xml_find_all
#' @importFrom boilerpipeR ArticleExtractor
#' @importFrom RCurl getURL



#' @export
#' @rdname scrapeWeb
clr_web_gnews <- function(x,language='en',country='us',type='topstories',search=NULL) {

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

  if(type=='topic') rss <- paste0(base,section,toupper(search),ned,hl1,gl,hl2)

  if(type=='term') {
    search1 <- paste("/",gsub(" ","",search),sep="")
    rss <- paste0(base,q,search1,search1,hl1,gl,ned) }

  doc <- xml2::read_xml(rss)

  title <- xml2::xml_text(xml2::xml_find_all(doc,"//item/title"))
  link <- xml2::xml_text(xml2::xml_find_all(doc,"//item/link"))
  pubDate <- xml2::xml_text(xml2::xml_find_all(doc,"//item/pubDate"))
  source <- gsub("(htt[a-z]*://)(www\\.)?(\\S+\\.[a-z]+)/\\S+$","\\3",link)

  date <- gsub("^.+, ","",pubDate)
  date <- gsub(" [0-9]*:.+$","", date)

  out <- as.data.frame(cbind(date,source,title,link))
  out$lang <- language
  out$country <- country
  out$search <- ifelse(type=='topic'|type=='term',paste(type,search,sep="_"), 'topstories')

  out[,c('date','source','title','link')] <- lapply(out[,c('date','source','title','link')], as.character)

  out <- subset(out,link != 'wsj.com')
  out[, c(5:7,1:4)]
}


#' @export
#' @rdname scrapeWeb
clr_web_scrape <- function(y,link_var='link') {

  raws <- sapply(y[link_var], function (x) {
    tryCatch(RCurl::getURL(x, .encoding='UTF-8', ssl.verifypeer = FALSE), error=function(e) NULL)})

  cleaned <- lapply(raws, function(z) {
    x <- lapply(z, boilerpipeR::ArticleExtractor)
    x <- gsub("\\\n"," ",x, perl=TRUE) #Note. Kills text structure.
    gsub("\\\"","\"",x, perl=TRUE)
    #gsub('share menu.*$|sharemenu.*$','',x)
      })

  names(cleaned) <- y[[link_var]]
  tif <- melt(unlist(cleaned),value.name='text')
  setDT(tif, keep.rownames = TRUE)[]
  colnames(tif)[1] <- 'link'
  tif <- merge(y,tif,by.x=c(link_var),by.y=c('link'))
  tif$text <- as.character(tif$text)
  tif$text <- enc2utf8(tif$text)

  tif <- tif[nchar(tif$text)>500,]
  tif <- tif[complete.cases(tif),]
  tif$doc_id <- as.character(seq.int(nrow(tif)))
  tif$date <- as.Date(tif$date, "%d %b %Y")

  tif <- tif[, c(ncol(tif),1:(ncol(tif)-1))]
  return(tif)
}
