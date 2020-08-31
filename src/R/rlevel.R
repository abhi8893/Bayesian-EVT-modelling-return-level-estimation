calc.rlevel <- function(x, rl){
  tryCatch({
  if (any(is.na(x))){return(NA)} else {
  fit <- fevd(x, method='Lmoments', units = "mm/day")
  rlevel <- return.level(fit, return.period = rl)[paste(rl)]
  return(rlevel)
  }
  },
  error=function(cond) {
    return(NA)
  }
  )
}

