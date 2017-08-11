# Coode Book

This Code Book contains the information of how the script RunAnalysys.R works, the information about the Data used, as well as the operations performed to clean up the data for the objectives asked in the assagnment (for more information take a loot at README.md)

# DATA

## Source

Jorge L. Reyes-Ortiz(1,2), Davide Anguita(1), Alessandro Ghio(1), Luca Oneto(1) and Xavier Parra(2)
1 - Smartlab - Non-Linear Complex Systems Laboratory
DITEN - Università degli Studi di Genova, Genoa (I-16145), Italy. 
2 - CETpD - Technical Research Centre for Dependency Care and Autonomous Living
Universitat Politècnica de Catalunya (BarcelonaTech). Vilanova i la Geltrú (08800), Spain
activityrecognition '@' smartlab.ws

## Information

The experiments have been carried out with a group of 30 volunteers within an age bracket of 19-48 years. Each person performed six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) wearing a smartphone (Samsung Galaxy S II) on the waist. Using its embedded accelerometer and gyroscope, we captured 3-axial linear acceleration and 3-axial angular velocity at a constant rate of 50Hz. The experiments have been video-recorded to label the data manually. The obtained dataset has been randomly partitioned into two sets, where 70% of the volunteers was selected for generating the training data and 30% the test data. 

The sensor signals (accelerometer and gyroscope) were pre-processed by applying noise filters and then sampled in fixed-width sliding windows of 2.56 sec and 50% overlap (128 readings/window). The sensor acceleration signal, which has gravitational and body motion components, was separated using a Butterworth low-pass filter into body acceleration and gravity. The gravitational force is assumed to have only low frequency components, therefore a filter with 0.3 Hz cutoff frequency was used. From each window, a vector of features was obtained by calculating variables from the time and frequency domain.

## Attribute Information

For each record in the dataset it is provided: 
- Triaxial acceleration from the accelerometer (total acceleration) and the estimated body acceleration. 
- Triaxial Angular velocity from the gyroscope. 
- A 561-feature vector with time and frequency domain variables. 
- Its activity label. 
- An identifier of the subject who carried out the experiment.

## Download

You can download the dataset from:

https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

# Data Files

- "UCI HAR Dataset/train/X_train.txt": Contains the main information about all the measurements for /tran
- "UCI HAR Dataset/train/y_train.txt": Contains the activity performed as an integer 1-6 for /train
- "UCI HAR Dataset/train/subject_train.txt": Contains the subject that performed the activity for /train
- "UCI HAR Dataset/test/X_test.txt": Contains the main information about all the measurements for /test
- "UCI HAR Dataset/test/y_test.txt": Contains the activity performed as an integer 1-6 for /test
- "UCI HAR Dataset/test/subject_test.txt": Contains the subject that performed the activity for /test
- "UCI HAR Dataset/features.txt": Contains the names of the features(ordered)
- "UCI HAR Dataset/activity_labels.txt": Contains the names of the activities (from 1-6 to activity name)

All the files avobe are used for this project. Whil ethe first 6 will be merged together with cbind and rbind, the other 2 will be used to replace the names of the dataframe and change the integer value from activity to it's name (eg. 1 replaced by "WALKING"")

## How RunAnalysis.R Works

```R
library(dplyr)
```

We load here the dplyr library that we will need (specially for task 5)

```R
# READING DATA AND PREPROCESSING

X_train <- read.fwf("UCI HAR Dataset/train/X_train.txt",widths=rep(16,561))
y_train <- read.csv("UCI HAR Dataset/train/y_train.txt",col.names = c("activity"),header = F)
subject_train <- read.csv("UCI HAR Dataset/train/subject_train.txt",col.names = c("subject"),header = F)

nrow(X_train);nrow(y_train);nrow(subject_train) # All of them have 7352 rows

X_test <- read.fwf("UCI HAR Dataset/test/X_test.txt",widths=rep(16,561))
y_test <- read.csv("UCI HAR Dataset/test/y_test.txt",col.names = c("activity"),header = F)
subject_test <- read.csv("UCI HAR Dataset/test/subject_test.txt",col.names = c("subject"),header = F)

nrow(X_test);nrow(y_test);nrow(subject_test) # All of them have 2947 rows

# Read the feature names
featureNames <- read.csv("UCI HAR Dataset/features.txt",header = F,sep=" ",col.names = c("id","f_name"),stringsAsFactors = F)
featureNames <- featureNames$f_name

# Read the activity labels
activityLabels <- read.csv("UCI HAR Dataset/activity_labels.txt",header = F,sep=" ",col.names = c("id","label"))

# Everything looks good!
```

Here we read all the data relevant for this analysis, as described above in the Data Files part.

All the **variables** defined avove will contain the information defined in **Data Files**.

```R
#First we bind both train and test for all tables
X <- rbind(X_train,X_test)
y <- rbind(y_train,y_test)
subjects <- rbind(subject_train,subject_test)
```

Here we bind all the data that is in both folders train and test (since they are the same but divided for machine learning purposes)

* **X** Will contain all the measurements for both train and test
* **y** Will contain all the activities for both train and test
* **subjects** Will contain all the subjects for both train and test

```R
#We will rename variables for our features [4]
names(X) <- featureNames
```

Here we set the names of the measurements taken from the features.txt file

```R
#We'll take only the mean and std for each measurement [2]
meanstdNamesLogic <- grepl("mean|std",featureNames)
X <- X[meanstdNamesLogic]
sum(meanstdNamesLogic) # 79 columns contain mean or std
```

Since we've been asked to only retrieve the mean and std measurements, we do so by applying a logical vector to our features X with the variables that contains "mean" or "std""

```R
# Uses descriptive activity names to name the activities in the data set [3]
y$activity <- activityLabels[y$activity,"label"]
```

Here we repalce the 1-6 integer value from activity replacing them by the strings found in the activity_labels.txt that already links this information.

```R
#Then we create the full dataframe [1]
df <- cbind(X,cbind(y,subjects))
nrow(df) # 10299 rows (all rows are there 7352 + 2947); 
ncol(df) # 81 columns (79 mean std cols + activity + subject)
```

Finally here we have the full tidy dataframe with all the information required from tasks [1-4]. We can check that everything looks fine with nrows and ncols functions.

* **df** Contains the full dataframe asked for questions [1-4]

```R
# Grouping the data to create a tidy dataset with the means by subject and activity [5]
gas <- group_by(df,activity,subject)
gdf <- as.data.frame(summarize_all(gas,funs(mean)))
ncol(gdf) # 81, which is 79 (mean and std measurements) + 2 (activity and subject)
nrow(gdf) # 180, which equals to 30*6.
```

For task 5 we've been asked to group the data by activity and subject and calculate the mean of all other variables. We do so by grouping by and summary methods defined in dyplr library. We check that everything looks ok with ncol and nrow columns.

* **gas** Will contain the grouped information of *df* by activity and subject
* **gdf** Will be the Grouped DataFrame by activity and subject with the mean of all measurements

There is some more extra code that defines the names of the variables for the grouped data frame but it is not in the scope of the exercice, so I'll not put in here.

If anything is not clear please send an email to the owned of this repository.

## Running RunAnalysis.R Requirements

- "dyplr" library must be installed
- The contents of the downloaded data "UCI HAR Dataset" folder (unzipped) must be in the R working directory

