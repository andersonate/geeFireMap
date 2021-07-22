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
# print(meanImage$getInfo())


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

## EH
geometryEH <- ee$Geometry$Rectangle(
  coords = c(0, -90, 180, 90),
  proj = "EPSG:4326"
)

# ## WH
geometryWH <- ee$Geometry$Rectangle(
  coords = c(-180, -90, 0, 90),
  proj = "EPSG:4326"
)



# Map$addLayer(
#   eeObject = geometry,
#   visParams = viz,
#   name = "Months_burned",
#   legend=TRUE
# )

# rgee::ee_image_info(meanImage)
# print(meanImage$getInfo())

# raster export
ee_as_raster(meanImage,
             dsn = "output/20210722BurnDateCount_WH.tif", 
             region = geometryWH, 
             via = "drive",
             scale = 500,
             maxPixels = 1606085776
              )
# ee_as_raster(meanImage,
#              dsn = "output/20210722BurnDateCount_EH.tif", 
#              region = geometryEH, 
#              via = "drive",
#              scale = 500,
#              maxPixels = 1606085776
# )
# meanImage$getInfo()
# # Map$addLayer(
# #   eeObject = geometry,
# #   # visParams = viz,
# #   name = "Months_burned",
# #   legend=TRUE
# # )
