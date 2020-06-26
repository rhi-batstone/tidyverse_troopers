server <- function(input, output) {
  
  # joined_map_data_reactive <- reactive({
  #   joined_map_data %>%
  #     filter(variable == input$data
  #     ) %>%
  #     filter(date_code <= input$date) %>%
  #     group_by(HBName) %>%
  # mutate(total = max(value)) %>% 
  #   ungroup()

  management_reactive <- reactive({
    management %>%
      filter(variable == input$data
      ) %>%
      filter(date_code <= input$date) %>%
      group_by(official_name) %>%
      mutate(total = max(value)) %>% 
      ungroup()
  })

  output$scot_plot <- renderLeaflet({
    
    # Join counts onto bondary geographical shape data 
    scotland_count <- scotland %>%
      left_join(management_reactive(), by = c("HBName" = "official_name"))
    
    bins <- c(0, 1000, 2000, 3000, 4000, 5000, Inf)
    pal <- colorBin("plasma", domain = scotland_count$total)

    labels <- sprintf(
      "<strong>%s</strong><br/>%g",
      scotland_count$HBName, 
      scotland_count$total
    ) %>% lapply(htmltools::HTML)

    ## ----------------------------------------------------------------
    ##                         Leaflet Plot                         --
    ## ----------------------------------------------------------------


    scotland_count %>%
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
        opacity = .5,
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
