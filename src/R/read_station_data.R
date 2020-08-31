############################################################
#####################** Description **######################
# Read station data from text file.
############################################################

library(dplyr)
library(tidyr)
library(lubridate)
library(ggplot2)

# File path
abs_directory <- '/home/abhi/Documents/mygit/EVS'
rel_directory <- 'data/station_data/91_03'
fname <- 'tab2.txt'

f <- paste(c(abs_directory, rel_directory, 'tab2.txt'), collapse='/')

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
trimmed_content <- all_content[10:(length(trimmed_content) - 2)][-2]

head(trimmed_content)

df <-
  textConnection(trimmed_content) %>% 
  read.table(header = T, fill=T) %>% 
  as_tibble

colnames(df) <- c("ID", "year", "month",
                  "day", "Tmax", "Tmin", "Prec")



# Let's include the station names from another excel table
rel_directory <-  'data/station_data'
f <- paste(c(abs_directory, rel_directory, 'NDCQ-2019-03-091_1.xlsx'),
           collapse='/')
df_metadata <- read_excel(f, skip=6)
# TODO: Find a way to read the whole xlsx
#       which contains multi level header
df_metadata %<>%
  select(ID=`St.Index No.`,
         City=`Station Name`) %>% 
  mutate(ID=factor(ID)) %>% 
  drop_na()


# But not every station has data corresponding to every year
df %>% 
  group_by(ID) %>% 
  summarise(year_start=min(year), year_end=max(year))


# % of missing values grouped by station
# NOTE: This result maybe partly wrong
#       due to absence of missing rows
df %>%
  group_by(ID) %>% 
  select(everything()) %>%  
  summarise_all(list(~mean(is.na(.))*100))



# Now join the two tables
# TODO: Change this to left_join and specifying which columns 
#       to keep from table B
# Let's make sure the ID column in
# both the dataframe has the same levels
combined <- sort(union(levels(df$ID), levels(df_metadata$ID)))


# Ordered factors according to ID value
city_ord_levels <- 
  df_metadata %>% count(ID, City) %>% select(City)

df <- 
  full_join(mutate(df, ID=factor(ID, levels=combined)),
          mutate(df_metadata, ID=factor(ID, levels=combined)), by="ID") %>%
  mutate(City = factor(City, levels=city_ord_levels$City, ordered = TRUE))


# Let's add a date yday column
df <- 
  df %>% 
  mutate(Date=as.Date(paste(year, month, day, sep='-'), # Using capital D
                      "%Y-%m-%d"),
         tobs=as.integer(yday(Date)),
         obs=row_number(),
         ID=as.factor(ID)) %>% 
  select(ID, obs, tobs, month, day, year, everything())



# Let's make the data have explicit missing entries
# between each station's respective start year and end year
df_ally_rel <-
  df %>% 
  group_by(ID, City) %>%
  complete(Date = seq.Date(min(Date), max(Date), by='day')) %>% 
  mutate( tobs=as.integer(yday(Date)),
          obs=row_number(),
          year=year(Date),
          day=day(Date),
          month=month(Date)) %>%
  select(ID, obs, tobs, month, day, year, everything())

  

df_ally_rel %>%
  group_by(ID, City) %>% 
  select(everything()) %>%  
  summarise_all(list(~mean(is.na(.))*100))





# Let's make the data have explicit missing entries
# between 1969-01-01 to 2018-12-31
df_ally_full <-
  df %>% 
  group_by(ID, City) %>% 
  complete(Date = seq.Date(ymd('1969-01-01'), ymd('2018-12-31'), by='day')) %>% 
  mutate( tobs=as.integer(yday(Date)),
          obs=row_number(),
          year=year(Date),
          day=day(Date),
          month=month(Date),
          year=year(Date)) %>%
  select(ID, obs, tobs, month, day, year, everything())


# Visualize number of missing values per year [in days]
# grouped by station
df_ymiss_full <- 
  df_ally_full %>% 
  group_by(ID, City, year) %>% 
  select(Prec, Tmax, Tmin) %>% 
  summarise_all(list(~sum(is.na(.)))) %>% 
  drop_na() # CHECK: Why do I have to do it?
            #        Even when df_ally_full doesn't have any missing?

# Function to visualize number of missing days per year
make_miss_plot <- function(df, variable, y=c("ID", "City"), 
                           limits=c(0, 366), 
                           title="Number of missing days per year",
                           palette='Reds'){
  y <- match.arg(y)
  var_names <- c(Prec="Precipitation", Tmax="Maximum Temperature",
                 Tmin="Minimum Temperature")
  miss_plot <-
    df %>%
    ggplot(aes(x=factor(year), y=get(y)))+
    geom_tile(color='black', aes(fill = get(variable)), colour = "white")+
    scale_fill_distiller(limits=limits, palette=palette,
                         breaks=seq(0, 100, 10),
                        name="% Days")
  
  base_size <- 10
  miss_plot <- 
    miss_plot +
    theme_grey(base_size = base_size) + labs(x = "", y = "")+
    scale_x_discrete(expand = c(0, 0),labels=c(1969:2018))+
    scale_y_discrete(expand = c(0, 0))+
    theme( 
      axis.ticks = element_line(), 
      axis.text.x = element_text(size = base_size *0.8, angle = 45, 
                                 hjust = 0, vjust=-0.2, colour = "grey50"))+
    ggtitle(paste(var_names[[variable]], ":", title))+
    theme(plot.title = element_text(hjust = 0.5))
  
  return(miss_plot)
  
  
}


df_imd <- readRDS("pickles/IMD_excel_missing.rds")

df_ymiss_diff <- 
  df_ymiss_full %>% 
  full_join(select(df_imd, ID, year, missing), by=c("ID", "year")) %>% 
  mutate(Prec=Prec-missing,  # TODO: Find a better of subtracting multiple cols
         Tmax=Tmax-missing,
         Tmin=Tmin-missing) %>% 
  select(-c(missing))


for (variable in c('Prec', 'Tmax', 'Tmin')){
  p <- make_miss_plot(df_ymiss_diff, variable, "City", 
                      limits=c(-366, 366), 
                      title="Difference in the number of missing days per year")
  ggsave(paste0('plots/', variable, '.pdf'), p, width=16, height=10, dpi=400)
}
