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
library(rmapshaper)
library(lubridate)

##################################################################
##                        Data Wrangling                        ##
##################################################################

#data file
management <- read_csv("clean_data/management_clean.csv")

#shape file and reducing the polygons to increase render speed
scotland <- st_read("clean_data/scotland.shp", quiet = TRUE) %>%
  ms_simplify(keep = 0.025)

