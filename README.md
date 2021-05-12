# *One Hundred and Fifty Years of Warming on Caribbean Coral Reefs*

<img src="https://user-images.githubusercontent.com/45176386/113480898-bfc60c00-9464-11eb-9a95-00af8f80c9ea.png" width = "700" />

GitHub repository containing data and code accompanying the Caribbean warming and MHW manuscript (Bove et al XXX; DOI: XXX)

**Repository DOI:** [![DOI](https://zenodo.org/badge/283885820.svg)](https://zenodo.org/badge/latestdoi/283885820)

**Authors:** Colleen B. Bove, Laura Mudge & John F Bruno

**Abstract:** 
Anthropogenic climate change is rapidly altering the characteristics and dynamics of biological communities. This is especially apparent in marine systems as the world’s oceans are warming at an unprecedented rate, causing dramatic changes to coastal marine systems, especially on coral reefs of the Caribbean. We used three complementary ocean temperature databases (HadISST, Pathfinder, and OISST) to quantify change in thermal characteristics of Caribbean coral reefs over the last 150 years (1871–2020). These sea surface temperature (SST) databases included combined in situ and satellite-derived SST (HadISST, OISST), as well as satellite-only observations (Pathfinder) at multiple spatial resolutions. We also compiled a Caribbean coral reef database identifying 5,326 unique reefs across the region. We found that Caribbean reefs have warmed on average by 0.20 °C per decade since 1987, the calculated year that rapid warming began on Caribbean reefs. Further, geographic variation in warming rates ranged from 0.17 °C per decade on Bahamian reefs to 0.26 °C per decade on reefs within the Southern and Eastern Caribbean ecoregions. If this linear rate of warming continues, these already threatened ecosystems would warm by an additional 1.6 °C on average by 2100. We also found that marine heatwave (MHW) events are increasing in both frequency and duration across the Caribbean. Caribbean coral reefs now experience on average 5 MHW events annually, compared to 1 per year in the early 1980s. Combined, these changes have caused a dramatic shift in the composition and function of Caribbean coral reef ecosystems. If reefs continue to warm at this rate, we are likely to lose even the remnant Caribbean coral reef communities of today in the coming decades. 

**Citation:** Bove, C.B., Mudge, L. & Bruno, J.F. *One Hundred and Fifty Years of Warming on Caribbean Coral Reefs.* XXX


#### Repository contains the following:
1. R markdown script and html output with all code and analyses included in manuscript (*CaribbeanSST_manuscript*)
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
      * Fig1_ReefMap.pdf (both PDF and PNG versions)
      * Fig2_SST_trends (both PDF and PNG versions)
      * Fig3_Ecoregion_SST_trends (both PDF and PNG versions)
      * Fig4_SST_MHW_map (both PDF and PNG versions)
      * Fig5_MHW_metrics (both PDF and PNG versions)
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
