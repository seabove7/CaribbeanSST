###############################################################
##### Pathfinder Raster Conversions and Slope Calculations ####
###############################################################
##--- Last edit was made by Colleen Bove on 15 March 2021 ---##

#---- This script was used with the Pathfinder SST netCDF (pathfinder_combined_monthly_data.nc) to:
#------- 1) add 'NA' to missing vaules (set as -52 in netCDF)
#------- 2) convert all values from Kelvin to Celsius
#------- 3) save edited raster as new netCDF (PathfinderSST_monthly_edit.nc)
#------- 4) calculate slope of change in SST (C / decade) per pixel and save as .csv/.Rdata
#------- 5) calculate p-value of SST slope per pixel and save as .csv

#--- This script was run on a high performance computing cluster due to time requirements (~ 3 hours)
#--- You will need this script and the Pathfinder netCDF (pathfinder_combined_monthly_data.nc) on the cluster
#--- A note in the Rmarkdown (CaribbeanSST_manuscript.Rmd) file references where this script was run 
##############################################################


#### -- The following lines until noted are included in the main script (CaribbeanSST_analysis.Rmd)
#### --- These should be copied from main script to ensure the correct bounds/restrictions are used

## spatial subsetting for Caribbean region (these match the bounds in the markdown)
Xmin<- -95
Xmax<- -55
Ymin<- 0
Ymax<- 40

# libraryies needed for running code:
library(ncdf4)
library(raster)
library(nlme)

## Read in the Pathfinder monthly mean SST dataset (created using python)
path_data <- "pathfinder_combined_monthly_data.nc"
data_brick2<-brick(path_data) # read SST data as rasterbrick
data_brick2<-crop(data_brick2,extent(Xmin,Xmax,Ymin,Ymax)) # clip rasterbrick for Caribbean region extent set above


ncdf_file <- nc_open(path_data) # open the netCDF file

nc_lats <- ncdf_file$dim$lat$vals # extracting lats
nc_longs <- ncdf_file$dim$lon$vals # longs
nc_longs[nc_longs>180] <- nc_longs[nc_longs>180]-360 # convert long values

## time handling
raw_times <- ncdf_file$dim$time$vals # times are seconds after the "start of time"
startoftime <- ncdf_file$dim$time$units # here's what the netCDF considers the start of time
nc_times<-as.POSIXct(raw_times, tz="UTC", gsub("seconds since ","", startoftime)) # removes the "seconds since" text
nc_times <- nc_times+3600*3 # to center readings at noon - just cosmetics
nc_close(ncdf_file) # close the netCDF

## temporal subsetting
start_date2 <- "1981-09-15" # This is the actual start date used in this file but can be changed
end_date2 <- "2019-12-16" # Desired ending date
start_date2 <- as.POSIXct(start_date2, tz="UTC") # change time format
end_date2 <- as.POSIXct(end_date2, tz="UTC") # change time format

## restrict temporally
Tstart_index2 <- min(which(difftime(nc_times,start_date2)>0)) 
Tend_index2 <- min(which(difftime(nc_times,end_date2)>0))
data_brick2 <- data_brick2[[Tstart_index2:Tend_index2]] # this restricts the raster brick by the time constraints
time <- nc_times[Tstart_index2:Tend_index2] # this 'time' list is used throughout the script as the time IDs


#### -- End of previously run scirpt. Below will run new script using the rasterBrick and calculate slope


### Remove NAs and convert to C
KtoC <- function(x){round(x-273.15,2)} # converts the raster from Kelvin to Celsius
NAset <- function(x){x[x < -54]<-NA; return(x)} # Pathfinder uses the value -54 (K) to denote missing data and this function replaces that with NA
data_brick2 <- calc(data_brick2, NAset) # apply the NA function written above to raster
data_brick2b <- calc(data_brick2, KtoC) # apply the Kelvin function written above to raster


### Slope Calculation
## Calculate slope of temperature change across time for each pixel
# gls function applied to the raster brick to calculate the slope of temperature change over timescale of raster (with account of temporal autocorrelation)
gls.fun2 <- function(x, time){
  if(all(is.na(x[1:200]))){ NA }
  else{
    nlme::gls(x ~ time, correlation = corAR1(form = ~ 1 | time), na.action = na.omit, control = list(singular.ok = TRUE))$coefficients[2]*60*60*24 # slope here is degrees/day
    #print(x)
    #print(xyFromCell(raster, x))
  }}


raster_slope2 <- calc(data_brick2b, function(x)lm.fun(x, time = time)) # function applied here

## Create dataframe from calculated slope raster in C per decade for plotting
raster_slope2 <- raster_slope2*(365.25*10) # this is currently C per decade
path_slope <- as.data.frame(as(raster_slope2, "SpatialPixelsDataFrame")) # convert to a raster to da$
colnames(path_slope) <- c("sst", "x", "y")


### P value Calculation
## function to pull the p value per pixel of the simple lm applied to the full HadISST raster brick 
pval.fun <- function(x, time){
  if(any(is.na(x))){NA}
  else{
    summary(nlme::gls(x ~ time, correlation = corAR1(form = ~ 1 | time), na.action = na.omit, control = list(singular.ok = TRUE)))$tTable[2,4] # pulls the p value
  }
}


## function to pull the p value per pixel of the simple lm applied to the full Pathfinder raster brick 
raster_pval2 <- calc(data_brick2b, function(x)pval.fun(x, time = time))

# convert the raster to a df for plotting
path_pavl <- as.data.frame(as(raster_pval2, "SpatialPixelsDataFrame")) # convert to a raster to dataframe
colnames(path_pavl) <- c("pval", "x", "y")
path_pavl$bins <- cut(path_pavl$pval, breaks = bins, labels = bin_names) # bins the pvales into 6 unique bins for plotting



### Save the edited netCDF file and the slope raster/dataframe
writeRaster(data_brick2b, filename = "PathfinderSST_monthly_edit.nc", format="CDF", overwrite=TRUE)
save(path_slope, file = "Pathfinder_slope.Rdata")
write.csv(path_slope, file = "Pathfinder_slope.csv", row.names=FALSE)
write.csv(path_pavl, file = "Pathfinder_pval.csv", row.names=FALSE)

