
# Read in the data
df <- readRDS('pickles/df_ally_full.rds')
df <- df %>% 
  gather("variable", "value", Tmax, Tmin, Prec)

# Is there a better way than defining a function?
my.max <- function(..., na.rm=T){
  if(!is.finite(max(..., na.rm = na.rm))){
    return(NA) # TODO: return the right NA type?
  }else{
    return(max(..., na.rm = na.rm))
  }
}

city <- 'KOLKATA (ALIPORE)'
var.name <- 'Prec'
# Annual maxima
df_ymax <- 
  df %>% 
  group_by(ID, City, year, variable) %>% 
  summarise(value=my.max(value)) %>%
  arrange(variable) %>% 
  ungroup()
  

df_ymax %>%
  filter(City == city, variable == var.name) %>% 
  mutate(ID=as.character(ID),
         City=as.character(City))


df.p.ymax <- 
  df_ymax %>% 
  filter(City == city, variable == var.name) %>% 
  mutate(ID=as.character(ID),
         City=as.character(City))

rf.p.ymax <- df.p.ymax$value
years <- df.p.ymax$year

df.p <- df %>% 
  filter(City == city, variable == var.name) %>%
  ungroup() %>% 
  mutate(ID=as.character(ID),
         City=as.character(City))

rf.p <- df.p$value
rf.p2 <- rf.p[!is.na(rf.p)]

rf.p.df <- df.p

years_range <- paste0(min(years), '-', max(years))

rf.p.df %>% 
  drop_na()

df_data <- rf.p.df %>% drop_na()

df_data
