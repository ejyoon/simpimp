EJY Simpimp: Data analysis for eye-tracking (140228 - kids & adults)
========================================================
### BEFORE STARTING
Before working on preprocessing and analyzing the data, make sure you have: 
- converted your idf file into a txt file using the idf converter. Refer to langcog wiki if you don't know how to do this!
- changed your raw data file name if needed.
- (If this is your first time analyzing some eye-tracking data) gone to et-ana.googlecode.com and clicked on: Source -> Browse -> (Directory) trunk, and downloaded: 
  et_helper.R, praglook_ana.R, praglook_preprocess.R, praglook_sanitycheck.R, useful.R (Change the names of these files to be specific for your own experiment: for example, my file was simpimp_preprocess.R because my experiment is called simpimp).
- created a directory for data analysis that have these following folders within: 
  1) raw_data: where you put the raw data in txt format!
  2) processed_data: where the processed data (i.e., rearranged version of the raw data) will be stored after running the functions below!
  3) R-scripts: for all the useful R scripts for analyses that you downloaded from et-ana webpage
  4) info: mostly for storing the 'order' file, which I'll describe later.

### PREPROCESSING

When you have these ready, you're ready to preprocess the data!
Open up the file simpimp_preprocess.R (or whatever yours is called!) on R Studio. Below I will follow the codes specified in this file step by step, to demonstrate what each thing does.

Run these first codes for some prelim prep:

```r
rm(list = ls())
setwd("/Users/ericang/Documents/Erica/Stanford/2013-Q2-Winter/Research/simpimpGIT/Data_analysis/")
source("R_scripts/useful.R")
```

```
## Warning: package 'bootstrap' was built under R version 3.0.2
```

```
## Loading required package: lattice Loading required package: Matrix
## 
## Attaching package: 'lme4'
## 
## The following object is masked from 'package:ggplot2':
## 
## fortify
```

```r
source("R_scripts/et_helper.R")
```


The R scripts specified above (useful.R, et_helper.R) are helper files that we call on for some functions needed for analyses. For example, function 'rezero.trials()' is established in the file et_helper.R. Look inside the files to see what functions are built in those!
Also, this means the name conventions your files use all have to be matched and consistent. For instance, the function 'rezero.trials()' calls on the column that specifies the onset time (i.e., exact time when the target word is produced) in your csv file. I had a trouble with this function at first, and then I discovered that the reason was because I had named the column different ('targetOnset') from the way it was specified in the function before ('target.onset'). So either go with the convention all the time, or be sure to go through these functions and change whatever was the convention that YOU used in the files you're using.

Specify the directories from which you'll get files:

```r
raw.data.path <- "raw_data/"
info.path <- "info/"
processed.data.path <- "processed_data/"
```


Below is the preprocessing stage:

```r
## LOOP TO READ IN FILES
all.data <- data.frame()
files <- dir(raw.data.path, pattern = "*.txt")
```

What we did above is to call all files with the extension 'txt' and save them into the variable 'files'.

Before we go on the next step, make sure that there are in fact 38 header rows (before the data starts), as the function below states. You can do this by opening your raw data file in a program that shows the number of rows (e.g., textWrangler).


```r
for (file.name in files) {
    print(file.name)
    
    ## these are the two functions that are most meaningful
    d <- read.smi.idf(paste(raw.data.path, file.name, sep = ""), header.rows = 35)
    d <- preprocess.data(d)
    d$subid <- file.name
    
    ## now here's where data get bound together
    all.data <- rbind(all.data, d)
}

## WRITE DATA OUT TO CSV FOR EASY ACCESS
write.csv(all.data, paste(processed.data.path, "simpimp_processed.csv", sep = ""), 
    row.names = FALSE)
```

```
## Warning: cannot open file 'processed_data/simpimp_processed.csv': No such
## file or directory
```

```
## Error: cannot open the connection
```


Now preprocessing is done! Next we save this as csv so that it can be easily accessed. (Code not shown here)

The csv file should have been saved onto the folder 'processed_data'. Open the folder and check if the file exists, and open the file to check that it's been preprocessed properly. First few rows of mine look like this:


```r
d <- read.csv("/Users/ericang/Documents/Erica/Stanford/2013-Q2-Winter/Research/simpimpGIT/Data_analysis/processed_data/simpimp_processed.csv")
head(d)
```

```
##       t      stimulus   x   y   t.stim            subid
## 1 0.000 elmo_duck.avi 630 289 0.008333 140217-02-L1.txt
## 2 0.008 elmo_duck.avi 639 269 0.016667 140217-02-L1.txt
## 3 0.017 elmo_duck.avi 641 277 0.025000 140217-02-L1.txt
## 4 0.025 elmo_duck.avi 648 293 0.033333 140217-02-L1.txt
## 5 0.033 elmo_duck.avi 648 331 0.041667 140217-02-L1.txt
## 6 0.042 elmo_duck.avi 641 303 0.050000 140217-02-L1.txt
```


Columns:
t: how much time has passed since the exp began
x and y: coordinates where the eye gaze is. 
t.stim: how much time has passed since the stimulus 'elmo_duck.avi', for example, has started playing. 
subid: the subject id. this is the name of the raw data file, so make sure the name is a sensible one!

### KEEP AND DROP

Before analyzing the data, we need to determine keep's and drop's. Run the package 'reshape'



```r
# Libraries
library(reshape)
```

```
## Attaching package: 'reshape'
## 
## The following object is masked from 'package:plyr':
## 
## rename, round_any
## 
## The following object is masked from 'package:reshape2':
## 
## colsplit, melt, recast
## 
## The following object is masked from 'package:Matrix':
## 
## expand
```


***Read in the orders and merge them with the data***

This step was initially part of the stage after all the sanity check, but I've decided to move it here because it's useful for us to focus on the part that we care about from the start.

For this, you need to have created a csv file that specifies the onset of target word, etc., for each trial. Refer to **order1.csv** on et-ana.googlecode.com, or the columns of the order file below for an example.


```r
order <- read.csv("/Users/ericang/Documents/Erica/Stanford/2013-Q2-Winter/Research/simpimpGIT/Data_analysis/info/simpkid_order.csv")
head(order)
```

```
##         stimulus order character container targetItem      trialType
## 1 simpkidsL1.012     1      elmo     table  teddybear control_single
## 2 simpkidsL1.015     1      elmo  lunchbox      apple      inference
## 3 simpkidsL1.017     1    grover     chair        dog control_double
## 4 simpkidsL1.020     1      elmo     plate     banana control_single
## 5 simpkidsL1.022     1    grover     house        car      inference
## 6 simpkidsL1.024     1     ernie  lunchbox     orange control_single
##   trialType2 targetPos distPos targetOnset
## 1    control         R       L       6.242
## 2  inference         L       R       6.410
## 3    control         R       L       6.750
## 4    control         L       R       6.111
## 5  inference         L       R       6.213
## 6    control         R       L       6.617
```

```r

nrow(d)  # first check number of rows
```

```
## [1] 819714
```

```r
plot(d$stimulus)  # now check the stimulus ordering
```

![plot of chunk unnamed-chunk-7](figure/unnamed-chunk-7.png) 


What we do now is use the join function to combine the processed data with the order csv file, so that the data file now has info about the onset time, target item, target item location, etc.


```r
# now join in the orders
d <- join(d, order)  # use join rather than merge because it doesn't sort
```

```
## Joining by: stimulus
```

```r

plot(d$stimulus)  # check that nothing got messed up
```

![plot of chunk unnamed-chunk-8](figure/unnamed-chunk-8.png) 

```r
nrow(d)  # check the number of rows again to see it remained the same
```

```
## [1] 819714
```

```r
head(d)
```

```
##       t      stimulus   x   y   t.stim            subid order character
## 1 0.000 elmo_duck.avi 630 289 0.008333 140217-02-L1.txt    NA      <NA>
## 2 0.008 elmo_duck.avi 639 269 0.016667 140217-02-L1.txt    NA      <NA>
## 3 0.017 elmo_duck.avi 641 277 0.025000 140217-02-L1.txt    NA      <NA>
## 4 0.025 elmo_duck.avi 648 293 0.033333 140217-02-L1.txt    NA      <NA>
## 5 0.033 elmo_duck.avi 648 331 0.041667 140217-02-L1.txt    NA      <NA>
## 6 0.042 elmo_duck.avi 641 303 0.050000 140217-02-L1.txt    NA      <NA>
##   container targetItem trialType trialType2 targetPos distPos targetOnset
## 1      <NA>       <NA>      <NA>       <NA>      <NA>    <NA>          NA
## 2      <NA>       <NA>      <NA>       <NA>      <NA>    <NA>          NA
## 3      <NA>       <NA>      <NA>       <NA>      <NA>    <NA>          NA
## 4      <NA>       <NA>      <NA>       <NA>      <NA>    <NA>          NA
## 5      <NA>       <NA>      <NA>       <NA>      <NA>    <NA>          NA
## 6      <NA>       <NA>      <NA>       <NA>      <NA>    <NA>          NA
```

