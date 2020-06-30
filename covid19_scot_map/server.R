server <- function(input, output, session) {

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
  ##                  plot for management values                  ##
  ##################################################################


  output$eg_plot <- renderPlotly({
    
    
    ggplotly(management %>%
      filter(variable == input$data) %>%
      filter(date_code <= input$date) %>%
      ggplot(aes(x = date_code, y = value, col = official_name
                 )) +
      geom_line() +
      scale_fill_viridis_b() +
      labs(
        x = "Date",
        y = "Count",
        col = "Region"
        ) +
        theme(
          legend.text = element_text(size = 5)
        ) +
      theme_classic() #+
      #theme(legend.position = 'none') 
      ) %>%
      add_trace(colors = "Dark2") 
    
  })
  
  
  output$scot_covid_plot <- renderLeaflet({ 
    
    # this needs to be reactive i think
    # labels2 <- labels <- sprintf(
    #   "<strong>%s</strong><br/>%g",
    #   scotland_covid$Name,
    #   scotland_covid$number_of_deaths
    # ) %>% lapply(htmltools::HTML)
    
    bins = c(0, 5, 17, max(scotland_covid$number_of_deaths))
    
    pal <- colorBin(c("#f1ed0e", "orange", "#FF0000"), 
                  domain = scotland_covid$number_of_deaths, 
                  bin = bins)
  
  scotland_covid %>%
    filter(local_authority %in% input$local_auth) %>% 
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
                     popup = ~Name
    )
  })
  
  ##################################################################
  ##                  plot for prescription meds                  ##
  ##################################################################
  
  output$prescriptions <- renderPlot({
    
  cardio_prescriptions %>% 
    filter(area_name %in% input$local_auth) %>% 
    group_by(week_ending) %>%
    mutate(avg = mean(variation)) %>% 
    ggplot(aes(x = week_ending, y = avg)) +
    geom_line() +
    theme_classic() +
    labs(
        x = "Date",
        y = "Number of Prescriptions"
      )
    
  })
  
  observe({
    updateCheckboxGroupInput(
      session, 'local_auth', choices = local_authorities,
      selected = if (input$bar) local_authorities
    )
  })
  
  
  output$title1 <- renderText({ 
    paste(input$data)
  })
  
  output$title2 <- renderText({ 
    paste(input$data)
  })
  
  
  output$note <- renderText({
    
    if (input$data == "Testing - Cumulative people tested for COVID-19 - Positive") {
      print("Note: Count is cumulative")
    } else {
      " "
    }
    
  }) 
  
}
  
  # ##################################################################
  # ##                             Johnny server                    ##
  # ##                              #                               ##
  # ##################################################################
  # 
  # 
  # observe({
  #   if (input$area_choice == "Scotland") {
  #     updateSelectInput(
  #       session,
  #       "data_set_choice",
  #       choices = data_sets
  #     )
  #   }
  # })
  # 
  # 
  # observe({
  #   if (input$area_choice != "Scotland") {
  #     updateSelectInput(
  #       session,
  #       "data_set_choice",
  #       choices = c(NULL, "Testing", "COVID-19 patients in hospital", "COVID-19 patients in ICU")
  #     )
  #   }
  # })
  # 
  # 
  # observe({
  #   if (input$data_set_choice == "General") {
  #     updateCheckboxGroupInput(session, "variable_choice", choices = general_variables$variable)
  #   }
  # })
  # 
  # observe({
  #   if (input$data_set_choice == "Testing - Daily") {
  #     updateCheckboxGroupInput(session, "variable_choice", choices = testing_variables_daily$variable)
  #   }
  # })
  # 
  # observe({
  #   if (input$data_set_choice == "Testing - Cumulative") {
  #     updateCheckboxGroupInput(session, "variable_choice", choices = testing_variables_cumulative$variable)
  #   }
  # })
  # 
  # observe({
  #   if (input$data_set_choice == "COVID-19 patients in ICU") {
  #     updateCheckboxGroupInput(session, "variable_choice", choices = ICU_variables$variable)
  #   }
  # })
  # 
  # observe({
  #   if (input$data_set_choice == "COVID-19 patients in hospital") {
  #     updateCheckboxGroupInput(session, "variable_choice", choices = general_patient_variables$variable)
  #   }
  # })
  # 
  # observe({
  #   if (input$data_set_choice == "Calls") {
  #     updateCheckboxGroupInput(session, "variable_choice", choices = calls_variables$variable)
  #   }
  # })
  # 
  # observe({
  #   if (input$data_set_choice == "Ambulance attendances") {
  #     updateCheckboxGroupInput(session, "variable_choice", choices = ambulance_variables$variable)
  #   }
  # })
  # observe({
  #   if (input$data_set_choice == "Adult care homes - Daily") {
  #     updateCheckboxGroupInput(session, "variable_choice", choices = care_home_variables_daily$variable)
  #   }
  # })
  # 
  # observe({
  #   if (input$data_set_choice == "Adult care homes - Proportion") {
  #     updateCheckboxGroupInput(session, "variable_choice", choices = care_home_variables_proportion$variable)
  #   }
  # })
  # 
  # observe({
  #   if (input$data_set_choice == "Adult care homes - Cumulative") {
  #     updateCheckboxGroupInput(session, "variable_choice", choices = care_home_variables_cumulative$variable)
  #   }
  # })
  # observe({
  #   if (input$data_set_choice == "NHS workforce COVID-19 absences") {
  #     updateCheckboxGroupInput(session, "variable_choice", choices = calls_variables$variable)
  #   }
  # })
  # observe({
  #   if (input$data_set_choice == "Calls") {
  #     updateCheckboxGroupInput(session, "variable_choice", choices = NHS_workforce_variables$variable)
  #   }
  # })
  # 
  # 
  # 
  # filtered_data <- reactive({
  #   full_data %>%
  #     filter(area %in% input$area_choice) %>%
  #     filter(data_set %in% input$data_set_choice) %>%
  #     group_by(variable) %>%
  #     filter(variable %in% input$variable_choice)
  # })
  # 
  # output$covid_plot <- renderPlot({
  #   # if(!is.null(filtered_data())) {
  #   filtered_data() %>%
  #     ggplot(aes(x = date, y = value, group = variable)) +
  #     geom_line(aes(colour = variable)) +
  #     theme(legend.position = "bottom",
  #           legend.title = element_blank())
  #   # }
  # })
  # 
  



