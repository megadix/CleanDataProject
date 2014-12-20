# Loads a complete dataset, merging all related files.
# e.g. for "test" set: X_test.txt, Y_test.txt, body_acc_x_test.txt, ...
loadDataset <- function(dataDir, setName) {
  
  # read features file
  filename <- paste(dataDir, "/features.txt", sep = "")
  features <- read.csv(file = filename, sep = " ")
  
  # retain only std() and mean() columns:
  meanAndStdColumns <- features[
    union(
      grep("mean()", fixed = T, features[,2]),
      grep("std()", fixed = T, features[,2])
    )
    , 1
  ]
  
  # read subject file ---------------------------------------------
  filename <- paste(dataDir, "/", setName, "/subject_", setName, ".txt", sep = "")
  message(paste("Reading", filename))
  data <- read.csv(filename, header = FALSE)
  
  # read X file ---------------------------------------------
  filename <- paste(dataDir, "/", setName, "/X_", setName, ".txt", sep = "")
  message(paste("Reading", filename))
  # read file manually, to avoid memory issues
  temp <- file(filename, open = "rt")
  
  xData <- data.frame()
  
  # buffer multiple lines at once
  rowIdx <- 1
  while(length(input <- readLines(temp, 100)) > 0) {
    for (i in 1:length(input)) {
      # process one line of input
      inputLine <- input[i]
      colIdx <- 1
      # parse only some of the columns
      for (col in meanAndStdColumns) {
        start <- (col - 1) * 16 + 2
        v <- substring(inputLine, start, start + 14)
        xData[rowIdx, colIdx] <- as.numeric(v)
        colIdx <- colIdx + 1
      }
      rowIdx <- rowIdx + 1
    }
    message(paste("Read", nrow(xData), "rows"))
  }
  
  data <- cbind(data, xData)
  
  # read y file ---------------------------------------------
  filename <- paste(dataDir, "/", setName, "/y_", setName, ".txt", sep = "")
  message(paste("Reading", filename))
  data <- cbind(data, read.csv(file = filename, header = FALSE))
  
  data
}

