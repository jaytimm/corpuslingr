

#devtools::use_data_raw()

clr_tag_codes <- read.csv("C:\\Users\\jtimm\\Google Drive\\GitHub\\packages\\corpuslingr\\data-raw\\tag_codes.csv")

#Output
devtools::use_data(clr_tag_codes, overwrite=TRUE)
