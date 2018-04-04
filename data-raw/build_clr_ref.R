

library(tidyverse)
#devtools::use_data_raw()

clr_ref_penntags <- read.csv("C:\\Users\\jason\\Google Drive\\GitHub\\packages\\corpuslingr\\data-raw\\clr_ref_penntags.csv")%>%
  mutate_all(as.character)
clr_ref_upos_codes <- read.csv("C:\\Users\\jason\\Google Drive\\GitHub\\packages\\corpuslingr\\data-raw\\clr_ref_upos_codes.csv")%>%
  mutate_all(as.character)


clr_ref_stops <- scan("C:\\Users\\jason\\Google Drive\\GitHub\\packages\\corpuslingr\\data-raw\\clr_ref_stops.txt",what="char",sep="\n")

clr_ref_pos_codes <- read.csv("C:\\Users\\jason\\Google Drive\\GitHub\\packages\\corpuslingr\\data-raw\\clr_ref_pos_codes.csv")%>%
  mutate_all(as.character)

clr_ref_search_egs <- read.csv("C:\\Users\\jason\\Google Drive\\GitHub\\packages\\corpuslingr\\data-raw\\clr_ref_search_egs.csv")%>%
  mutate_all(as.character)

setwd("C:\\Users\\jason\\Google Drive\\GitHub\\packages\\corpuslingr")
#Output
devtools::use_data(clr_ref_penntags, overwrite=TRUE)
devtools::use_data(clr_ref_upos_codes, overwrite=TRUE)
devtools::use_data(clr_ref_stops, overwrite=TRUE)
devtools::use_data(clr_ref_pos_codes, overwrite=TRUE)
devtools::use_data(clr_ref_search_egs, overwrite=TRUE)

#We need consistent names for all 'resource' tables.
