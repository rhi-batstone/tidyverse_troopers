library(tidyverse)
library(janitor)
library(lubridate)
library(sf)
library(readxl)
library(rmapshaper)


## ----------------------------------------------------------------
##                          Covid Management                     --
## ----------------------------------------------------------------

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

# save clean file
write_csv(management_clean, "../covid19_scot_map/clean_data/management_clean.csv")

## ----------------------------------------------------------------
##                    Scotland Health Board shp                  --
## ----------------------------------------------------------------


## Joining the shapefile to the data
# from: https://data.gov.uk/dataset/27d0fe5f-79bb-4116-aec9-a8e565ff756a/nhs-health-boards
scotland <- st_read("../covid19_scot_map/raw_data/SG_NHS_HealthBoards_2019/SG_NHS_HealthBoards_2019.shp") %>%
  ms_simplify() %>% 
  group_by(HBName) %>%
  summarise(geometry = sf::st_union(geometry)) %>%
  st_transform("+proj=longlat +datum=WGS84")


# save clean file
st_write(scotland, "../covid19_scot_map/clean_data/scotland.shp", append=FALSE)


## ----------------------------------------------------------------
##                    Intermediate Zone Data                     --
## ----------------------------------------------------------------

#  Data read
covid <- read_csv("../covid19_scot_map/raw_data/covid.csv") %>%
  clean_names() 

# Shapefile read
scotland_interm <- st_read("../covid19_scot_map/raw_data/SG_IntermediateZoneCent_2011/SG_IntermediateZone_Cent_2011.shp") %>% 
  st_transform("+proj=longlat +datum=WGS84")

# Converting shapfile to tibble and extracting coordinates
# (It is POINT geometry not polygons)
scotland_covid <- scotland_interm %>%
  as_tibble() %>% 
  mutate(geometry = as.character(geometry),
         geometry = str_sub(geometry, 3, -2)) %>% 
  separate(col = geometry, c("long", "lat"), sep = ", ") %>% 
  mutate(lat = as.double(lat),
         long = as.double(long)) %>% 
  left_join(covid, by = c("Name" = "name_of_intermediate_zone"))


# save clean file
write_csv(scotland_covid, "../covid19_scot_map/clean_data/scotland_covid.csv")

## ----------------------------------------------------------------
##                    Cardiovascular Medication                  --
## ----------------------------------------------------------------

# Creating local authorities to match datasets 
local_authorities <- unique(scotland_covid$local_authority)

cardio_prescriptions <- read_csv("../covid19_scot_map/raw_data/cardio_extract.csv") %>% 
  mutate(week_ending = str_replace(week_ending, "Jan", "01"),
         week_ending = str_replace(week_ending, "Feb", "02"),
         week_ending = str_replace(week_ending, "Mar", "03"),
         week_ending = str_replace(week_ending, "Apr", "04"),
         week_ending = str_replace(week_ending, "May", "05"),
         week_ending = str_replace(week_ending, "Jun", "06"),
         week_ending = str_replace_all(week_ending, " ", "-"),
         area_name = str_replace_all(area_name, "&", "and"),
         area_name = str_replace_all(area_name, "NHS ", ""),
         area_name = str_replace(area_name, "Edinburgh", "City of Edinburgh"),
         area_name = str_replace(area_name, "Western Isles", "Na h-Eileanan Siar"),
         week_ending = dmy(week_ending)) 
# Splitting Clackmannanshire and Stirling
stirling <- cardio_prescriptions %>% 
  filter(area_name == "Clackmannanshire and Stirling") %>% 
  mutate(area_name = str_replace(area_name, "Clackmannanshire and Stirling", "Stirling"))
  
cardio_prescriptions <- cardio_prescriptions %>%
  rbind(stirling) %>% 
  mutate(area_name = str_replace(area_name, "Clackmannanshire and Stirling", "Clackmannanshire")) %>% 
  filter(area_name %in% local_authorities)

