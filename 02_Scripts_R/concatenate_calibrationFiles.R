# Load necessary libraries
library(dplyr)
library(readr)
library(stringr)
library(rstudioapi)

#Manipulation to get into the folder fishCount_in_DOV
current_dir <- getSourceEditorContext()$path
parent_dir <- dirname(current_dir)
parent_dir <- dirname(parent_dir)
setwd(parent_dir)

#Class1
{
setwd("./02_Datasets/dataset1/Nheuristic_calibration")

# Set the directory containing the CSV files
dir_path <- "."

# List all CSV files in the directory
file_list <- list.files(path = dir_path, pattern = "*.csv", full.names = TRUE)

# Initialize an empty dataframe to store combined data
combined_data <- data.frame()

# Loop through each file
for (file in file_list) {
  # Extract filename from the file path
  filename <- basename(file)
  
  # Extract threshold and n_frames values from the filename
  threshold <- str_extract(filename, "(?<=th_)[^_]+")
  n_frames <- str_extract(filename, "(?<=nFrames_)[^_]+")
  
  # Read the data from the CSV file
  data <- read_csv(file)
  
  # Add the extracted information as new columns
  data <- data %>%
    mutate(threshold = threshold, n_frames = n_frames)
  
  # Combine the data into the combined_data dataframe
  combined_data <- bind_rows(combined_data, data)
}

setwd(parent_dir)

setwd("./02_Datasets/dataset1/")

# Save the combined data to a new CSV file
write_csv(combined_data, "combined_data_class1.csv")
}

#Class13
{
  setwd(parent_dir)
  setwd("./02_Datasets/dataset13/Nheuristic_calibration")
  
  # Set the directory containing the CSV files
  dir_path <- "."
  
  # List all CSV files in the directory
  file_list <- list.files(path = dir_path, pattern = "*.csv", full.names = TRUE)
  
  # Initialize an empty dataframe to store combined data
  combined_data <- data.frame()
  
  # Loop through each file
  for (file in file_list) {
    # Extract filename from the file path
    filename <- basename(file)
    
    # Extract threshold and n_frames values from the filename
    threshold <- str_extract(filename, "(?<=th_)[^_]+")
    n_frames <- str_extract(filename, "(?<=nFrames_)[^_]+")
    
    # Read the data from the CSV file
    data <- read_csv(file)
    
    # Add the extracted information as new columns
    data <- data %>%
      mutate(threshold = threshold, n_frames = n_frames)
    
    # Combine the data into the combined_data dataframe
    combined_data <- bind_rows(combined_data, data)
  }
  
  setwd(parent_dir)
  
  setwd("./02_Datasets/dataset13/")
  
  # Save the combined data to a new CSV file
  write_csv(combined_data, "combined_data_class13.csv")
}

#Class17
{
  setwd(parent_dir)
  setwd("./02_Datasets/dataset17/Nheuristic_calibration")
  
  # Set the directory containing the CSV files
  dir_path <- "."
  
  # List all CSV files in the directory
  file_list <- list.files(path = dir_path, pattern = "*.csv", full.names = TRUE)
  
  # Initialize an empty dataframe to store combined data
  combined_data <- data.frame()
  
  # Loop through each file
  for (file in file_list) {
    # Extract filename from the file path
    filename <- basename(file)
    
    # Extract threshold and n_frames values from the filename
    threshold <- str_extract(filename, "(?<=th_)[^_]+")
    n_frames <- str_extract(filename, "(?<=nFrames_)[^_]+")
    
    # Read the data from the CSV file
    data <- read_csv(file)
    
    # Add the extracted information as new columns
    data <- data %>%
      mutate(threshold = threshold, n_frames = n_frames)
    
    # Combine the data into the combined_data dataframe
    combined_data <- bind_rows(combined_data, data)
  }
  
  setwd(parent_dir)
  
  setwd("./02_Datasets/dataset17/")
  
  # Save the combined data to a new CSV file
  write_csv(combined_data, "combined_data_class17.csv")
}