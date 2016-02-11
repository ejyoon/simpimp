################################################################################
## ANALYSIS SCRIPT FOR SIMPIMP
################################################################################

# after simpimp_keepdrop

### DATA ANALYSES

### ANALYSES
# From Mike:every analysis has two parts: an aggregation step and a plotting step
# - aggregation averages over some kind of unit of interest, e.g. trial type
# - and then plotting is making a picture relative to that aggregation
detach(package:plyr)
library(dplyr)
library(data.table)

d_et <- fread("/Users/ericang/Documents/Research/simpimp_GIT/simpimp_et_all.csv")

######

# line graph

## correct ~ t.crit.binned + trial_type + age_group
mss <- d_et %>%
  filter(age_group == "2" | age_group == "3" | age_group == "4" | age_group == "5" | age_group == "adult") %>%
  # filter(expt == "0") %>%
  filter(t.crit > -1 & t.crit <= 3) %>%
  group_by(expt,trial_type, age_group, t.crit.binned, subid) %>%
  summarise(correct = mean(correct, na.rm = TRUE))

mss$subid <- factor(mss$subid)
mss$age_group <- as.factor(mss$age_group) # age as factor
mss$age_group <- factor(mss$age_group, levels = c("2","3","4", "5", "adult"))
mss$expt <- as.factor(mss$expt)
levels(mss$expt) <- c("2-vs-1", "3-vs-1")

ms <- aggregate(correct ~ expt + t.crit.binned + trial_type + age_group, mss, mean)
# levels(ms$trial_type) <- c("control-double", "control-single", "inference")

p <- ggplot(subset(ms, age_group != "adult"), aes(x = t.crit.binned, y = correct, colour = expt)) +
  geom_line() +
  facet_grid(age_group~trial_type) +
  geom_vline(xintercept=0,lty=3) + 
  geom_vline(xintercept=0.78,lty=3) + 
  geom_hline(yintercept=.50,lty=4) + 
  xlab("Time (s)") + ylab("Proportion correct looking") + 
  scale_x_continuous(expand = c(0,0)) + 
  scale_y_continuous(limits=c(0,1),expand = c(0,0))
p



############

# onset-contingency plot
ms <- d %>% 
  # filter(expt == "0") %>%
  filter(age_group == "2" | age_group == "3" | age_group == "4" | age_group == "5") %>%
  filter(trial_type == "inf") %>%
  group_by(expt, age_group, targetAtOnset, t.crit.binned) %>%
  summarize(
    correct = mean(correct, na.rm=TRUE)
  ) %>%
  filter(targetAtOnset != "NA") 

# ms[with(ms,
#                          targetAtOnset==1 & min != roll.mean),
#                     c("min","max")]<- 0
# ms[with(ms,
#                          targetAtOnset==0 & max != roll.mean),
#                     c("min","max")]<- 0

ms$targetAtOnset <- as.numeric(ms$targetAtOnset)
ms$correct[ms$targetAtOnset==1] <- 1 - ms$correct[ms$targetAtOnset==1]
ms$age_group <- factor(ms$age_group, levels = c("2","3","4", "5", "adult"))


qplot(as.numeric(as.character(t.crit.binned)),correct,
      colour=factor(targetAtOnset), 
      # group=factor(targetAtOnset),
      geom="line", #lty=factor(targetAtOnset), # alpha=.5,     
      data=ms) + 
  facet_wrap(expt~age_group, ncol=4) + 
  scale_fill_brewer(palette="Set1") +
  geom_hline(yintercept=.5,lty=4) + 
  geom_vline(xintercept=.78,lty=3) + 
  geom_vline(xintercept=0,lty=3) + 
  # geom_ribbon(aes(ymin=min,ymax=max), fill="blue", alpha="0.5") +
  #geom_polygon(aes(y = correct,     group = group)) +
  #geom_polygon(aes(x =as.numeric(as.character(t.crit.binned)), y = correct), fill = "red", alpha = 0.2)+
  scale_y_continuous(expand = c(0, 0), limits=c(0,20)) + 
  xlab("Time (s)") + ylab("Proportion switching") + 
  scale_x_continuous(limits=c(0,2.9),expand = c(0,0)) + 
  scale_y_continuous(limits=c(0,1),expand = c(0,0)) # make the axes start at 0

#############

# bar graph

# by age
mss <- d %>%
  filter(age_group!= "1" & age_group != "6" & age_group != "adult") %>%
  filter(expt != "proskidNEW") %>%
  filter(t.crit > 0.78 & t.crit <= 3) %>%
#  mutate(window = ifelse(t.crit <= 1.89, "early", "late")) %>%   # window
#  filter(trial_type == "inf") %>%
  group_by(expt, age_group, trial_type, subid) %>%
  summarise(correct = mean(correct, na.rm = TRUE))

mss$subid <- factor(mss$subid)
mss$expt <- factor(mss$expt)
mss$age_group <- as.factor(mss$age_group) # age as factor
mss$trial_type <- as.factor(mss$trial_type)

ms <- aggregate(correct ~ expt + age_group + trial_type, mss, mean)
ms$cih <- aggregate(correct ~ expt + age_group + trial_type, mss, ci.high)$correct
ms$cil <- aggregate(correct ~ expt + age_group + trial_type, mss, ci.low)$correct

ms$expt <- as.factor(ms$expt)
levels(ms$expt) <- c("2-vs-1", "3-vs-1")
mss$age_group <- factor(mss$age_group, levels = c("2","3","4", "5", "adult"))
ms$age_group <- factor(ms$age_group, levels = c("2","3","4", "5", "adult"))
levels(ms$trial_type) <- c("control-double", "control-single", "inference")

ggplot(ms, 
       aes(fill=expt, y=correct, x=trial_type)) +
  geom_bar(position="dodge", stat="identity") + 
  facet_wrap(~age_group, ncol=4) +
  ylab("Proportion correct looking") + 
  guides(fill=guide_legend(title=NULL)) +
  geom_hline(yintercept=.50,lty=4) + 
  geom_errorbar(aes(ymin=correct-cil,ymax=correct+cih,width=.2),position=position_dodge(width = 0.90))