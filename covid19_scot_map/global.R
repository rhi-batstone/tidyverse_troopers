## code for deploying to shiny.io
# library(rsconnect)
# deployApp()
#################################################################
##                          Libraries                          ##
#################################################################


library(tidyverse)
library(sf)
library(leaflet)
library(shiny)
library(shinythemes)

##################################################################
##                        Data Wrangling                        ##
##################################################################


management <- read_csv("clean_data/management_clean.csv")
scotland <- st_read("clean_data/scotland.shp", quiet = TRUE)


## !!!Don't view this object - RStudio will hang 
# joined_map_data <- scotland %>%
#   #st_transform("+proj=longlat +datum=WGS84") %>%
#   left_join(management, by = c("HBName" = "official_name"))