```
We see that the graph and number of rows did not get messed up by this operation.


```r
order2 <- read.csv("/Users/ericang/Documents/Erica/Stanford/2013-Q2-Winter/Research/simpimpGIT/Data_analysis/info/simpkid-log.csv")
head(order2)
```

```
##              subid keep_drop             reason_drop consent consent.vid
## 1 140217-01-L2.txt      drop              no_consent       N           Y
## 2 140217-02-L1.txt      keep                    <NA>       Y           Y
## 3 140217-03-L1.txt      drop prior_exposure_to_study       Y           Y
## 4 140217-04-L2.txt      keep                    <NA>       Y           Y
## 5 140217-05-L2.txt      drop        wrong_birth_date       Y           Y
## 6 140217-06-L1.txt      keep                    <NA>       Y           Y
##        dob age_group sex hispanic_latino  Race English   lang1    lang2
## 1  6/23/09         4   F               N white       5   Farsi Romanian
## 2  1/11/11         3   F               N white       5 Russian     <NA>
## 3  1/17/09         5   F               N white       5 Russian     <NA>
## 4  10/2/09         4   F               N white       5     ASL     <NA>
## 5 10/27/14      <NA>   F               N Asian       5  Sindhi     <NA>
## 6   5/9/11         2   F               Y white       6    <NA>     <NA>
##   lang3   parent1_ed    parent2_ed No_preemie
## 1    NA some_college  some_college          Y
## 2    NA     graduate  some_college          Y
## 3    NA     graduate  some_college          Y
## 4    NA     graduate      graduate          N
## 5    NA     graduate      graduate          Y
## 6    NA  4yr_college some_graduate          Y
```

```r

# now join in the orders
d <- join(d, order2)  # use join rather than merge because it doesn't sort
```

```
## Joining by: subid
```

```r

plot(d$stimulus)  # check that nothing got messed up
```

![plot of chunk unnamed-chunk-9](figure/unnamed-chunk-9.png) 

```r
nrow(d)  # check the number of rows again to see it remained the same
```

```
## [1] 868354
```

```r
head(d)
```

```
##       t      stimulus   x   y   t.stim            subid order character
## 1 0.000 elmo_duck.avi 630 289 0.008333 140217-02-L1.txt    NA      <NA>
## 2 0.008 elmo_duck.avi 639 269 0.016667 140217-02-L1.txt    NA      <NA>
## 3 0.017 elmo_duck.avi 641 277 0.025000 140217-02-L1.txt    NA      <NA>
## 4 0.025 elmo_duck.avi 648 293 0.033333 140217-02-L1.txt    NA      <NA>
## 5 0.033 elmo_duck.avi 648 331 0.041667 140217-02-L1.txt    NA      <NA>
## 6 0.042 elmo_duck.avi 641 303 0.050000 140217-02-L1.txt    NA      <NA>
##   container targetItem trialType trialType2 targetPos distPos targetOnset
## 1      <NA>       <NA>      <NA>       <NA>      <NA>    <NA>          NA
## 2      <NA>       <NA>      <NA>       <NA>      <NA>    <NA>          NA
## 3      <NA>       <NA>      <NA>       <NA>      <NA>    <NA>          NA
## 4      <NA>       <NA>      <NA>       <NA>      <NA>    <NA>          NA
## 5      <NA>       <NA>      <NA>       <NA>      <NA>    <NA>          NA
## 6      <NA>       <NA>      <NA>       <NA>      <NA>    <NA>          NA
##   keep_drop reason_drop consent consent.vid     dob age_group sex
## 1      keep        <NA>       Y           Y 1/11/11         3   F
## 2      keep        <NA>       Y           Y 1/11/11         3   F
## 3      keep        <NA>       Y           Y 1/11/11         3   F
## 4      keep        <NA>       Y           Y 1/11/11         3   F
## 5      keep        <NA>       Y           Y 1/11/11         3   F
## 6      keep        <NA>       Y           Y 1/11/11         3   F
##   hispanic_latino  Race English   lang1 lang2 lang3 parent1_ed
## 1               N white       5 Russian  <NA>    NA   graduate
## 2               N white       5 Russian  <NA>    NA   graduate
## 3               N white       5 Russian  <NA>    NA   graduate
## 4               N white       5 Russian  <NA>    NA   graduate
## 5               N white       5 Russian  <NA>    NA   graduate
## 6               N white       5 Russian  <NA>    NA   graduate
##     parent2_ed No_preemie
## 1 some_college          Y
## 2 some_college          Y
## 3 some_college          Y
## 4 some_college          Y
## 5 some_college          Y
## 6 some_college          Y
```

```r
summary(d)
```

```
##        t                    stimulus            x               y        
##  Min.   :  0   blank            : 58116   Min.   :   0    Min.   :   0   
##  1st Qu.:147   elmo_tapping1.avi: 48227   1st Qu.: 238    1st Qu.: 489   
##  Median :254   elmo_duck.avi    : 41297   Median : 604    Median : 642   
##  Mean   :260   elmo_rap.avi     : 27717   Mean   : 642    Mean   : 661   
##  3rd Qu.:367   simpkidsL1.008   : 11827   3rd Qu.:1074    3rd Qu.: 844   
##  Max.   :683   simpkidsL1.010   : 10890   Max.   :1680    Max.   :1050   
##                (Other)          :670280   NA's   :14223   NA's   :26560  
##      t.stim                   subid            order       
##  Min.   : 0.00   140226-01-L2.txt: 97280   Min.   :1       
##  1st Qu.: 1.28   140228-01-L1.txt: 52882   1st Qu.:1       
##  Median : 4.07   140228-03-L2.txt: 51168   Median :2       
##  Mean   : 6.06   140228-04-L1.txt: 50832   Mean   :2       
##  3rd Qu.: 7.46   140228-02-L2.txt: 49616   3rd Qu.:2       
##  Max.   :86.70   140226-03-L1.txt: 48911   Max.   :3       
##                  (Other)         :517665   NA's   :451939  
##   character         container          targetItem    
##  bert  :119165   chair   : 68649   car      : 46691  
##  elmo  : 88741   friend  : 69818   cat      : 41305  
##  ernie : 91971   house   : 71222   ball     : 39743  
##  grover:116538   lunchbox: 71829   teddybear: 39253  
##  NA's  :451939   plate   : 59043   orange   : 36658  
##                  table   : 75854   (Other)  :212765  
##                  NA's    :451939   NA's     :451939  
##           trialType          trialType2     targetPos     distPos      
##  control_double:106347   control  :311798   L   :211975   L   :204440  
##  control_single:205451   inference:104617   R   :204440   R   :211975  
##  inference     :104617   NA's     :451939   NA's:451939   NA's:451939  
##  NA's          :451939                                                 
##                                                                        
##                                                                        
##                                                                        
##   targetOnset     keep_drop                      reason_drop    
##  Min.   :6        drop:     0   no_birth_date          :     0  
##  1st Qu.:6        keep:819443   no_consent             :     0  
##  Median :6        NA's: 48911   prior_exposure_to_study:     0  
##  Mean   :6                      side_bias              :     0  
##  3rd Qu.:6                      wrong_birth_date       :     0  
##  Max.   :7                      NA's                   :868354  
##  NA's   :451939                                                 
##  consent       consent.vid        dob         age_group        sex        
##  N   :     0   N   :163922   6/16/10: 40806   2    :227986   F   :476157  
##  Y   :819443   Y   :655521   9/28/11: 38053   3    :138527   M   :343286  
##  NA's: 48911   NA's: 48911   10/2/09: 37722   4    : 72287   NA's: 48911  
##                              9/22/11: 37690   5    : 31312                
##                              1/11/12: 37061   adult:349331                
##                              (Other):278780   NA's : 48911                
##                              NA's   :398242                               
##  hispanic_latino              Race           English      
##  N   :376651     american_indian: 31101   Min.   :4       
##  Y   : 93461     Asian          :     0   1st Qu.:5       
##  NA's:398242     other          : 62989   Median :5       
##                  white          :376022   Mean   :5       
##                  NA's           :398242   3rd Qu.:6       
##                                           Max.   :6       
##                                           NA's   :398242  
##      lang1             lang2         lang3                parent1_ed    
##  Spanish: 62688   Oriya   :     0   Mode:logical   4yr_college :162940  
##  ASL    : 37722   Romanian:     0   NA's:868354    graduate    :239010  
##  Russian: 34732   NA's    :868354                  some_college: 68162  
##  Turkish: 34565                                    NA's        :398242  
##  Arabic : 31402                                                         
##  (Other): 17324                                                         
##  NA's   :649921                                                         
##          parent2_ed     No_preemie   
##  4yr_college  :204422   N   : 37722  
##  graduate     :132023   Y   :432390  
##  high_school  : 31101   NA's:398242  
##  some_college : 71793                
##  some_graduate: 30773                
##  NA's         :398242                
## 
```


There is a weird default for the eye-tracker such that when you are not looking, the coordinates recorded is (0,1050). So let's get rid of these default coordinates, by making them into NA's.



```r
d$x[d$y == "1050" & d$x == "0"] <- NA
d$y[d$y == "1050"] <- NA
# make a column that shows whether NA (true) or not (false)
d$count.na <- is.na(d$x)

# remove those rows where column 'targetOnset' is NA (i.e., rows that are
# not showing test trials)
d <- subset(d, targetOnset != "NA")

## TRIAL REJECTION: reject trials that have NAs for over 30% of their samples
trial.nas <- ddply(d, c("subid", "stimulus", "count.na"), "nrow")
trial.nas <- reshape(trial.nas, timevar = "count.na", idvar = c("subid", "stimulus"), 
    direction = "wide")
