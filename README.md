![Bove_SST_abstract_image](https://user-images.githubusercontent.com/45176386/113480898-bfc60c00-9464-11eb-9a95-00af8f80c9ea.png)
# CaribbeanSST

**GitHub repository containing data and code accompanying the Caribbean warming and MHW manuscript (Bove et al XXX; DOI: XXX)**

### Title: *One Hundred and Fifty Years of Warming on Caribbean Coral Reefs*

**Authors:** Colleen B. Bove, Laura Mudge & John F Bruno

**Abstract:** 

**Citation:** Bove, C.B., Mudge, L. & Bruno, J.F. *One Hundred and Fifty Years of Warming on Caribbean Coral Reefs.* XXX


#### Repository contains the following:
1. R markdown script and html output with all code and analyses included in manuscript (*Coral_GVC_Analysis*)
2. Code
   * External R script used to extract SST from netCDF files using coral reef GPS coordinates to run remotely  (*SSTExtraction_ReefGPS.R*)
   * External R script used to clip Pathfinder netCDF and calculate rates of warming to run remotely (*Pathfinder_RasterCalculations.R*)
   * Functions from Gavin Simpson (GitHub: gavinsimpson) for calculating significant slopes from a GAM (*GSimpsonFunctions.R*)
4. Data
   * EcoRegions
      * Caribbean ecoregion shapefiles (*Caribbean_ecoregions.**)
   * HadISST
      * (*HadISST_ecoregion_sst.Rdata*)
      * (*HadISST_reefs_gps.Rdata*)
      * (*HadISST_reefs_poly.Rdata*)
      * (*HadISST_reefs_SST_update.Rdata*)
   * Pathfinder
      * 
   * ReefData
      * (*CaribbeanReef_points.csv*)
      * (*Caribbean_reefs.**)
5. Figures
   * Manuscript
      * Fig1_ReefMap.pdf
      * Fig2_SST_trends.pdf (*not created in Rmarkdown script*)
      * Fig3_Ecoregion_SST_trends.pdf
      * Fig4_SST_MHW_map.pdf
      * Fig5_ (*still working on this one*)
      * Fig6_MHW_metrics.pdf
   * Supplemental
      * FigS2_HadISST_GAM_slopes.pdf
      * FigS3_Pathfinder_SST_trends.pdf
      * FigS4_Both_SST_trends.pdf
      * FigS5_Ecoregion_MapSST.pdf
      * FigS6_SST_MHW_significance_map.pdf
      * FigS7_HadISST_map.pdf
      * FigS8_HadISST_subset_map.pdf
      * FigS9_MHW_metrics_ecoregions.pdf
      * HadISST.gif

