#################################################################################
################ SST Extraction at Reef Location GPS Coordinates  ################
#################################################################################
##--- Last edit was made by Colleen Bove on 10 March 2021 ---##

#---- This script can be used with either the Pathfinder or HadISST netCDF to:
#------- 1) assign Caribbean reef coordinates to each ecoregion
#------- 2) extract SST from raster based on specific Caribbean reef GPS coordinates
#------- 3) transform extracted SST into a dataframe
#------- 4) save the dataframe as a .Rdata object and .csv


#--- This script was run on a high performance computing cluster due to time requirements
#--- You need this script, SST netCDF (HadISST), Caribbean reef GPS coordinates, and ecoregion shapefiles (Caribbean_ecoregions.shp) on the cluster
#--- A note in the Rmarkdown (CaribbeanSST_analysis.Rmd) file references where this script was run for each data set
##############################################################

#### Set paths for desired SST netCDF and shapefiles:
# this is currently set to run with HadISST data (HadISST_sst.nc) extracted with the Caribbean reefs cliped by ecoregions
# the script can be adapted to any similar netCDF/shapefile combination

database <- "HadISST" # set which database being used for saving files
netCDF <- "data/HadISST/HadISST_sst.nc" # this is the desired SST netCDF and path
reef_locations <- "data/ReefData/CaribbeanReef_points.csv" # name of the file with the reef GPS coordinates
region_shapes <- "data/Ecoregions/Caribbean_ecoregions.shp" # name of ecoregion shape file (with .shp extension)
region_path <- "data/EcoRegions" # path to ecoregion shape files
region_name <- "Caribbean_ecoregions" # how the ecoregion shapefiles are named (without the extension)

## Spatial subsetting for Caribbean region
Xmin <- -100
Xmax <- -55
Ymin <- 0
Ymax <- 40

## set the projection
proj <- "+proj=longlat +ellps=WGS84 +datum=WGS84"


#######################

### Load libraries
library(raster)
library(rgdal)
library(sf)
library(ncdf4)
library(tidyverse)
library(foreach)


### Set up the ecoregions and reef locations

## Read in the reef points csv and clipped Caribbean ecoregion shapefile
reef_gps <- read.csv(reef_locations) # read in FULL reef locations csv
ecoreg <- sf::read_sf(region_shapes) # this is used for ecoregion name list (plotting ecoregion bounds)
ecoregions2 <- readOGR(region_path, region_name) # this is used for assigning ecoregion in the forloop


## Subset shapefile for the TNA province (code 12) with Bermuda removed and only the N. GoM within the WTNA province (codes 6)
carib_ecoreg <- ecoreg %>% 
  filter(PROV_CODE == 12 & ECOREGION != "Bermuda" | PROV_CODE == 6 & ECOREGION == "Northern Gulf of Mexico") 

## create unique reef id
reef_points <- reef_gps %>%
  mutate(reef_id = as.numeric(interaction(lat, lon, drop=TRUE))) %>%
  filter()

## transform points into SpatialPointsDataFrames and modify projection to be the same
coordinates(reef_points) <- c("lon", "lat")  
projection(reef_points) <- proj # apply projection to reef coordinates
projection(ecoregions2) <- proj # apply projection to ecoregions

## create a list of the ecoregions (used in the forloop)
eco_list <- carib_ecoreg$ECOREGION


### Extract SST using the ecoregion classifications and reef points

## Create an empty dataframe to populate while running the forloop with the following parameters:
eco_df <- data.frame('date' = integer(),
                     'sst' = integer(),
                     'ecoregion' = factor())

eco_sst_df <- data.frame('date' = integer(),
                         'sst' = integer(),
                         'ecoregion' = factor())


#### Run the forloop in parallel (if able):

## Read in the netCDF and clip based on Caribbean bounds
data_brick <- brick(netCDF) # read SST data as rasterbrick
raster_brick <- crop(data_brick, extent(Xmin, Xmax, Ymin, Ymax)) # clip rasterbrick for Caribbean region only (see 'spatial subsetting' above)
layers <- raster_brick@data@nlayers

for(e in 1:length(eco_list)) {
 
  ## First, select reefs within specific ecoregion 
  ecoregion_name <- eco_list[[e]] # pull the name of ecoregion
  subset_ecoreg <- ecoregions2[ecoregions2@data$ECOREGION == ecoregion_name, ] # subset for only the desired ecoregion
  projection(subset_ecoreg) <- proj # modify the lat/lon projection to match reef points
  ecoregion_reefs <- reef_points[subset_ecoreg, ] # clip the reef points by the ecoregion bounds
  
  output <- foreach(i = 1:layers, .combine = "rbind", .packages = c("raster", "rgdal", "sf", "ncdf4", "tidyverse")) %dopar% {
    
    ## Read in the netCDF and clip based on Caribbean bounds
    data_brick <- brick("data/HadISST/HadISST_sst.nc") # read SST data as rasterbrick
    raster_brick <- crop(data_brick, extent(Xmin, Xmax, Ymin, Ymax)) # clip rasterbrick for Caribbean region only (see 'spatial subsetting' above)
    
    ## Then, extract SST from reef locations wihtin the current ecoregion and append to dataframe
    raster <- raster_brick[[i]] # select the layer of the rasterbrick 
    sst_vals <- raster::extract(raster, ecoregion_reefs) # extract SST at lat/lon of each reef
    # create dataframe of current layer (date) and extracted SST
    df <- data.frame('date' = raster@data@names,
                     'sst' = sst_vals)
    df$ecoregion <- rep(ecoregion_name, length(df$date)) # add a ecoregion name column
    eco_df <- rbind(eco_df, df) # adds current layer SST data to the full dataframe
    
    return(eco_df)
  }
  eco_sst_df <- rbind(eco_sst_df, output)
}




## Once completed, saves the resulting dataframe as both a .Rdata object and .csv
# *** Only uncomment these lines if you want to write over existing files ***
save(eco_sst_df, file = paste(database, "_ecoregion_sst.Rdata", sep = ""))
write.csv(eco_sst_df, file = paste(database, "_ecoregion_sst.csv", sep = ""), row.names=FALSE)
