

#devtools::use_data_raw()

clr_tag_codes <- read.csv("C:\\Users\\jtimm\\Google Drive\\GitHub\\packages\\corpuslingr\\data-raw\\tag_codes.csv")
clr_upos_codes <- read.csv("C:\\Users\\jtimm\\Google Drive\\GitHub\\packages\\corpuslingr\\data-raw\\upos_codes.csv")


clr_stops <- scan("C:\\Users\\jason\\Google Drive\\GitHub\\packages\\corpuslingr\\data-raw\\corenlp_stops.txt",what="char",sep="\n")


#Output
devtools::use_data(clr_tag_codes, overwrite=TRUE)
devtools::use_data(clr_upos_codes, overwrite=TRUE)
devtools::use_data(clr_stops, overwrite=TRUE)
