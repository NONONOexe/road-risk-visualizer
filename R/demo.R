library(tidyverse)
library(pavement)
library(sf)
library(mapgl)

center_lon <- 139.728187
center_lat <- 35.679636

convoluted_network <- readRDS("data/convoluted_network.rds")
osm_buildings <- readRDS("data/osm_buildings.rds")

get_heatmap_colours <- function(segment_values) {
  heatmap_colours <- paste0(heat.colors(100, rev = TRUE), "CD")
  normalized_values <- segment_values / max(segment_values)
  colours <- heatmap_colours[as.numeric(cut(normalized_values, breaks = 100))]

  return(colours)
}

segments <- convoluted_network$segments |>
  st_transform(4326) |>
  mutate(colour = get_heatmap_colours(density))

events <- convoluted_network$events |>
  st_transform(4326)

buildings <- osm_buildings$osm_polygons |>
  mutate(render_height = if_else(
    is.na(height), 20.0, as.numeric(height)
  ))

maplibre(
  style = carto_style("positron-no-labels"),
  center = c(center_lon, center_lat),
  zoom = 14
) |>
  add_source(
    id   = "segments",
    data = segments
  ) |>
  add_line_layer(
    id     = "density",
    source = "segments",
    line_width = 10,
    line_color = get_column("colour")
  ) |>
  add_source(
    id   = "events",
    data = events
  ) |>
  add_circle_layer(
    id     = "accidents",
    source = "events",
    circle_color = "red"
  ) |>
  add_source(
    id   = "buildings",
    data = buildings
  ) |>
  add_layer(
    id     = "3d-buildings",
    type   = "fill-extrusion",
    source = "buildings",
    paint = list(
      "fill-extrusion-color"   = "white",
      "fill-extrusion-height"  = get_column("render_height"),
      "fill-extrusion-base"    = 0,
      "fill-extrusion-opacity" = 0.5
    )
  ) |>
  add_markers(
    c(139.7356162, 35.6798366),
    color = "#06c755",
    popup = "LINEヤフー株式会社 本社",
    draggable = TRUE,
    marker_id = "marker1"
  ) |>
  add_layers_control()
