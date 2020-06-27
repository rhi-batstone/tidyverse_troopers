ui <- fluidPage(
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
      titlePanel("Covid-19 Management in Scotland"),


      # Sidebar with a slider input for date and selector for data
               sidebarLayout(
                 sidebarPanel(
                   sliderInput(
                     "date",
                     "Date Range:",
                     min = min(management$date_code),
                     max = max(management$date_code),
                     value = max(management$date_code)
                     ),
                   
                   selectInput(
                     "data",
                      label = "Data type:",
                      choices = list(
                         "COVID-19 positive cases" = "Testing - Cumulative people tested for COVID-19 - Positive",
                         "COVID-19 patients in ICU - Total",
                         "COVID-19 patients in hospital - Suspected",
                         "COVID-19 patients in hospital - Confirmed"),
                      selected = "Testing - Cumulative people tested for COVID-19 - Positive"),
                   
                   tags$a(href="https://statistics.gov.scot/data/coronavirus-covid-19-management-information", "Data Source")
                   
                   ),

          mainPanel(
            column(6,
          leafletOutput("scot_plot", height = 600)
        ),
        column(6,
          
          plotlyOutput("eg_plot", height = 600)
        ))
      )
    ),

    tabPanel(
      title = "Scotland",

      # App title
      titlePanel("Covid-19 related Deaths"),


      # Sidebar with a slider input for date and selector for data
      sidebarLayout(
        sidebarPanel(
          checkboxGroupInput("local_auth", label = h3("Local Authorities"), 
                             choices = local_authorities,
                             selected = local_authorities)
        ),
        
        
        
        mainPanel(
          leafletOutput("scot_covid_plot", width = 900, height = 600)
        )
      )
    )
  )
)

