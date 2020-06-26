ui <- fluidPage(

  # tags$head(
  #   tags$link(rel = "stylesheet", type = "text/css", href = "images/app.css")
  # ),

  theme = shinytheme("flatly"),
  
  navbarPage(
    

    # Page title
    # Displayed to the left of the navigation bar
    title = div(
      img(
        src = "covid19_scot_map/images/scotland_hex.svg",
        height = "40px"
      ),
      style = "position: relative; top: -10px"
    ),
    windowTitle = "Tidyverse Troopers",

  
    # Contains the MVP and a broad overview of the data
    tabPanel(
      title = "Health Board Regions",

      # App title
      titlePanel("Scot Gov Covid-19 management"),


      # Sidebar with a slider input for date and selector for data
      fluidRow(
        column(4,
          
          sliderInput("date",
            "Date Range:",
            min = min(joined_map_data$date_code),
            max = max(joined_map_data$date_code),
            value = min(joined_map_data$date_code)
          ),

          
          selectInput("data",
            label = "Data type",
            choices = list("COVID-19 positive cases" = "Testing - Cumulative people tested for COVID-19 - Positive",
                           "COVID-19 patients in ICU - Total",
                           "COVID-19 patients in hospital - Suspected",
                           "COVID-19 patients in hospital - Confirmed"),
            selected = "Testing - Cumulative people tested for COVID-19 - Positive"
          )),
        
        column(4,
        
          leafletOutput("scot_plot")
       ),
        column(4,
       h4("Johnny's Plot")
       )
        )
      ),
    
    tabPanel(
      title = "Scotland",
      
      # App title
      titlePanel("Scot Gov Covid-19 management"),
      
      
      # Sidebar with a slider input for date and selector for data
      sidebarLayout(
        
        
        sidebarPanel(
          
          sliderInput("date_2",
                      "Date Range:",
                      min = min(joined_map_data$date_code),
                      max = max(joined_map_data$date_code),
                      value = min(joined_map_data$date_code)
          ),
          
          
          selectInput("data_2",
                      label = "Data type",
                      choices = list("COVID-19 Positive cases" = "Testing - Cumulative people tested for COVID-19 - Positive",
                                     "COVID-19 patients in ICU - Total",
                                     "COVID-19 patients in hospital - Suspected",
                                     "COVID-19 patients in hospital - Confirmed"),
                      selected = "Testing - Cumulative people tested for COVID-19 - Positive"
          )
        ),
        
        mainPanel(
          
        )
      )
    )
  )
)

