############################################################
#####################** Description **######################
# Trend_plots helper functions
############################################################

get_var_units <- function(var_name){
  if (var_name == 'Prec'){
    var_units <- 'mm' 
  } else if (var_name %in% c('Tmax', 'Tmean', 'Tmin')){
    var_units <- 'C'
  }
  
  return(var_units)
}

get_pval_with_stars <- function(pval){
  interval <- findInterval(pval, c(0, 0.001, 0.01, 0.05, 0.1, 1), 
                           left.open = T)
  num_stars <- 4 - interval + 1
  pval <- formatC(pval, format='e', digits = 1)
  pval_with_stars <- paste0(pval,
                            paste(rep('*', num_stars), collapse='')
  )
  
  return(pval_with_stars)
  
}

get_fit_label <- function(IDs, seas, variable, method='lm'){
  df <- get_station_fit_stats(IDs, seas, variable)
  trends <- df[[paste0('trend_', method)]]
  
  pvals <- df[[paste0('pval_', method)]]
  pvals_with_stars <- sapply(pvals, get_pval_with_stars)
  label <- paste0('Trend:', ' ', round(trends, 3), ' ', get_var_units(variable),
                  '/year',
                  '\n', 
                  'P-value:', ' ', pvals_with_stars)
  return(label)
}