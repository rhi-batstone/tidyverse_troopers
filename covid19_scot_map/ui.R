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

    # Parent sections organised by tab
    # Overview parent tab
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
            choices = list(
              "Testing - Cumulative people tested for COVID-19 - Positive" = 1,
              "COVID-19 patients in hospital - Confirmed" = 2,
              "COVID-19 patients in ICU - Total" = 3
            ),
            selected = 1
          )
        ),

        mainPanel(
          leafletOutput("scot_plot")
        )
      )
    )
  )
)
