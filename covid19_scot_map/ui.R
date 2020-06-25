# Define the app's user interface
ui <- fixedPage(

  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "images/app.css")
  ),

  navbarPage(

    # Page title
    # Displayed to the left of the navigation bar
    title = div(
      img(
        src = "images/scotland_hex.svg",
        height = "40px"
      ),
      style = "position: relative; top: -10px"
    ),
    windowTitle = "Tidyverse Troopers",

  
    # Contains the MVP and a broad overview of the data
    tabPanel(
      title = "Map",

      # App title
      titlePanel("Scot Gov Covid-19 management"),


      # Sidebar with a slider input for date and selector for data
      sidebarLayout(


        sidebarPanel(
          
          sliderInput("date",
            "Date Range:",
            min = min(joined_map_data$date_code),
            max = max(joined_map_data$date_code),
            value = min(joined_map_data$date_code)
          ),

          
          selectInput("data",
            label = h3("Data type"),
            choices = data_types,
            selected = "Testing - Cumulative people tested for COVID-19 - Positive"
          )
        ),

        mainPanel(
          leafletOutput("scot_plot")
        )
      )
    ),
    
    tabPanel(
      title = "Data Viz",
      
      # App title
      titlePanel("Scot Gov Covid-19 management"),
      
      
      # Sidebar with a slider input for date and selector for data
      sidebarLayout(
        
        
        sidebarPanel(
          
        ),
        
        mainPanel(
          
        )
      )
    )
  )
)
