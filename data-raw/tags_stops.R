

library(tidyverse)
#devtools::use_data_raw()

clr_ref_penntags <- read.csv("C:\\Users\\jason\\Google Drive\\GitHub\\packages\\corpuslingr\\data-raw\\tag_codes.csv")%>%
  mutate_all(as.character)
clr_ref_upos <- read.csv("C:\\Users\\jason\\Google Drive\\GitHub\\packages\\corpuslingr\\data-raw\\upos_codes.csv")%>%
  mutate_all(as.character)


clr_ref_stops <- scan("C:\\Users\\jason\\Google Drive\\GitHub\\packages\\corpuslingr\\data-raw\\corenlp_stops.txt",what="char",sep="\n")

clr_ref_pos_syntax <- read.csv("C:\\Users\\jason\\Google Drive\\GitHub\\packages\\corpuslingr\\data-raw\\search_syntax.csv")%>%
  mutate_all(as.character)

clr_ref_search_egs <- read.csv("C:\\Users\\jason\\Google Drive\\GitHub\\packages\\corpuslingr\\data-raw\\example_search.csv")%>%
  mutate_all(as.character)

setwd("C:\\Users\\jason\\Google Drive\\GitHub\\packages\\corpuslingr")
#Output
devtools::use_data(clr_ref_penntags, overwrite=TRUE)
devtools::use_data(clr_ref_upos, overwrite=TRUE)
devtools::use_data(clr_ref_stops, overwrite=TRUE)
devtools::use_data(clr_ref_pos_syntax, overwrite=TRUE)
devtools::use_data(clr_ref_search_egs, overwrite=TRUE)

#We need consistent names for all 'resource' tables.
