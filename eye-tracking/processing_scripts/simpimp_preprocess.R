################################################################################
## PREPROCESSING SCRIPT FOR SIMPIMP
## read in data files and consolidate them
##
## ey mcf 1/14
################################################################################

## PRELIMINARIES
rm(list = ls())
# source("et_helper_old.R")
source("et_helper.R")

# raw.data.path <- "../raw_data/old_data/"
raw.data.path <- "../raw_data/new_data/"
processed.data.path <- "../processed_data/"

## LOOP TO READ IN FILES
all.data <- data.frame()
files <- dir(raw.data.path,pattern="*.txt")

for (file.name in files) {
  print(file.name)
  
  ## these are the two functions that are most meaningful
  d <- read.smi.idf(paste(raw.data.path,file.name,sep=""),header.rows=35)
  d <- preprocess.data(d)
  d$subid <- file.name
  
  ## now here's where data get bound together
  all.data <- rbind(all.data, d)
}

# d_old <- all.data
# d_new <- all.data
# d <- rbind(d_old, d_new)

## WRITE DATA OUT TO CSV FOR EASY ACCESS
write.csv(all.data,paste(processed.data.path,
                         "simpimp_processed.csv",sep=""),
          row.names=FALSE) 

