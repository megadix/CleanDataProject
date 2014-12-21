# Code book for "Getting and Cleaning Data" Course Project

This file contains the description of data contained in this repository.

# Sources

The source of the data is *Human Activity Recognition Using Smartphones Data Set* from UCI Machine Learning Repository:
http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

# Data trasformations

The data has been transformed according to instructions given in the course project assignment:

1. merge the training and the test sets to create one data set;
2. extract only the measurements on the mean and standard deviation for each measurement;
3. use descriptive activity names to name the activities in the data set;
4. appropriately label the data set with descriptive variable names;
5. from the data set in step 4, create a second, independent tidy data set with the average of each variable for each activity and each subject.

The *run_analysis.R* script implements these specifications.

## Main

At the end of the script, after the definitions of the functions, is the main execution.

- the ***data*** dataframe is progressively enhanced and transformed into the complete data set;
- data contained in *data* is transformed and aggregated, then stored into ***tidy*** data frame;
- *tidy* data frame is stored into ***tidy.txt*** file.

## readFeatures()

Reads the list of variables of the study, used later in other functions.

## loadDataset()

This function loads all the appropriate files from the specified set (*setName* variable), e.g. for "test" dataset:

- test/subject_test.txt
- test/X_test.txt
- test/y_test.txt

The first file to be loaded is the subject file.

The second file to be loaded is the *"X_"* file. Since the input data is huge, and that only a subset of it must be kept, the reading of source files has been implemented as a **read buffer loop** (buffer size = 100 lines). This makes it possible to use very little memory, at the price of a slower processing.

The last file is *"y_"*, which gives the *activity_id* field.

## labelActivities()

This function loads the ***activity_labels.txt***, assigning activity labels according to *activity_id* fields.

## aggregateData()

This functions performs the reshaping and aggregation of the data:

1. *melt()* the data frame, transforming it from "wide" to "tall";
2. aggregate the resulting data frame using *dcast()* function and aggregating using *mean*.

## Write tidy.txt

Finally, *tidy* data frame is written into ***tidy.txt*** file using *write.table()* as specified by assignment.