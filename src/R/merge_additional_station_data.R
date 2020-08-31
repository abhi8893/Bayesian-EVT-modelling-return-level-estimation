df <- readRDS('pickles/df_ally_full.rds')

library(dplyr)
library(tidyr)
library(lubridate)
library(ggplot2)

# File path
abs_directory <- '/home/abhi/Documents/mygit/EVS'
rel_directory <- 'data/station_data/91_03'
fname <- 'tab2_additional.txt'

f <- paste(c(abs_directory, rel_directory, fname), collapse='/')

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

df_add <-
  textConnection(trimmed_content) %>%
  read.table(header = T, fill=T) %>% 
  as_tibble

colnames(df_add) <- c("ID", "year", "month",
                  "day", "Tmax", "Tmin", "Prec")

df <-
  df %>% 
  gather('variable', 'value', Tmax, Tmin, Prec)

get_city <- function(ID){
  if (ID == '42339'){
    return('JODHPUR')
  }else if(ID == '42867'){
    return('NAGPUR (A)')
  }
}

df_add %<>%
  gather("variable", "value", Tmax, Tmin, Prec) %>% 
  mutate(Date=as.Date(paste(year, month, day, sep='-'), # Using capital D
                      "%Y-%m-%d"),
         tobs=as.integer(yday(Date)),
         obs=row_number(),
         ID=as.factor(ID),
         City=plyr::mapvalues(ID, c('42339', '42867'), 
                              c('JODHPUR', 'NAGPUR (A)'))
  ) 

df_add <- 
  df_add %>% 
  group_by(ID, City, variable) %>% 
  complete(Date = seq.Date(ymd('1969-01-01'), ymd('2018-12-31'), by='day')) %>% 
  mutate( tobs=as.integer(yday(Date)),
          obs=row_number(),
          year=year(Date),
          day=day(Date),
          month=month(Date),
          year=year(Date))


# Drop JODHPUR and NAGPUR
df <- 
  df %>%
  filter(!(City %in% c('JODHPUR', 'NAGPUR (MAYO HOSPITAL)')))


df_full <- 
  full_join(df, df_add)

df_full_s <- 
  df_full %>% 
  spread(variable, value)

df_ymiss_joined <- 
  df_full_s %>% 
  group_by(ID, City, year) %>% 
  select(Prec, Tmax, Tmin) %>% 
  summarise_all(list(~mean(is.na(.))*100)) %>% 
  drop_na()


df_cities <- tibble(ID=unique(df_full_s$ID), City=unique(df_full_s$City))

saveRDS(df_full_s, "pickles/df_ally_full_joined.rds")
