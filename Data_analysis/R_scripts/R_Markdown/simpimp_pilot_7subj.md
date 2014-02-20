EJY Simpimp: Data analysis for eye-tracking (Piloting data: at 7 subjects)
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
    d <- read.smi.idf(paste(raw.data.path, file.name, sep = ""), header.rows = 38)
    d <- preprocess.data(d)
    d$subid <- file.name
    
    ## now here's where data get bound together
    all.data <- rbind(all.data, d)
}
```


Now preprocessing is done! Next we save this as csv so that it can be easily accessed. (Code not shown here)

The csv file should have been saved onto the folder 'processed_data'. Open the folder and check if the file exists, and open the file to check that it's been preprocessed properly. First few rows of mine look like this:


```r
d <- read.csv("/Users/ericang/Documents/Erica/Stanford/2013-Q2-Winter/Research/simpimpGIT/Data_analysis/processed_data/simpimp_processed.csv")
head(d)
```

```
##       t      stimulus x    y   t.stim            subid
## 1 0.000 elmo_duck.avi 0 1050 0.008333 140130-01_L1.txt
## 2 0.008 elmo_duck.avi 0 1050 0.025000 140130-01_L1.txt
## 3 0.025 elmo_duck.avi 0 1050 0.033333 140130-01_L1.txt
## 4 0.033 elmo_duck.avi 0 1050 0.041667 140130-01_L1.txt
## 5 0.042 elmo_duck.avi 0 1050 0.058333 140130-01_L1.txt
## 6 0.059 elmo_duck.avi 0 1050 0.066667 140130-01_L1.txt
```


Columns:
t: how much time has passed since the exp began
x and y: coordinates where the eye gaze is. 
t.stim: how much time has passed since the stimulus 'elmo_duck.avi', for example, has started playing. 
subid: the subject id. this is the name of the raw data file, so make sure the name is a sensible one!

### SANITY CHECK

Now let's do some sanity check.
Open up the file simpimp_sanitycheck.R, and run the preliminary codes again.

First let's look at the distribution of data:

```r
# do histograms of the data for x and y coordinates
hist(d$x)
```

![plot of chunk unnamed-chunk-6](figure/unnamed-chunk-61.png) 

```r
hist(d$y)
```

![plot of chunk unnamed-chunk-6](figure/unnamed-chunk-62.png) 


First histogram shows tha distribution of eye gaze across x coordinates. 

(Note: dimensions of the eye-tracker screen are 1680 x 1050, check if the numbers on the histogram make sense based on those numbers!)

There is one big clump at the center and two small clumps at the left and right sides. Good news is that in my exp simpimp, there are three items on left, center, and right in test trials, so three clumps are good, but why is the center so big? Maybe due to characters being at the center for filler trials? This is something to keep in mind about, to come back to check later.

For y, we see two big clumps, which is good because there are two vertical positions we care about, one for the center items, and the other for left and right items. 

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
## Use 'binwidth = x' to adjust this.
```

![plot of chunk unnamed-chunk-7](figure/unnamed-chunk-71.png) 

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
## Use 'binwidth = x' to adjust this.
```

![plot of chunk unnamed-chunk-7](figure/unnamed-chunk-72.png) 


We see that the first subject has a weird peak at the end of the spectrum. for both graphs: note that this subject had a really bad calibration. So let's get rid of those and try again:


```r
d <- subset(d, (y != "1050" & x != "0"))

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
## Use 'binwidth = x' to adjust this.
```

![plot of chunk unnamed-chunk-8](figure/unnamed-chunk-81.png) 

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
## Use 'binwidth = x' to adjust this.
```

![plot of chunk unnamed-chunk-8](figure/unnamed-chunk-82.png) 


Other than that, the distribution of the corrdinates seem pretty normal for each subject. (three clumps for x and two clumps for y)

Next, we check the location of fixations. Here we'll visualize how the gazes looked on the screen:


```r
qplot(x, y, data = d, facets = ~subid)
```

![plot of chunk unnamed-chunk-9](figure/unnamed-chunk-9.png) 


