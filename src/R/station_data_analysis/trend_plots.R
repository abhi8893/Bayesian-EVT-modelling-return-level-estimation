library(dplyr)
library(ggplot2)
library(ggpmisc)

source('src/R/station_data_analysis/trend_plot_help.R')

df_var <- readRDS('src/R/station_data_analysis/pickles/df_yearmean.rds')
var_names <- list(Prec='Precipitation', Tmin='Miniumum Temperature', 
                  Tmax='Maximum Temperature')

make_trend_plot <- function(seas_name, 
                            var_name ,
                            include_IDs=c('42647','42339','42807','42369',
                                          '42867','42182','43128'),
                            save_plot=FALSE){
  p <- 
    df_var %>%
    ungroup() %>% 
    mutate(City=as.character(City),
           ID=as.character(ID)) %>% 
    filter((ID %in% include_IDs)) %>%
    filter((variable == var_name) & (seas == seas_name)) %>% #[& instead of , ?]
    ggplot(aes(x = year, y = value)) +
    facet_wrap(.~City, scales='free')+
    geom_line()+
    geom_smooth(method='lm')+
    ggtitle(paste(var_names[[var_name]], ":", seas_name))+
    theme(plot.title = element_text(hjust = 0.5))
  
  p <- 
    p +
    annotate(geom='text',
             x=1970, y=Inf,
             vjust=1, hjust=0,
             size=5,
             label=get_fit_label(include_IDs, seas_name, var_name))
  
  
  
  # formula <- y ~x
  # p <- p +
  #   stat_fit_glance(method = sen, 
  #                   method.args = list(formula = formula),
  #                   label.x = "left",
  #                   label.y = "top",
  #                   aes(label = paste("italic(P)*\"-value = \"*", 
  #                                     signif(..p.value.., digits = 2), sep = ""),
  #                       size=0.5),
  #                   parse = TRUE)
  
  return(p)
}

p <- make_trend_plot('Annual', 'Tmax')
p
