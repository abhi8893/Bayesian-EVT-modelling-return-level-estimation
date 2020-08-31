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


df_ymiss_joined %>% 
  select(Tmax, year) %>% 
  filter(Tmax >= 80)

df %<>% 
  group_by(ID, City, year, variable, seas) %>% 
  mutate(available_year_perc=mean(!is.na(value))*100)

df_Tmax <-
  df %>% 
  filter(variable == 'Tmax') %>% 
  group_by(ID, City, year, seas) %>% 
  mutate(value=plyr::mapvalues(value ,0, NA), available_year_perc=mean(!is.na(value))*100)
  

df_criteria_Tmax <-
   
  df_seas_comb %>%
  filter(variable == 'Tmax', available_year_perc > 90) %>% 
  group_by(City, ID, seas, variable) %>% 
  complete(year=1969:2018)


df %>% 
  filter(variable == 'Tmax', City == 'JODHPUR') %>%
  group_by(year) %>%
  summarize(missing=mean(is.na(value))*100) %>% 
  tail()

df_seas_comb %>% 
  filter(variable == 'Tmax', City == 'JODHPUR', seas == 'Annual') %>% 
  tail()

df_add_o <-
  textConnection(trimmed_content) %>% 
  read.table(header = T, fill=T) %>% 
  as_tibble

colnames(df_add_o) <- c("ID", "year", "month",
                      "day", "Tmax", "Tmin", "Prec")

df_add_o %>% 
  filter(ID == 42339) %>% 
  select(-Prec, -Tmin) %>% 
  group_by(year) %>% 
  summarise(Tmax=mean(Tmax), missing=mean(is.na(Tmax))) %>% 
  tail()

df_add %>% 
  filter(variable == 'Tmax')

df_add %>%
  filter(ID == 42339, year == 2014) %>% 
  select(Tmax) %>% 
  filter(Tmax == 0)


x <- rnorm(100)
y <- rnorm(100, 1)

get_slope <- function(x, y){
  return(lm(y~x)$coefficients[['x']])
}

df_criteria_Tmax %<>% 
  group_by(ID, City, seas, variable) %>% 
  mutate(trend=get_slope(year, value))


df_trends <- 
  df_criteria_Tmax %>% 
  group_by(City, ID, seas) %>% 
  summarise(trend=mean(trend))

saveRDS(df_criteria_Tmax, 'pickles/df_criteria_Tmax.rds')
