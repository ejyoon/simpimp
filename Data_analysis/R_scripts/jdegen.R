######################
## Spaghetti plot code
## created by jdegen on 06/19/2013
## Uses a reduced version of the dataset reported in Degen & Tanenhaus (under review). In particular, the garden-path and number term conditions are excluded. The dataset is pre-downsampled to 20ms. 

rm(list = ls())
setwd("/Users/ericang/Documents/Erica/Stanford/2013-Q2-Winter/Research/simpimpGIT/Data_analysis/")
source("/Users/ericang/Documents/Erica/Stanford/2013-Q2-Winter/Research/simpimpGIT/Data_analysis/R_scripts/useful.R")
load("processed_data/dt.RData")

nrow(dt)
head(dt)
summary(dt)

###########################################
# Important variables:
# Time (zero point at trial onset)
# Time_rel_stim_Sound (zero point at audio onset)
# Time_rel_stim_Qonset (zero point at quantifier onset)
# Time_rel_stim_Conset (zero point at color adjective onset)
# rp_RegionType (factor coding regions of interest -- t: target, c: competitor, ti: upper chamber on target side, ci: upper chamber on competitor side, center: central button on machine, none)
# ResponseType (factor coding participants' response -- target, competitor, center (FALSE))
# Quantifier (factor coding quantifier -- some, all)
# Numbers (factor coding whether numbers were present or absent)
# POD (factor coding whether point of disambiguation was early or late. If early, there was a contrast in the lower chamber, not otherwise.)
# TargetSize (factor coding whether the target set size is big (4/5) or small (2/3))
# Target (factor coding whether 1: current look is to target or 0: current look is not to target)

###########################################
## What do we want to know?
# 1. Does including number terms slow down processing (regardless of quantifier/differently for different quantifiers)?
# 2. Are looks slower to converge on the target after "some" than after "all"? 
# 3. Does set size interact with the answer to 2.?
# 4. Baseline check: Do looks converge on target later in the late than in the early condition?
# --> We can create spaghetti plots that address any one of these questions. Eg, let's start with 1.

########################################
# Create spaghetti plot stepwise for question 1.

# Do we need to exclude any of the data?
# Yes, we need neither the late nor the number data
toplot = subset(dt, POD != "late")

# Next, we need to create the time variable to plot on the x axis. This is Time_rel_stim_Qonset. Let's just make it explicit - this is important in case you want to have the zero point somewhere else rather than at the zero point of Time_rel_stim_Qonset. For example, if we want the zero point to be at mean audio onset (which in this case is real audio onset because the stimuli are cross-spliced), we move the zero point back by 462 ms
toplot$TimePlot = toplot$Time_rel_stim_Qonset + 462

# Remove time samples that fall outside the time window you want to plot. We want to go from 0 (audio onset) to 1600ms
toplot = subset(toplot, TimePlot >= 0 & TimePlot <= 1600)

# To speed things up, it's often helpful to reduce large datasets to smaller ones that contain only the information you need. In this case, we care only about TimePlot, Numbers, and Target. 
toplot = droplevels(toplot)
melted = toplot[,c("TimePlot","Numbers","Target")]
melted$Target = as.numeric(as.character(melted$Target))

#### NUMBERS: aggregate the data to get the mean at each time point 
agr <- aggregate(Target ~ TimePlot + Numbers, melted, mean)

ggplot(agr, aes(x=TimePlot, y=Target, color=Numbers)) +
  geom_line(size=2) +
  scale_y_continuous("Proportion of looks to target",breaks=seq(0,1,by=0.2),limits=c(0,1)) +
  #    coord_cartesian(ylim=c(0,1)) +				
  scale_x_continuous("Time (ms)",breaks=seq(0,1600,by=200)) +
  geom_vline(xintercept=462, color="black", size=I(1),show_guide=FALSE)

#### QUANTIFIER: aggregate by additional variable
melted = toplot[,c("TimePlot","Numbers","Target","Quantifier")]
melted$Target = to.n(melted$Target)
agr <- aggregate(Target ~ TimePlot + Numbers + Quantifier, melted, mean)

ggplot(agr, aes(x=TimePlot, y=Target, linetype=Numbers, color=Quantifier)) +
  geom_line(size=2) +
  scale_y_continuous("Proportion of looks to target",breaks=seq(0,1,by=0.2),limits=c(0,1)) +
  scale_x_continuous("Time (ms)",breaks=seq(0,1600,by=200)) +
  geom_vline(xintercept=462, color="black", size=I(1),show_guide=FALSE)

#### TARGET SET SIZE: aggregate by additional variable
agr <- aggregate(Target ~ TimePlot + Numbers + Quantifier + TargetSize, melted, mean)

ggplot(agr, aes(x=TimePlot, y=Target, linetype=Numbers, color=Quantifier)) +
  geom_line(size=2) +
  scale_y_continuous("Proportion of looks to target",breaks=seq(0,1,by=0.2),limits=c(0,1)) +
  scale_x_continuous("Time (ms)",breaks=seq(0,1600,by=200)) +
  facet_wrap(~TargetSize) +
  geom_vline(xintercept=462, color="black", size=I(1),show_guide=FALSE)

################################################
# Now let's plot multiple regions instead of only looks to the target
# For example, target & competitor
melted = melt(toplot, id=c("TimePlot","Quantifier"),
              measure=c("Target","Competitor"),
              value.name="Looks",variable.name="Region")
melted$Looks = to.n(melted$Looks)
agr <- aggregate(Looks ~ Region + TimePlot + Quantifier, melted, mean)