names(trial.nas) <- c("subid", "stimulus", "false", "true")
head(trial.nas)
```

```
##               subid       stimulus false true
## 1  140217-02-L1.txt simpkidsL1.012  1145   46
## 3  140217-02-L1.txt simpkidsL1.015  1051   90
## 5  140217-02-L1.txt simpkidsL1.017  1007   42
## 7  140217-02-L1.txt simpkidsL1.020  1137   62
## 9  140217-02-L1.txt simpkidsL1.022   753  112
## 11 140217-02-L1.txt simpkidsL1.024   523  183
```

```r
# calculate the proportion of non-NA's over all
trial.nas$prop <- trial.nas$false/(trial.nas$true + trial.nas$false)
summary(trial.nas)
```

```
##               subid               stimulus       false           true     
##  140226-01-L2.txt: 24   simpkidsL1.012:  7   Min.   :   9   Min.   :   1  
##  140226-02-L1.txt: 24   simpkidsL1.015:  7   1st Qu.: 695   1st Qu.:  53  
##  140226-03-L1.txt: 24   simpkidsL1.017:  7   Median :1020   Median : 152  
##  140228-01-L1.txt: 24   simpkidsL1.020:  7   Mean   : 938   Mean   : 189  
##  140228-02-L2.txt: 24   simpkidsL1.022:  7   3rd Qu.:1143   3rd Qu.: 244  
##  140228-03-L2.txt: 24   simpkidsL1.024:  7   Max.   :2184   Max.   :1102  
##  (Other)         :243   (Other)       :345   NA's   :16     NA's   :25    
##       prop     
##  Min.   :0.03  
##  1st Qu.:0.72  
##  Median :0.88  
##  Mean   :0.80  
##  3rd Qu.:0.96  
##  Max.   :1.00  
##  NA's   :41
```

```r
reject.trials <- trial.nas[trial.nas$prop < 0.5, ]

# add a column in data that combines subid and stim (trial)
d$subtrial <- paste(d$subid, "_", d$stimulus, sep = "")
# reject trials
reject.trials$subtrial <- paste(reject.trials$subid, "_", reject.trials$stimulus, 
    sep = "")
print(reject.trials)
```

```
##                  subid            stimulus false true    prop
## 29    140217-02-L1.txt      simpkidsL1.046   207  286 0.41988
## NA                <NA>                <NA>    NA   NA      NA
## NA.1              <NA>                <NA>    NA   NA      NA
## NA.2              <NA>                <NA>    NA   NA      NA
## NA.3              <NA>                <NA>    NA   NA      NA
## NA.4              <NA>                <NA>    NA   NA      NA
## 116   140217-08-L1.txt      simpkidsL1.041   156  238 0.39594
## NA.5              <NA>                <NA>    NA   NA      NA
## NA.6              <NA>                <NA>    NA   NA      NA
## NA.7              <NA>                <NA>    NA   NA      NA
## 147   140220-01-L2.txt      simpkidsL2.043   393  410 0.48941
## NA.8              <NA>                <NA>    NA   NA      NA
## 206   140220-03-L2.txt      simpkidsL2.039   150  174 0.46296
## NA.9              <NA>                <NA>    NA   NA      NA
## 217   140220-04-L2.txt      simpkidsL2.015    55  249 0.18092
## 221   140220-04-L2.txt      simpkidsL2.020   284  345 0.45151
## NA.10             <NA>                <NA>    NA   NA      NA
## 226   140220-04-L2.txt      simpkidsL2.027    67  231 0.22483
## 228   140220-04-L2.txt      simpkidsL2.029   212  230 0.47964
## NA.11             <NA>                <NA>    NA   NA      NA
## NA.12             <NA>                <NA>    NA   NA      NA
## 232   140220-04-L2.txt      simpkidsL2.036    30   53 0.36145
## NA.13             <NA>                <NA>    NA   NA      NA
## 253   140220-05-L1.txt      simpkidsL1.036   244  335 0.42142
## 257   140220-05-L1.txt      simpkidsL1.041   231  318 0.42077
## 315   140226-02-L1.txt SIMPIMP_2AFC-L1.017   217  892 0.19567
## 319   140226-02-L1.txt SIMPIMP_2AFC-L1.021    61 1083 0.05332
## 321   140226-02-L1.txt SIMPIMP_2AFC-L1.024    76 1015 0.06966
## 323   140226-02-L1.txt SIMPIMP_2AFC-L1.026   186  900 0.17127
## 325   140226-02-L1.txt SIMPIMP_2AFC-L1.028   376  719 0.34338
## 327   140226-02-L1.txt SIMPIMP_2AFC-L1.030   415  680 0.37900
## 329   140226-02-L1.txt SIMPIMP_2AFC-L1.033   295  767 0.27778
## 331   140226-02-L1.txt SIMPIMP_2AFC-L1.035   442  603 0.42297
## 333   140226-02-L1.txt SIMPIMP_2AFC-L1.037   106 1019 0.09422
## 335   140226-02-L1.txt SIMPIMP_2AFC-L1.040   159  324 0.32919
## NA.14             <NA>                <NA>    NA   NA      NA
## 360   140226-03-L1.txt SIMPIMP_2AFC-L1.014   260  865 0.23111
## 362   140226-03-L1.txt SIMPIMP_2AFC-L1.017   475  587 0.44727
## 364   140226-03-L1.txt SIMPIMP_2AFC-L1.019    93  925 0.09136
## 366   140226-03-L1.txt SIMPIMP_2AFC-L1.021   272  849 0.24264
## 368   140226-03-L1.txt SIMPIMP_2AFC-L1.024   412  532 0.43644
## 372   140226-03-L1.txt SIMPIMP_2AFC-L1.028    42 1102 0.03671
## 374   140226-03-L1.txt SIMPIMP_2AFC-L1.030   246  908 0.21317
## 376   140226-03-L1.txt SIMPIMP_2AFC-L1.033   252  872 0.22420
## 378   140226-03-L1.txt SIMPIMP_2AFC-L1.035    97 1022 0.08668
## 402   140226-03-L1.txt SIMPIMP_2AFC-L1.063   248  381 0.39428
## 406   140226-03-L1.txt SIMPIMP_2AFC-L1.067   277  375 0.42485
## NA.15             <NA>                <NA>    NA   NA      NA
## NA.16             <NA>                <NA>    NA   NA      NA
## 456   140227-02-L1.txt      simpkidsL1.034   168  271 0.38269
## NA.17             <NA>                <NA>    NA   NA      NA
## 469   140227-03-L2.txt      simpkidsL2.012    60  219 0.21505
## NA.18             <NA>                <NA>    NA   NA      NA
## 480   140227-03-L2.txt      simpkidsL2.027   267  576 0.31673
## 486   140227-03-L2.txt      simpkidsL2.034   444  500 0.47034
## NA.19             <NA>                <NA>    NA   NA      NA
## 495   140227-03-L2.txt      simpkidsL2.046    45  449 0.09109
## 497   140227-03-L2.txt      simpkidsL2.048   219  288 0.43195
## NA.20             <NA>                <NA>    NA   NA      NA
## NA.21             <NA>                <NA>    NA   NA      NA
## 521   140227-04-L2.txt      simpkidsL2.041   285  476 0.37451
## NA.22             <NA>                <NA>    NA   NA      NA
## NA.23             <NA>                <NA>    NA   NA      NA
## NA.24             <NA>                <NA>    NA   NA      NA
## NA.25             <NA>                <NA>    NA   NA      NA
## NA.26             <NA>                <NA>    NA   NA      NA
## NA.27             <NA>                <NA>    NA   NA      NA
## NA.28             <NA>                <NA>    NA   NA      NA
## 542   140227-07-L2.txt      simpkidsL2.036     9  346 0.02535
## NA.29             <NA>                <NA>    NA   NA      NA
## NA.30             <NA>                <NA>    NA   NA      NA
## NA.31             <NA>                <NA>    NA   NA      NA
## NA.32             <NA>                <NA>    NA   NA      NA
## NA.33             <NA>                <NA>    NA   NA      NA
## NA.34             <NA>                <NA>    NA   NA      NA
## NA.35             <NA>                <NA>    NA   NA      NA
## NA.36             <NA>                <NA>    NA   NA      NA
## NA.37             <NA>                <NA>    NA   NA      NA
## NA.38             <NA>                <NA>    NA   NA      NA
## NA.39             <NA>                <NA>    NA   NA      NA
## NA.40             <NA>                <NA>    NA   NA      NA
##                                   subtrial
## 29         140217-02-L1.txt_simpkidsL1.046
## NA                                   NA_NA
## NA.1                                 NA_NA
## NA.2                                 NA_NA
## NA.3                                 NA_NA
## NA.4                                 NA_NA
## 116        140217-08-L1.txt_simpkidsL1.041
## NA.5                                 NA_NA
## NA.6                                 NA_NA
## NA.7                                 NA_NA
## 147        140220-01-L2.txt_simpkidsL2.043
## NA.8                                 NA_NA
## 206        140220-03-L2.txt_simpkidsL2.039
## NA.9                                 NA_NA
## 217        140220-04-L2.txt_simpkidsL2.015
## 221        140220-04-L2.txt_simpkidsL2.020
## NA.10                                NA_NA
## 226        140220-04-L2.txt_simpkidsL2.027
## 228        140220-04-L2.txt_simpkidsL2.029
## NA.11                                NA_NA
## NA.12                                NA_NA
## 232        140220-04-L2.txt_simpkidsL2.036
## NA.13                                NA_NA
## 253        140220-05-L1.txt_simpkidsL1.036
## 257        140220-05-L1.txt_simpkidsL1.041
## 315   140226-02-L1.txt_SIMPIMP_2AFC-L1.017
## 319   140226-02-L1.txt_SIMPIMP_2AFC-L1.021
## 321   140226-02-L1.txt_SIMPIMP_2AFC-L1.024
## 323   140226-02-L1.txt_SIMPIMP_2AFC-L1.026
## 325   140226-02-L1.txt_SIMPIMP_2AFC-L1.028
## 327   140226-02-L1.txt_SIMPIMP_2AFC-L1.030
## 329   140226-02-L1.txt_SIMPIMP_2AFC-L1.033
## 331   140226-02-L1.txt_SIMPIMP_2AFC-L1.035
## 333   140226-02-L1.txt_SIMPIMP_2AFC-L1.037
## 335   140226-02-L1.txt_SIMPIMP_2AFC-L1.040
## NA.14                                NA_NA
## 360   140226-03-L1.txt_SIMPIMP_2AFC-L1.014
## 362   140226-03-L1.txt_SIMPIMP_2AFC-L1.017
## 364   140226-03-L1.txt_SIMPIMP_2AFC-L1.019
## 366   140226-03-L1.txt_SIMPIMP_2AFC-L1.021
## 368   140226-03-L1.txt_SIMPIMP_2AFC-L1.024
## 372   140226-03-L1.txt_SIMPIMP_2AFC-L1.028
## 374   140226-03-L1.txt_SIMPIMP_2AFC-L1.030
## 376   140226-03-L1.txt_SIMPIMP_2AFC-L1.033
## 378   140226-03-L1.txt_SIMPIMP_2AFC-L1.035
## 402   140226-03-L1.txt_SIMPIMP_2AFC-L1.063
## 406   140226-03-L1.txt_SIMPIMP_2AFC-L1.067
## NA.15                                NA_NA
## NA.16                                NA_NA
## 456        140227-02-L1.txt_simpkidsL1.034
## NA.17                                NA_NA
## 469        140227-03-L2.txt_simpkidsL2.012
## NA.18                                NA_NA
## 480        140227-03-L2.txt_simpkidsL2.027
## 486        140227-03-L2.txt_simpkidsL2.034
## NA.19                                NA_NA
## 495        140227-03-L2.txt_simpkidsL2.046
## 497        140227-03-L2.txt_simpkidsL2.048
## NA.20                                NA_NA
## NA.21                                NA_NA
## 521        140227-04-L2.txt_simpkidsL2.041
## NA.22                                NA_NA
## NA.23                                NA_NA
## NA.24                                NA_NA
## NA.25                                NA_NA
## NA.26                                NA_NA
## NA.27                                NA_NA
## NA.28                                NA_NA
## 542        140227-07-L2.txt_simpkidsL2.036
## NA.29                                NA_NA
## NA.30                                NA_NA
## NA.31                                NA_NA
## NA.32                                NA_NA
## NA.33                                NA_NA
## NA.34                                NA_NA
## NA.35                                NA_NA
## NA.36                                NA_NA
## NA.37                                NA_NA
## NA.38                                NA_NA
## NA.39                                NA_NA
## NA.40                                NA_NA
```

```r
for (i in reject.trials$subtrial) {
    d <- d[d$subtrial != i, ]
}

