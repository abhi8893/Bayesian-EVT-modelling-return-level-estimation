############################################################
#####################** Description **######################
# Demonstration of calculation of return levels
# Author: Abhishek Bhatia

############################################################

# Functions
source('scripts/EXtreme/Functions.R')

# Libraries
library('ncdf4')
library('evdbayes') ; library('coda') ; library('extRemes')

# lat-lon point
p.lat <- 18
p.lon<- 74.5

# Make a netcdf file for that location
system(paste("cdo -remapnn,lon=",p.lon,"_lat=",p.lat, " ", f, " /tmp/point.nc", sep=""))

# Open the nc file
nc0 <- nc_open("/tmp/point.nc")
nc.var <- ncvar_get(nc0, "rf")

# Input dataframe
input<-data.frame(Date=Date('1901-01-01','2017-12-31','1 day'),Value=nc.var)

outdir <-'output/PLOTS/' # Change this to the desired location
plt.title <- paste("Annual", "lon =",p.lon,"lat =",p.lat) 
month.vals <- 1:12 # Choose a sequence of 1 to 12 for Annual

extremes_makeplot(input,2,'month',month.vals,'mm',plt.title, outdir)
