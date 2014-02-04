################################################################################
## ANALYSIS SCRIPT FOR SIMPIMP
################################################################################

## PRELIMINARIES
rm(list = ls())
setwd("/Users/ericang/Documents/Erica/Stanford/2013-Q2-Winter/Research/simpimpGIT/Data_analysis/")
source("/Users/ericang/Documents/Erica/Stanford/2013-Q2-Winter/Research/simpimpGIT/Data_analysis/R_scripts/useful.R")
source("/Users/ericang/Documents/Erica/Stanford/2013-Q2-Winter/Research/simpimpGIT/Data_analysis/R_scripts/et_helper.R")

d <- read.csv("processed_data/simpimp_processed.csv")
head(d)

## minor odds and ends
d <- subset(d,stimulus != "blank") # remove blanks
# got rid of (because the stimulus names are in characters): d$stimulus <- to.n(d$stimulus) # convert to numeric

################ PRELIMINARIES #################
## 1. Read in the orders and merge them with the data
order <- read.csv("info/simpimp_order.csv")
head(order)

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
qplot(roi,data=d, facets=~subid)
qplot(roi,data=d, facets=~targetPos)
qplot(roi,data=d, facets=~target)

# set up correctness
d$correct <- d$roi == d$targetPos
d$incorrect <- d$roi == d$distPos

d$target <- ifelse(d$roi == d$targetPos, "1", "0")
d$dist <- ifelse(d$roi == d$distPos, "1", "0")
d$foil <- ifelse(d$roi == d$foilPos, "1", "0")

head(d)
d <- subset(d,correct != "NA") ## Post-hoc elimination of trials other than test
qplot(roi,data=d)


## 3. Align trials to the onset of the critical word
d <- rezero.trials(d)


## 4. subsample the data so that you get smooth curves
##    I like to do this when I don't have much data so that I'm not distracted 
##    by the variation in the data, but then relax the subsampling if I have more data.
subsample.hz <- 5 # 10 hz is decent, eventually we should set to 30 or 60 hz
d$t.crit.binned <- round(d$t.crit*subsample.hz)/subsample.hz # subsample step

################ ANALYSES #################
# every analysis has two parts: an aggregation step and a plotting step
# - aggregation averages over some kind of unit of interest, e.g. trial type
# - and then plotting is making a picture relative to that aggregation

## 1. TRIAL TYPE ANALYSIS
ms <- aggregate(correct ~ t.crit.binned + trialType, d, mean)

qplot(t.crit.binned, correct,
      colour=trialType,
      geom="line",      
      data=ms) + 
  geom_hline(yintercept=.33,lty=2) + 
  geom_hline(yintercept=.5,lty=4) + 
  geom_vline(xintercept=0,lty=3) + 
  xlab("Time (s)") + ylab("Proportion correct looking") + 
  scale_x_continuous(limits=c(-4,3),expand = c(0,0)) + 
  scale_y_continuous(limits=c(0,1),expand = c(0,0)) # make the axes start at 0

## 1aa. all regions (target, dist, foil)

melted = melt(d, id=c("t.crit.binned", "trialType"), 
              measure=c("target", "dist", "foil"),
              value.name="Looks", variable.name="Region")
melted$Looks = to.n(melted$Looks)

subsample.hz <- 5 # 10 hz is decent, eventually we should set to 30 or 60 hz
d$t.crit.binned <- round(d$t.crit*subsample.hz)/subsample.hz # subsample step

ms <- aggregate(Looks ~ Region + t.crit.binned + trialType, melted, mean)

qplot(t.crit.binned, Looks,
      colour=trialType,
      linetype=Region,
      geom="line",      
      data=ms) + 
  geom_hline(yintercept=.33,lty=2) + 
  geom_hline(yintercept=.5,lty=4) + 
  geom_vline(xintercept=0,lty=3) + 
  xlab("Time (s)") + ylab("Proportion Looking") + 
  scale_x_continuous(limits=c(-4,3),expand = c(0,0)) + 
  scale_y_continuous(limits=c(0,1),expand = c(0,0)) # make the axes start at 0



## 1b. by participant
ms <- aggregate(correct ~ t.crit.binned + trialType + subid, d, mean)

qplot(t.crit.binned,correct,
      colour=trialType, 
      geom="point",      
      data=ms) + 
  facet_wrap(~ subid) + 
  geom_hline(yintercept=.33,lty=2) + 
  geom_hline(yintercept=.5,lty=4) + 
  geom_vline(xintercept=0,lty=3) + 
  geom_smooth() + 
  xlab("Time (s)") + ylab("Proportion correct looking") + 
  scale_x_continuous(limits=c(-4,4),expand = c(0,0)) + 
  scale_y_continuous(limits=c(0,1),expand = c(0,0)) # make the axes start at 0

# try points
subsample.hz <- 60 # 10 hz is decent, eventually we should set to 30 or 60 hz
d$t.crit.binned <- round(d$t.crit*subsample.hz)/subsample.hz # subsample step
ms <- aggregate(correct ~ t.crit.binned + trialType, d, mean)
ms_i <- aggregate(incorrect ~ t.crit.binned + trialType, d, mean)

qplot(t.crit.binned,correct,
      colour=trialType, 
      geom="point",      
      data=ms) + 
  geom_hline(yintercept=.33,lty=2) + 
  geom_vline(xintercept=0,lty=3) + 
  geom_smooth(method="loess",span=.5) +
  xlab("Time (s)") + ylab("Proportion correct looking") + 
  scale_x_continuous(limits=c(-4,3),expand = c(0,0)) + 
  scale_y_continuous(limits=c(0,1),expand = c(0,0)) # make the axes start at 0

