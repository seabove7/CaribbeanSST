# *One Hundred and Fifty Years of Warming on Caribbean Coral Reefs*

<img src="https://user-images.githubusercontent.com/45176386/113480898-bfc60c00-9464-11eb-9a95-00af8f80c9ea.png" width = "700" />

GitHub repository containing data and code accompanying the Caribbean warming and MHW manuscript (Bove et al XXX; DOI: XXX)

**Authors:** Colleen B. Bove, Laura Mudge & John F Bruno

**Abstract:** 

**Citation:** Bove, C.B., Mudge, L. & Bruno, J.F. *One Hundred and Fifty Years of Warming on Caribbean Coral Reefs.* XXX


#### Repository contains the following:
1. R markdown script and html output with all code and analyses included in manuscript (*Coral_GVC_Analysis*)
2. Code
   * External R script used to extract SST from netCDF files using coral reef GPS coordinates to run remotely  (*SSTExtraction_ReefGPS.R*)
   * External R script used to clip Pathfinder netCDF and calculate rates of warming to run remotely (*Pathfinder_RasterCalculations.R*)
   * Functions from Gavin Simpson (GitHub: gavinsimpson) for calculating significant slopes from a GAM (*GSimpsonFunctions.R*)
3. Data
   * EcoRegions
      * Caribbean ecoregion shapefiles (*Caribbean_ecoregions.*)
   * HadISST
      * (*HadISST_ecoregion_sst.Rdata*)
      * (*HadISST_reefs_gps.Rdata*)
      * (*HadISST_reefs_poly.Rdata*)
      * (*HadISST_reefs_SST_update.Rdata*)
   * Pathfinder
      * (*Pathfinder_times.Rdata*)
   * ReefData
      * (*CaribbeanReef_points.csv*)
      * (*Caribbean_reefs.**)
   * Supplemental tables as an excel file produced in the markdown file (*Supplemental_Tables.xlsx*)
4. Figures
   * Manuscript
      * Fig1_ReefMap.pdf
      * Fig2_SST_trends.pdf
      * Fig3_Ecoregion_SST_trends.pdf
      * Fig4_SST_MHW_map.pdf
      * Fig5_MHW_metrics.pdf
   * Supplemental
      * FigS1_HadISST_GAM_slopes.pdf
      * FigS2_Pathfinder_SST_trends.pdf
      * FigS3_Both_SST_trends.pdf
      * FigS4_Ecoregion_MapSST.pdf
      * FigS5_SST_MHW_significance_map.pdf
      * FigS6_HadISST_map.pdf
      * FigS7_HadISST_subset_map.pdf
      * FigS8_MHW_metrics_ecoregions.pdf
      * HadISST.gif

**NOTE:** The original OISST database compilation and MHW analyses were all performed by Laura Mudge (GitHub: [Lmudge13](https://github.com/Lmudge13)). This repository includes the previously compiled/calculated OISST and MHW parameters for simplicity. To find the code and data used to compile the datasets for Caribbean MHWs in this repository, please visit [Laura's GitHub](https://github.com/Lmudge13) or email me (colleenbove@gmail.com).
