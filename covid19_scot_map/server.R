server <- function(input, output) {

  # Create reactive dataset
  management_reactive <- reactive({
    if (input$data == "Testing - Cumulative people tested for COVID-19 - Positive") {
      management %>%
        filter(variable == input$data) %>%
        filter(date_code <= input$date) %>%
        group_by(official_name) %>%
        mutate(total = max(value)) %>%
        ungroup()
    } else {
      management %>%
        filter(variable == input$data) %>%
        filter(date_code == input$date) %>%
        mutate(total = value)
    }
  })

  ## ----------------------------------------------------------------
  ##                         Leaflet Plot                         --
  ## ----------------------------------------------------------------

  output$scot_plot <- renderLeaflet({

    # Join counts onto bondary geographical shape data
    scotland_count <- scotland %>%
      left_join(management_reactive(), by = c("HBName" = "official_name"))

    # creates bins and palette for leaflet plot
    #bins <- seq(0, max(management_reactive()$total), length.out = 6)
    
    pal <- colorBin("plasma", domain = scotland_count$total, bins = 5)

    # creates hover over labels
    labels <- sprintf(
      "<strong>%s</strong><br/>%g",
      scotland_count$HBName,
      scotland_count$total
    ) %>% lapply(htmltools::HTML)


    scotland_count %>%
      leaflet() %>%
      addPolygons(
        fillColor = ~ pal(total),
        weight = 2,
        opacity = 1,
        color = "white",
        dashArray = "3",
        fillOpacity = 0.5,
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

  ##################################################################
  ##              place holder for Johnny's data viz              ##
  ##################################################################


  output$eg_plot <- renderPlotly({
    
    
    ggplotly(management %>%
      filter(variable == input$data) %>%
      filter(date_code <= input$date) %>%
      ggplot(aes(x = date_code, y = value, col = official_name)) +
      geom_line() +
      scale_fill_viridis_b() +
      labs(
        x = "Date",
        y = "Count",
        title = "Count by Health Board") +
      theme_classic() +
      theme(legend.position = 'none') 
      ) %>%
      add_trace(colors = "Dark2")
    
  })
  
  
  output$scot_covid_plot <- renderLeaflet({ 
    
    bins = c(0, 5, 17, max(scotland_covid$number_of_deaths))
    
    pal <- colorBin(c("#FAF799", "orange", "#FF0000"), 
                  domain = scotland_covid$number_of_deaths, 
                  bin = bins)
  
  scotland_covid %>%
    leaflet() %>%
    addProviderTiles(
      providers$CartoDB.Positron
    ) %>%
    addCircleMarkers(lng = ~long,
                     lat = ~lat,
                     fillOpacity = 0.5,
                     stroke = F,
                     radius = ~population_2018_based/1000,
                     color = ~pal(number_of_deaths),
    )
  })
  
}
