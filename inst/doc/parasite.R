## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup--------------------------------------------------------------------
# install.packages("ArctosR")
# install.packages("ggplot2")
# install.packages("ggspatial")
# install.packages("ggtext")
# install.packages("maps")
# install.packages("patchwork")
# install.packages("sf")

library(ArctosR)
library(ggplot2)
library(ggspatial)
library(ggtext)
library(maps)
library(patchwork)
library(sf)

## ----eval=FALSE---------------------------------------------------------------
# # Request a list of all query parameters.
# query_params <- get_query_parameters()
# 
# # Explore all parameters.
# View(query_params)

## ----eval=FALSE---------------------------------------------------------------
# # Request a list of all result parameters. These are the names that can show up
# # as columns in a dataframe returned by ArctosR.
# result_params <- get_result_parameters()
# 
# # Explore all parameters.
# View(result_params)

## ----eval=FALSE---------------------------------------------------------------
# # Check only core and record parameters.
# result_params[result_params$category %in% c("core", "record"), 1:3]

## ----eval=FALSE---------------------------------------------------------------
# # Request just the number of records matching a query.
# count <- get_record_count(country = "Mongolia", genus = "Microtus",
#                           guid_prefix = "MSB:Mamm",
#                           filter_by=list("examined for"="parasite"),
#                           api_key=YOUR_API_KEY)

## ----eval=FALSE---------------------------------------------------------------
# # Request to download all available data matching a query (specific columns).
# microtus <- get_records(country = "Mongolia", genus = "Microtus",
#                         guid_prefix = "MSB:Mamm",
#                         columns = list("guid", "scientific_name", "dec_long",
#                                        "dec_lat", "verbatim_date", "parts",
#                                        "partdetail"),
#                         filter_by=list("examined for"="parasite"),
#                         all_records = TRUE,
#                         api_key=YOUR_API_KEY)

## ----include=FALSE------------------------------------------------------------
microtus <- read_response_rds(
  system.file("extdata", "microtus.RDS", package = "ArctosR"))

## ----eval=TRUE----------------------------------------------------------------
# Expand a column that contains complex information in JSON format
expand_column(query = microtus, column_name = "partdetail")

## ----eval=TRUE----------------------------------------------------------------
# Grab the dataframe of records from the response.
microtus_df <- response_data(microtus)

# Filter out records which are missing latitude and longitude information
microtus_df <- microtus_df[microtus_df$dec_lat != "" & microtus_df$dec_long != "", ]

## ----eval=TRUE----------------------------------------------------------------
# Filter the data to keep only Microtus records in which nematodes were found
## Whole-word match for 'nematode' or 'nematodes'
pattern <- "\\bnematodes?\\b"

## A small function to check within data.frames in partdetail 
has_nematode <- function(df) {
  if (!is.data.frame(df) || is.null(df[["part_name"]])) {
    return(FALSE)
  } else {
    return(any(grepl(pattern, df[["part_name"]], ignore.case = TRUE, perl = TRUE)))
  }
}

## Add column that is TRUE when a record has a nematode and FALSE otherwise
microtus_df$nematode <- sapply(microtus_df$partdetail, has_nematode)

## Subset of microtus_df with matches
microtus_df_nematode <- microtus_df[microtus_df$nematode == TRUE, ]
microtus_df_no_nematode <- microtus_df[microtus_df$nematode == FALSE, ]

## Number of Microtus from Mongolia 
nrow(microtus_df)

## Number of Microtus from Mongolia that had nematodes
nrow(microtus_df_nematode)

## Number of Microtus from Mongolia that did not have nematodes
nrow(microtus_df_no_nematode)

## ----eval=TRUE----------------------------------------------------------------
# Initial plot of Microtus sampled in Mongolia

plot_map <- map_data("world", region=c("Mongolia"))

