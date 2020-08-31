# Cleaning the memory
rm(list=ls())

# Get state and district from args
args <- commandArgs()
state <- args[6]
district <- args[7]

# Functions
source('Functions.R')

# Libraries
library('ncdf4')
library('evdbayes') ; library('coda') ; library('extRemes')

# Open NETCDF file
nc0<-nc_open(paste0('../../junk/regions/',state,'/',district,'.nc'))
nc.raw<-ncvar_get(nc0,'rf')

input<-data.frame(Date=Date('1901-01-01','2017-12-31','1 day'),Value=nc.raw)

# Data
# Threshold
# Frequency season month
# Period monsoon 1
# Units
# Place - (State,District, City,...)
# Address where the figures will be saved
result<-extremes_makeplot(input,2,'season','monsoon','mm',district,paste0('../../output/plots/',state, '/'))
