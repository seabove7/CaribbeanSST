#################################################################################
################# SST Extraction by Individual Ecoregion Reefs  #################
#################################################################################
##--- Last edit was made by Colleen Bove on 21 August 2020 ---##

#---- This script can be used with either the Pathfinder SST EDITED netCDF (HadISST_sst.nc) or HadISST netCDF to:
#------- 1) clip Caribbean reef shapefile by selected ecoregion
#------- 2) extract SST from raster based on specific Caribbean ecoregion reef polygons
#------- 3) transform extracted SST into a dataframe
#------- 4) save the dataframe as a .Rdata object and .csv


#--- This script was run on a high performance computing cluster due to time requirements (~ 20 hours per ecoregion; single node)
#--- You need this script, SST netCDF (HadISST), Caribbean reef, and ecoregion shapefiles (Caribbean_ecoregions.shp) on the cluster
#--- A note in the Rmarkdown (CaribbeanSST_analysis.Rmd) file references where this script was run for each data set
##############################################################

#### Set paths for desired SST netCDF and shapefiles:
# this is currently set to run with HadISST data (HadISST_sst.nc) extracted with the Caribbean reefs cliped by ecoregions
# the script can be adapted to any similar netCDF/shapefile combination

region <- "Bahamian" # specify the name of the data set here (important for selecting ecoregion and saving as that name)
netCDF <- "/Users/colleen/Dropbox/Git/Data_Not_On_Git/CaribbeanSST_data//HadISST_sst.nc" # this is the desired SST netCDF and path
reef_path <- "data/ReefData" # path to reef shape files
reef_name <- "Caribbean_reefs" # how the reef shapefiles are named (without the extension)
region_path <- "data/EcoRegions" # path to ecoregion shape files
region_name <- "Caribbean_ecoregions" # how the ecoregion shapefiles are named (without the extension)

#######################

### Load libraries
library(raster)
library(rgdal)


## Load reef and ecoregion shapefiles
shapes <- readOGR(reef_path, reef_name)
ecoregions2 <- readOGR(region_path, region_name)


### Subset reefs by ecoregions for analyses by region
ecoreg <- ecoregions2[ecoregions2@data$ECOREGION == region, ] # Select the only the desired ecoregion
ecoreg_reefs <- shapes[ecoreg,] # Clip the reefs by the selected ecoregion bounds


## Load the netCDF as rasterBrick
raster_brick <- brick(netCDF)

## Create an empty dataframe to populate while running the forloop with the following parameters:
reg_df <- data.frame('date' = integer(),
                     'mean' = integer(),
                     'min' = integer(),
                     'max' = integer(),
                     'weighted' = integer(),
                     'difference' = integer(),
                     'polygon' = integer(),
                     'ecoregion' = factor())


## for loop that runs through each raster layer and extracts the SST corresponding to reef polygons
for (i in 1:raster_brick@file@nbands) {
  raster <- raster_brick[[i]]
  
  mean_sst_vals <- raster::extract(raster, ecoreg_reefs, fun=mean) # calculates a mean SST within each reef polygon
  min_sst_vals <- raster::extract(raster, ecoreg_reefs, fun=min) # minimum SST within each reef polygon
  max_sst_vals <- raster::extract(raster, ecoreg_reefs, fun=max) # maximum SST within each reef polygon
  weighted_mean <- raster::extract(raster, ecoreg_reefs, weights=TRUE, fun=mean) # calculates the weighted mean SST within each reef polygon
  
  df <- data.frame('date' = raster@data@names,
                   'mean' = mean_sst_vals,
                   'min' = min_sst_vals,
                   'max' = max_sst_vals,
                   'weighted' = weighted_mean,
                   'difference' = mean_sst_vals - weighted_mean)

  df$polygon <- rownames(df) # names the row with polygon ID (numeric IDs)
  df$ecoregion <- rep(region, length(df$date)) # add a column to identify the ecoregion  

  reg_df <- rbind(reg_df, df) # adds the above information for each polygon onto the dataframe containing the other calculated values
}


## Once completed, saves the resulting dataframe as both a .Rdata object and .csv
save(reg_df, file = paste("data/HadISST/Ecoregion_SST/", region, "_reefs.Rdata", sep = ""))
write.csv(reg_df, file = paste("data/HadISST/Ecoregion_SST/", region, "_reefs.csv", sep = ""), row.names=FALSE)