Notice that there are mainly three clumps, as expected, but there is another clump to the left side of the big center clump. Again, maybe that's due to some filler item that shows up there a lot? We'll need to make sure.

I don't have fixation cross trials, so instead I tried calling on some random trial number to see if the two subjects match in their looking pattern:


```r
qplot(x, y, data = subset(d, stimulus == "list4.024"), facets = ~subid)
```

![plot of chunk unnamed-chunk-10](figure/unnamed-chunk-10.png) 


The cool graph below helps us visualize the main regions where the gazes fell. 


```r
qplot(x, y, geom = "density2d", data = d, xlim = c(0, 1680), ylim = c(0, 1050), 
    facets = ~subid)
```

![plot of chunk unnamed-chunk-11](figure/unnamed-chunk-11.png) 


There is a mass at the left top corner which really shouldn't be there; this seems to be a weird default for the eye-tracker when the eye gaze is not present, assuming from the processed data file (the first few rows all have 0, 1050) Other than that and the weird lump to the left side of the center clump, nothing else strikes me as odd, even though some people have more distributed eye gazes than others.


```r
qplot(x, y, facets = ~subid, geom = "density2d", data = subset(d, stimulus == 
    "list4.024"), xlim = c(0, 1680), ylim = c(0, 1050))
```

![plot of chunk unnamed-chunk-12](figure/unnamed-chunk-12.png) 


Same idea, with the randomy selected trial. Seems that this trial had two items that were distractors for each other at L and R!

Then we check for missing data:

```r
# how many NAs are there in the dataset?
sum(is.na(d$x))
```

```
## [1] 0
```

```r

# how about for each participant?  HINT: use na.action='na.pass' to pass NAs
# through aggregate
aggregate(x ~ subid, d, function(y) {
    return(sum(is.na(y)))
}, na.action = "na.pass")
```

```
##              subid x
## 1 140130-01_L1.txt 0
## 2 140130-02_L2.txt 0
## 3 140131-01_L3.txt 0
## 4 140131-02_L4.txt 0
## 5 140131-03_L2.txt 0
## 6 140131-04_L1.txt 0
## 7 140131-05_L4.txt 0
```


We see that the first two subjects have greater number of NA's, so maybe that signals to us that we should try to count those out later if there's anything weird in this piloting data.

### DATA ANALYSES

Now we're ready for the fun part: data analyses!
Again, run the prelim codes for sourcing scripts.

***PRELIMINARIES***
***1. Read in the orders and merge them with the data***

For this, you need to have created a csv file that specifies the onset of target word, etc., for each trial. Refer to **order1.csv** on et-ana.googlecode.com, or the columns of the order file below for an example.


```r
order <- read.csv("/Users/ericang/Documents/Erica/Stanford/2013-Q2-Winter/Research/simpimpGIT/Data_analysis/info/simpimp_order.csv")
head(order)
```

```
##                        stimulus order order2 character container
## 1 140121-ey-simpleImp-list1.013   pre     T1      elmo    friend
## 2 140121-ey-simpleImp-list1.016   pre     T1      elmo  lunchbox
## 3 140121-ey-simpleImp-list1.018   pre     T2    grover     chair
## 4 140121-ey-simpleImp-list1.021   pre     T2    grover     house
## 5 140121-ey-simpleImp-list1.024   pre     T3      elmo     plate
## 6 140121-ey-simpleImp-list1.026   pre     T3      elmo     table
##   targetItem trialType targetPos distPos foilPos targetOnset
## 1      truck   control         L       R       C       6.161
## 2      apple inference         L       C       R       6.410
## 3        cat inference         C       L       R       6.697
## 4    bicycle   control         R       L       C       6.287
## 5     banana inference         R       L       C       6.111
## 6  teddybear   control         C       L       R       6.242
```

```r

nrow(d)  # first check number of rows
```

```
## [1] 204291
```

```r
plot(d$stimulus)  # now check the stimulus ordering
```

![plot of chunk unnamed-chunk-14](figure/unnamed-chunk-14.png) 


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

