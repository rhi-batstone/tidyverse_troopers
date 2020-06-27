library(tidyverse)
library(sf)
library(leaflet)
library(janitor)
library(rmapshaper)

## ----------------------------------------------------------------
##                         read & clean data                     --
## ----------------------------------------------------------------

covid <- read_csv("dev/intermediate_zones/covid.csv") %>%
  clean_names()


scotland_interm <- st_read("dev/intermediate_zones/SG_IntermediateZoneCent_2011/SG_IntermediateZone_Cent_2011.shp") %>% 
  st_transform("+proj=longlat +datum=WGS84")

scotland_covid <- scotland_interm %>%
  as_tibble() %>% 
  mutate(geometry = as.character(geometry),
         geometry = str_sub(geometry, 3, -2)) %>% 
  separate(col = geometry, c("long", "lat"), sep = ", ") %>% 
  mutate(lat = as.double(lat),
         long = as.double(long)) %>% 
  left_join(covid, by = c("Name" = "name_of_intermediate_zone"))
  

## ----------------------------------------------------------------
##                         Leaflet Plot                          --
## ----------------------------------------------------------------


scotland_covid %>%
  leaflet() %>%
  addTiles() %>% 
  addCircles(lng = ~long,
             lat = ~lat,
             radius = ~number_of_deaths)
    
   