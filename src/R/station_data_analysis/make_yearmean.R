library(dplyr)
library(tidyr)
df <- readRDS('src/R/station_data_analysis/pickles/df_complete.rds')

df_cities <- readRDS('src/R/station_data_analysis/pickles/df_cities.rds')

df_criteria <- 
  df %>% 
  filter(!(ID %in% c('10202', '42866')) & (available_perc > 90) &(year < 2016)) 
  

df_seas <- 
  df_criteria %>% 
  group_by(ID, City, year, seas, variable) %>% 
  summarise(value=mean(value, na.rm=T)) %>%
  group_by(ID, City, seas, variable) %>% # VERIFY: Do I need to group again?
  complete(year=1969:2018)


df_annual <- 
  df_criteria %>% 
  group_by(ID, City, year,variable) %>% 
  summarise(value=mean(value, na.rm=T)) %>%
  group_by(ID, City, variable) %>% # VERIFY: Do I need to group again?
  complete(year=1969:2018) %>% 
  mutate(seas='Annual')

df_yearmean <- full_join(df_seas, df_annual)  

saveRDS(df_yearmean, 'src/R/station_data_analysis/pickles/df_yearmean.rds')