![plot of chunk unnamed-chunk-15](figure/unnamed-chunk-15.png) 

```r
nrow(d)  # check the number of rows again
```

```
## [1] 204291
```


We see that the graph and number of rows did not get messed up by this operation.

***2. Define the target ROIs (regions of interest)***

At this stage, we define the regions of interest, which are the regions upon which the gazes fell that we care about. 


```r
rois <- list()
rois[[1]] <- c(0, 0, 840, 550)  # left
rois[[2]] <- c(840, 0, 840, 550)  # right
rois[[3]] <- c(420, 550, 840, 550)  # center
names(rois) <- c("L", "R", "C")
roi.image(rois)
```

![plot of chunk unnamed-chunk-16](figure/unnamed-chunk-16.png) 


We are using the function 'roi.image' that was specified in our helper file et_helper.R. 


```r
# use check code to make sure that ROIs look right
d$roi <- roi.check(d, rois)

# see how the distribution of ROIs looks
qplot(roi, data = d)
```

![plot of chunk unnamed-chunk-17](figure/unnamed-chunk-17.png) 

The graph above shows the distribution of the gazes by region. Just as we would have predicted from what we saw above, the clump for center is the biggest (something to keep in mind and check that it's not a center bias for the test trials we care about)


```r
# set up correctness
d$correct <- d$roi == d$targetPos
```


Here we are saying that if the ROI fell in the region where the target item is positioned, then the column 'correct' will reflect this.



```r
# another way to organize by ROI's: set up three possible regions
d$target <- ifelse(d$roi == d$targetPos, "1", "0")
d$dist <- ifelse(d$roi == d$distPos, "1", "0")
d$foil <- ifelse(d$roi == d$foilPos, "1", "0")
```


Now let's only keep the rows that we care about: for the ones we have info about whether they looked at the correct target or not.

```r
# remove those rows where column 'correct' is NA
d <- subset(d, correct != "NA")

# check what we're left with
plot(d$stimulus)
```

![plot of chunk unnamed-chunk-20](figure/unnamed-chunk-201.png) 

```r
nrow(d)
```

```
## [1] 83158
```

```r
qplot(roi, data = d)
```

![plot of chunk unnamed-chunk-20](figure/unnamed-chunk-202.png) 



***3. Align trials to the onset of the critical word***

Here we "create timestamps starting from the point of disambiguation".


```r
d <- rezero.trials(d)  # specified in et_helper.R
```


***4. subsample the data so that you get smooth curves***

From Mike: I like to do this when I don't have much data so that I'm not distracted by the variation in the data, but then relax the subsampling if I have more data.


```r
subsample.hz <- 10  # 10 hz is decent, eventually we should set to 30 or 60 hz
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
    geom_hline(yintercept = 0.33, lty = 2) + geom_hline(yintercept = 0.5, lty = 4) + 
    geom_vline(xintercept = 0, lty = 3) + xlab("Time (s)") + ylab("Proportion correct looking") + 
    scale_x_continuous(limits = c(-4, 3), expand = c(0, 0)) + scale_y_continuous(limits = c(0, 
    1), expand = c(0, 0))  # make the axes start at 0
```

```
## Warning: Removed 73 rows containing missing values (geom_path).
```

![plot of chunk unnamed-chunk-23](figure/unnamed-chunk-231.png) 

```r

## 1a+ add error bars with 95% CI
mss <- aggregate(correct ~ t.crit.binned + trialType + subid, d, mean)
ms <- aggregate(correct ~ t.crit.binned + trialType, mss, mean)
ms$cih <- aggregate(correct ~ t.crit.binned + trialType, mss, ci.high)$correct
ms$cil <- aggregate(correct ~ t.crit.binned + trialType, mss, ci.low)$correct

qplot(t.crit.binned, correct, colour = trialType, geom = "line", data = ms) + 
    geom_pointrange(aes(ymin = correct - cil, ymax = correct + cih), position = position_dodge(0.05)) + 
    geom_hline(yintercept = 0.33, lty = 2) + geom_hline(yintercept = 0.5, lty = 4) + 
    geom_vline(xintercept = 0, lty = 3) + xlab("Time (s)") + ylab("Proportion correct looking") + 
    scale_x_continuous(limits = c(-4, 3), expand = c(0, 0)) + scale_y_continuous(limits = c(0, 
    1), expand = c(0, 0))  # make the axes start at 0
```

```
## Warning: Removed 73 rows containing missing values (geom_path). Warning:
## Removed 37 rows containing missing values (geom_segment). Warning: Removed
## 37 rows containing missing values (geom_point). Warning: Removed 38 rows
## containing missing values (geom_segment). Warning: Removed 38 rows
## containing missing values (geom_point).
```

![plot of chunk unnamed-chunk-23](figure/unnamed-chunk-232.png) 


Now let's try to make a graph that shows all three possible eye-gaze locations: target, distractor, and foil. 


```r
melted = melt(d, id = c("t.crit.binned", "trialType"), measure = c("target", 
    "dist", "foil"), value.name = "Looks", variable.name = "Region")
melted$Looks = to.n(melted$Looks)

subsample.hz <- 10  # 10 hz is decent, eventually we should set to 30 or 60 hz
d$t.crit.binned <- round(d$t.crit * subsample.hz)/subsample.hz  # subsample step

ms <- aggregate(Looks ~ Region + t.crit.binned + trialType, melted, mean)

qplot(t.crit.binned, Looks, colour = trialType, linetype = Region, geom = "line", 
    data = ms) + geom_hline(yintercept = 0.33, lty = 2) + geom_hline(yintercept = 0.5, 
    lty = 4) + geom_vline(xintercept = 0, lty = 3) + xlab("Time (s)") + ylab("Proportion Looking") + 
    scale_x_continuous(limits = c(-4, 3), expand = c(0, 0)) + scale_y_continuous(limits = c(0, 
    1), expand = c(0, 0))  # make the axes start at 0
```

```
## Warning: Removed 219 rows containing missing values (geom_path).
```

![plot of chunk unnamed-chunk-24](figure/unnamed-chunk-24.png) 


Also, we want to see a graph splitting by target location, since we saw the center bias before.


```r
## 1e. target positions
ms <- aggregate(correct ~ t.crit.binned + trialType + targetPos, d, mean)

qplot(t.crit.binned, correct, colour = trialType, geom = "point", data = ms) + 
    facet_grid(. ~ targetPos) + geom_hline(yintercept = 0.33, lty = 2) + geom_hline(yintercept = 0.5, 
    lty = 4) + geom_vline(xintercept = 0, lty = 3) + geom_smooth() + xlab("Time (s)") + 
    ylab("Proportion correct looking") + scale_x_continuous(limits = c(-3, 3), 
    expand = c(0, 0)) + scale_y_continuous(limits = c(0, 1), expand = c(0, 0))  # make the axes start at 0
```

```
## geom_smooth: method="auto" and size of largest group is <1000, so using
## loess. Use 'method = x' to change the smoothing method.
```

```
## Warning: Removed 45 rows containing missing values (stat_smooth). Warning:
## Removed 47 rows containing missing values (stat_smooth).
```

```
## geom_smooth: method="auto" and size of largest group is <1000, so using
## loess. Use 'method = x' to change the smoothing method.
```

```
## Warning: Removed 46 rows containing missing values (stat_smooth). Warning:
## Removed 46 rows containing missing values (stat_smooth).
```

```
## geom_smooth: method="auto" and size of largest group is <1000, so using
## loess. Use 'method = x' to change the smoothing method.
```

```
## Warning: Removed 44 rows containing missing values (stat_smooth). Warning:
## Removed 46 rows containing missing values (stat_smooth). Warning: Removed
## 92 rows containing missing values (geom_point). Warning: Removed 92 rows
## containing missing values (geom_point). Warning: Removed 90 rows
## containing missing values (geom_point).
```

![plot of chunk unnamed-chunk-25](figure/unnamed-chunk-25.png) 


From this graph, it seems that expecting the correct target position BEFORE the onset of target word is greater for center targets than for left and right targets.

Then we see how each partcipant performed:


```r
## 1b. by participant
ms <- aggregate(correct ~ t.crit.binned + trialType + subid, d, mean)

qplot(t.crit.binned, correct, colour = trialType, geom = "point", data = ms) + 
    facet_wrap(~subid) + geom_hline(yintercept = 0.33, lty = 2) + geom_hline(yintercept = 0.5, 
    lty = 4) + geom_vline(xintercept = 0, lty = 3) + geom_smooth() + xlab("Time (s)") + 
    ylab("Proportion correct looking") + scale_x_continuous(limits = c(-4, 3), 
    expand = c(0, 0)) + scale_y_continuous(limits = c(0, 1), expand = c(0, 0))  # make the axes start at 0
```

```
## geom_smooth: method="auto" and size of largest group is <1000, so using
## loess. Use 'method = x' to change the smoothing method.
```

```
## Warning: Removed 32 rows containing missing values (stat_smooth). Warning:
## Removed 35 rows containing missing values (stat_smooth).
```

```
## geom_smooth: method="auto" and size of largest group is <1000, so using
## loess. Use 'method = x' to change the smoothing method.
```

```
## Warning: Removed 35 rows containing missing values (stat_smooth). Warning:
## Removed 36 rows containing missing values (stat_smooth).
```

```
## geom_smooth: method="auto" and size of largest group is <1000, so using
## loess. Use 'method = x' to change the smoothing method.
```

```
## Warning: Removed 34 rows containing missing values (stat_smooth). Warning:
## Removed 36 rows containing missing values (stat_smooth).
```

```
## geom_smooth: method="auto" and size of largest group is <1000, so using
## loess. Use 'method = x' to change the smoothing method.
```

```
## Warning: Removed 35 rows containing missing values (stat_smooth). Warning:
## Removed 37 rows containing missing values (stat_smooth).
```

```
## geom_smooth: method="auto" and size of largest group is <1000, so using
## loess. Use 'method = x' to change the smoothing method.
```

```
## Warning: Removed 36 rows containing missing values (stat_smooth). Warning:
## Removed 35 rows containing missing values (stat_smooth).
```

```
## geom_smooth: method="auto" and size of largest group is <1000, so using
## loess. Use 'method = x' to change the smoothing method.
```

```
## Warning: Removed 34 rows containing missing values (stat_smooth). Warning:
## Removed 36 rows containing missing values (stat_smooth).
```

```
## geom_smooth: method="auto" and size of largest group is <1000, so using
## loess. Use 'method = x' to change the smoothing method.
```

```
## Warning: Removed 35 rows containing missing values (stat_smooth). Warning:
## Removed 37 rows containing missing values (stat_smooth). Warning: Removed
## 67 rows containing missing values (geom_point). Warning: Removed 71 rows
## containing missing values (geom_point). Warning: Removed 70 rows
## containing missing values (geom_point). Warning: Removed 72 rows
## containing missing values (geom_point). Warning: Removed 71 rows
## containing missing values (geom_point). Warning: Removed 70 rows
## containing missing values (geom_point). Warning: Removed 72 rows
## containing missing values (geom_point). Warning: Removed 3 rows containing
## missing values (geom_path). Warning: Removed 12 rows containing missing
## values (geom_path). Warning: Removed 9 rows containing missing values
## (geom_path). Warning: Removed 3 rows containing missing values
## (geom_path). Warning: Removed 7 rows containing missing values
## (geom_path). Warning: Removed 9 rows containing missing values
## (geom_path).
```

![plot of chunk unnamed-chunk-26](figure/unnamed-chunk-26.png) 


About half of the participants have told me that:
1) they noticed that when there are a container with two items and another with one item, then they knew the answer would be the one-item container so they looked toward that
2) they noticed in the second half that if they saw the same container then the target would be the same, so they looked at the target even before the sentence said it

