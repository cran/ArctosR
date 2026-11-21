## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup--------------------------------------------------------------------
# Install packages if needed
# install.packages("ArctosR")
# install.packages("ggplot2")

# Load packages
library(ArctosR)
library(ggplot2)

## ----eval=FALSE---------------------------------------------------------------
# # Download all available records of Didelphis virginiana, and include latitude
# # and longitude data
# brule_query <- get_records(
#   scientific_name = "Didelphis virginiana",
#   columns = list("guid", "dec_lat", "dec_long", "weight", "age"),
#   api_key = YOUR_API_KEY,
#   all_records = TRUE
# )

## ----include=FALSE------------------------------------------------------------
brule_query <- read_response_rds(
  system.file("extdata", "brule_query.RDS", package = "ArctosR"))

## ----eval=TRUE----------------------------------------------------------------
# Obtain data frame from response 
brule_query_df <- response_data(brule_query)
colnames(brule_query_df)

# Filter by age and keep a subset of columns
adults <- brule_query_df$age %in% c("adult", "")

brule_data <- brule_query_df[adults, c("dec_lat", "dec_long", "weight", "age")]

# Filter to keep records with latitude information
brule_data <- brule_data[brule_data$dec_lat != "", ]

# Format latitude as numeric
brule_data$dec_lat <- as.numeric(brule_data$dec_lat)

# Filter by weight
## Remove no data
unique(brule_data$weight)

brule_data <- brule_data[brule_data$weight != "", ]

## Process data to keep it in the same units
oweghts <- brule_data$weight

### Erase units from values
brule_data$weight <- gsub(" g$", "", brule_data$weight)
brule_data$weight <- gsub(" kg$", "", brule_data$weight)
brule_data$weight <- gsub(" oz$", "", brule_data$weight)

### Make it numeric
brule_data$weight <- as.numeric(brule_data$weight)

### Transform units
woz <- grep(" oz$", oweghts)
wkg <- grep(" kg$", oweghts)

brule_data$weight[woz] <- brule_data$weight[woz] * 28.35
brule_data$weight[wkg] <- brule_data$weight[wkg] * 1000

### Filter by weights considered to represent adult sizes
brule_data <- brule_data[brule_data$weight > 300 &
                          brule_data$weight < 6500, ]


## ----eval=TRUE----------------------------------------------------------------
# Create the plot with a linear regression line
ggplot(brule_data, aes(x = dec_lat, y = weight)) +
  geom_point(alpha = 0.5) + 
  geom_smooth(formula = "y ~ x", method = "lm", col = "blue") + 
  labs(title = "Relationship between latitude and weight for the Virginia opossum",
       x = "Decimal Latitude",
       y = "Weight") +
  theme_minimal() 

