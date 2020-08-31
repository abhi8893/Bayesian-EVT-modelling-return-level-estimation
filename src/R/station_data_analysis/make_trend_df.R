############################################################
#####################** Description **######################
# Make trend df
# Choose method
#   1. OLS
#   2. Sen's slope

# TODO: Implement below functionality in a much more
#       way by using nest and map multiple models
#       
############################################################

sen <- function(..., weights = NULL) {
  mblm::mblm(...)
}

get_summary <- function(x, y, method='lm', ...){
  # TODO: Find a way to implement formula
  #       While generalising to x and y variable names
  formula <- y~x
  if (method == 'lm'){
    fit <- lm(formula, ...)
  } else if (method == 'sen'){
    fit <- sen(formula, ...)
  }
  
  return(summary(fit))
}

get_trend <- function(x, y, method='lm', ...){
  s <- get_summary(x, y, method=method, ...)
  trend <- s$coefficients['x', 'Estimate']
  return(trend)
}
get_intercept <- function(x, y, method='lm', ...){
  s <- get_summary(x, y, method=method, ...)
  intercept <- s$coefficients['(Intercept)', 'Estimate']
  return(intercept)
}

get_pval <- function(x, y, method='lm', ...){
  if (method == 'lm'){
    stat_name <- 't'
  } else if (method == 'sen'){
    stat_name <- 'V'
  }
  stat_prob <- paste0('Pr(>', '|', stat_name, '|)')
  pval <- get_summary(x, y, method=method, ...)$coefficients['x', stat_prob]
  
  return(pval)
}

# TODO: I would really want the arg names to be ID, seas, variable
#       But they conflict inside the dplyr chain
#       Is there a way to implement it
get_station_fit_stats <- 
function(IDs, seas_names, var_names, 
         rds_file='src/R/station_data_analysis/pickles/df_fit_stats.rds'){
  
  if (file.exists(rds_file)){
    df <- readRDS(rds_file)
  } else{
    main()
    rds_file <- 'src/R/station_data_analysis/pickles/df_fit_stats.rds'
    df <- readRDS(rds_file)
  }
  
  df %>% 
    filter(ID %in% IDs, 
           seas %in% seas_names,
           variable %in% var_names) %>% 
    arrange(City)
  
}

get_station_fit_df <- function(method){
  df <- readRDS('src/R/station_data_analysis/pickles/df_yearmean.rds')
  df_fit_stats <- df %>% 
    group_by(ID, City, seas, variable) %>% 
    summarise(intercept=get_intercept(year, value, method=method),
              trend=get_trend(year, value, method=method),
              pval=get_pval(year, value, method=method))
  
  return(df_fit_stats)
  
  
}

# CHECK: if defining functions later is okay or not?
main <- function(){
  df1 <- get_station_fit_df('lm')
  df2 <- get_station_fit_df('lm')
  
  df_joined <- full_join(df1, df2, by=c('ID', 'City', 'seas', 'variable'), 
                         suffix=c('_lm', '_sen'))
  
  rds_file <- 'src/R/station_data_analysis/pickles/df_fit_stats.rds'
  saveRDS(df_joined, rds_file)
}

if(!interactive()){
  main()
}