So I tried to see if this effect is big enough to be worried, by dividing the data into first (pre) and second (post) half of the trials:


```r
## 1c. first half vs. second half of trials
ms <- aggregate(correct ~ t.crit.binned + trialType + order, d, mean)

qplot(t.crit.binned, correct, colour = trialType, geom = "point", data = ms) + 
    facet_grid(. ~ order) + geom_hline(yintercept = 0.33, lty = 2) + geom_hline(yintercept = 0.5, 
    lty = 4) + geom_vline(xintercept = 0, lty = 3) + geom_smooth() + xlab("Time (s)") + 
    ylab("Proportion correct looking") + scale_x_continuous(limits = c(-2, 3), 
    expand = c(0, 0)) + scale_y_continuous(limits = c(0, 1), expand = c(0, 0))  # make the axes start at 0
```

```
## geom_smooth: method="auto" and size of largest group is <1000, so using
## loess. Use 'method = x' to change the smoothing method.
```

```
## Warning: Removed 55 rows containing missing values (stat_smooth). Warning:
## Removed 57 rows containing missing values (stat_smooth).
```

```
## geom_smooth: method="auto" and size of largest group is <1000, so using
## loess. Use 'method = x' to change the smoothing method.
```

```
## Warning: Removed 56 rows containing missing values (stat_smooth). Warning:
## Removed 57 rows containing missing values (stat_smooth). Warning: Removed
## 112 rows containing missing values (geom_point). Warning: Removed 113 rows
## containing missing values (geom_point).
```

