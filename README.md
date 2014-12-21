# "Getting and Cleaning Data" Course Project

This repository contains my submission of the *"Getting and Cleaning Data" Course Project*.

## Scripts

There is only one R script that does everything:

*run_analysis.R*

## Setup and configuration

### 1) obtain data

Download the ZIP file:

https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

and unzip it into a directory on your computer.

### 2) configure script

Modify the value of ***dataDir*** variable in ***run_analysis.R*** source file, so that it points to the path of downloaded data. Some examples:

Windows:

	dataDir <- "G:/Users/Dimitri/Downloads/UCI HAR Dataset"

Linux/Unix/Mac OS X:

	dataDir <- "/users/dimitri/Downloads/UCI HAR Dataset"

If the data directory is contained in the same directory of the script, you can use a **relative path**, e.g.:

	dataDir <- "UCI HAR Dataset"

### 3) Setup working directory

Call *setwd()* to set the current working directory on your environment.

### 3) run script

After running *run_analysis.R* script, you will find a new file in the working directory, named ***tidy.txt***. It contains the tidy dataset requested by the assignment.