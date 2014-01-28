################################################################################
## PREPROCESSING SCRIPT FOR SIMPIMP
## read in data files and consolidate them
##
## ey mcf 1/14
################################################################################

## PRELIMINARIES
rm(list = ls())
setwd("/Users/ericang/Documents/Erica/Stanford/2013-Q2-Winter/Research/simpimpGIT/Data_analysis/")
source("/Users/ericang/Documents/Erica/Stanford/2013-Q2-Winter/Research/simpimpGIT/Data_analysis/R_scripts/useful.R")
source("/Users/ericang/Documents/Erica/Stanford/2013-Q2-Winter/Research/simpimpGIT/Data_analysis/R_scripts/et_helper.R")

raw.data.path <- "raw_data/"
info.path <- "info/"
processed.data.path <- "processed_data/"

## LOOP TO READ IN FILES
all.data <- data.frame()
files <- dir(raw.data.path,pattern="*.txt")

for (file.name in files) {
  print(file.name)
  
  ## these are the two functions that are most meaningful
  d <- read.smi.idf(paste(raw.data.path,file.name,sep=""),header.rows=38)
  d <- preprocess.data(d)
  d$subid <- file.name
  
  ## now here's where data get bound together
  all.data <- rbind(all.data, d)
}

## WRITE DATA OUT TO CSV FOR EASY ACCESS
write.csv(all.data,paste(processed.data.path,
                         "simpimp_processed.csv",sep=""),
          row.names=FALSE) 