![plot of chunk unnamed-chunk-27](figure/unnamed-chunk-271.png) 

```r

## 1d. each trial
ms <- aggregate(correct ~ t.crit.binned + trialType + order2, d, mean)

qplot(t.crit.binned, correct, colour = trialType, geom = "point", data = ms) + 
    facet_wrap(~order2) + geom_hline(yintercept = 0.33, lty = 2) + geom_hline(yintercept = 0.5, 
    lty = 4) + geom_vline(xintercept = 0, lty = 3) + geom_smooth() + xlab("Time (s)") + 
    ylab("Proportion correct looking") + scale_x_continuous(limits = c(-3, 3), 
    expand = c(0, 0)) + scale_y_continuous(limits = c(0, 1), expand = c(0, 0))  # make the axes start at 0
```

```
## geom_smooth: method="auto" and size of largest group is <1000, so using
## loess. Use 'method = x' to change the smoothing method.
```

```
## Warning: Removed 44 rows containing missing values (stat_smooth). Warning:
## Removed 47 rows containing missing values (stat_smooth).
```

```
## geom_smooth: method="auto" and size of largest group is <1000, so using
## loess. Use 'method = x' to change the smoothing method.
```

```
## Warning: Removed 42 rows containing missing values (stat_smooth). Warning:
## Removed 46 rows containing missing values (stat_smooth).
```

