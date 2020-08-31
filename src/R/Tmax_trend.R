library(dplyr)
library(ggplot2)
library(ggpmisc)

df_Tmax <- readRDS('src/R/station_data_analysis/pickles/df_complete.rds')
var_names <- list(Prec='Precipitation', Tmin='Miniumum Temperature', 
                  Tmax='Maximum Temperature')
include_IDs <- c('42867')

make_trend_plot <- function(seas_name, var_name){
  p <- 
    df_Tmax %>%
    ungroup() %>% 
    filter(year < 2016) %>% 
    mutate(City=as.character(City),
           ID=as.character(ID)) %>% 
    filter((ID %in% include_IDs)) %>%
    filter(variable == var_name & seas == seas_name) %>% # [& instead of , ?]
    ggplot(aes(x = year, y = value)) +
    facet_wrap(.~City, scales='free')+
    geom_line()+
    geom_smooth(method='lm')+
    ggtitle(paste(var_names[[var_name]], ":", seas_name))+
    theme(plot.title = element_text(hjust = 0.5))
  
  
  formula <- y ~x
  p <- p +
    stat_fit_glance(method = "lm", 
                    method.args = list(formula = formula),
                    label.x = "left",
                    label.y = "top",
                    aes(label = paste("italic(P)*\"-value = \"*", 
                                      signif(..p.value.., digits = 2), sep = ""),
                        size=0.5),
                    parse = TRUE)
  
  return(p)
}

make_trend_plot('Annual', 'Tmax')
