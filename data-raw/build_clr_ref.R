

library(tidyverse)
#devtools::use_data_raw()

clr_ref_penntags <- read.csv("C:\\Users\\jtimm\\Google Drive\\GitHub\\packages\\corpuslingr\\data-raw\\clr_ref_penntags.csv")%>%
  mutate_all(as.character)
clr_ref_upos <- read.csv("C:\\Users\\jtimm\\Google Drive\\GitHub\\packages\\corpuslingr\\data-raw\\clr_ref_upos.csv")%>%
  mutate_all(as.character)


clr_ref_stops <- scan("C:\\Users\\jtimm\\Google Drive\\GitHub\\packages\\corpuslingr\\data-raw\\clr_ref_stops.txt",what="char",sep="\n")

clr_ref_pos_syntax <- read.csv("C:\\Users\\jtimm\\Google Drive\\GitHub\\packages\\corpuslingr\\data-raw\\clr_ref_pos_syntax.csv")%>%
  mutate_all(as.character)

clr_ref_search_egs <- read.csv("C:\\Users\\jtimm\\Google Drive\\GitHub\\packages\\corpuslingr\\data-raw\\clr_ref_search_egs.csv")%>%
  mutate_all(as.character)

setwd("C:\\Users\\jtimm\\Google Drive\\GitHub\\packages\\corpuslingr")
#Output
devtools::use_data(clr_ref_penntags, overwrite=TRUE)
devtools::use_data(clr_ref_upos, overwrite=TRUE)
devtools::use_data(clr_ref_stops, overwrite=TRUE)
devtools::use_data(clr_ref_pos_syntax, overwrite=TRUE)
devtools::use_data(clr_ref_search_egs, overwrite=TRUE)

#We need consistent names for all 'resource' tables.
