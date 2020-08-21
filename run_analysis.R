# Load the libraries we'll need.

library(dplyr)
library(readr)
library(stringr)

# Downlaod the data and unzip the zip file

url = 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
if (!file.exists("./data.zip")){
  download.file(url,'./data.zip', mode = 'wb')
  unzip("data.zip", exdir = getwd())
}
setwd("./UCI HAR Dataset/")

# Use the 'features' file to get the names of the columns, and clean them a little

colheads <- read.table("./features.txt", header = FALSE)
colheads <- sapply(colheads$V2, function(x){gsub("[()]", "", x)})

# import the training and test data, and combine it all 

x.train <- read.table("./train/X_train.txt", header = FALSE, col.names = colheads)
x.test <- read.table("./test/X_test.txt", header = FALSE, col.names = colheads)
y.train <- read.table("./train/Y_train.txt", col.names = "activity")
y.test <- read.table("./test/Y_test.txt", col.names = "activity")
subject.test <- read.table("./test/subject_test.txt", col.names = "subject")
subject.train <- read.table("./train/subject_train.txt", col.names = "subject")
test_complete <- cbind(y.test, x.test)
train_complete <- cbind(y.train, x.train)
subject_complete <- rbind(subject.train, subject.test)
complete_data <- rbind(train_complete, test_complete)
complete_data <- cbind(subject_complete, complete_data)

# Create a final table with only the mean and std columns

colheads <- names(complete_data)
dat <- complete_data %>% select(colheads[grepl("subject|activity|(mean|std)\\.",colheads)])

# Relabel the first column with the activity names

activity_labels <- read.table("./activity_labels.txt")
dat$activity <- sapply(dat$activity, function(x) {tolower(activity_labels$V2[as.integer(x)])})

# Give the columns meaningful names
dat <- dat %>% rename_with(~ tolower(gsub("Acc", "_Acceleration", .x, fixed = TRUE)))
dat <- dat %>% rename_with(~ tolower(gsub("jerk", "_jerk", .x, fixed = TRUE)))
dat <- dat %>% rename_with(~ tolower(gsub("gyro", "_gyroscope", .x, fixed = TRUE)))
dat <- dat %>% rename_with(~ tolower(gsub("tbody", "time_body", .x, fixed = TRUE,)))
dat <- dat %>% rename_with(~ tolower(gsub("tgravity", "time_gravity", .x, fixed = TRUE,)))
dat <- dat %>% rename_with(~ tolower(gsub("fbody", "frequency_body", .x, fixed = TRUE,)))

# Create a final tidy data file, and export it as a .txt file.
new_tidy_data <- dat %>% group_by(subject, activity) %>% summarise_all(mean)
write.table(new_tidy_data, file = 'TidyData.txt', row.names = FALSE)
