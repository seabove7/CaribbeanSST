##############################################################
#############  SST Extraction by Reef Polygons  ##############
##############################################################
##--- Last edit was made by Colleen Bove on 31 July 2020 ---##

#---- This script can be used with either the Pathfinder SST EDITED netCDF (PathfinderSST_monthly_edit.nc) or HadISST netCDF to:
#------- 1) extract SST from raster based on Caribbean reef shapefile polygons
#------- 2) transform extracted SST into a dataframe
#------- 3) save the dataframe as a .Rdata object and .csv


#--- This script was run on a high performance computing cluster due to time requirements (~ 34 hours; single node)
#--- You will need this script, SST netCDF (Pathfinder or HadISST), and Caribbean shapefiles on the cluster
#--- A note in the Rmarkdown (CaribbeanSST_analysis.Rmd) file references where this script was run for each data set
##############################################################

#### Set paths for desired SST netCDF and shapefiles:
# this is currently set to run with Pathfinder data (PathfinderSST_monthly_edit.nc) extracted with Caribbean shapefiles (Caribbean_reefs.shp)
# the script can be adapted to any similar netCDF/shapefile combination

data_set <- "Pathfinder" # specify the name of the data set here so it will be named as: 'data_set'_reefs_poly
netCDF <- "/pine/scr/c/o/colbrynn/SCRATCH/SST_data/Pathfinder/PathfinderSST_monthly_edit.nc" # this is the desired SST netCDF and path
shape_path <- "/pine/scr/c/o/colbrynn/SCRATCH/SST_data/HADISST/Longleaf_working" # path to shape files
shape_name <- "Caribbean_reefs" # how the shapefiles are names (without the extension)

#######################

## Load libraries 
library(sf)
library(ncdf4)
library(raster)
library(rgdal)
library(tidyverse)
library(xts)
library(tidyr)
library(dplyr)
library(sp)


## Load data
shapes <- readOGR(shape_path, shape_name) # load the Caribbean shapefiles
sst_raster <- brick(netCDF) # convert netCDF to rasterBrick


## Create an empty dataframe to populate while running the forloop with the following parameters:
extract_df <- data.frame('date' = integer(),
                         'mean' = integer(),
                         'min' = integer(),
                         'max' = integer(),
                         'weighted' = integer(),
                         'difference' = integer(),
                         'polygon' = integer())


## for loop that runs through each raster layer and extracts the SST corresponding to reef polygons
for (i in 1:sst_raster@file@nbands) {
  raster <- sst_raster[[i]]
  
  mean_sst_vals <- raster::extract(raster, shapes, fun=mean) # calculates a mean SST within each reef polygon
  min_sst_vals <- raster::extract(raster, shapes, fun=min) # minimum SST within each reef polygon
  max_sst_vals <- raster::extract(raster, shapes, fun=max) # maximum SST within each reef polygon
  weighted_mean <- raster::extract(raster, shapes, weights=TRUE, fun=mean) # calculates the weighted mean SST within each reef polygon
  
  layer_df <- data.frame('date' = raster@data@names,
                         'mean' = mean_sst_vals,
                         'min' = min_sst_vals,
                         'max' = max_sst_vals,
                         'weighted' = weighted_mean,
                         'difference' = mean_sst_vals - weighted_mean)
  
  layer_df$polygon <- rownames(layer_df) # names the row with polygon ID (numeric IDs)
  
  extract_df <- rbind(extract_df, layer_df) # adds the above information for each polygon onto the dataframe containing the other calculated values
}


## Once completed, saves the resulting dataframe as both a .Rdata object and .csv
save(extract_df, file = paste(data_set,"_reefs_poly.Rdata", sep = "")) # save the dataframe as Rdata object
write.csv(extract_df, file = paste(data_set,"_reefs_poly.csv", sep = "")) # save the dataframe as .csv
