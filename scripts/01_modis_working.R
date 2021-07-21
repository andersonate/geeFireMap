###########################################

## Title: 01_modis_working
## Description: Modis burned area data to look at number of momths burned for the globe 
## Date: 20210721
  ## Last edited: 20210721
## Contributors: M. Campbell
## Contacts: michelineleecampbell@gmail.com
## Notes:

###########################################

library(reticulate)
library(rgee)
library(sf)

ee_Initialize(email = 'michelineleecampbell@gmail.com',drive = TRUE)

modis_img <- ee$ImageCollection("MODIS/006/MCD64A1")$
  filterDate("2000-11-01", "2021-05-01")$ ##full date range
  # filterDate("2020-01-01")$
  select('BurnDate')
# ee_get_date_ic(modis_img, time_end = TRUE) ### check date range

meanImage <- modis_img$reduce(ee$Reducer$count()) ## gte the count of non-Zero numvbers for each pixel
print(meanImage$getInfo())


viz <- list(
  max = 20,
  min = 0,
  palette = c("#ffffb2", "#fecc5c", "#fd8d3c", "#f03b20", "#bd0026") ## colour palette
)

# plot the data
Map$addLayer(
  eeObject = meanImage,
  visParams = viz,
  name = "Months_burned",
  legend=TRUE
) 

## geometry for raster export
geometry <- ee$Geometry$Rectangle( 
  coords = c(-179.999, -90, 180, 90)
)


# raster export
ee_as_raster(meanImage,dsn = "BurnDateCount.tif", region = geometry, via = "drive")
