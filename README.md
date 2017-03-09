# simpimp
Children's processing of ad-hoc implicatures

## Files required for knitting the manuscript file

`paper/simpimp_paper.Rmd`:
markdown for manuscript, in APA format. Includes codes for analyzing the processed data files. This file calls on the following files within the repo:

`eye-tracking/processed_data/simpimp_processed_2v1.csv`:
processed data file for Experiment 1A

`eye-tracking/processed_data/simpimp_processed_3v1.csv`:
processed data file for Experiment 1B

`ipad/simpimp_ipad_short.csv`:
processed data file for Experiment 2

## Required files for generating eye-tracking processed data files

### 1) processing scripts

`eye-tracking/processing_scripts/simpimp_preprocess.R`:
converting raw data into R-readable format, and then putting all the data from all subjects together into one csv file
(or rather, two csv file: separately for each experiment, 1A and 1B)

`eye-tracking/processing_scripts/simpimp_keepdrop.R`:
binding information from the subject log and order sheet 

### 2) raw data files 
in `eye-tracking/raw_data`. 

There are two directories here:

`old_data`: houses data files from the “old” eye-tracker

`new_data`: houses data files from the “old” eye-tracker

### 3) info sheets

`eye-tracking/info/simpimp_et_log.csv`:
subject log, where the columns are:

subid: subject id
keep_drop: whether the subject should be excluded even before considering other experiment-specific criteria. e.g. if the subject’s age was not indicated on the demographics form
expt: experiment version. 0 = Experiment 1A in manuscript. sc = Experiment 1B in manuscript. 
age: numeric age calculated using: ( test date - birth date ) / 365
age_group: binned into an age group by year
sex: participant sex
English: daily level of exposure to English as reported by parent. 4 (75%) is the passing criterion.


`eye-tracking/info/simpimp_et_order.csv`:
order sheet, where the columns are:

stimulus: slide name that got recorded on the raw data file
order: whether the slide appeared on the first vs. second half of the trials
trial_num: trial number (i.e. when this trial was shown)
trial_type: trial type. cs = control-single; cd = control-double; inf = inference
targetPos: position of the target referent; could be left (L) or right (R)
distPos: position of the distractor
targetOnset: the time at which the target noun was produced

