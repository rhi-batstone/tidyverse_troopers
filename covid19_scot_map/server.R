server <- function(input, output) {
  
  joined_map_data_reactive <- reactive({
    joined_map_data %>%
      # filter(variable == input$data
      # ) %>%
      filter(date_code <= input$date) %>%
      group_by(official_name) %>%
      summarise(total = max(value))
  })


  output$scot_plot <- renderLeaflet({
    
    bins <- c(0, max(joined_map_data_reactive()$total), 6)
    pal <- colorBin("plasma", domain = joined_map_data_reactive()$total)

    labels <- sprintf(
      "<strong>%s</strong><br/>%g",
      joined_map_data_reactive()$official_name, 
      joined_map_data_reactive()$total
    ) %>% lapply(htmltools::HTML)

    ## ----------------------------------------------------------------
    ##                         Leaflet Plot                         --
    ## ----------------------------------------------------------------


    joined_map_data_reactive() %>%
      leaflet() %>%
      # addProviderTiles(
      #   providers$OpenStreetMap
        # "MapBox",
        # options = providerTileOptions(
        #   id = "mapbox.light",
        #   accessToken = Sys.getenv("MAPBOX_ACCESS_TOKEN")
      #   # )
      # ) %>%
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
        pal = pal, 
        values = ~total, 
        opacity = 0.7, 
        title = "Count",
        position = "topleft"
      )
  })
}
