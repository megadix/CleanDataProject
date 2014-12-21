# Loads a complete dataset, joining all columns of related files.
# e.g. for "test" set: X_test.txt, Y_test.txt
loadDataset <- function(setName) {
  
  message(paste("Loading dataset:", setName))
  
  dataDir <- "data"
  
  # read features file
  
  filename <- paste(dataDir, "/features.txt", sep = "")
  features <- read.csv(file = filename, sep = " ", header = FALSE)
  
  # build an array with the indexes of columns to retain: std() and mean()
  # See point #2:
  #   "Extracts only the measurements on the mean and standard deviation for each measurement."
  
  choosenColumns <- features[
    sort(
      union(
        grep("mean()", fixed = T, features[,2]),
        grep("std()", fixed = T, features[,2])
      )
    )
    , 1
  ]
  
  # read subject file ---------------------------------------------
  
  filename <- paste(dataDir, "/", setName, "/subject_", setName, ".txt", sep = "")
  message(paste("Reading", filename))
  data <- read.csv(filename, header = FALSE, col.names = c("subject_id"))
  data$subject_id <- factor(data$subject_id)
  
  # read X file ---------------------------------------------
  
  filename <- paste(dataDir, "/", setName, "/X_", setName, ".txt", sep = "")
  message(paste("Reading", filename))
  
  # read file manually, to avoid memory overflows
  temp <- file(filename, open = "rt")
  xData <- data.frame()
  
  # buffer multiple lines at once
  bufSize <- 100
  rowIdx <- 1
  
  while(length(input <- readLines(temp, bufSize)) > 0) {
    for (i in 1:length(input)) {
      # process one line of input
      inputLine <- input[i]
      # parse columns we're interested in
      for (col in choosenColumns) {
        start <- (col - 1) * 16 + 2
        v <- substring(inputLine, start, start + 14)
        colname <- features[col, 2]
        xData[rowIdx, as.character(colname)] <- as.numeric(v)
      }
      rowIdx <- rowIdx + 1
    }
    message(paste("Read", nrow(xData), "rows"))
  }
  
  data <- cbind(data, xData)
  
  close(temp)
  
  # read y file ---------------------------------------------
  filename <- paste(dataDir, "/", setName, "/y_", setName, ".txt", sep = "")
  message(paste("Reading", filename))
  data <- cbind(data, read.csv(file = filename, header = FALSE, col.names = "activity_id"))
  data$activity_id <- factor(data$activity_id)
  
  data
}

glueDatasets <- function() {
  data <- loadDataset("train")
  data <- rbind(data, loadDataset("test"))  
  
  data
}

labelActivities <- function(data) {
  activities <- read.csv("data/activity_labels.txt", sep = " ", header = FALSE,
                         col.names = c("activity_id", "activity_label"))
  merge(x = data, y = activities)
}

aggregateData <- function(data) {
  melt <- melt(data, id.vars = c("activity_id", "subject_id", "activity_label"))
  dcast(melt, subject_id + activity_id + activity_label ~ variable, mean)
}

# ---------------------------------------------------------------
# Main execution
# ---------------------------------------------------------------

# data <- glueDatasets()
# data <- labelActivities(data)

tidy <- aggregateData(data)

write.table(tidy, file = "tidy.txt", row.names = FALSE)