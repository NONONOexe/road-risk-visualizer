library(sf)
library(osmdata)

center_lon <- 139.728187
center_lat <- 35.679636

osm_buildings <- opq_around(
    lon = center_lon,
    lat = center_lat,
    radius = 1000,
    key = "building"
  ) |> osmdata_sf()

saveRDS(osm_buildings, file = "data/osm-buildings.rds")
