library(rgdal)

zones <- readOGR("dev/SG_IntermediateZone_Bdry_2011 (7) (1).json")

covid_zones <- zones %>% 
  left_join("covid19_scot_map/clean_data/scotland_covid.csv", by = "Name")

pal <- colorNumeric("plasma", NULL)

leaflet(nycounties) %>%
  addTiles() %>%
  addPolygons(stroke = FALSE, smoothFactor = 0.3, fillOpacity = 1,
              fillColor = ~pal(log10(pop)),
              label = ~paste0(county, ": ", formatC(pop, big.mark = ","))) %>%
  addLegend(pal = pal, values = ~log10(pop), opacity = 1.0,
            labFormat = labelFormat(transform = function(x) round(10^x)))