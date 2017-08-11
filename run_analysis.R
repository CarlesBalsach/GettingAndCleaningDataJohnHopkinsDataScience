library(dplyr)

# Goals
# [1] Merges the training and the test sets to create one data set
# [2] Extracts only the measurements on the mean and standard deviation for each measurement
# [3] Uses descriptive activity names to name the activities in the data set
# [4] Appropriately labels the data set with descriptive variable names
# [5] From the data set in step 4, creates a second, independent tidy data set with the average
#     of each variable for each activity and each subject

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

#First we bind both train and test for all tables
X <- rbind(X_train,X_test)
y <- rbind(y_train,y_test)
subjects <- rbind(subject_train,subject_test)

#We will rename variables for our features [4]
names(X) <- featureNames

#We'll take only the mean and std for each measurement [2]
meanstdNamesLogic <- grepl("mean|std",featureNames)
X <- X[meanstdNamesLogic]
sum(meanstdNamesLogic) # 79 columns contain mean or std

# Uses descriptive activity names to name the activities in the data set [3]
y$activity <- activityLabels[y$activity,"label"]

#Then we create the full dataframe [1]
df <- cbind(X,cbind(y,subjects))
nrow(df) # 10299 rows (all rows are there 7352 + 2947); 
ncol(df) # 81 columns (79 mean std cols + activity + subject)

# Grouping the data to create a tidy dataset with the means by subject and activity [5]
gas <- group_by(df,activity,subject)
gdf <- as.data.frame(summarize_all(gas,funs(mean)))
ncol(gdf) # 81, which is 79 (mean and std measurements) + 2 (activity and subject)
nrow(gdf) # 180, which equals to 30*6.

#All OK!

# Extra work

# Let's rename the variables to know they are a mean by Activity and Subject
names <- names(gdf)[3:length(names(gdf))]
names <- paste(names,"meanByAct&Sub",sep="-")
names(gdf)[3:length(names(gdf))] <- names

# We remove the previous data since we don't longer need them
rm(X_train); rm(y_train); rm(subject_train)
rm(X_test); rm(y_test); rm(subject_test)
rm(X); rm(y); rm(subjects)

# Tidy Data Frame for [1-4]
str(df)

# Tidy Data Frame for [5]
str(gdf)

#Export data
write.table(x = gdf, file = "groupeddf.txt", row.names = FALSE)