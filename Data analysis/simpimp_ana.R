################################################################################
## ANALYSIS SCRIPT FOR SIMPIMP
################################################################################

## PRELIMINARIES
rm(list = ls())
source("~/Projects/R/Ranalysis/useful.R")
source("~/Projects/R/Ranalysis/et_helper.R")

d <- read.csv("processed_data/simpimp processed.csv")

## minor odds and ends
d <- subset(d,stimulus != "cross_white") # remove fixation cross
d$stimulus <- to.n(d$stimulus) # convert to numeric

################ PRELIMINARIES #################
## 1. Read in the orders and merge them with the data
order <- read.csv("info/order1.csv")

nrow(d) # first check number of rows
plot(d$stimulus) # now check the stimulus ordering

# now join in the orders
d <- join(d, order) # use join rather than merge because it doesn't sort

plot(d$stimulus) # check that nothing got messed up
nrow(d) # check the number of rows again

## 2. Define the target ROIs (regions of interest)
rois <- list()
rois[[1]] <- c(0,0,840,550) # left
rois[[2]] <- c(840,0,840,550) # right
rois[[3]] <- c(420,550,840,550) # center
names(rois) <- c("L","R","C")
roi.image(rois) 

# use check code to make sure that ROIs look right
d$roi <- roi.check(d,rois) 

# see how the distribution of ROIs looks
qplot(roi,data=d)

# set up correctness
d$correct <- d$roi == d$targ.pos

## 3. Align trials to the onset of the critical word
d <- rezero.trials(d)

## 4. subsample the data so that you get smooth curves
##    I like to do this when I don't have much data so that I'm not distracted 
##    by the variation in the data, but then relax the subsampling if I have more data.
subsample.hz <- 10 # 10 hz is decent, eventually we should set to 30 or 60 hz
d$t.crit.binned <- round(d$t.crit*subsample.hz)/subsample.hz # subsample step

################ ANALYSES #################
# every analysis has two parts: an aggregation step and a plotting step
# - aggregation averages over some kind of unit of interest, e.g. trial type
# - and then plotting is making a picture relative to that aggregation

## 1. TRIAL TYPE ANALYSIS
ms <- aggregate(correct ~ t.crit.binned + trial.type, d, mean)

qplot(t.crit.binned,correct,
      colour=trial.type, 
      geom="line",      
      data=ms) + 
  geom_hline(yintercept=.33,lty=2) + 
  geom_vline(xintercept=0,lty=3) + 
  xlab("Time (s)") + ylab("Proportion correct looking") + 
  scale_x_continuous(limits=c(-2,3),expand = c(0,0)) + 
  scale_y_continuous(limits=c(0,1),expand = c(0,0)) # make the axes start at 0

## add error bars with 95% CI
mss <- aggregate(correct ~ t.crit.binned + trial.type + subid, d, mean)
ms <- aggregate(correct ~ t.crit.binned + trial.type, mss, mean)
ms$cih <- aggregate(correct ~ t.crit.binned + trial.type, mss, ci.high)$correct
ms$cil <- aggregate(correct ~ t.crit.binned + trial.type, mss, ci.low)$correct

qplot(t.crit.binned,correct,
      colour=trial.type, 
      geom="line",      
      data=ms) + 
  geom_pointrange(aes(ymin=correct-cil, ymax=correct+cih),
                  position=position_dodge(.05)) +
  geom_hline(yintercept=.33,lty=2) + 
  geom_vline(xintercept=0,lty=3) + 
  xlab("Time (s)") + ylab("Proportion correct looking") + 
  scale_x_continuous(limits=c(-2,3),expand = c(0,0)) + 
  scale_y_continuous(limits=c(0,1),expand = c(0,0)) # make the axes start at 0

## 2. BY ITEM ANALYSIS
# this won't look good until we have a lot of data because we are dividing our 
# data in 6 parts
ms <- aggregate(correct ~ t.crit.binned + trial.type + item, d, mean)

qplot(t.crit.binned,correct,
      colour=trial.type, facets=~item,
      geom="line",
      data=ms) + 
  geom_hline(yintercept=.33,lty=2) + 
  xlab("Time (s)") + ylab("Proportion correct looking") + 
  scale_x_continuous(limits=c(-2,3),expand = c(0,0)) + 
  scale_y_continuous(limits=c(0,1),expand = c(0,0)) 

## 3. DWELL TIME IN WINDOW ANALYSIS
# this will look good because we're averaging considerably
window <- c(.5,2.5)
mss <- aggregate(correct ~ trial.type + subid, 
                subset(d,t.crit.binned > window[1] & t.crit.binned < window[2]), 
                       mean)
ms <- aggregate(correct ~ trial.type, mss, mean)
ms$cih <- aggregate(correct ~ trial.type, mss, ci.high)$correct
ms$cil <- aggregate(correct ~ trial.type, mss, ci.low)$correct

qplot(trial.type,correct,
      fill=trial.type, stat="identity",
      geom="bar",ylim=c(0,1),
      data=ms) + 
  ylab("Proportion correct looking") + 
  geom_hline(yintercept=.33,lty=2) + 
  geom_errorbar(aes(ymin=correct-cil,ymax=correct+cih,width=.2))