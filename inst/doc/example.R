## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup--------------------------------------------------------------------
# install.packages("ArctosR")

library(ArctosR)

## ----eval=FALSE---------------------------------------------------------------
#  # Request a list of all result parameters. These are the names that can show up
#  # as columns in a dataframe returned by ArctosR.
#  result_params <- get_result_parameters()
#  
#  # Explore all parameters.
#  View(result_params)

## ----eval=FALSE---------------------------------------------------------------
#  # Check only core and record parameters.
#  result_params[result_params$category %in% c("core", "record"), 1:3]

## ----eval=FALSE---------------------------------------------------------------
#  # Request just the number of records matching a query.
#  count <- get_record_count(country = "Mongolia", genus = "Microtus",
#                            guid_prefix = "MSB:Mamm",
#                            api_key=YOUR_API_KEY)

## ----eval=FALSE---------------------------------------------------------------
#  # Request to download all available data matching a query (specific columns).
#  microtus <- get_records(country = "Mongolia", genus = "Microtus",
#                          guid_prefix = "MSB:Mamm",
#                          columns = list("guid", "scientific_name", "dec_long",
#                                         "dec_lat", "verbatim_date", "parts",
#                                         "partdetail"),
#                          all_records = TRUE,
#                          api_key=YOUR_API_KEY)

## ----eval=FALSE---------------------------------------------------------------
#  # Expand a column that contains complex information in JSON format
#  expand_column(query = microtus, column_name = "partdetail")

## ----eval=FALSE---------------------------------------------------------------
#  # Grab the dataframe of records from the response.
#  microtus_df <- response_data(microtus)

## ----eval=FALSE---------------------------------------------------------------
#  # Filter the data to keep only Microtus records in which nematodes were found
#  ## Whole-word match for 'nematode' or 'nematodes'
#  pattern <- "\\bnematodes?\\b"
#  
#  ## A small function to check within data.frames in partdetail
#  has_nematode <- function(df) {
#    if (!is.data.frame(df) || is.null(df[["part_name"]])) {
#      return(FALSE)
#    } else {
#      return(any(grepl(pattern, df[["part_name"]], ignore.case = TRUE, perl = TRUE)))
#    }
#  }
#  
#  ## TRUE/FALSE mask for mic_df rows (whether they had nematodes or not)
#  mask <- vapply(microtus_df$partdetail, has_nematode, logical(1))
#  
#  ## Subset of microtus_df with matches
#  microtus_df_nematode <- microtus_df[mask, 1:5, drop = FALSE]
#  
#  nrow(microtus_df)  # Number of Microtus from Mongolia
#  nrow(microtus_df_nematode)  # Number of Microtus from Mongolia that had nematodes

