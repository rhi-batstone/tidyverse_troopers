library(tidyverse)
library(janitor)
library(lubridate)
library(sf)
library(rmapshaper)

management <- read_csv("../covid19_scot_map/raw_data/covid19_management.csv") %>%
  clean_names()

management_clean <- management %>%
  filter(
    variable %in% c("Testing - Cumulative people tested for COVID-19 - Positive",
                    "COVID-19 patients in hospital - Confirmed",
                    "COVID-19 patients in hospital - Suspected",
                    "COVID-19 patients in ICU - Total"
                    ),
    official_name != "Scotland"
  ) %>%
  select(-c(
    feature_code,
    measurement,
    units
  )) %>%
  mutate(
    value = str_replace_all(value, "\\*", "0"),
    value = as.numeric(value),
    date_code = as_date(date_code)
  )

## Joining the shapefile to the data
# from: https://data.gov.uk/dataset/27d0fe5f-79bb-4116-aec9-a8e565ff756a/nhs-health-boards
scotland <- st_read("../covid19_scot_map/raw_data/SG_NHS_HealthBoards_2019/SG_NHS_HealthBoards_2019.shp") %>%
  ms_simplify() %>% 
  group_by(HBName) %>%
  summarise(geometry = sf::st_union(geometry)) %>%
  st_transform("+proj=longlat +datum=WGS84")


## ----------------------------------------------------------------
##                    Intermediate Zone Data                     --
## ----------------------------------------------------------------

covid <- read_csv("covid19_scot_map/raw_data/covid.csv") %>%
  clean_names()


scotland_interm <- st_read("../covid19_scot_map/raw_data/SG_IntermediateZoneCent_2011/SG_IntermediateZone_Cent_2011.shp") %>% 
  st_transform("+proj=longlat +datum=WGS84")

scotland_covid <- scotland_interm %>%
  as_tibble() %>% 
  mutate(geometry = as.character(geometry),
         geometry = str_sub(geometry, 3, -2)) %>% 
  separate(col = geometry, c("long", "lat"), sep = ", ") %>% 
  mutate(lat = as.double(lat),
         long = as.double(long)) %>% 
  left_join(covid, by = c("Name" = "name_of_intermediate_zone"))



st_write(scotland, "../covid19_scot_map/clean_data/scotland.shp", append=FALSE)
write_csv(management_clean, "../covid19_scot_map/clean_data/management_clean.csv")
write_csv(scotland_covid, "../covid19_scot_map/clean_data/scotland_covid.csv")

