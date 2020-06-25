library(tidyverse)
library(janitor)
library(lubridate)
library(sf)


management <- read_csv("raw_data/covid19_management.csv") %>%
  clean_names()

management_clean <- management %>%
  filter(
    variable %in% c("Testing - Cumulative people tested for COVID-19 - Positive",
                    "COVID-19 patients in hospital - Confirmed",
                   # "COVID-19 patients in hospital - Suspected",
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

write_csv(management_clean, "clean_data/management_clean.csv")

