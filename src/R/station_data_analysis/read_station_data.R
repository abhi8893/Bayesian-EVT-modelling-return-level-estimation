library(dplyr)
library(readr)

# Create a function to read imd station data
read_imd_station_data <- function(f, 
                                  col_names=c("ID", "year", "month",
                                              "day", "Tmax", "Tmin", "Prec"),
                                  col_types=c('f', 'i', 'i', 'i', 'd', 'd', 'd')
                                  ){
  
  # Since there is some text at the beginning
  # Let's read first 20 lines
  content <- readLines(f, 20)
  
  # Looks like this
  # Header is at 10th line
  # Values start from 12th line
  content
  
  # Keep the metadata content
  metadata <- content[1:9]
  
  
  # Let's read all the content and trim it
  all_content <- readLines(f)
  
  # But last two rows are not needed
  tail(all_content)
  
  # Trim to keep the header row and actual values
  # Remove the row after header since it has -----
  # Remove the last two rows
  trimmed_content <- all_content[10:(length(all_content) - 3)][-2]
  
  head(trimmed_content)
  
  col_names <- c("ID", "year", "month",
                 "day", "Tmax", "Tmin", "Prec")
  col_types <- c('f', 'i', 'i', 'i', 'd', 'd', 'd')
  
  details_fwf <- fwf_empty(trimmed_content,
                           col_names = col_names)
  
  df <- read_fwf(trimmed_content, col_positions = details_fwf, 
                 col_types = paste(col_types, collapse=''), skip=1)
  
  return(df)
  
  
}
# File path
if (!interactive()) {
  abs_directory <- '/home/abhi/Documents/mygit/EVS'
  rel_directory <- 'data/station_data/91_03'
  
  f <- paste(c(abs_directory, rel_directory, 'tab2.txt'), collapse='/')
  f_add <- paste(c(abs_directory, rel_directory, 'tab2_additional.txt'), 
                 collapse='/')
  
  read_imd_station_data(f_add)
}



