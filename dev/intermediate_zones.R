library(tidyverse)
library(sf)
library(leaflet)
library(janitor)
library(rmapshaper)

## ----------------------------------------------------------------
##                         read & clean data                     --
## ----------------------------------------------------------------

covid <- read_csv("covid19_scot_map/intermediate_zones/covid.csv") %>%
  clean_names()

scotland_interm <- st_read("covid19_scot_map/intermediate_zones/SG_IntermediateZoneCent_2011/SG_IntermediateZone_Cent_2011.cpg") %>%
  st_transform("+proj=longlat +datum=WGS84") %>% 
  left_join(covid, by = c("Name" = "name_of_intermediate_zone")) %>% 
  str_split(geometry, ", ") 


# ggplot(data = scotland_interm, aes(fill = number_of_deaths)) + 
#   geom_sf() +
#   theme_classic()
## ----------------------------------------------------------------
##                         Define Bins & pal                     --
## ----------------------------------------------------------------


bins <- seq(0, max(scotland_interm$number_of_deaths), length.out = 6)
pal <- colorBin("plasma", domain = scotland_interm$number_of_deaths)

labels <- sprintf(
  "<strong>%s</strong><br/>%g",
  scotland_interm$Name, 
  scotland_interm$number_of_deaths
) %>% lapply(htmltools::HTML)




## ----------------------------------------------------------------
##                         Leaflet Plot                          --
## ----------------------------------------------------------------


scotland_interm %>%
  leaflet() %>%
  addProviderTiles("MapBox", options = providerTileOptions(
    id = "mapbox.light",
    accessToken = Sys.getenv('MAPBOX_ACCESS_TOKEN'))) %>%
  addCircles(
    
    ),
    label = labels,
    labelOptions = labelOptions(
      style = list(
        "font-weight" = "normal",
        padding = "3px 8px"
      ),
      textsize = "15px",
      direction = "auto"
    )
  ) %>%
  addLegend(
    pal = pal, 
    values = ~number_of_deaths, 
    opacity = 0.7, 
    title = "Count",
    position = "topleft"
  )
