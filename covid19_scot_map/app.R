
#################################################################
##                          Libraries                          ##
#################################################################



library(tidyverse)
library(sf)
library(leaflet)
library(shiny)



##################################################################
##                        Data Wrangling                        ##
##################################################################


positive_cases <- read_csv("positive_cases.csv")

## Joining the shapefile to the data
# from: https://data.gov.uk/dataset/27d0fe5f-79bb-4116-aec9-a8e565ff756a/nhs-health-boards
scotland <- st_read("raw_data/SG_NHS_HealthBoards_2019/SG_NHS_HealthBoards_2019.shp") %>%
    rename("official_name" = HBName)

joined_map_data <- scotland %>%
    st_transform("+proj=longlat +datum=WGS84") %>%
    left_join(positive_cases, by = "official_name") %>% 
    group_by(official_name) %>%
    summarise(total = max(value))


##################################################################
##                              UI                              ##
##################################################################


ui <- fluidPage(

    # Application title
    titlePanel("Scot Gov Covid-19 management"),

    # Sidebar with a slider input for number of bins
    fluidRow(
        column(4,
            sliderInput("date",
                        "Date Range:",
                        min = min(joined_map_data$date_code),
                        max = max(joined_map_data$date_code),
                        value = min(joined_map_data$date_code)),
        
            selectInput("data", label = h3("Data type"), 
                    choices = list("Positive" = "Testing - Cumulative people tested for COVID-19 - Positive", 
                                   "Patients in Hospital" = "COVID-19 patients in hospital - Confirmed", 
                                   "Patients ICU" = "COVID-19 patients in ICU - Total"), 
                    selected = "Positive")),

        #
        column(4,
           leafletOutput("scot_plot")
        ))
    )
    


##################################################################
##                            Server                            ##
##################################################################


server <- function(input, output) {

    
    bins <- seq(0, max(joined_map_data$total), length.out = 6)
    pal <- colorBin("plasma", domain = joined_map_data$total, bins = bins)
    
    labels <- sprintf(
        "<strong>%s</strong><br/>%g",
        joined_map_data$official_name, joined_map_data$total
    ) %>% lapply(htmltools::HTML)
    
    output$scot_plot <- renderLeaflet({
        
        
      
##----------------------------------------------------------------
##                         Leaflet Plot                         --
##----------------------------------------------------------------
      
      
        joined_map_data %>%
            #filter(
              #date_code <= input$date,
              #variable == input$data
              #) %>% 
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
