## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup--------------------------------------------------------------------
# install.packages("ArctosR")

library(ArctosR)

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

## ----eval=FALSE---------------------------------------------------------------
# # Expand a column that contains complex information in JSON format
# expand_column(query = microtus, column_name = "partdetail")

## ----eval=FALSE---------------------------------------------------------------
# # Grab the dataframe of records from the response.
# microtus_df <- response_data(microtus)
# 
# # Filter out records which are missing latitude and longitude information
# microtus_df <- microtus_df[microtus_df$dec_lat != "" & microtus_df$dec_long != "", ]

## ----eval=FALSE---------------------------------------------------------------
# # Filter the data to keep only Microtus records in which nematodes were found
# ## Whole-word match for 'nematode' or 'nematodes'
# pattern <- "\\bnematodes?\\b"
# 
# ## A small function to check within data.frames in partdetail
# has_nematode <- function(df) {
#   if (!is.data.frame(df) || is.null(df[["part_name"]])) {
#     return(FALSE)
#   } else {
#     return(any(grepl(pattern, df[["part_name"]], ignore.case = TRUE, perl = TRUE)))
#   }
# }
# 
# ## Add column that is TRUE when a record has a nematode and FALSE otherwise
# microtus_df$nematode <- sapply(microtus_df$partdetail, has_nematode)
# 
# ## Subset of microtus_df with matches
# microtus_df_nematode <- microtus_df[microtus_df$nematode == TRUE, ]
# microtus_df_no_nematode <- microtus_df[microtus_df$nematode == FALSE, ]
# 
# ## Number of Microtus from Mongolia
# nrow(microtus_df)
# 
# ## Number of Microtus from Mongolia that had nematodes
# nrow(microtus_df_nematode)
# 
# ## Number of Microtus from Mongolia that did not have nematodes
# nrow(microtus_df_no_nematode)

## ----eval=FALSE---------------------------------------------------------------
# library(maps)
# library(ggplot2)

## ----eval=FALSE---------------------------------------------------------------
# # Initial plot of Microtus sampled in Mongolia
# 
# ## adapted from
# ## https://www.r-bloggers.com/2012/07/map-biodiversity-records-with-rgbif-maps-and-ggplot2-packages-in-r/
# 
# library(maps)
# library(ggplot2)
# 
# mongolia <- ggplot2::map_data("world", region="Mongolia")
# 
# ggplot(mongolia, aes(long, lat)) +
#   geom_polygon(aes(group = group), fill = "white", color = "gray20",
#                size = .2) +
#   geom_jitter(data = microtus_df,
#               aes(x = as.numeric(dec_long), y = as.numeric(dec_lat)),
#               alpha = .5, size = 2, color = "red")

## ----eval=FALSE---------------------------------------------------------------
# # Plot of Microtus sampled in Mongolia filtered by nematode detected/not detected
# 
# ggplot(mongolia, aes(long, lat)) +
#   geom_polygon(aes(group = group), fill = "white", color = "gray20",
#                size = .2) +
#   geom_jitter(data = microtus_df_no_nematode,
#               aes(x = as.numeric(dec_long), y = as.numeric(dec_lat)),
#               alpha = .5, size = 2, color = "black") +
#   geom_jitter(data = microtus_df_nematode,
#               aes(x = as.numeric(dec_long), y = as.numeric(dec_lat)),
#               alpha = .5, size = 2, color = "red", shape="triangle")