ggplot(agr, aes(x=TimePlot,y=Looks,linetype=Region,color=Quantifier)) +
  geom_line(size=2) +
  geom_vline(xintercept=462, color="black", size=I(1),show_guide=FALSE)


### Why don't the proportions sum to 1?
# Exclude all looks that aren't to the target or the competitor
melted = melt(subset(toplot,rp_RegionType %in% c("t","c")), 
              id=c("TimePlot","Quantifier"),
              measure=c("Target","Competitor"),
              value.name="Looks",variable.name="Region")
melted$Looks = to.n(melted$Looks)

agr <- aggregate(Looks ~ TimePlot + Quantifier + Region, melted, mean)
agr$errbargroup = as.factor(paste(agr$Region,agr$Quantifier))

ggplot(agr, aes(x=TimePlot,y=Looks,linetype=Region,color=Quantifier)) +
  geom_line(size=2) +
  geom_vline(xintercept=462, color="black", size=I(1),show_guide=FALSE)


### Plot looks to target, competitor, and center
toplot$Center = as.factor(ifelse(toplot$rp_RegionType == "center",1,0))
melted = melt(toplot, id=c("TimePlot","Quantifier"),
              measure=c("Target","Competitor","Center"),
              value.name="Looks",variable.name="Region")
melted$Looks = to.n(melted$Looks)

agr = aggregate(Looks ~ Region + Quantifier + TimePlot, melted, mean)

ggplot(agr, aes(x=TimePlot,y=Looks,linetype=Region,color=Quantifier)) +
  geom_line(size=2) +
  geom_vline(xintercept=462, color="black", size=I(1),show_guide=FALSE)


# It's starting to get cluttered.  Let's instead plot all regions in different colors, in separate facets for different quantifiers
ggplot(agr, aes(x=TimePlot,y=Looks,linetype=Region,color=Region)) +
  geom_line(size=2) +
  geom_vline(xintercept=462, color="black", size=I(1),show_guide=FALSE) +
  facet_wrap(~Quantifier)



# Now let's say we want to add error bars. For the absent condition, let's see if target looks for "some" and "all" vary. Let's display big and small target sets in separate facets for readability.
melted = melt(subset(toplot, Numbers == "absent" & rp_RegionType %in% c("t","c")), id=c("TimePlot","Quantifier","TargetSize"),measure=c("Target"))
melted$value = as.numeric(as.character(melted$value))

agr = with(melted, aggregate(value,by=list(Quantifier,TimePlot,TargetSize),FUN=mean))
colnames(agr) = c("Quantifier","Time","TargetSize","Proportion")
# add the standard error to the data.frame
agr$SE = with(melted, aggregate(value,by=list(Quantifier,TimePlot,TargetSize),FUN=se))$x
# add SE lower limit
agr$YMin = agr$Proportion - agr$SE
# add SE upper limit
agr$YMax = agr$Proportion + agr$SE

p = ggplot(agr, aes(x=Time,y=Proportion,color=Quantifier)) +
  geom_line(size=2) +
  geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  facet_wrap(~TargetSize) +
  geom_vline(xintercept=462, color="black", size=I(1),show_guide=FALSE)
p

# Add additional line for mean adjective onset to see POD
toplot$AdjDiff = toplot$Time_rel_stim_Qonset - toplot$Time_rel_stim_Conset
# get mean adjective onset overall
meanadj = mean(toplot$AdjDiff)
p = ggplot(agr, aes(x=Time,y=Proportion,color=Quantifier)) +
  geom_line(size=2) +
  geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  facet_wrap(~TargetSize) +
  geom_vline(xintercept=462, color="black", size=I(1),show_guide=FALSE) +
  geom_vline(xintercept=meanadj, color="black", size=I(1),show_guide=FALSE)   
p

# We need to add quantifier onset!
meanadj = meanadj + 462
p = ggplot(agr, aes(x=Time,y=Proportion,color=Quantifier)) +
  geom_line(size=2) +
  geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  facet_wrap(~TargetSize) +
  geom_vline(xintercept=462, color="black", size=I(1),show_guide=FALSE) +
  geom_vline(xintercept=meanadj, color="black", size=I(1),show_guide=FALSE)   
p

# If we want the entire time window offset by 200ms (time it takes before information from the signal can affect eye movements), we can.
meanadj = meanadj + 200
p = ggplot(agr, aes(x=Time,y=Proportion,color=Quantifier)) +
  geom_line(size=2) +
  geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  facet_wrap(~TargetSize) +
  scale_y_continuous(limits=c(0,1)) +
  geom_vline(xintercept=662, color="black", size=I(1),show_guide=FALSE) +
  geom_vline(xintercept=meanadj, color="black", size=I(1),show_guide=FALSE)   
p

# Real adjective onset differs somewhat for "some" and "all". Let's compute the actual adjective onsets. 
meanadj = aggregate(toplot$AdjDiff,by=list(toplot$Quantifier),FUN=mean)
meanadj
meanadj$x = meanadj$x + 462
# Let's assign colors manually to make the adjective onset lines match the quantifier lines
p = ggplot(agr, aes(x=Time,y=Proportion,color=Quantifier)) +
  geom_line(size=2) +
  geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  scale_color_manual(values=c("red","blue")) +
  facet_wrap(~TargetSize) +
  scale_y_continuous(limits=c(0,1)) +
  geom_vline(xintercept=662, color="black", size=I(1),show_guide=FALSE) +
  geom_vline(xintercept=meanadj$x[1]+200, color="red", size=I(1),show_guide=FALSE)+
  geom_vline(xintercept=meanadj$x[2]+200, color="blue", size=I(1),show_guide=FALSE)   
p

