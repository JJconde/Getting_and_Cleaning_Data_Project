# Before you run the code below, make sure that UCI Har Dataset folder is in your working directory

# Read the activity list and rename the column names
activity <- read.csv("UCI HAR Dataset/activity_labels.txt", header=FALSE, sep=" ")
names(activity) <- c("activity_id", "activity")

# Read the features, and only select the second column
features <- read.csv("UCI HAR Dataset/features.txt", header=FALSE, sep=" ", colClasses="character")
features <- features[, 2]

# Read the subject and combine the train and test dataset
subject_train <- read.csv("UCI HAR Dataset/train/subject_train.txt", header=FALSE, sep=" ")
subject_test <- read.csv("UCI HAR Dataset/test/subject_test.txt", header=FALSE, sep=" ")
subject <- rbind(subject_train, subject_test)
rm(list=c("subject_train", "subject_test"))

# Read the activity ids for all the observation from train and test dataset
activity_train <- read.csv("UCI HAR Dataset/train/y_train.txt", header=FALSE, sep=" ")
activity_test <- read.csv("UCI HAR Dataset/test/y_test.txt", header=FALSE, sep=" ")
activity_id <- rbind(activity_train, activity_test)
rm(list=c("activity_train", "activity_test"))

# Read all the measureable observation from train and test dataset
X_train <- read.table("UCI HAR Dataset/train/X_train.txt", header=FALSE)
X_test <- read.table("UCI HAR Dataset/test/X_test.txt", header=FALSE)
X_train <- data.frame(X_train)
X_test <- data.frame(X_test)
X <- rbind(X_train, X_test)
rm(list=c("X_train", "X_test"))

# Input the feature names
names(X) <- features

# Select only the columns with mean and std in them
selected_features <- features[grepl("mean|std", features)]

# create the tidy dataset with the new features that were selected earlier
tidy_dataset <- subset(X, select=selected_features)

# Combine the activity and subject to the new dataset
tidy_dataset$activity_id <- activity_id$V1 # +1 only select the vector, not the data.frame
tidy_dataset$subject <- subject$V1
tidy_dataset <- merge(tidy_dataset, activity)
tidy_dataset$activity_id <- NULL # get rid of the activity_id

# Create a second dataset for the average of each variable for each activity and subject
tidy_dataset <- data.table(tidy_dataset)
avg_tidy_dataset <- tidy_dataset[, lapply(.SD, mean), by=c("subject", "activity")]

# Write the table to a file
write.table(avg_tidy_dataset, file="tidy_dataset.txt", row.name=FALSE)

# How to read the table back to double check
dt <- read.table("tidy_dataset.txt", header=TRUE)
