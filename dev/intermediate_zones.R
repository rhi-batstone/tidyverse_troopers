library(tidyverse)
library(sf)
library(leaflet)
library(janitor)


## ----------------------------------------------------------------
##                         read & clean data                     --
## ----------------------------------------------------------------

covid <- read_csv("../dev/intermediate_zones/covid.csv") %>%
  clean_names()


scotland_interm <- st_read("../dev/intermediate_zones/SG_IntermediateZoneCent_2011/SG_IntermediateZone_Cent_2011.shp") %>% 
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
bins = c(0, 5, 17, max(scotland_covid$number_of_deaths))
pal <- colorBin(c("#FAF799", "orange", "#FF0000"), 
                   domain = scotland_covid$number_of_deaths, 
                   bin = bins)

scotland_covid %>%
  leaflet() %>%
  addProviderTiles(
    providers$CartoDB.Positron
  ) %>%
  addCircleMarkers(lng = ~long,
             lat = ~lat,
             fillOpacity = 0.25,
             stroke = F,
             radius = ~population_2018_based/500,
             color = ~pal(number_of_deaths)
             )

     
   