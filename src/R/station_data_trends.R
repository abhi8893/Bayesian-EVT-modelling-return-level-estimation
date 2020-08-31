library(dplyr)
library(tidyr)
library(ggpmisc)

abs_dir <- '/home/abhi/Documents/mygit/EVS'
rel_dir <- 'pickles'
fname <- 'df_ally_full_joined.rds'
f <- paste(c(abs_dir, rel_dir, fname), collapse = '/')
df <- readRDS(f)
df <- df %>% 
  gather("variable", "value", Tmax, Tmin, Prec)

get_seas <- function(month){
  if(month %in% c(12, 1, 2)){
    seas <- 'DJF'
  }else if(month %in% c(3, 4, 5)){
    seas <- 'MAM'
  }else if(month %in% c(6, 7, 8, 9)){
    seas <- 'JJAS'
  }else if(month %in% c(10, 11)){
    seas <- 'ON'
  }
  
  return(seas)
}

df %<>% 
  rowwise() %>%  # WARNING: really slow! Find alternative.
  mutate(seas=get_seas(month)) %>% 
  ungroup() # Verify: If this works.

df_cities <- tibble(ID=unique(df$ID), City=unique(df$City))
View(df_cities)  


# city <- df_cities %>% filter(ID == '')

# Season wise
df_seas <- 
  df_Tmax %>% 
  group_by(City, ID, year, seas, variable) %>%
  summarise(value=mean(value, na.rm = T)) %>%
  group_by(City, ID, year, variable) %>% 
  mutate(available_year_perc=mean(!is.na(value))*100) %>% 
  ungroup() %>% 
  arrange(seas, variable, City, ID, year) # Some other way?

# Annual
# TODO: Find a way to do seas wise in one step?
df_annual <- 
  df_Tmax %>% 
  group_by(City, ID, year, variable) %>% 
  summarise(value=mean(value, na.rm = T)) %>%
  group_by(City, ID, year, variable) %>% 
  mutate(available_year_perc=mean(!is.na(value))*100) %>% 
  ungroup() %>% 
  mutate(seas='Annual')
  # arrange(seas, variable, City, ID, year) # Some other way? Doesn't work.

  
# Join the two dfs
df_seas_comb <- full_join(df_seas, df_annual)




get_trend <- function(eq){
  x_term <- strsplit(eq, '\\s')[[1]][3]
  trend <- gsub("x", "", x_term)
  return(trend)
  
}

annotate_textp <- function(label, x, y, facets=NULL, hjust=0, vjust=0, color='black', alpha=NA,
                           family=thm$text$family, size=thm$text$size, fontface=1, lineheight=1.0,
                           box_just=ifelse(c(x,y)<0.5,0,1), margin=unit(size/2, 'pt'), thm=theme_get()) {
  x <- scales::squish_infinite(x)
  y <- scales::squish_infinite(y)
  data <- if (is.null(facets)) data.frame(x=NA) else data.frame(x=NA, facets)
  
  tg <- grid::textGrob(
    label, x=0, y=0, hjust=hjust, vjust=vjust,
    gp=grid::gpar(col=alpha(color, alpha), fontsize=size, fontfamily=family, fontface=fontface, lineheight=lineheight)
  )
  ts <- grid::unit.c(grid::grobWidth(tg), grid::grobHeight(tg))
  vp <- grid::viewport(x=x, y=y, width=ts[1], height=ts[2], just=box_just)
  tg <- grid::editGrob(tg, x=ts[1]*hjust, y=ts[2]*vjust, vp=vp)
  inner <- grid::grobTree(tg, vp=grid::viewport(width=unit(1, 'npc')-margin*2, height=unit(1, 'npc')-margin*2))
  
  layer(
    data = NULL,
    stat = StatIdentity,
    position = PositionIdentity,
    geom = GeomCustomAnn,
    inherit.aes = TRUE,
    params = list(
      grob=grid::grobTree(inner), 
      xmin=-Inf, 
      xmax=Inf, 
      ymin=-Inf, 
      ymax=Inf
    )
  )
}


# Visualize


get_coeff_label <- function(x, y, variable){
  
  s <- summary(lm(y~x))
  trend <- s$coefficients['x', 1]
  if(variable == 'Prec'){
    units <- 'mm/year'
  }else if (variable %in% c('Tmean', 'Tmax', 'Tmin')){
    units <- 'C/year'
  }
  label <- paste('Trend =', round(trend, 2), units)
  return(label)
}
var_names <- list(Prec='Precipitation', Tmin='Miniumum Temperature', 
                  Tmax='Maximum Temperature')

# exclude_cities <- c('JODHPUR', 'NAGPUR (MAYO HOSPITAL)')
# if (var_name == 'Prec'){
#   exclude_cities <- c(exclude_cities, 'GUWAHATI / BORJHAR(A)', 
#                       'IMPHAL / TULIHAL(A)')
# }

include_IDs <- c('42182', '42369', '42807',
                 '43128', '42647', '42339')
var_name <- 'Tmax'
seas_name <- 'JJAS'

make_trend_plot <- function(seas_name){
  p <- 
    df_criteria_Tmax %>%
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
  
  
p

# TODO 1: Function to plot (variable, seas, to_exclude)
# TODO 2: Fit/map linear models and store them in a tibble column
# TODO 3: Extract relevant results from the model
# NOTE: For reference see the R for data science [Models]
