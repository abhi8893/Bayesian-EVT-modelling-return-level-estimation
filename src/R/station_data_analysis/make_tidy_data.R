############################################################
#####################** Description **######################
# Making data tidy and complete
############################################################

library(dplyr)
library(lubridate)
library(tidyr)

source('src/R/station_data_analysis/add_city_col.R')
source('src/R/station_data_analysis/add_seas_col.R')
source('src/R/station_data_analysis/evaluate_missing_data.R')

df <- readRDS('src/R/station_data_analysis/pickles/df.rds')


date_range <- 
  df %>% 
  summarise_at(vars(year, month, day), funs(list(range(., na.rm=T)))) %>% 
  unnest() %>% 
  rowwise() %>% 
  mutate(Date=as.Date(paste(year, month, day, sep='-')))

to <- date_range$Date[1]
from <- date_range$Date[2]



  

df <- 
  df %>% 
  mutate(Date=as.Date(paste(year, month, day, sep='-'))) %>%
  add_city_col() %>% 
  group_by(ID, City) %>% 
  complete(Date=seq.Date(to, from, 'day')) %>%
  ungroup() %>% # Good Practice plus you can't modify a grouping variable
  mutate(year=year(Date), month=month(Date), day=day(Date)) %>% 
  add_seas_col() %>% 
  add_var_col() %>%
  get_available_col(ID, City, year, seas, perc=TRUE) %>% 
  select(ID, City, everything())

saveRDS(df, 'src/R/station_data_analysis/pickles/df_complete.rds')

