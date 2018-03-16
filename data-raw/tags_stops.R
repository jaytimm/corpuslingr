

#devtools::use_data_raw()

clr_tag_codes <- read.csv("C:\\Users\\jtimm\\Google Drive\\GitHub\\packages\\corpuslingr\\data-raw\\tag_codes.csv")
clr_upos_codes <- read.csv("C:\\Users\\jtimm\\Google Drive\\GitHub\\packages\\corpuslingr\\data-raw\\upos_codes.csv")


clr_stops <- scan("C:\\Users\\jason\\Google Drive\\GitHub\\packages\\corpuslingr\\data-raw\\corenlp_stops.txt",what="char",sep="\n")

clr_search_syntax <- read.csv("C:\\Users\\jason\\Google Drive\\GitHub\\packages\\corpuslingr\\data-raw\\search_syntax.csv")

setwd("C:\\Users\\jason\\Google Drive\\GitHub\\packages\\corpuslingr")
#Output
devtools::use_data(clr_tag_codes, overwrite=TRUE)
devtools::use_data(clr_upos_codes, overwrite=TRUE)
devtools::use_data(clr_stops, overwrite=TRUE)
devtools::use_data(clr_search_syntax, overwrite=TRUE)
