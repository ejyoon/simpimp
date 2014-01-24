################################################################################
## SANITY CHECK SCRIPT 
################################################################################

## PRELIMINARIES
rm(list = ls())
source("~/Projects/R/Ranalysis/useful.R")
source("~/Projects/R/Ranalysis/et_helper.R")

d <- read.csv("processed_data/simpimp processed.csv")

## THINGS TO CHECK
## 1. distribution of data 

# do histograms of the data for x and y coordinates
hist(d$x)
hist(d$y)

# break down by subject 
# HINT: use facets!
qplot(x,
      facets = ~ subid,
      geom="histogram",
      data=d)
qplot(y,
      facets = ~ subid,
      geom="histogram",
      data=d)

## 2. location of fixations
# plot all the datapoints

qplot(x,y,data=d)

## 2a. check location of fixations that are on the fixation cross
##     better be the center!

qplot(x,y,data=subset(d,stimulus=="cross_white")) # what's going on here?

# and as densities (try geom="density2d")

qplot(x,y,geom="density2d",
      data=d,
      xlim=c(0,1680),ylim=c(0,1050)) 

# also try plotting by subject

qplot(x,y, 
      facets = ~ subid,
      geom="density2d",
      data=subset(d,stimulus=="cross_white"),
      xlim=c(0,1680),
      ylim=c(0,1050))

## 2b. now fixations that aren't on the cross

# basic scatter plot
qplot(x,y,data=subset(d,stimulus!="cross_white")) # what's going on here?

# and densities by subject
qplot(x,y, 
      facets = ~ subid,
      geom="density2d",
      data=subset(d,stimulus!="cross_white"),
      xlim=c(0,1680),
      ylim=c(0,1050)) 

## 3. Check for missing data
# how many NAs are there in the dataset?

sum(is.na(d$x))

# how about for each participant?
# HINT: use na.action="na.pass" to pass NAs through aggregate

aggregate(x ~ subid, d, function(y) {return(sum(is.na(y)))},
          na.action="na.pass")