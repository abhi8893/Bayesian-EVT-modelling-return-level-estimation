source('src/R/station_data_analysis/read_station_data.R')

library(dplyr)
library(readxl)
library(tidyr)

abs_directory <- '/home/abhi/Documents/mygit/EVS'
rel_directory <- 'data/station_data'
f <- paste(c(abs_directory, rel_directory, 'NDCQ-2019-03-091_1.xlsx'),
           collapse='/')
col_names <- c("row_num", 'ID', 'City', 'data_type', 'Hours', 
               'year_start', 'year_end', 'available_years', 'available_total')
df_metadata <- read_excel(f, col_names = col_names,
                 skip=8)

df_metadata %<>% 
  select(-c(Hours, row_num, data_type)) %>%
  mutate(ID=factor(ID)) %>% 
  drop_na()


df_cities <- 
  df_metadata %>% 
  select(ID, City) %>% 
  full_join(tibble(ID=c('42339', '42867'),
                   City=c('JODHPUR', 'NAGPUR (A)')))

saveRDS(df_cities, 'src/R/station_data_analysis/pickles/df_cities.rds')
