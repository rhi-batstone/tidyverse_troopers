server <- function(input, output) {
  
  joined_map_data_reactive <- reactive({
    joined_map_data %>%
      filter(
        date_code <= input$date,
        variable %in% input$data
      )
  })
  
  
  
  output$scot_plot <- renderLeaflet({
    
    
    bins <- c(0, 1000, 2000, 3000, 4000, 5000, Inf)
    pal <- colorBin("viridis", domain = joined_map_data_reactive()$value)
    
    labels <- sprintf(
      "<strong>%s</strong><br/>%g",
      joined_map_data_reactive()$official_name, joined_map_data_reactive()$value
    ) %>% lapply(htmltools::HTML)
    
    ##----------------------------------------------------------------
    ##                         Leaflet Plot                         --
    ##----------------------------------------------------------------
    
    
    joined_map_data_reactive() %>% 
      leaflet() %>%
      addProviderTiles("MapBox",
                       options = providerTileOptions(
                         id = "mapbox.light",
                         accessToken = Sys.getenv("MAPBOX_ACCESS_TOKEN")
                       )
      ) %>%
      addPolygons(
        fillColor = ~ pal(value),
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
        pal = pal, values = ~value, opacity = 0.7, title = "# Positive Cases",
        position = "topleft"
      )
    
  })
}