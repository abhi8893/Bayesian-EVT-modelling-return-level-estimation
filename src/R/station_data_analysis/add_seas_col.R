############################################################
#####################** Description **######################
# Add seas col
############################################################

add_seas_col <- function(df){
  seas <- function(month){
    case_when(
      month %in% c(12, 1, 2) ~ 'DJF',
      month %in% c(3, 4, 5) ~ 'MAM',
      month %in% c(6, 7, 8, 9) ~ 'JJAS',
      month %in% c(10, 11) ~ 'ON'
    )
  }
  
  df %>%
    mutate(seas=seas(month))
}