## SUBJECT REJECTION: reject trials that have NAs for over 30% of their
## trials
subject.nas <- ddply(d, c("subid", "stimulus"), "nrow")
subject.nas2 <- ddply(subject.nas, "subid", "nrow")
print(subject.nas2)
```

```
##               subid nrow
## 1  140217-02-L1.txt   15
## 2  140217-04-L2.txt   16
## 3  140217-06-L1.txt   16
## 4  140217-08-L1.txt   15
## 5  140220-01-L2.txt   15
## 6  140220-02-L1.txt   16
## 7  140220-03-L2.txt   15
## 8  140220-04-L2.txt    6
## 9  140220-05-L1.txt   14
## 10 140226-01-L2.txt   24
## 11 140226-02-L1.txt   14
## 12 140226-03-L1.txt   13
## 13 140227-01-L1.txt   16
## 14 140227-02-L1.txt   15
## 15 140227-03-L2.txt   11
## 16 140227-04-L2.txt   15
## 17 140227-07-L2.txt   15
## 18 140228-01-L1.txt   24
## 19 140228-02-L2.txt   24
## 20 140228-03-L2.txt   24
## 21 140228-04-L1.txt   24
```

```r
## reject subjects that have less than 70% of the trials remaining (11 out of
## 16)
reject.subjects <- subject.nas2[subject.nas2$nrow < 8, ]
print(reject.subjects)
```

```
##              subid nrow
## 8 140220-04-L2.txt    6
```

```r
for (i in reject.subjects$subid) {
    d <- d[d$subid != i, ]
}

subj <- ddply(d, c("subid", "age_group"), "nrow")
subj2 <- ddply(subj, "age_group", "nrow")
subj2
```

```
##   age_group nrow
## 1         2    6
## 2         3    4
## 3         4    2
## 4         5    1
## 5     adult    6
## 6      <NA>    1
```


NOTE: weirdly, the subject that I thought did great(140220-02) was dropped (only 10 good trials) maybe worth changing the criteria at this point?

### SANITY CHECK
Now let's do some sanity check.
Open up the file simpimp_sanitycheck.R, and run the preliminary codes again.

First let's look at the distribution of data:

```r
# do histograms of the data for x and y coordinates
hist(d$x)
```

![plot of chunk unnamed-chunk-11](figure/unnamed-chunk-111.png) 

```r
hist(d$y)
```

![plot of chunk unnamed-chunk-11](figure/unnamed-chunk-112.png) 


First histogram shows tha distribution of eye gaze across x coordinates. 

(Note: dimensions of the eye-tracker screen are 1680 x 1050, check if the numbers on the histogram make sense based on those numbers!)

Below are some alternative ways to visualize the distribution, separating by subjects:


```r
# break down by subject
qplot(x, facets = ~subid, geom = "histogram", data = d)
```

```
## stat_bin: binwidth defaulted to range/30. Use 'binwidth = x' to adjust
## this. stat_bin: binwidth defaulted to range/30. Use 'binwidth = x' to
## adjust this. stat_bin: binwidth defaulted to range/30. Use 'binwidth = x'
## to adjust this. stat_bin: binwidth defaulted to range/30. Use 'binwidth =
## x' to adjust this. stat_bin: binwidth defaulted to range/30. Use 'binwidth
## = x' to adjust this. stat_bin: binwidth defaulted to range/30. Use
## 'binwidth = x' to adjust this. stat_bin: binwidth defaulted to range/30.
## Use 'binwidth = x' to adjust this. stat_bin: binwidth defaulted to
## range/30. Use 'binwidth = x' to adjust this. stat_bin: binwidth defaulted
## to range/30. Use 'binwidth = x' to adjust this. stat_bin: binwidth
## defaulted to range/30. Use 'binwidth = x' to adjust this. stat_bin:
## binwidth defaulted to range/30. Use 'binwidth = x' to adjust this.
## stat_bin: binwidth defaulted to range/30. Use 'binwidth = x' to adjust
## this. stat_bin: binwidth defaulted to range/30. Use 'binwidth = x' to
## adjust this. stat_bin: binwidth defaulted to range/30. Use 'binwidth = x'
## to adjust this. stat_bin: binwidth defaulted to range/30. Use 'binwidth =
## x' to adjust this. stat_bin: binwidth defaulted to range/30. Use 'binwidth
## = x' to adjust this. stat_bin: binwidth defaulted to range/30. Use
## 'binwidth = x' to adjust this. stat_bin: binwidth defaulted to range/30.
## Use 'binwidth = x' to adjust this. stat_bin: binwidth defaulted to
## range/30. Use 'binwidth = x' to adjust this. stat_bin: binwidth defaulted
## to range/30. Use 'binwidth = x' to adjust this.
```

![plot of chunk unnamed-chunk-12](figure/unnamed-chunk-121.png) 

```r
qplot(y, facets = ~subid, geom = "histogram", data = d)
```

```
## stat_bin: binwidth defaulted to range/30. Use 'binwidth = x' to adjust
## this. stat_bin: binwidth defaulted to range/30. Use 'binwidth = x' to
## adjust this. stat_bin: binwidth defaulted to range/30. Use 'binwidth = x'
## to adjust this. stat_bin: binwidth defaulted to range/30. Use 'binwidth =
## x' to adjust this. stat_bin: binwidth defaulted to range/30. Use 'binwidth
## = x' to adjust this. stat_bin: binwidth defaulted to range/30. Use
## 'binwidth = x' to adjust this. stat_bin: binwidth defaulted to range/30.
## Use 'binwidth = x' to adjust this. stat_bin: binwidth defaulted to
## range/30. Use 'binwidth = x' to adjust this. stat_bin: binwidth defaulted
## to range/30. Use 'binwidth = x' to adjust this. stat_bin: binwidth
## defaulted to range/30. Use 'binwidth = x' to adjust this. stat_bin:
## binwidth defaulted to range/30. Use 'binwidth = x' to adjust this.
## stat_bin: binwidth defaulted to range/30. Use 'binwidth = x' to adjust
## this. stat_bin: binwidth defaulted to range/30. Use 'binwidth = x' to
## adjust this. stat_bin: binwidth defaulted to range/30. Use 'binwidth = x'
## to adjust this. stat_bin: binwidth defaulted to range/30. Use 'binwidth =
## x' to adjust this. stat_bin: binwidth defaulted to range/30. Use 'binwidth
## = x' to adjust this. stat_bin: binwidth defaulted to range/30. Use
## 'binwidth = x' to adjust this. stat_bin: binwidth defaulted to range/30.
## Use 'binwidth = x' to adjust this. stat_bin: binwidth defaulted to
## range/30. Use 'binwidth = x' to adjust this. stat_bin: binwidth defaulted
## to range/30. Use 'binwidth = x' to adjust this.
```

![plot of chunk unnamed-chunk-12](figure/unnamed-chunk-122.png) 


Next, we check the location of fixations. Here we'll visualize how the gazes looked on the screen:


```r
qplot(x, y, data = d, facets = ~subid)
```

```
## Warning: Removed 1897 rows containing missing values (geom_point).
## Warning: Removed 1575 rows containing missing values (geom_point).
## Warning: Removed 2857 rows containing missing values (geom_point).
## Warning: Removed 2958 rows containing missing values (geom_point).
## Warning: Removed 918 rows containing missing values (geom_point). Warning:
## Removed 5157 rows containing missing values (geom_point). Warning: Removed
## 2622 rows containing missing values (geom_point). Warning: Removed 2482
## rows containing missing values (geom_point). Warning: Removed 4598 rows
## containing missing values (geom_point). Warning: Removed 3433 rows
## containing missing values (geom_point). Warning: Removed 3951 rows
## containing missing values (geom_point). Warning: Removed 943 rows
## containing missing values (geom_point). Warning: Removed 1701 rows
## containing missing values (geom_point). Warning: Removed 2701 rows
## containing missing values (geom_point). Warning: Removed 1885 rows
## containing missing values (geom_point). Warning: Removed 2764 rows
## containing missing values (geom_point). Warning: Removed 643 rows
## containing missing values (geom_point). Warning: Removed 559 rows
## containing missing values (geom_point). Warning: Removed 1547 rows
## containing missing values (geom_point). Warning: Removed 6051 rows
## containing missing values (geom_point).
```

![plot of chunk unnamed-chunk-13](figure/unnamed-chunk-13.png) 


The cool graph below helps us visualize the main regions where the gazes fell. 


```r
qplot(x, y, geom = "density2d", data = d, xlim = c(0, 1680), ylim = c(0, 1050), 
    facets = ~subid)