mongolia1 <- ggplot(plot_map, aes(long, lat)) +
  geom_polygon(
    aes(group = group), fill = "white", color = "gray20",
    linewidth = .2) +
  geom_jitter(
    data = microtus_df,
    aes(x = as.numeric(dec_long), y = as.numeric(dec_lat),
    color = "Microtus", shape = "Microtus"),
    alpha = .5, size = 1.0
  ) +
  scale_color_manual(
    values = c("Microtus" = "red"),
    labels = c("*Microtus*")
  ) +
  scale_shape_manual(
    values = c("Microtus" = 16),
    labels = c("*Microtus*")
  ) +
  labs(
    color = "Genus", shape = "Genus", x = NULL, y = NULL
  ) +
  coord_sf(
    crs = "+proj=lcc +lat_1=44 +lat_2=50 +lat_0=47 +lon_0=103.5 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs",
    xlim = c(87, 120), 
    ylim = c(40, 52.5),
    default_crs = sf::st_crs(4326),
    expand = FALSE
  ) +
  annotation_scale(
    location = "bl",
    width_hint = 0.4
  ) +
  annotation_north_arrow(
    location = "bl",
    which_north = "true", 
    pad_x = unit(0.2, "in"),
    pad_y = unit(0.3, "in"),
    style = north_arrow_fancy_orienteering
  ) +
  theme_minimal() +
  theme(
    panel.background = element_rect(fill = "aliceblue"),
    panel.border = element_rect(color = "black", fill = NA, linewidth = 1),
    legend.position = "none"
  )

ggsave(
  filename = "figures/mongolia1.png",
  plot = mongolia1,
  width = 6.53,
  height = 6.53,
  dpi = 150,
  create.dir = TRUE
)

## ----eval=TRUE----------------------------------------------------------------
# install.packages("patchwork")
library(patchwork)

# Plot of Microtus sampled in Mongolia filtered by nematode detected/not detected

plot_map <- map_data("world", region=c("Mongolia"))

mongolia2 <- ggplot(plot_map, aes(long, lat)) +
  geom_polygon(
    aes(group = group), fill = "white", color = "gray20",
    linewidth = .2
  ) +
  geom_jitter(
    data = microtus_df_no_nematode,
    aes(x = as.numeric(dec_long), y = as.numeric(dec_lat),
    color = "Microtus", shape = "Microtus"),
    alpha = .5, size = 2.0
  ) +
  geom_jitter(
    data = microtus_df_nematode,
    aes(x = as.numeric(dec_long), y = as.numeric(dec_lat),
    color = "Microtus nematodes", shape = "Microtus nematodes"),
    alpha = .5, size = 2.0
  ) +
  scale_color_manual(
    values = c("Microtus" = "red", "Microtus nematodes" = "black"),
    labels = c("*Microtus*", "*Microtus* with nematodes")
  ) +
  scale_shape_manual(
    values = c("Microtus" = 16, "Microtus nematodes" = 17),
    labels = c("*Microtus*", "*Microtus* with nematodes")
  ) +
  labs(
    color = "Genus", shape = "Genus", x = NULL, y = NULL
  ) +
  coord_sf(
    crs = "+proj=lcc +lat_1=44 +lat_2=50 +lat_0=47 +lon_0=103.5 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs",
    xlim = c(87, 120), 
    ylim = c(40, 52.5),
    default_crs = sf::st_crs(4326),
    expand = FALSE
  ) +
  annotation_scale(
    location = "br",
    width_hint = 0.4
  ) +
  annotation_north_arrow(
    location = "br",
    which_north = "true", 
    pad_x = unit(0.2, "in"),
    pad_y = unit(0.3, "in"),
    style = north_arrow_fancy_orienteering
  ) +
  theme_minimal() +
  theme(
    panel.background = element_rect(fill = "aliceblue"),
    panel.border = element_rect(color = "black", fill = NA, linewidth = 1.25),
    legend.position = c(0.0025, 0.0025),
    legend.justification = c(0, 0),
    legend.background = element_rect(fill = "white"),
    legend.text = element_markdown(),
    legend.title = element_blank()
  )

ggsave(
  filename = "figures/mongolia2.png",
  plot = mongolia2,
  width = 6.5,
  height = 4,
  dpi = 150,
  create.dir = TRUE
)

## ----eval=FALSE---------------------------------------------------------------
# get_relationships("MSB:Mamm:293449", YOUR_API_KEY)

