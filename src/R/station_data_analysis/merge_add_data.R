source('src/R/station_data_analysis/read_station_data.R')

abs_directory <- '/home/abhi/Documents/mygit/EVS'
rel_directory <- 'data/station_data/91_03'

f1 <- paste(c(abs_directory, rel_directory, 'tab2.txt'), collapse='/')
f2 <- paste(c(abs_directory, rel_directory, 'tab2_additional.txt'), collapse='/')

df1 <- read_imd_station_data(f1)
df2 <- read_imd_station_data(f2)

df <- full_join(df1, df2)

saveRDS(df, 'src/R/station_data_analysis/pickles/df.rds')
