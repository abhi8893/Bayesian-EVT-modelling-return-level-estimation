sen <- function(..., weights = NULL) {
  mblm::mblm(...)
}

library(broom)
library(tidyverse)

mtcars %>% 
  ggplot(aes(qsec, wt)) +   
  geom_point() +     
  geom_smooth(method = sen)

df_mm <- 
  df_criteria_Tmax %>% 
  nest(-City, -ID, -seas, -variable) %>% 
  mutate(model = map(data, ~sen(value~year, data=.)),
         results = map(model, glance)
  )
