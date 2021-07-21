###########################################

## Title: 01_GEE_tutorial
## Description: Following install instructions for working with GEE in R
## Date: 20210720
  ## Last edited: 20210720
## Contributors: M. Campbell
## Contacts: michelineleecampbell@gmail.com
## Notes: http://www.css.cornell.edu/faculty/dgr2/_static/files/R_html/ex_rgee.html.
  # python installed, numpy installed

###########################################


# packages ----------------------------------------------------------------

library(reticulate)
library(rgee)
Sys.which("python3")
use_python(Sys.which("python3"))  #

np <- reticulate::import("numpy", convert = FALSE)

a <- np$array(c(1:4))
print(a)
print(py_to_r(a)) 
(sum <- a$cumsum())


## y to store environmental variables
rgee::ee_install()
ee_check()
ee_clean_pyenv() #
ee_Initialize()


dataset <- ee$ImageCollection('LANDSAT/LC08/C01/T1_8DAY_EVI')$filterDate('2017-01-01', '2017-12-31')
ee_print(dataset)



# trash code 2 ------------------------------------------------------------

# https://csaybar.github.io/blog/2020/06/10/rgee_01_worldmap/

library(rgee)
ee_Initialize(email = 'michelineleecampbell@gmail.com',drive = TRUE)

# library(raster)  # Manipulate raster data
# library(scales)  # Scale functions for visualization
# library(cptcity)  # cptcity color gradients!
# library(tmap)    # Thematic Map Visualization <3
# library(rgee) 

createTimeBand <-function(img) {
  year <- ee$Date(img$get('system:time_start'))$get('year')$subtract(1991L)
  ee$Image(year)$byte()$addBands(img)
}


collection <- ee$
  ImageCollection("MODIS/006/MCD64A1")$
  select('BurnDate')$
  map(createTimeBand)

col_reduce <- collection$reduce(ee$Reducer$linearFit())
col_reduce <- col_reduce$addBands(
  col_reduce$select('scale'))
ee_print(col_reduce)

Map$setCenter(9.08203, 47.39835, 3)
Map$addLayer(
  eeObject = col_reduce,
  visParams = list(
    bands = c("scale", "offset", "scale"),
    min = 0,
    max = c(0.18, 20, -0.18)
  ),
  name = "stable lights trend"
)

library(tidyverse)
library(sf)
nc <- st_read(system.file("shape/nc.shp", package = "sf"), quiet = TRUE)
# nc
ggplot() + geom_sf(data=nc,aes())

ee_nc_rain <- ee_extract(x = terraclimate, y = nc, sf = FALSE)
colnames(ee_nc_rain) <- paste0("month_",sprintf("%02d", 1:12))
nc_rain <- nc %>% bind_cols(ee_nc_rain)



modis_img <- ee$ImageCollection("MODIS/006/MCD64A1")$
  filterDate("2000-11-01", "2021-05-01")
ee_get_date_ic(modis_img, time_end = TRUE)


m_clean <- function(img) {
  # Extract the NDVI band
  # evi_values <- img$select("EVI")
  evi_qa <- img$select("SummaryQA")
  quality_mask <- getQABits(evi_qa, "110000000000000")
  evi_values$updateMask(quality_mask)
}


modis_img <- ee$ImageCollection("MODIS/006/MCD64A1")$
  filterDate("2000-11-01", "2021-05-01")$
  select('BurnDate')
ee_get_date_ic(modis_img, time_end = TRUE)



modis_img <- ee$ImageCollection("MODIS/006/MCD64A1")$
  filterDate("2000-11-01", "2021-05-01")$
  select('BurnDate')
ee_get_date_ic(modis_img, time_end = TRUE)

nc <- st_read(
  dsn = system.file("shape/nc.shp", package = "sf"),
  stringsAsFactors = FALSE,
  quiet = TRUE
)



terraclimate <- ee$ImageCollection("IDAHO_EPSCOR/TERRACLIMATE") %>%
  ee$ImageCollection$filterDate("2001-01-01", "2002-01-01") %>%
  ee$ImageCollection$map(
    function(x) {
      date <- ee$Date(x$get("system:time_start"))$format('YYYY_MM_dd')
      name <- ee$String$cat("Terraclimate_pp_", date)
      x$select("pr")$rename(name)
    }
  )

