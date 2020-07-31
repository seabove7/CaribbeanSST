##############################################################
#######  Pathfinder SST Extraction by Reef Polygons  #########
##############################################################
##--- Last edit was made by Colleen Bove on 31 July 2020 ---##

#---- This script was used with the Pathfinder SST EDITED netCDF (PathfinderSST_monthly_edit.nc) and Caribbean reef shapefile to:
#------- 1) extract SST from Pathfinder raster based on Caribbean reef shapefile polygons
#------- 2) transform extracted SST into a dataframe
#------- 3) save the dataframe as a .Rdata object and .csv


#--- This script was run on a high performance computing cluster due to time requirements (~ 34 hours; single node)
#--- You will need this script, the Pathfinder netCDF (PathfinderSST_monthly_edit.nc), and Caribbean shapefiles on the cluster
#--- A note in the Rmarkdown (CaribbeanSST_analysis.Rmd) file references where this script was run 
##############################################################

## set paths and file names for Pathfinder netCDF and Caribbean reef shapefiles
Pathfinder_netCDF <- "/pine/scr/c/o/colbrynn/SCRATCH/SST_data/Pathfinder/PathfinderSST_monthly_edit.nc" # this is the edited netCDF
shape_path <- "/pine/scr/c/o/colbrynn/SCRATCH/SST_data/HADISST/Longleaf_working" # path to where the Caribbean shape files are
shape_name <- "Caribbean_reefs" # how the shapefiles are names (without the extension)


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
data_brick2 <- brick(Pathfinder_netCDF) # convert Pathfinder EDIT netCDF to rasterBrick


## Create an empty dataframe to populate while running the forloop with the following parameters:
path_df <- data.frame('date' = integer(),
                      'mean' = integer(),
                      'min' = integer(),
                      'max' = integer(),
                      'weighted' = integer(),
                      'difference' = integer(),
                      'polygon' = integer())


## for loop that runs through each raster layer and extracts the SST corresponding to reef polygons
for (i in 1:data_brick2@file@nbands) {
  raster <- data_brick2[[i]]
  
  mean_sst_vals <- raster::extract(raster, shapes, fun=mean) # calculates a mean SST within each reef polygon
  min_sst_vals <- raster::extract(raster, shapes, fun=min) # minimum SST within each reef polygon
  max_sst_vals <- raster::extract(raster, shapes, fun=max) # maximum SST within each reef polygon
  weighted_mean <- raster::extract(raster, shapes, weights=TRUE, fun=mean) # calculates the weighted mean SST within each reef polygon
  
  df <- data.frame('date' = raster@data@names,
                   'mean' = mean_sst_vals,
                   'min' = min_sst_vals,
                   'max' = max_sst_vals,
                   'weighted' = weighted_mean,
                   'difference' = mean_sst_vals - weighted_mean)
  
  df$polygon <- rownames(df) # names the row with polygon ID (numeric IDs)
  
  path_df <- rbind(path_df, df) # adds the above information for each polygon onto the dataframe containing the other calculated values
}


## Once completed, saves the resulting dataframe as both a .Rdata object and .csv
save(path_df, file = "Pathfinder_reefs_poly.Rdata")
write.csv(path_df, file = "Pathfinder_reefs_poly.csv")