```
## geom_smooth: method="auto" and size of largest group is <1000, so using
## loess. Use 'method = x' to change the smoothing method.
```

```
## Warning: Removed 46 rows containing missing values (stat_smooth). Warning:
## Removed 44 rows containing missing values (stat_smooth).
```

```
## geom_smooth: method="auto" and size of largest group is <1000, so using
## loess. Use 'method = x' to change the smoothing method.
```

```
## Warning: Removed 44 rows containing missing values (stat_smooth). Warning:
## Removed 46 rows containing missing values (stat_smooth).
```

```
## geom_smooth: method="auto" and size of largest group is <1000, so using
## loess. Use 'method = x' to change the smoothing method.
```

```
## Warning: Removed 42 rows containing missing values (stat_smooth). Warning:
## Removed 46 rows containing missing values (stat_smooth).
```

```
## geom_smooth: method="auto" and size of largest group is <1000, so using
## loess. Use 'method = x' to change the smoothing method.
```

```
## Warning: Removed 45 rows containing missing values (stat_smooth). Warning:
## Removed 44 rows containing missing values (stat_smooth). Warning: Removed
## 91 rows containing missing values (geom_point). Warning: Removed 88 rows
## containing missing values (geom_point). Warning: Removed 90 rows
## containing missing values (geom_point). Warning: Removed 90 rows
## containing missing values (geom_point). Warning: Removed 88 rows
## containing missing values (geom_point). Warning: Removed 89 rows
## containing missing values (geom_point). Warning: Removed 5 rows containing
## missing values (geom_path).
```

