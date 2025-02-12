library(pavement)
library(jpaccidents)
library(sf)

center_lon <- 139.728187
center_lat <- 35.679636
width <- height <- 0.02

bounding_box <- create_bbox(
  center_lon = center_lon,
  center_lat = center_lat,
  width      = width,
  height     = height
)
roads <- fetch_roads(bounding_box) |>
  st_transform(crs = 6677)

download_path <- download_accident_data("main")
accident_data <- read_accident_data(download_path)
accident_data <- read_accident_data("honhyo_2023.csv")
filter_area <- bounding_box |>
  convert_bbox_to_polygon(crs = st_crs(accident_data$accident))
filtered_data <- accident_data$accident |>
  st_filter(filter_area) |>
  st_transform(crs = 6677)

road_network <- create_road_network(roads) |>
  set_events(filtered_data)
segmented_network <- road_network |>
  create_segmented_network(segment_length = 10)

convoluted_network <- segmented_network |>
  convolute_segmented_network(bandwidth = 100)
saveRDS(convoluted_network, "data/convoluted_network.rds")
