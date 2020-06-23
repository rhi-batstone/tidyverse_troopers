library(tidyverse)
library(janitor)
library(sf)
library(shiny)


management <- read_csv("../raw_data/covid19_management.csv") %>%
    clean_names()

positive_cases <- management %>%
    filter(
        variable %in% c("Testing - Cumulative people tested for COVID-19 - Positive"),
        official_name != "Scotland"
    ) %>%
    select(-c(
        feature_code,
        measurement,
        units
    )) %>%
    mutate(
        value = str_replace_all(value, "\\*", "0"),
        value = as.numeric(value)
    )

# from: https://data.gov.uk/dataset/27d0fe5f-79bb-4116-aec9-a8e565ff756a/nhs-health-boards
scotland <- st_read("../raw_data/SG_NHS_HealthBoards_2019/SG_NHS_HealthBoards_2019.shp") %>%
    rename("official_name" = HBName)

joined_map_data <- scotland %>%
    st_transform("+proj=longlat +datum=WGS84") %>%
    left_join(positive_cases, by = "official_name") %>% 
    group_by(official_name) %>%
    summarise(total = max(value))



# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Positive Covid-19 cases"),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
            sliderInput("date",
                        "Date Range:",
                        min = min(joined_map_data$date_code),
                        max = max(joined_map_data$date_code),
                        value = max(joined_map_data$date_code)
        )),

        # Show a plot of the generated distribution
        mainPanel(
           leafletOutput("scot_plot")
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {

    output$scot_plot <- renderLeaflet({
        
        # leaflet plot
        bins <- seq(0, 5000, length.out = 11)
        pal <- colorBin("plasma", domain = joined_map_data$total, bins = bins)
        
        labels <- sprintf(
            "<strong>%s</strong><br/>%g",
            joined_map_data$official_name, joined_map_data$total
        ) %>% lapply(htmltools::HTML)
        
        
        
        joined_map_data %>%
            # filter(date_code <= input$date) %>%
            # group_by(official_name) %>%
            # summarise(total = max(value)) %>% 
            leaflet() %>%
            addProviderTiles("MapBox",
                             options = providerTileOptions(
                                 id = "mapbox.light",
                                 accessToken = Sys.getenv("MAPBOX_ACCESS_TOKEN")
                             )
            ) %>%
            addPolygons(
                fillColor = ~ pal(total),
                weight = 2,
                opacity = 1,
                color = "white",
                dashArray = "3",
                fillOpacity = 0.7,
                highlight = highlightOptions(
                    weight = 5,
                    color = "#666",
                    dashArray = "",
                    fillOpacity = 0.7,
                    bringToFront = TRUE
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
                pal = pal, values = ~total, opacity = 0.7, title = "# Positive Cases",
                position = "topleft"
            )
        
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