ee$ImageCollection$map(
  function(x) {
    date <- ee$Date(x$get("system:time_start"))$format('YYYY_MM_dd')
    name <- ee$String$cat("Terraclimate_pp_", date)
    x$select("pr")$rename(name)
  }
)

ee_extract(
  x = modis_img,
  y = nc["NAME"],
  scale = 250,
  fun = ee$Reducer$mean(),
  sf = TRUE)



# 
# ee_date <- era_img$get('system:time_start')
# ee_date$getInfo() #
# eedate_to_rdate(ee_date = ee_date, timestamp = TRUE)
# ee_get_date_img(modis_img, time_end = TRUE)


# trash code 3 ------------------------------------------------------------

###########################################

## Title: 01_MODIS_map_try1
## Description: First atttempt at mapping modis
## Date: 20210720
## Last edited: 20210720
## Contributors: M. Campbell
## Contacts: michelineleecampbell@gmail.com
## Notes: Using GEE

###########################################


# packages ----------------------------------------------------------------

library(rgee)
library(tidyverse)
library(reticulate)


# access GEE --------------------------------------------------------------

ee_Initialize()
srtm <- ee$ImageCollection("MODIS/006/MCD64A1")



viz <- list(
  max = 4000,
  min = 0,
  palette = c("#000000","#5AAD5A","#A9AD84","#FFFFFF")
)

Map$addLayer(
  eeObject = srtm,
  visParams =  viz,
  name = 'SRTM',
  legend = TRUE
)


# terraclimate ------------------------------------------------------------

terraclimate <- ee$ImageCollection("IDAHO_EPSCOR/TERRACLIMATE")$
  filterDate("2001-01-01", "2002-01-01")$
  map(function(x){
    date <- ee$Date(x$get("system:time_start"))$format('YYYY_MM_dd')
    name <- ee$String$cat("Terraclimate_pp_", date)
    x$select("pr")$reproject("EPSG:4326")$set("RGEE_NAME", name)
  })

# Define a geometry
nc <- st_read(
  dsn = system.file("shape/nc.shp", package = "sf"),
  stringsAsFactors = FALSE,
  quiet = TRUE
)

# Extract values
ee_nc_rain <- ee_extract(
  x = terraclimate,
  y = nc["geometry"],
  scale = 250,
  fun = ee$Reducer$allNonZero(),
  sf = FALSE
)

ee_extract()

# gganimate
colnames(ee_nc_rain) <- sprintf("%02d", 1:12)
ee_nc_rain$name <- nc$NAME

ee_nc_rain %>%
  pivot_longer(-name, names_to = "month", values_to = "pr") %>%
  ggplot(aes(x = as.integer(month), y = pr, color = pr)) +
  geom_line(alpha = 0.8, size = 2) +
  xlab("Month") +
  ylab("Precipitation (mm)") +
  theme_minimal() +
  transition_states(name) +
  shadow_mark(size = 0.4, colour = "grey")





terraclimate <- ee$ImageCollection("IDAHO_EPSCOR/TERRACLIMATE") %>%
  ee$ImageCollection$filterDate("2001-01-01", "2002-01-01") %>%
  ee$ImageCollection$map(
    function(x) {
      date <- ee$Date(x$get("system:time_start"))$format('YYYY_MM_dd')
      name <- ee$String$cat("Terraclimate_pp_", date)
      x$select("pr")$rename(name)
    }
  )

### Define a geometry
nc <- st_read(
  dsn = system.file("shape/nc.shp", package = "sf"),
  stringsAsFactors = FALSE,
  quiet = TRUE
)


### Extract values works for mean
ee_nc_rain <- ee_extract(
  x = terraclimate,
  y = nc["NAME"],
  scale = 250,
  fun = ee$Reducer$mean(),
  #via = "drive",
  lazy = TRUE,
  sf = TRUE
)
##################

library(rgee)
library(sf)

ee_Initialize()

