df_filled <- 
  df %>% 
  group_by(ID, City, tobs, variable) %>% 
  fill(value)


df_miss <- 
  df %>% 
  ungroup() %>% 
  mutate(ID=as.character(ID),
         City=as.character(City)) %>% 
  group_by(ID, City, year, variable) %>% 
  summarise(missing=sum(is.na(value)))

df_ymiss <- 
  df_miss %>%
  count(year, variable, wt=missing, name = 'missing') %>%
  spread(variable, missing)
