---
title: "Getting and Cleaning Data Project"
author: "JRB"
date: "Thursday, September 18, 2014"
---

===

### Introduction

On this project, I simply divide what I'm doing to 4 things:

1) Reading the data  
2) Manipulating the data  
3) Combine the data  
4) Create and Summarize the Combined data  

===

### Reading the data

First, I simply read the activity list which contains the **ID** and the **name**.

```{r}
# Read the activity list and rename the column names
activity <- read.csv("UCI HAR Dataset/activity_labels.txt", header=FALSE, sep=" ")
names(activity) <- c("activity_id", "activity")
```

Second, similar as above except that I only want the second column which is the **feature name** to do the manipulation later on.

```{r}
# Read the features, and only select the second column
features <- read.csv("UCI HAR Dataset/features.txt", header=FALSE, sep=" ", colClasses="character")
features <- features[, 2]
```

Third, we also need the **subject**, and on the following code, I'll be combining both train and test dataset using `rbind`.  

I like to remove the previous datasets when I combine both train and test to free up my memory and have less things to worry about.

```{r}
# Read the subject and combine the train and test dataset
subject_train <- read.csv("UCI HAR Dataset/train/subject_train.txt", header=FALSE, sep=" ")
subject_test <- read.csv("UCI HAR Dataset/test/subject_test.txt", header=FALSE, sep=" ")
subject <- rbind(subject_train, subject_test)
rm(list=c("subject_train", "subject_test"))
```

Fourth, using a similar script as subject, this will read the **activity_id** which we'll need later on.

**Note:** I will be using this later to convert the ID to the activity name

```{r}
# Read the activity ids for all the observation from train and test dataset
activity_train <- read.csv("UCI HAR Dataset/train/y_train.txt", header=FALSE, sep=" ")
activity_test <- read.csv("UCI HAR Dataset/test/y_test.txt", header=FALSE, sep=" ")
activity_id <- rbind(activity_train, activity_test)
rm(list=c("activity_train", "activity_test"))
```

Fifth, this is the main dataset that we'll need. Using the `read.table` this time to make it faster to read.  

Also, I like to convert the dataset back to `data.frame` because `data.table` has some different subsetting features that I don't want.

```{r}
# Read all the measureable observation from train and test dataset
X_train <- read.table("UCI HAR Dataset/train/X_train.txt", header=FALSE)
X_test <- read.table("UCI HAR Dataset/test/X_test.txt", header=FALSE)
X_train <- data.frame(X_train)
X_test <- data.frame(X_test)
X <- rbind(X_train, X_test)
rm(list=c("X_train", "X_test"))
```
===

### Manipulating the data

Overall, I simply use the features dataset to name the main data that we care about.  

Afterwards, I selected the column names with `mean` and `std` in them.

```{r}
# Input the feature names
names(X) <- features

# Select only the columns with mean and std in them
selected_features <- features[grepl("mean|std", features)]

# create the tidy dataset with the new features that were selected earlier
tidy_dataset <- subset(X, select=selected_features)
```
===

### Combine the data

First, I added both the **activity_id** and **subject** to the main dataset.  

```{r}
# Combine the activity and subject to the new dataset
tidy_dataset$activity_id <- activity_id$V1 # +1 only select the vector, not the data.frame
tidy_dataset$subject <- subject$V1
```

Second, I `merged` the main dataset and the activity dataset using the **activity_id** for the join.  

Afterwards, I simply removed the activity_id to make it easier later to summarize the values.

```{r}
tidy_dataset <- merge(tidy_dataset, activity)

# Get rid of the activity_id
tidy_dataset$activity_id <- NULL 
```
===

### Create and Summarize the Combined data

First, I wanted to make it easier to work it by converting the dataset to `data.table`.  

Aftewards, using the built-in capability of `data.table`, I simply used `lapply` to take the *average* by **subject** and **activity**.

```{r}
# Create a second dataset for the average of each variable for each activity and subject
tidy_dataset <- data.table(tidy_dataset)
avg_tidy_dataset <- tidy_dataset[, lapply(.SD, mean), by=c("subject", "activity")]
```

Second, this will write the newly created dataset to a txt file in the working directory.

```{r}
# Write the table to a file
write.table(avg_tidy_dataset, file="tidy_dataset.txt", row.name=FALSE)
```

We all know that it is sometimes harder to read the txt file as it depends on several things.  

I've created a code below as an example on how to read the file I created from above. This will make it easier to work with later on.

```{r}
# How to read the table back to double check etc.
dt <- read.table("tidy_dataset.txt", header=TRUE)
```