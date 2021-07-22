###########################################

## Title: 03_merge_rasters
## Description: Merge rasters output from GEE MODIS data
## Date: 20210722
  ## Last edited: 20210722
## Contributors: M. Campbell
## Contacts: michelineleecampbell@gmail.com
## Notes:  https://stackoverflow.com/questions/15876591/merging-multiple-rasters-in-r

###########################################


# packages ----------------------------------------------------------------

library(raster)

files <- list.files("output")

map1 <- raster("output/20210722BurnDateCount_EH-0001.tif")
map2 <- raster("output/20210722BurnDateCount_EH-0002.tif")
map3 <- raster("output/20210722BurnDateCount_EH-0003.tif")
map4 <- raster("output/20210722BurnDateCount_EH-0004.tif")
map5 <- raster("output/20210722BurnDateCount_WH-0001.tif")
map6 <- raster("output/20210722BurnDateCount_WH-0002.tif")
map7 <- raster("output/20210722BurnDateCount_WH-0003.tif")
map8 <- raster("output/20210722BurnDateCount_WH-0004.tif")

test <- merge(map1, map2, map3, map4, map5, map6, map7, map8)
plot(test)

writeRaster(test, "output/globalFireCount.tif", format = "GTiff")