# save clean file
write_csv(cardio_prescriptions, "../covid19_scot_map/clean_data/cardio_prescriptions.csv")


##################################################################
##                    Johnny cleaning script                    ##
##                              #                               ##
##################################################################


# 
# 
# 
# cumulative <- c("Cumulative people tested for COVID-19 - Positive",
#                 "Cumulative people tested for COVID-19 - Negative",
#                 "Total number of COVID-19 tests carried out by Regional Testing Centres - Cumulative",
#                 "Total number of COVID-19 tests carried out by NHS Labs - Cumulative",
#                 "Cumulative people tested for COVID-19 - Total")
# 
# 
# daily <- c("Daily people found positive",
#            "Total number of COVID-19 tests carried out by NHS Labs - Daily",
#            "Total number of COVID-19 tests carried out by Regional Testing Centres - Daily")
# 
# 
# cumulative_care <- c("Cumulative number of suspected COVID-19 cases",
#                      "Cumulative number that have reported a suspected COVID-19 case",
#                      "Cumulative number that have reported more than one suspected COVID-19 case")
# 
# daily_care <- c("Daily number of new suspected COVID-19 cases","Number of staff reported as absent",
#                 "Number with current suspected COVID-19 cases","Adult care homes which submitted a return", "Total number of staff in adult care homes which submitted a return")
# 
# proportion_care <- c("Proportion that have reported a suspected COVID-19 case", "Proportion with current suspected COVID-19 cases", "Response rate", "Staff absence rate")
# 
# 
# 
# # 1. Comprehensive data and regions
# management_johnny <- read_csv("covid19_scot_map/raw_data/covid19_management.csv") %>%
#   clean_names() %>%
#   select(-units) %>%
#   rename(date = date_code, area_code = feature_code
#   ) %>%
#   mutate(value = as.numeric(value)) %>%
#   drop_na()
# 
# 
# 
# # 2. Populations
# pop_estimates <- read_excel("covid19_scot_map/raw_data/pop_estimates.xlsx",
#            sheet = "Table 9", col_names = FALSE,
#            skip = 5) %>%
#   # mutate(...1 = ifelse(...1 == "S92000003", "SB0801", ...1)) %>%
#   rename(area_code = ...1,
#          area = ...2,
#          population = ...3,
#          square_km = ...4,
#          people_per_square_km = ...5) %>%
#   drop_na()
# 
# 
# 
# 
# 
# # 3. Comprehensive data, regions and populations
# comprehensive_data_with_reg_pop <- management_johnny %>%
#   left_join(pop_estimates, by = "area_code") %>%
#   #relocate(c(date, area, variable)) %>%
#   select(-official_name, -area_code) %>%
#   mutate(variable = ifelse(variable == "Delayed discharges", "General - Delayed discharges", variable)) %>%
#   mutate(variable = ifelse(variable == "Number of COVID-19 confirmed deaths registered to date", "General - Number of COVID-19 confirmed deaths registered to date", variable)) %>%
#   separate(variable, c("data_set", "variable"), " - ", extra = "merge") %>%
#   mutate(date = as.Date(date)) %>%
#   mutate(data_set = ifelse(variable %in% cumulative, "Testing - Cumulative", data_set)) %>%
#   mutate(data_set = ifelse(variable %in% daily, "Testing - Daily", data_set)) %>%
#   mutate(data_set = ifelse(variable %in% cumulative_care, "Adult Care Homes - Cumulative", data_set)) %>%
#   mutate(data_set = ifelse(variable %in% daily_care, "Adult Care Homes - Daily", data_set)) %>%
#   mutate(data_set = ifelse(variable %in% proportion_care, "Adult Care Homes - Proportion", data_set)) %>%
#   write_csv("covid19_scot_map/clean_data/comprehensive_data_with_populations.csv")
# 
# 
# 
# 
# 
# 
# 
# 
# 