```

```
## Warning: Removed 1897 rows containing non-finite values (stat_density2d).
## Warning: Removed 1575 rows containing non-finite values (stat_density2d).
## Warning: Removed 2857 rows containing non-finite values (stat_density2d).
## Warning: Removed 2958 rows containing non-finite values (stat_density2d).
## Warning: Removed 918 rows containing non-finite values (stat_density2d).
## Warning: Removed 5157 rows containing non-finite values (stat_density2d).
## Warning: Removed 2622 rows containing non-finite values (stat_density2d).
## Warning: Removed 2482 rows containing non-finite values (stat_density2d).
## Warning: Removed 4598 rows containing non-finite values (stat_density2d).
## Warning: Removed 3433 rows containing non-finite values (stat_density2d).
## Warning: Removed 3951 rows containing non-finite values (stat_density2d).
## Warning: Removed 943 rows containing non-finite values (stat_density2d).
## Warning: Removed 1701 rows containing non-finite values (stat_density2d).
## Warning: Removed 2701 rows containing non-finite values (stat_density2d).
## Warning: Removed 1885 rows containing non-finite values (stat_density2d).
## Warning: Removed 2764 rows containing non-finite values (stat_density2d).
## Warning: Removed 643 rows containing non-finite values (stat_density2d).
## Warning: Removed 559 rows containing non-finite values (stat_density2d).
## Warning: Removed 1547 rows containing non-finite values (stat_density2d).
## Warning: Removed 6051 rows containing non-finite values (stat_density2d).
```

![plot of chunk unnamed-chunk-14](figure/unnamed-chunk-14.png) 


### DATA ANALYSES

Now we're ready for the fun part: data analyses!
Again, run the prelim codes for sourcing scripts.

***PRELIMINARIES***
***1. Read in the orders and merge them with the data***
NOTE: I've now moved this step to the beginning of the sanity check part, since I need to take into account what trials are the ones that count

***2. Define the target ROIs (regions of interest)***

At this stage, we define the regions of interest, which are the regions upon which the gazes fell that we care about. 


```r
rois <- list()
rois[[1]] <- c(0, 250, 840, 650)  # left
rois[[2]] <- c(840, 250, 840, 650)  # right
names(rois) <- c("L", "R")
roi.image(rois)
```

![plot of chunk unnamed-chunk-15](figure/unnamed-chunk-15.png) 


We are using the function 'roi.image' that was specified in our helper file et_helper.R. 


```r
# use check code to make sure that ROIs look right
d$roi <- roi.check(d, rois)

# see how the distribution of ROIs looks
qplot(roi, data = d)
```

![plot of chunk unnamed-chunk-16](figure/unnamed-chunk-16.png) 


Why the left bias?


```r
LR <- ddply(d, c("subid", "roi", "trialType"), "nrow")
LR <- reshape(LR, timevar = "roi", idvar = c("subid", "trialType"), direction = "wide")
```

```
## Warning: there are records with missing times, which will be dropped.
```

```r
names(LR) <- c("subid", "trial", "leftLook", "rightLook")
# calculate the proportion of non-NA's over all
LR$prop <- LR$leftLook/(LR$leftLook + LR$rightLook)
print(LR)
```

```
##                subid          trial leftLook rightLook   NA   prop
## 1   140217-02-L1.txt control_double     2123      1833  472 0.5367
## 2   140217-02-L1.txt control_single     2901      3251 1341 0.4716
## 3   140217-02-L1.txt      inference     1365      1103  478 0.5531
## 10  140217-04-L2.txt control_double     3116      1275  402 0.7096
## 11  140217-04-L2.txt control_single     6248      2501  793 0.7141
## 12  140217-04-L2.txt      inference     2762      1452  581 0.6554
## 19  140217-06-L1.txt control_double     1021      1549  763 0.3973
## 20  140217-06-L1.txt control_single     1747      2571 1759 0.4046
## 21  140217-06-L1.txt      inference     1238      1572  594 0.4406
## 28  140217-08-L1.txt control_double     1163      1523  934 0.4330
## 29  140217-08-L1.txt control_single     2247      2902 1226 0.4364
## 30  140217-08-L1.txt      inference      895      1057  978 0.4585
## 37  140220-01-L2.txt control_double     1825      1643   90 0.5262
## 38  140220-01-L2.txt control_single     3356      4157  992 0.4467
## 39  140220-01-L2.txt      inference     2274      2120  209 0.5175
## 46  140220-02-L1.txt control_double     1113      1755 1788 0.3881
## 47  140220-02-L1.txt control_single     2310      2719 4154 0.4593
## 48  140220-02-L1.txt      inference      763       451 3069 0.6285
## 55  140220-03-L2.txt control_double     1211      1590  898 0.4323
## 56  140220-03-L2.txt control_single     2860      2678 1557 0.5164
## 57  140220-03-L2.txt      inference     1178       904  427 0.5658
## 64  140220-05-L1.txt control_double     1648      1701  734 0.4921
## 65  140220-05-L1.txt control_single     1682      2329 1190 0.4193
## 66  140220-05-L1.txt      inference     1136      1539  904 0.4247
## 73  140226-01-L2.txt control_double     5346      5586 2704 0.4890
## 74  140226-01-L2.txt control_single    12094      9742 5096 0.5539
## 75  140226-01-L2.txt      inference     6152      4652 2638 0.5694
## 82  140226-02-L1.txt control_double     1393      1136 1528 0.5508
## 83  140226-02-L1.txt control_single     1567      2295 2610 0.4057
## 84  140226-02-L1.txt      inference      770      1806  684 0.2989
## 91  140226-03-L1.txt control_double      769       836  613 0.4791
## 92  140226-03-L1.txt control_single     1438      2170 3294 0.3986
## 93  140226-03-L1.txt      inference     1262      1689 1360 0.4277
## 100 140227-01-L1.txt control_double     3217      1392  150 0.6980
## 101 140227-01-L1.txt control_single     4804      4060  439 0.5420
## 102 140227-01-L1.txt      inference     2751      1516  495 0.6447
## 109 140227-02-L1.txt control_double     1739      2488  496 0.4114
## 110 140227-02-L1.txt control_single     2969      3228 1179 0.4791
## 111 140227-02-L1.txt      inference     2169      2282  322 0.4873
## 118 140227-03-L2.txt control_double      780       779 1048 0.5003
## 119 140227-03-L2.txt control_single     1218      1183 1130 0.5073
## 120 140227-03-L2.txt      inference      668       783  908 0.4604
## 127 140227-04-L2.txt control_double     2429      1049  489 0.6984
## 128 140227-04-L2.txt control_single     3330      2834 1116 0.5402
## 129 140227-04-L2.txt      inference     2165      1448  404 0.5992
## 136 140227-07-L2.txt control_double     1119       721  973 0.6082
## 137 140227-07-L2.txt control_single     1706      2806 1314 0.3781
## 138 140227-07-L2.txt      inference     1396      1773  928 0.4405
## 145 140228-01-L1.txt control_double     3718      2752  199 0.5747
## 146 140228-01-L1.txt control_single     6375      6578  377 0.4922
## 147 140228-01-L1.txt      inference     3368      3277  106 0.5068
## 154 140228-02-L2.txt control_double     3430      3048  248 0.5295
## 155 140228-02-L2.txt control_single     7832      5137  792 0.6039
## 156 140228-02-L2.txt      inference     2787      3101  987 0.4733
## 163 140228-03-L2.txt control_double     3411      2850  392 0.5448
## 164 140228-03-L2.txt control_single     6787      5452  956 0.5545
## 165 140228-03-L2.txt      inference     3254      3016  395 0.5190
## 172 140228-04-L1.txt control_double     3233      1967 1768 0.6217
## 173 140228-04-L1.txt control_single     5038      4068 4491 0.5533
## 174 140228-04-L1.txt      inference     3154      2307 1541 0.5775
```


Seems like one subject has a strong left bias. Should be worried?


```r
# set up correctness
d$correct <- d$roi == d$targetPos
```


Here we are saying that if the ROI fell in the region where the target item is positioned, then the column 'correct' will reflect this.



```r
# another way to organize by ROI's: set up three possible regions
d$target <- ifelse(d$roi == d$targetPos, "1", "0")
d$dist <- ifelse(d$roi == d$distPos, "1", "0")
```


***3. Align trials to the onset of the critical word***

Here we "create timestamps starting from the point of disambiguation".


```r
d <- rezero.trials(d)  # specified in et_helper.R
```


***4. subsample the data so that you get smooth curves***

From Mike: I like to do this when I don't have much data so that I'm not distracted by the variation in the data, but then relax the subsampling if I have more data.


```r
subsample.hz <- 5  # 10 hz is decent, eventually we should set to 30 or 60 hz
d$t.crit.binned <- round(d$t.crit * subsample.hz)/subsample.hz  # subsample step
```


***ANALYSES***

From Mike:every analysis has two parts: an aggregation step and a plotting step
- aggregation averages over some kind of unit of interest, e.g. trial type
- and then plotting is making a picture relative to that aggregation

***1. TRIAL TYPE ANALYSIS***

```r
## 1a. overall
ms <- aggregate(correct ~ t.crit.binned + trialType, d, mean)