## 1c. trial order
ms <- aggregate(correct ~ t.crit.binned + trialType + order2, d, mean)

qplot(t.crit.binned,correct,
      colour=trialType, 
      geom="point",      
      data=ms) + 
  facet_grid(.~ order2) + 
  geom_hline(yintercept=.33,lty=2) + 
  geom_hline(yintercept=.5,lty=4) + 
  geom_vline(xintercept=0,lty=3) + 
  geom_smooth() + 
  xlab("Time (s)") + ylab("Proportion correct looking") + 
  scale_x_continuous(limits=c(-3,3),expand = c(0,0)) + 
  scale_y_continuous(limits=c(0,1),expand = c(0,0)) # make the axes start at 0

# incorrect
qplot(t.crit.binned,incorrect,
      colour=trialType, 
      geom="line",      
      data=ms_i) + 
  geom_hline(yintercept=.33,lty=2) + 
  geom_vline(xintercept=0,lty=3) + 
  xlab("Time (s)") + ylab("Proportion incorrect looking") + 
  scale_x_continuous(limits=c(-2,3),expand = c(0,0)) + 
  scale_y_continuous(limits=c(0,1),expand = c(0,0)) # make the axes start at 0

## add error bars with 95% CI
mss <- aggregate(correct ~ t.crit.binned + trialType + subid, d, mean)
ms <- aggregate(correct ~ t.crit.binned + trialType, mss, mean)
ms$cih <- aggregate(correct ~ t.crit.binned + trialType, mss, ci.high)$correct
ms$cil <- aggregate(correct ~ t.crit.binned + trialType, mss, ci.low)$correct

qplot(t.crit.binned,correct,
      colour=trialType, 
      geom="line",      
      data=ms) + 
  geom_pointrange(aes(ymin=correct-cil, ymax=correct+cih),
                  position=position_dodge(.05)) +
  geom_hline(yintercept=.33,lty=2) + 
  geom_vline(xintercept=0,lty=3) + 
  xlab("Time (s)") + ylab("Proportion correct looking") + 
  scale_x_continuous(limits=c(-2,3),expand = c(0,0)) + 
  scale_y_continuous(limits=c(0,1),expand = c(0,0)) # make the axes start at 0

## 1d. looking at target, distractor, and foil altogether
melted = melt(d, id=c("targetOnset"),
  measure=c("targetPos","distPos", "foilPos"),
  value.name="Looks",variable.name="Region")
head(melted)
melted$Looks = to.n(melted$Looks)
agr <- aggregate(Looks ~ Region + TimePlot + Quantifier, melted, mean)

ggplot(agr, aes(x=TimePlot,y=Looks,linetype=Region,color=Quantifier)) +
  geom_line(size=2) +
  geom_vline(xintercept=462, color="black", size=I(1),show_guide=FALSE)



## 2. BY ITEM ANALYSIS
# this won't look good until we have a lot of data because we are dividing our 
# data in 6 parts
ms <- aggregate(correct ~ t.crit.binned + trialType + target, d, mean)

qplot(t.crit.binned,correct,
      colour=trialType, facets=~target,
      geom="line",
      data=ms) + 
  geom_hline(yintercept=.33,lty=2) + 
  xlab("Time (s)") + ylab("Proportion correct looking") + 
  scale_x_continuous(limits=c(-2,3),expand = c(0,0)) + 
  scale_y_continuous(limits=c(0,1),expand = c(0,0)) 

## 3. DWELL TIME IN WINDOW ANALYSIS
# this will look good because we're averaging considerably
window <- c(.5,2.5)
mss <- aggregate(correct ~ trialType + subid, 
                subset(d,t.crit.binned > window[1] & t.crit.binned < window[2]), 
                       mean)
ms <- aggregate(correct ~ trialType, mss, mean)
ms$cih <- aggregate(correct ~ trialType, mss, ci.high)$correct
ms$cil <- aggregate(correct ~ trialType, mss, ci.low)$correct

qplot(trialType,correct,
      fill=trialType, stat="identity",
      geom="bar",ylim=c(0,1),
      data=ms) + 
  ylab("Proportion correct looking") + 
  geom_hline(yintercept=.33,lty=2) + 
  geom_errorbar(aes(ymin=correct-cil,ymax=correct+cih,width=.2))

# by subject
qplot(trialType,correct,
      fill=trialType, stat="identity",
      geom="bar",ylim=c(0,1),
      data=mss) +
  facet_grid(. ~ subid) +
  ylab("Proportion correct looking") + 
  geom_hline(yintercept=.33,lty=2) 

#incorrect looks?
window <- c(.5,2.5)
mss_i <- aggregate(incorrect ~ trialType + subid, 
                 subset(d,t.crit.binned > window[1] & t.crit.binned < window[2]), 
                 mean)
ms_i <- aggregate(incorrect ~ trialType, mss_i, mean)
ms_i$cih <- aggregate(incorrect ~ trialType, mss_i, ci.high)$incorrect
ms_i$cil <- aggregate(incorrect ~ trialType, mss_i, ci.low)$incorrect

qplot(trialType,incorrect,
      fill=trialType, stat="identity",
      geom="bar",ylim=c(0,1),
      data=ms_i) + 
  ylab("Proportion correct looking") + 
  geom_hline(yintercept=.33,lty=2) + 
  geom_errorbar(aes(ymin=incorrect-cil,ymax=incorrect+cih,width=.2))
