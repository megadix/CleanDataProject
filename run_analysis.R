# Reads the list of variables of the study
readFeatures <- function(dataDir) {
  # read features file
  filename <- paste(dataDir, "/features.txt", sep = "")
  message(paste("Loading features:", filename))
  read.csv(file = filename, sep = " ", header = FALSE)
}

# Loads a complete dataset, joining all columns of related files.
# e.g. for "test" set: X_test.txt, Y_test.txt
loadDataset <- function(dataDir, setName, features) {
  
  message(paste("Loading dataset:", setName))
    
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

# Add labels to activities
labelActivities <- function(dataDir, data) {
  activities <- read.csv(paste(dataDir, "activity_labels.txt", sep = "/"), sep = " ", header = FALSE,
                         col.names = c("activity_id", "activity_label"))
  merge(x = data, y = activities)
}

# perform data reshaping and aggregation
aggregateData <- function(data) {
  melt <- melt(data, id.vars = c("activity_id", "subject_id", "activity_label"))
  dcast(melt, subject_id + activity_id + activity_label ~ variable, mean)
}

# ---------------------------------------------------------------
# Main execution
# ---------------------------------------------------------------

dataDir <- "UCI HAR Dataset"

features <- readFeatures(dataDir)
data <- loadDataset(dataDir, "train", features)
data <- rbind(data, loadDataset(dataDir, "test", features))
data <- labelActivities(dataDir, data)
tidy <- aggregateData(data)

# write data
message("Writing tidy.txt")
write.table(tidy, file = "tidy.txt", row.names = FALSE)