qplot(t.crit.binned, correct, colour = trialType, geom = "line", data = ms) + 
    geom_hline(yintercept = 0.5, lty = 4) + geom_vline(xintercept = 0, lty = 3) + 
    xlab("Time (s)") + ylab("Proportion correct looking") + scale_x_continuous(limits = c(-4, 
    4), expand = c(0, 0)) + scale_y_continuous(limits = c(0, 1), expand = c(0, 
    0))  # make the axes start at 0
```

```
## Warning: Removed 41 rows containing missing values (geom_path).
```

![plot of chunk unnamed-chunk-22](figure/unnamed-chunk-221.png) 

```r

## 1aa. overall: just inference vs. control distinction
ms <- aggregate(correct ~ t.crit.binned + trialType2, d, mean)

qplot(t.crit.binned, correct, colour = trialType2, geom = "line", data = ms) + 
    geom_hline(yintercept = 0.5, lty = 4) + geom_vline(xintercept = 0, lty = 3) + 
    xlab("Time (s)") + ylab("Proportion correct looking") + scale_x_continuous(limits = c(-4, 
    4), expand = c(0, 0)) + scale_y_continuous(limits = c(0, 1), expand = c(0, 
    0))  # make the axes start at 0
```

```
## Warning: Removed 27 rows containing missing values (geom_path).
```

![plot of chunk unnamed-chunk-22](figure/unnamed-chunk-222.png) 

```r

## 1a+ add error bars with 95% CI
mss <- aggregate(correct ~ t.crit.binned + trialType2 + subid, d, mean)
ms <- aggregate(correct ~ t.crit.binned + trialType2, mss, mean)
ms$cih <- aggregate(correct ~ t.crit.binned + trialType2, mss, ci.high)$correct
ms$cil <- aggregate(correct ~ t.crit.binned + trialType2, mss, ci.low)$correct

qplot(t.crit.binned, correct, colour = trialType2, geom = "line", data = ms) + 
    geom_pointrange(aes(ymin = correct - cil, ymax = correct + cih), position = position_dodge(0.05)) + 
    geom_hline(yintercept = 0.5, lty = 4) + geom_vline(xintercept = 0, lty = 3) + 
    xlab("Time (s)") + ylab("Proportion correct looking") + scale_x_continuous(limits = c(-4, 
    3), expand = c(0, 0)) + scale_y_continuous(limits = c(0, 1), expand = c(0, 
    0))  # make the axes start at 0
```

```
## Warning: Removed 36 rows containing missing values (geom_path). Warning:
## Removed 20 rows containing missing values (geom_segment). Warning: Removed
## 20 rows containing missing values (geom_point). Warning: Removed 18 rows
## containing missing values (geom_segment). Warning: Removed 18 rows
## containing missing values (geom_point).
```

![plot of chunk unnamed-chunk-22](figure/unnamed-chunk-223.png) 

```r

## loess
ms <- aggregate(correct ~ t.crit.binned + trialType, d, mean)

qplot(t.crit.binned, correct, colour = trialType, geom = "point", data = ms) + 
    geom_hline(yintercept = 0.5, lty = 4) + geom_vline(xintercept = 0, lty = 3) + 
    geom_smooth(method = "loess", span = 0.5) + xlab("Time (s)") + ylab("Proportion correct looking") + 
    scale_x_continuous(limits = c(-2, 4), expand = c(0, 0)) + scale_y_continuous(limits = c(0, 
    1), expand = c(0, 0))
```

```
## Warning: Removed 24 rows containing missing values (stat_smooth). Warning:
## Removed 24 rows containing missing values (stat_smooth). Warning: Removed
## 23 rows containing missing values (stat_smooth). Warning: Removed 71 rows
## containing missing values (geom_point).
```

![plot of chunk unnamed-chunk-22](figure/unnamed-chunk-224.png) 


Now let's try to make a graph that shows both possible eye-gaze locations: target and distractor. 


```r
## gaze at target vs. distractor
subsample.hz <- 5  # 10 hz is decent, eventually we should set to 30 or 60 hz
d$t.crit.binned <- round(d$t.crit * subsample.hz)/subsample.hz  # subsample step

melted = melt(d, id = c("t.crit.binned", "trialType2"), measure = c("target", 
    "dist"), value.name = "Looks", variable.name = "Region")
melted$value = to.n(melted$value)

ms <- aggregate(value ~ variable + t.crit.binned + trialType2, melted, mean)

qplot(t.crit.binned, value, colour = trialType2, linetype = variable, geom = "line", 
    data = ms) + geom_hline(yintercept = 0.5, lty = 4) + geom_vline(xintercept = 0, 
    lty = 3) + xlab("Time (s)") + ylab("Proportion Looking") + scale_x_continuous(limits = c(-4, 
    3), expand = c(0, 0)) + scale_y_continuous(limits = c(0, 1), expand = c(0, 
    0))  # make the axes start at 0
```

```
## Warning: Removed 72 rows containing missing values (geom_path).
```

![plot of chunk unnamed-chunk-23](figure/unnamed-chunk-23.png) 


Splitting by target location:


```r
## 1e. target positions
ms <- aggregate(correct ~ t.crit.binned + trialType + targetPos, d, mean)

qplot(t.crit.binned, correct, colour = trialType, geom = "point", data = ms) + 
    facet_grid(. ~ targetPos) + geom_hline(yintercept = 0.5, lty = 4) + geom_vline(xintercept = 0, 
    lty = 3) + geom_smooth() + xlab("Time (s)") + ylab("Proportion correct looking") + 
    scale_x_continuous(limits = c(-3, 3), expand = c(0, 0)) + scale_y_continuous(limits = c(0, 
    1), expand = c(0, 0))  # make the axes start at 0
```

```
## geom_smooth: method="auto" and size of largest group is <1000, so using
## loess. Use 'method = x' to change the smoothing method.
```

```
## Warning: Removed 22 rows containing missing values (stat_smooth). Warning:
## Removed 23 rows containing missing values (stat_smooth). Warning: Removed
## 22 rows containing missing values (stat_smooth).
```

```
## geom_smooth: method="auto" and size of largest group is <1000, so using
## loess. Use 'method = x' to change the smoothing method.
```

```
## Warning: Removed 23 rows containing missing values (stat_smooth). Warning:
## Removed 23 rows containing missing values (stat_smooth). Warning: Removed
## 22 rows containing missing values (stat_smooth). Warning: Removed 67 rows
## containing missing values (geom_point). Warning: Removed 68 rows
## containing missing values (geom_point).
```

![plot of chunk unnamed-chunk-24](figure/unnamed-chunk-24.png) 


Then we see how each partcipant performed:


```r
## 1b. by participant
ms <- aggregate(correct ~ t.crit.binned + trialType + subid, d, mean)

qplot(t.crit.binned, correct, colour = trialType, geom = "point", data = ms) + 
    facet_wrap(~subid) + geom_hline(yintercept = 0.5, lty = 4) + geom_vline(xintercept = 0, 
    lty = 3) + geom_smooth() + xlab("Time (s)") + ylab("Proportion correct looking") + 
    scale_x_continuous(limits = c(-4, 5), expand = c(0, 0)) + scale_y_continuous(limits = c(0, 
    1), expand = c(0, 0))  # make the axes start at 0
