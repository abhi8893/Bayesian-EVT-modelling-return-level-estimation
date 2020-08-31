############################################################
#####################** Description **######################
# evaluate missing data
############################################################

# Evaluate missing data function
# For each station
# 1. By seas [Annual, DJF, MAM, JJAS, ON]
# 2. By year 
# Option - percentage, number of days


get_missing_df <- function(..., df, perc=FALSE, func=summarise){
  # TODO: Implement this
  # miss_col = deparse(substitute(miss_col))
  if (perc){
    miss_func <- function(x) mean(x)*100
  }else{
    miss_func <- sum
  }
  df <- 
    df %>% 
    group_by(...) %>% 
    summarise(missing=miss_func(is.na(value)))
  
  if(perc){
    df %>% 
      rename(missing_perc=missing)
  }else {
    df
  }
  
  
}

get_available_df <- function(..., df, perc=FALSE, func=summarise){
  # TODO: Implement this
  # miss_col = deparse(substitute(miss_col))
  if (perc){
    miss_func <- function(x) mean(x)*100
  }else{
    miss_func <- sum
  }
  df <- 
    df %>% 
    group_by(...) %>% 
    func(available=miss_func(!is.na(value)))
  
  if(perc){
    df %>%
      rename(available_perc=available)
  } else{
    df
  }
  
}

get_available_col <- function(df, ..., perc=FALSE){
  get_available_df(..., df=df, perc=perc, func=mutate)
}

get_missing_col <- function(..., df, perc=FALSE){
  get_missing_df(..., df=df, perc=perc, func=mutate)
}
