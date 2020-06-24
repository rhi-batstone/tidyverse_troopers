
#################################################################
##                          Libraries                          ##
#################################################################


library(tidyverse)
library(sf)
library(leaflet)
library(shiny)



##################################################################
##                        Data Wrangling                        ##
##################################################################


management <- read_csv("management_clean.csv")

## Joining the shapefile to the data
# from: https://data.gov.uk/dataset/27d0fe5f-79bb-4116-aec9-a8e565ff756a/nhs-health-boards
scotland <- st_read("raw_data/SG_NHS_HealthBoards_2019/SG_NHS_HealthBoards_2019.shp") %>%
  rename("official_name" = HBName)

joined_map_data <- scotland %>%
  st_transform("+proj=longlat +datum=WGS84") %>%
  left_join(management, by = "official_name")

