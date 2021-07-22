
# packages ----------------------------------------------------------------

library(raster)
library(tidyverse)

map <- raster("output/globalFireCount.tif")

NAvalue(map) <- 0
plot(map)
world <- rnaturalearth::ne_countries()

rasterVis::gplot(map) + 
  geom_tile(aes(fill = value)) +
  geom_path(data = world, aes(x = long, y = lat, group = group)) +
  scale_fill_continuous(
    low = "#0C4278",
    high = "#c81414",
    na.value = "transparent"
  ) +
  coord_equal() 

