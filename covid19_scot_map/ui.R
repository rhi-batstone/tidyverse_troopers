ui <- fluidPage(
  theme = shinytheme("flatly"),

  navbarPage(
    
    # Page title
    # Displayed to the left of the navigation bar
    title = div(
      img(
        src = "sta.png",
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
            "Date:",
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
          
          textOutput("note"),
          br(),
          
          tags$a(href="https://statistics.gov.scot/data/coronavirus-covid-19-management-information", "Data Source")
          
        ),
        
        mainPanel(
          column(6,
                 textOutput("title1"),
                 leafletOutput("scot_plot", height = 550) %>% withSpinner(color="#0dc5c1")
          ),
          column(6,
                 textOutput("title2"),
                 plotlyOutput("eg_plot", height = 550) %>% withSpinner(color="#0dc5c1")
          ))
      )
    ),
    
    tabPanel(
      title = "Scotland",
      
      # App title
      titlePanel("COVID-19 at a local level"),
      
      
      # Sidebar with a slider input for date and selector for data
      sidebarLayout(
        sidebarPanel(width = 3,
          h3("Local Authorities"),
          checkboxInput("bar", "All/None", value = T),
          checkboxGroupInput("local_auth", label = "Selector", 
                             choices = local_authorities,
                             selected = local_authorities
                             )
          
          ),
        
        
        
        mainPanel(width = 9,
          tabsetPanel(type = "tabs",
                      tabPanel("Deaths",
                               h4("Total COVID 19 related deaths to date"),
                               column(6,
                                      leafletOutput("scot_covid_plot", width = 400, height = 550) 
                                      %>% withSpinner(color="#0dc5c1"),
                               tags$a(href="https://statistics.gov.scot/data/coronavirus-covid-19-management-information", "Data Source")),
                               column(6,
                               "Note: Some locations are named IZ followed by a number, please refer",
                               tags$a(href="https://www2.gov.scot/Topics/Statistics/sns/SNSRef/DZresponseplan", "here for more information."))
                               ),
                               
                      tabPanel("Cardiovascular Prescriptions", 
                               h4("Number of Cardiovascular Prescriptions in Scotland"),
                               plotOutput("prescriptions")
                               %>% withSpinner(color="#0dc5c1"),
                               tags$a(href="https://scotland.shinyapps.io/phs-covid-wider-impact/", "Data Source")),
                      
                      tabPanel("Testing")
          )
        )
      )
    )
  )
)