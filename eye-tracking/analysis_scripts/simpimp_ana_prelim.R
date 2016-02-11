## PRELIMINARIES

# 1. Read in the orders and merge them with the data
# NOTE: I've now moved this step to the beginning of the sanity check part, since I need to take into account what trials are the ones that count

# 2. Define the target ROIs (regions of interest)
rois <- list()
rois[[1]] <- c(0,250,840,750) # left
rois[[2]] <- c(840,250,840,750) # right
names(rois) <- c("L","R")
roi.image(rois)

# use check code to make sure that ROIs look right
d$roi <- roi.check(d,rois) 

# see how the distribution of ROIs looks
qplot(roi,data=d)

# 3. Setting up variables for correct looking
# set up correctness
d <- d %>%
  mutate(correct = roi == targetPos)
#   # another way to organize by ROI's: set up three possible regions
# d$target <- ifelse(d$roi == d$targetPos, "1", "0")
# d$dist <- ifelse(d$roi == d$distPos, "1", "0")

## 4. Align trials to the onset of the critical word
# Here we "create timestamps starting from the point of disambiguation".
d <- rezero.trials(d) # specified in et_helper.R

# clean-up
d <- d %>%
  select(expt, subid, stimulus, order, trial_type, age_group, correct, t.crit)

## 5. Indicate where subject was looking at during word onset
# Extra column to divide participants depending on where they were looking at the word onset
onset <- d %>%
  select(subid, stimulus, t.crit, correct) %>%
  filter(t.crit > - 0.005 & t.crit < 0.005) %>%
  mutate(targetAtOnset = ifelse(correct == TRUE, TRUE, FALSE)) %>%
  select(subid, stimulus, targetAtOnset) %>%
  distinct(subid, stimulus)
d <- join(d, onset)

## 6. subsample the data so that you get smooth curves***

# From Mike: I like to do this when I don't have much data so that I'm not distracted by the variation in the data, but then relax the subsampling if I have more data.
subsample.hz <- 30 # 10 hz is decent, eventually we should set to 30 or 60 hz
d <- d %>%
  mutate(t.crit.binned = round(t.crit*subsample.hz)/subsample.hz) %>%
  mutate(t.crit.binned = signif(t.crit.binned, 4))


### rbind to the old file
# d_all <- read.csv("/Users/ericang/Documents/Research/SIMPIMP/SIMPIMP_GIT/Data_analysis/processed_data/simpimp_all_150717.csv")
# d1 <- d %>% 
#   select(age_group, correct, expt, order, subid, subtrial, t.crit, t.crit.binned, targetAtOnset, trialType) %>%
#   mutate(trial_type = trialType)
# d1$trialType <- NULL
# levels(d1$trial_type) <- c("cd", "cs", "inf")
# 
# d <- rbind(d_all, d1)

# write.csv(d,paste(processed.data.path,
#                   "simpimp_all_150717.csv",sep=""), # CHANGE FILE NAME AS NEEDED
#           row.names=FALSE) 
# 