```

```
## geom_smooth: method="auto" and size of largest group is <1000, so using
## loess. Use 'method = x' to change the smoothing method.
```

```
## Warning: Removed 13 rows containing missing values (stat_smooth). Warning:
## Removed 11 rows containing missing values (stat_smooth). Warning: Removed
## 12 rows containing missing values (stat_smooth).
```

```
## geom_smooth: method="auto" and size of largest group is <1000, so using
## loess. Use 'method = x' to change the smoothing method.
```

```
## Warning: Removed 13 rows containing missing values (stat_smooth). Warning:
## Removed 14 rows containing missing values (stat_smooth). Warning: Removed
## 13 rows containing missing values (stat_smooth).
```

```
## geom_smooth: method="auto" and size of largest group is <1000, so using
## loess. Use 'method = x' to change the smoothing method.
```

```
## Warning: Removed 14 rows containing missing values (stat_smooth). Warning:
## Removed 13 rows containing missing values (stat_smooth). Warning: Removed
## 12 rows containing missing values (stat_smooth).
```

```
## geom_smooth: method="auto" and size of largest group is <1000, so using
## loess. Use 'method = x' to change the smoothing method.
```

```
## Warning: Removed 14 rows containing missing values (stat_smooth). Warning:
## Removed 13 rows containing missing values (stat_smooth). Warning: Removed
## 12 rows containing missing values (stat_smooth).
```

```
## geom_smooth: method="auto" and size of largest group is <1000, so using
## loess. Use 'method = x' to change the smoothing method.
```

```
## Warning: Removed 13 rows containing missing values (stat_smooth). Warning:
## Removed 14 rows containing missing values (stat_smooth). Warning: Removed
## 13 rows containing missing values (stat_smooth).
```

```
## geom_smooth: method="auto" and size of largest group is <1000, so using
## loess. Use 'method = x' to change the smoothing method.
```

```
## Warning: Removed 14 rows containing missing values (stat_smooth). Warning:
## Removed 13 rows containing missing values (stat_smooth). Warning: Removed
## 12 rows containing missing values (stat_smooth).
```

```
## geom_smooth: method="auto" and size of largest group is <1000, so using
## loess. Use 'method = x' to change the smoothing method.
```

```
## Warning: Removed 13 rows containing missing values (stat_smooth). Warning:
## Removed 14 rows containing missing values (stat_smooth). Warning: Removed
## 13 rows containing missing values (stat_smooth).
```

```
## geom_smooth: method="auto" and size of largest group is <1000, so using
## loess. Use 'method = x' to change the smoothing method.
```

```
## Warning: Removed 13 rows containing missing values (stat_smooth). Warning:
## Removed 13 rows containing missing values (stat_smooth). Warning: Removed
## 12 rows containing missing values (stat_smooth).
```

```
## geom_smooth: method="auto" and size of largest group is <1000, so using
## loess. Use 'method = x' to change the smoothing method.
```

```
## Warning: Removed 13 rows containing missing values (stat_smooth). Warning:
## Removed 14 rows containing missing values (stat_smooth). Warning: Removed
## 13 rows containing missing values (stat_smooth).
```

```
## geom_smooth: method="auto" and size of largest group is <1000, so using
## loess. Use 'method = x' to change the smoothing method.
```

```
## Warning: Removed 13 rows containing missing values (stat_smooth). Warning:
## Removed 13 rows containing missing values (stat_smooth). Warning: Removed
## 12 rows containing missing values (stat_smooth).
```

```
## geom_smooth: method="auto" and size of largest group is <1000, so using
## loess. Use 'method = x' to change the smoothing method.
```

```
## Warning: Removed 14 rows containing missing values (stat_smooth). Warning:
## Removed 13 rows containing missing values (stat_smooth). Warning: Removed
## 12 rows containing missing values (stat_smooth).
```

```
## geom_smooth: method="auto" and size of largest group is <1000, so using
## loess. Use 'method = x' to change the smoothing method.
```

```
## Warning: Removed 14 rows containing missing values (stat_smooth). Warning:
## Removed 13 rows containing missing values (stat_smooth). Warning: Removed
## 12 rows containing missing values (stat_smooth).
```

```
## geom_smooth: method="auto" and size of largest group is <1000, so using
## loess. Use 'method = x' to change the smoothing method.
```

```
## Warning: Removed 14 rows containing missing values (stat_smooth). Warning:
## Removed 13 rows containing missing values (stat_smooth). Warning: Removed
## 12 rows containing missing values (stat_smooth).
```

```
## geom_smooth: method="auto" and size of largest group is <1000, so using
## loess. Use 'method = x' to change the smoothing method.
```

```
## Warning: Removed 11 rows containing missing values (stat_smooth). Warning:
## Removed 12 rows containing missing values (stat_smooth). Warning: Removed
## 11 rows containing missing values (stat_smooth).
```

```
## geom_smooth: method="auto" and size of largest group is <1000, so using
## loess. Use 'method = x' to change the smoothing method.
```

```
## Warning: Removed 13 rows containing missing values (stat_smooth). Warning:
## Removed 14 rows containing missing values (stat_smooth). Warning: Removed
## 13 rows containing missing values (stat_smooth).
```

```
## geom_smooth: method="auto" and size of largest group is <1000, so using
## loess. Use 'method = x' to change the smoothing method.
```

```
## Warning: Removed 13 rows containing missing values (stat_smooth). Warning:
## Removed 14 rows containing missing values (stat_smooth). Warning: Removed
## 13 rows containing missing values (stat_smooth).
```

```
## geom_smooth: method="auto" and size of largest group is <1000, so using
## loess. Use 'method = x' to change the smoothing method.
```

```
## Warning: Removed 14 rows containing missing values (stat_smooth). Warning:
## Removed 13 rows containing missing values (stat_smooth). Warning: Removed
## 12 rows containing missing values (stat_smooth).
```

```
## geom_smooth: method="auto" and size of largest group is <1000, so using
## loess. Use 'method = x' to change the smoothing method.
```

```
## Warning: Removed 13 rows containing missing values (stat_smooth). Warning:
## Removed 14 rows containing missing values (stat_smooth). Warning: Removed
## 13 rows containing missing values (stat_smooth).
```

```
## geom_smooth: method="auto" and size of largest group is <1000, so using
## loess. Use 'method = x' to change the smoothing method.
```

```
## Warning: Removed 13 rows containing missing values (stat_smooth). Warning:
## Removed 14 rows containing missing values (stat_smooth). Warning: Removed
## 13 rows containing missing values (stat_smooth).
```

```
## geom_smooth: method="auto" and size of largest group is <1000, so using
## loess. Use 'method = x' to change the smoothing method.
```

```
## Warning: Removed 13 rows containing missing values (stat_smooth). Warning:
## Removed 13 rows containing missing values (stat_smooth). Warning: Removed
## 12 rows containing missing values (stat_smooth). Warning: Removed 36 rows
## containing missing values (geom_point). Warning: Removed 40 rows
## containing missing values (geom_point). Warning: Removed 39 rows
## containing missing values (geom_point). Warning: Removed 39 rows
## containing missing values (geom_point). Warning: Removed 40 rows
## containing missing values (geom_point). Warning: Removed 39 rows
## containing missing values (geom_point). Warning: Removed 40 rows
## containing missing values (geom_point). Warning: Removed 38 rows
## containing missing values (geom_point). Warning: Removed 40 rows
## containing missing values (geom_point). Warning: Removed 38 rows
## containing missing values (geom_point). Warning: Removed 39 rows
## containing missing values (geom_point). Warning: Removed 39 rows
## containing missing values (geom_point). Warning: Removed 39 rows
## containing missing values (geom_point). Warning: Removed 34 rows
## containing missing values (geom_point). Warning: Removed 40 rows
## containing missing values (geom_point). Warning: Removed 40 rows
## containing missing values (geom_point). Warning: Removed 39 rows
## containing missing values (geom_point). Warning: Removed 40 rows
## containing missing values (geom_point). Warning: Removed 40 rows
## containing missing values (geom_point). Warning: Removed 38 rows
## containing missing values (geom_point). Warning: Removed 4 rows containing
## missing values (geom_path). Warning: Removed 4 rows containing missing
## values (geom_path). Warning: Removed 4 rows containing missing values
## (geom_path). Warning: Removed 2 rows containing missing values
## (geom_path). Warning: Removed 3 rows containing missing values
## (geom_path). Warning: Removed 1 rows containing missing values
## (geom_path). Warning: Removed 1 rows containing missing values
## (geom_path). Warning: Removed 1 rows containing missing values
## (geom_path). Warning: Removed 1 rows containing missing values
## (geom_path). Warning: Removed 2 rows containing missing values
## (geom_path). Warning: Removed 6 rows containing missing values
## (geom_path). Warning: Removed 2 rows containing missing values
## (geom_path). Warning: Removed 6 rows containing missing values
## (geom_path). Warning: Removed 2 rows containing missing values
## (geom_path). Warning: Removed 4 rows containing missing values
## (geom_path). Warning: Removed 4 rows containing missing values
## (geom_path).
```

![plot of chunk unnamed-chunk-25](figure/unnamed-chunk-25.png) 


By age:


```r
## 1c. age loess
ms <- aggregate(correct ~ t.crit.binned + trialType + age_group, d, mean)

qplot(t.crit.binned, correct, colour = trialType, geom = "point", data = ms) + 
    facet_wrap(~age_group) + geom_hline(yintercept = 0.5, lty = 4) + geom_vline(xintercept = 0, 
    lty = 3) + geom_smooth() + xlab("Time (s)") + ylab("Proportion correct looking") + 
    scale_x_continuous(limits = c(-4, 5), expand = c(0, 0)) + scale_y_continuous(limits = c(0, 
    1), expand = c(0, 0))  # make the axes start at 0
```

```
## geom_smooth: method="auto" and size of largest group is <1000, so using
## loess. Use 'method = x' to change the smoothing method.
```

```
## Warning: Removed 14 rows containing missing values (stat_smooth). Warning:
## Removed 14 rows containing missing values (stat_smooth). Warning: Removed
## 13 rows containing missing values (stat_smooth).
```

```
## geom_smooth: method="auto" and size of largest group is <1000, so using
## loess. Use 'method = x' to change the smoothing method.
```

```
## Warning: Removed 14 rows containing missing values (stat_smooth). Warning:
## Removed 13 rows containing missing values (stat_smooth). Warning: Removed
## 12 rows containing missing values (stat_smooth).
```

```
## geom_smooth: method="auto" and size of largest group is <1000, so using
## loess. Use 'method = x' to change the smoothing method.
```

```
## Warning: Removed 13 rows containing missing values (stat_smooth). Warning:
## Removed 14 rows containing missing values (stat_smooth). Warning: Removed
## 13 rows containing missing values (stat_smooth).
```

```
## geom_smooth: method="auto" and size of largest group is <1000, so using
## loess. Use 'method = x' to change the smoothing method.
```

```
## Warning: Removed 13 rows containing missing values (stat_smooth). Warning:
## Removed 14 rows containing missing values (stat_smooth). Warning: Removed
## 13 rows containing missing values (stat_smooth).
```

```
## geom_smooth: method="auto" and size of largest group is <1000, so using
## loess. Use 'method = x' to change the smoothing method.
```

```
## Warning: Removed 14 rows containing missing values (stat_smooth). Warning:
## Removed 14 rows containing missing values (stat_smooth). Warning: Removed
## 13 rows containing missing values (stat_smooth). Warning: Removed 41 rows
## containing missing values (geom_point). Warning: Removed 39 rows
## containing missing values (geom_point). Warning: Removed 40 rows
## containing missing values (geom_point). Warning: Removed 40 rows
## containing missing values (geom_point). Warning: Removed 41 rows
## containing missing values (geom_point). Warning: Removed 1 rows containing
## missing values (geom_path).
```

![plot of chunk unnamed-chunk-26](figure/unnamed-chunk-26.png) 


Order effect?


```r
## 1d. order
ms <- aggregate(correct ~ t.crit.binned + trialType + order + age_group, d, 
    mean)

