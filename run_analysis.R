##install and load necessary packages
install.packages("dplyr")
library(dplyr)

#download the dataset
#create a variable with the name of the destination folder
files <- "Coursera_UCI.zip"

#check to see if the folder exists and if not, download it from the web
if (!file.exists(files)){
  filesource <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(filesource, files)
}  

#check for folder and unzip if it doesn't exist yet, creating a new folder with the data in it
if (!file.exists("UCI HAR Dataset")) { 
  unzip(files) 
}


#read through each text file and create a data frame for each one's contents
features <- read.table("UCI HAR Dataset/features.txt", col.names = c("n","functions"))
activities <- read.table("UCI HAR Dataset/activity_labels.txt", col.names = c("activitycode", "activity"))
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt", col.names = "subject")
x_test <- read.table("UCI HAR Dataset/test/X_test.txt", col.names = features$functions)
y_test <- read.table("UCI HAR Dataset/test/y_test.txt", col.names = "activitycode")
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt", col.names = "subject")
x_train <- read.table("UCI HAR Dataset/train/X_train.txt", col.names = features$functions)
y_train <- read.table("UCI HAR Dataset/train/y_train.txt", col.names = "activitycode")


#the data is still separate and needs to be joined into a single data set

#first use rbind to connect the x data
x <- rbind(x_train, x_test)
#then use rbind to connect the y data
y <- rbind(y_train, y_test)
#then use rbind to connect the subject data
subject <- rbind(subject_train, subject_test)
#lastly join all 3 together with cbind
datamerged <- cbind(subject, y, X)



#subset the data to get just the mean and standard deviation
tidydata <- datamerged %>% select(subject, activitycode, contains("mean"), contains("std"))


#swap out the activity code for the activity label

tidydata$activitycode <- activities[tidydata$activitycode, 2]


#replace the data labels with improved data labels

names(tidydata)[2] = "activity"
names(tidydata)<-gsub("Acc", "accelerometer", names(tidydata))
names(tidydata)<-gsub("Gyro", "gyroscope", names(tidydata))
names(tidydata)<-gsub("BodyBody", "body", names(tidydata))
names(tidydata)<-gsub("Mag", "magnitude", names(tidydata))
names(tidydata)<-gsub("^t", "time", names(tidydata))
names(tidydata)<-gsub("^f", "frequency", names(tidydata))
names(tidydata)<-gsub("tBody", "timebody", names(tidydata))
names(tidydata)<-gsub("-mean()", "mean", names(tidydata), ignore.case = TRUE)
names(tidydata)<-gsub("-std()", "std", names(tidydata), ignore.case = TRUE)
names(tidydata)<-gsub("-freq()", "frequency", names(tidydata), ignore.case = TRUE)
names(tidydata)<-gsub("angle", "angle", names(tidydata))
names(tidydata)<-gsub("gravity", "gravity", names(tidydata))



#subset just the averages
FinalData <- tidydata %>%
    group_by(subject, activity) %>%
    summarize_all(funs(mean))
write.table(FinalData, "FinalData.txt", row.name=FALSE)

 
