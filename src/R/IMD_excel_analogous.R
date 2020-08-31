############################################################
#####################** Description **######################
# Create a analogous data-frame from IMD provided excel file 
# and
# compare the results with actual missing values data-frame
# as computed in read_station_data.R
############################################################

library(dplyr)
library(stringr)
library(ggplot2)

rel_directory <-  'data/station_data'
f <- paste(c(abs_directory, rel_directory, 'NDCQ-2019-03-091_1.xlsx'),
           collapse='/')
col_names <- c("row_num", 'ID', 'City', 'data_type', 'Hours', 
               'year_start', 'year_end', 'available_years', 'available_total')
df <- read_excel(f, col_names = col_names,
                 skip=8)

df %<>% 
  select(-c(Hours, row_num, data_type)) %>%
  mutate(ID=factor(ID)) %>% 
  drop_na()


num_days <- function(year){
  if (year %% 4  == 0){
    return(366)
  } else{
    return(365)
  }
}


# Add years from 1969-2018 to each station
df %<>% 
  group_by_all() %>%
  mutate(year=1969) %>% 
  complete(year=1969:2018)

# Function to parse missing record information from available_years




str_match(s1, '(\\d{4})\\[(\\d{3})\\]')[,2:3]

# Keeping outside the function to avoid repeated
# unneccessary generation of vectors
y <- 1969:2018
d <- setNames(sapply(y, num_days), y)

get_missing_year <- function(s, year){
  year <- as.character(year)
  available <- as.integer(str_match(s, paste0(year, '\\[([0-9]+)\\]'))[, 2])
  if(is.na(available)){
    miss_vals <- d[year]
  } else{
  miss_vals <- d[year] - available
  }
  return(miss_vals)
}

df %<>% 
  group_by(ID, year) %>% 
  mutate(missing=get_missing_year(available_years, year))


saveRDS(df, "pickles/IMD_excel_missing.rds")
