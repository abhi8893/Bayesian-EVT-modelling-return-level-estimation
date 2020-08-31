############################################################
#####################** Description **######################
# Function to add city column
############################################################
library(dplyr)

add_city_col <- function(df){
  df_cities <- readRDS('src/R/station_data_analysis/pickles/df_cities.rds')
  df_with_cities <- full_join(df, df_cities)
  return(df_with_cities)
}

if(!interactive()){
  df <- readRDS('src/R/station_data_analysis/pickles/df.rds')
  df_with_cities <- saveRDS(add_city_col(df), 
                            'src/R/station_data_analysis/pickles/df_with_cities.rds')
}