qplot(t.crit.binned, correct, colour = trialType, geom = "point", data = ms) + 
    facet_wrap(age_group ~ order) + geom_hline(yintercept = 0.5, lty = 4) + 
    geom_vline(xintercept = 0, lty = 3) + geom_smooth() + xlab("Time (s)") + 
    ylab("Proportion correct looking") + scale_x_continuous(limits = c(-4, 5), 
    expand = c(0, 0)) + scale_y_continuous(limits = c(0, 1), expand = c(0, 0))  # make the axes start at 0
```

```
## geom_smooth: method="auto" and size of largest group is <1000, so using
## loess. Use 'method = x' to change the smoothing method.
```

```
## Warning: Removed 14 rows containing missing values (stat_smooth). Warning:
## Removed 14 rows containing missing values (stat_smooth). Warning: Removed
## 13 rows containing missing values (stat_smooth).
```

```
## geom_smooth: method="auto" and size of largest group is <1000, so using
## loess. Use 'method = x' to change the smoothing method.
```

```
## Warning: Removed 14 rows containing missing values (stat_smooth). Warning:
## Removed 12 rows containing missing values (stat_smooth). Warning: Removed
## 12 rows containing missing values (stat_smooth).
```

```
## geom_smooth: method="auto" and size of largest group is <1000, so using
## loess. Use 'method = x' to change the smoothing method.
```

```
## Warning: Removed 14 rows containing missing values (stat_smooth). Warning:
## Removed 13 rows containing missing values (stat_smooth). Warning: Removed
## 12 rows containing missing values (stat_smooth).
```

```
## geom_smooth: method="auto" and size of largest group is <1000, so using
## loess. Use 'method = x' to change the smoothing method.
```

```
## Warning: Removed 14 rows containing missing values (stat_smooth). Warning:
## Removed 11 rows containing missing values (stat_smooth). Warning: Removed
## 12 rows containing missing values (stat_smooth).
```

```
## geom_smooth: method="auto" and size of largest group is <1000, so using
## loess. Use 'method = x' to change the smoothing method.
```

```
## Warning: Removed 11 rows containing missing values (stat_smooth). Warning:
## Removed 14 rows containing missing values (stat_smooth). Warning: Removed
## 13 rows containing missing values (stat_smooth).
```

```
## geom_smooth: method="auto" and size of largest group is <1000, so using
## loess. Use 'method = x' to change the smoothing method.
```

```
## Warning: Removed 13 rows containing missing values (stat_smooth). Warning:
## Removed 12 rows containing missing values (stat_smooth). Warning: Removed
## 12 rows containing missing values (stat_smooth).
```

```
## geom_smooth: method="auto" and size of largest group is <1000, so using
## loess. Use 'method = x' to change the smoothing method.
```

```
## Warning: Removed 11 rows containing missing values (stat_smooth). Warning:
## Removed 14 rows containing missing values (stat_smooth). Warning: Removed
## 13 rows containing missing values (stat_smooth).
```

```
## geom_smooth: method="auto" and size of largest group is <1000, so using
## loess. Use 'method = x' to change the smoothing method.
```

```
## Warning: Removed 10 rows containing missing values (stat_smooth). Warning:
## Removed 11 rows containing missing values (stat_smooth). Warning: Removed
## 7 rows containing missing values (stat_smooth).
```

```
## geom_smooth: method="auto" and size of largest group is <1000, so using
## loess. Use 'method = x' to change the smoothing method.
```

```
## Warning: Removed 13 rows containing missing values (stat_smooth). Warning:
## Removed 14 rows containing missing values (stat_smooth). Warning: Removed
## 13 rows containing missing values (stat_smooth).
```

```
## geom_smooth: method="auto" and size of largest group is <1000, so using
## loess. Use 'method = x' to change the smoothing method.
```

```
## Warning: Removed 14 rows containing missing values (stat_smooth). Warning:
## Removed 13 rows containing missing values (stat_smooth). Warning: Removed
## 12 rows containing missing values (stat_smooth).
```

```
## geom_smooth: method="auto" and size of largest group is <1000, so using
## loess. Use 'method = x' to change the smoothing method.
```

```
## Warning: Removed 11 rows containing missing values (stat_smooth). Warning:
## Removed 13 rows containing missing values (stat_smooth). Warning: Removed
## 13 rows containing missing values (stat_smooth). Warning: Removed 41 rows
## containing missing values (geom_point). Warning: Removed 38 rows
## containing missing values (geom_point). Warning: Removed 39 rows
## containing missing values (geom_point). Warning: Removed 37 rows
## containing missing values (geom_point). Warning: Removed 38 rows
## containing missing values (geom_point). Warning: Removed 37 rows
## containing missing values (geom_point). Warning: Removed 38 rows
## containing missing values (geom_point). Warning: Removed 28 rows
## containing missing values (geom_point). Warning: Removed 40 rows
## containing missing values (geom_point). Warning: Removed 39 rows
## containing missing values (geom_point). Warning: Removed 37 rows
## containing missing values (geom_point). Warning: Removed 1 rows containing
## missing values (geom_path). Warning: Removed 3 rows containing missing
## values (geom_path). Warning: Removed 1 rows containing missing values
## (geom_path). Warning: Removed 7 rows containing missing values
## (geom_path).
```

![plot of chunk unnamed-chunk-27](figure/unnamed-chunk-27.png) 


***2. BY ITEM ANALYSIS***

From Mike: this won't look good until we have a lot of data because we are dividing our data in 6 parts


```r
ms <- aggregate(correct ~ t.crit.binned + trialType + targetItem, d, mean)

qplot(t.crit.binned, correct, colour = trialType, facets = ~targetItem, geom = "line", 
    data = ms) + geom_hline(yintercept = 0.5, lty = 2) + xlab("Time (s)") + 
    ylab("Proportion correct looking") + scale_x_continuous(limits = c(-2, 3), 
    expand = c(0, 0)) + scale_y_continuous(limits = c(0, 1), expand = c(0, 0))
```

```
## Warning: Removed 76 rows containing missing values (geom_path). Warning:
## Removed 75 rows containing missing values (geom_path). Warning: Removed 76
## rows containing missing values (geom_path). Warning: Removed 75 rows
## containing missing values (geom_path). Warning: Removed 75 rows containing
## missing values (geom_path). Warning: Removed 75 rows containing missing
## values (geom_path). Warning: Removed 76 rows containing missing values
## (geom_path). Warning: Removed 75 rows containing missing values
## (geom_path). Warning: Removed 75 rows containing missing values
## (geom_path). Warning: Removed 76 rows containing missing values
## (geom_path). Warning: Removed 76 rows containing missing values
## (geom_path). Warning: Removed 75 rows containing missing values
## (geom_path).
```

![plot of chunk unnamed-chunk-28](figure/unnamed-chunk-28.png) 


***3. DWELL TIME IN WINDOW ANALYSIS***

From Mike: this will look good because we're averaging considerably


```r
window <- c(0.5, 4)
mss <- aggregate(correct ~ trialType + age_group, subset(d, t.crit.binned > 
    window[1] & t.crit.binned < window[2]), mean)
ms <- aggregate(correct ~ trialType, mss, mean)
ms$cih <- aggregate(correct ~ trialType, mss, ci.high)$correct
ms$cil <- aggregate(correct ~ trialType, mss, ci.low)$correct

qplot(trialType, correct, fill = trialType, stat = "identity", geom = "bar", 
    ylim = c(0, 1), data = ms) + ylab("Proportion correct looking") + geom_hline(yintercept = 0.5, 
    lty = 4) + geom_errorbar(aes(ymin = correct - cil, ymax = correct + cih, 
    width = 0.2))
```

![plot of chunk unnamed-chunk-29](figure/unnamed-chunk-291.png) 

```r

# by age
ms <- aggregate(correct ~ trialType + age_group, mss, mean)
ms$cih <- aggregate(correct ~ age_group, mss, ci.high)$correct
ms$cil <- aggregate(correct ~ age_group, mss, ci.low)$correct

qplot(trialType, correct, fill = trialType, stat = "identity", geom = "bar", 
    ylim = c(0, 1), data = ms) + ylab("Proportion correct looking") + geom_hline(yintercept = 0.5, 
    lty = 4) + facet_wrap(~age_group) + geom_errorbar(aes(ymin = correct - cil, 
    ymax = correct + cih, width = 0.2))
```

```
## Warning: Removed 4 rows containing missing values (geom_path).
```

![plot of chunk unnamed-chunk-29](figure/unnamed-chunk-292.png) 