### Define a Image or ImageCollection: Terraclimate
terraclimate <- ee$ImageCollection("IDAHO_EPSCOR/TERRACLIMATE") %>%
  ee$ImageCollection$filterDate("2001-01-01", "2002-01-01") %>%
  ee$ImageCollection$map(
    function(x) {
      date <- ee$Date(x$get("system:time_start"))$format('YYYY_MM_dd')
      name <- ee$String$cat("Terraclimate_pp_", date)
      x$select("pr")$rename(name)
    }
  )

### Define a geometry
nc <- st_read(
  dsn = system.file("shape/nc.shp", package = "sf"),
  stringsAsFactors = FALSE,
  quiet = TRUE
)


### Extract values works for mean
ee_nc_rain <- ee_extract(
  x = terraclimate,
  y = nc["NAME"],
  scale = 250,
  fun = ee$Reducer$mean(),
  #via = "drive",
  lazy = TRUE,
  sf = TRUE
)

#####################

library(rgee)
# ee_reattach() # reattach ee as a reserved word

ee_Initialize()

# This function gets NDVI from Landsat 8 imagery.
addNDVI <- function(image) {
  return(image$addBands(image$normalizedDifference(c("B5", "B4"))))
}

# Load the Landsat 8 raw data, filter by location and date.
collection <- ee$ImageCollection("LANDSAT/LC08/C01/T1")$
  filterBounds(ee$Geometry$Point(-122.262, 37.8719))$
  filterDate("2014-06-01", "2014-10-01")

# Map the function over the collection.
ndviCollection <- collection$map(addNDVI)

first <- ndviCollection$first()
print(first$getInfo())

bandNames <- first$bandNames()
print(bandNames$getInfo())



#######################################

library(rgee)
# ee_reattach() # reattach ee as a reserved word

ee_Initialize()

# Load and display a Landsat TOA image.
image <- ee$Image("LANDSAT/LC08/C01/T1_TOA/LC08_044034_20140318")
Map$addLayer(
  eeObject = image,
  visParams = list(bands = c("B4", "B3", "B2"), max = 30000),
  name = "Landsat 8"
)

# Create an arbitrary rectangle as a region and display it.
region <- ee$Geometry$Rectangle(-122.2806, 37.1209, -122.0554, 37.2413)
Map$addLayer(
  eeObject = region,
  name = "Region"
)

# Get a dictionary of means in the region.  Keys are bandnames.
mean <- image$reduceRegion(
  reducer = ee$Reducer$mean(),
  geometry = region,
  scale = 30
)

print(mean$getInfo())


#######################

# This function gets NDVI from Landsat 8 imagery.
addNDVI <- function(image) {
  return(image$addBands(image$normalizedDifference(c("B5", "B4"))))
}

# This function masks cloudy pixels.
cloudMask <- function(image) {
  clouds <- ee$Algorithms$Landsat$simpleCloudScore(image)$select("cloud")
  return(image$updateMask(clouds$lt(10)))
}

# Load a Landsat collection, map the NDVI and cloud masking functions over it.
collection <- ee$ImageCollection("LANDSAT/LC08/C01/T1_TOA")$
  filterBounds(ee$Geometry$Point(c(-122.262, 37.8719)))$
  filterDate("2014-03-01", "2014-05-31")$
  map(addNDVI)$
  map(cloudMask)

# Reduce the collection to the mean of each pixel and display.
meanImage <- collection$reduce(ee$Reducer$mean())
vizParams <- list(
  bands = c("B5_mean", "B4_mean", "B3_mean"),
  min = 0,
  max = 0.5
)

Map$addLayer(
  eeObject = meanImage,
  visParams = vizParams,
  name = "mean"
)

# Load a region in which to compute the mean and display it.
counties <- ee$FeatureCollection("TIGER/2016/Counties")
santaClara <- ee$Feature(counties$filter(
  ee$Filter$eq("NAME", "Santa Clara")
)$first())

Map$addLayer(
  eeObject = santaClara,
  visParams = list(palette = "yellow"),
  name = "Santa Clara"
)

# Get the mean of NDVI in the region.
mean <- meanImage$select("nd_mean")$reduceRegion(
  reducer = ee$Reducer$mean(),
  geometry = santaClara$geometry(),
  scale = 30
)

# Print mean NDVI for the region.
cat("Santa Clara spring mean NDVI:", mean$get("nd_mean")$getInfo())