![plot of chunk unnamed-chunk-27](figure/unnamed-chunk-272.png) 

```r


subsample.hz <- 60
d$t.crit.binned <- round(d$t.crit * subsample.hz)/subsample.hz  # subsample step
ms <- aggregate(correct ~ t.crit.binned + trialType, d, mean)

qplot(t.crit.binned, correct, colour = trialType, geom = "point", data = ms) + 
    geom_hline(yintercept = 0.33, lty = 2) + geom_hline(yintercept = 0.5, lty = 4) + 
    geom_vline(xintercept = 0, lty = 3) + geom_smooth(method = "loess", span = 0.5) + 
    xlab("Time (s)") + ylab("Proportion correct looking") + scale_x_continuous(limits = c(-2, 
    3), expand = c(0, 0)) + scale_y_continuous(limits = c(0, 1), expand = c(0, 
    0))
```

```
## Warning: Removed 334 rows containing missing values (stat_smooth).
## Warning: Removed 338 rows containing missing values (stat_smooth).
## Warning: Removed 672 rows containing missing values (geom_point).
```

![plot of chunk unnamed-chunk-27](figure/unnamed-chunk-273.png) 

```r

## 1e. dividing by target location
```


***2. BY ITEM ANALYSIS***

From Mike: this won't look good until we have a lot of data because we are dividing our data in 6 parts


```r
ms <- aggregate(correct ~ t.crit.binned + trialType + targetItem, d, mean)

qplot(t.crit.binned, correct, colour = trialType, facets = ~targetItem, geom = "line", 
    data = ms) + geom_hline(yintercept = 0.33, lty = 2) + xlab("Time (s)") + 
    ylab("Proportion correct looking") + scale_x_continuous(limits = c(-2, 3), 
    expand = c(0, 0)) + scale_y_continuous(limits = c(0, 1), expand = c(0, 0))
```

```
## Warning: Removed 600 rows containing missing values (geom_path). Warning:
## Removed 600 rows containing missing values (geom_path). Warning: Removed
## 599 rows containing missing values (geom_path). Warning: Removed 599 rows
## containing missing values (geom_path). Warning: Removed 600 rows
## containing missing values (geom_path). Warning: Removed 600 rows
## containing missing values (geom_path). Warning: Removed 600 rows
## containing missing values (geom_path). Warning: Removed 601 rows
## containing missing values (geom_path). Warning: Removed 600 rows
## containing missing values (geom_path). Warning: Removed 600 rows
## containing missing values (geom_path). Warning: Removed 599 rows
## containing missing values (geom_path). Warning: Removed 598 rows
## containing missing values (geom_path).
```

![plot of chunk unnamed-chunk-28](figure/unnamed-chunk-28.png) 


***3. DWELL TIME IN WINDOW ANALYSIS***

From Mike: this will look good because we're averaging considerably


```r
window <- c(0.5, 2.5)
mss <- aggregate(correct ~ trialType + subid, subset(d, t.crit.binned > window[1] & 
    t.crit.binned < window[2]), mean)
ms <- aggregate(correct ~ trialType, mss, mean)
ms$cih <- aggregate(correct ~ trialType, mss, ci.high)$correct
ms$cil <- aggregate(correct ~ trialType, mss, ci.low)$correct

qplot(trialType, correct, fill = trialType, stat = "identity", geom = "bar", 
    ylim = c(0, 1), data = ms) + ylab("Proportion correct looking") + geom_hline(yintercept = 0.5, 
    lty = 4) + geom_hline(yintercept = 0.33, lty = 2) + geom_errorbar(aes(ymin = correct - 
    cil, ymax = correct + cih, width = 0.2))
```

![plot of chunk unnamed-chunk-29](figure/unnamed-chunk-29.png) 

