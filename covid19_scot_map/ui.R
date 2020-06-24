
ui <- fluidPage(

  # Application title
  titlePanel("Scot Gov Covid-19 management"),

  # Sidebar with a slider input for number of bins
  fluidRow(
    column(
      4,
      sliderInput("date",
        "Date Range:",
        min = min(joined_map_data$date_code),
        max = max(joined_map_data$date_code),
        value = min(joined_map_data$date_code)
      ),

      selectInput("data",
        label = h3("Data type"),
        choices = list(
          "Positive" = "Testing - Cumulative people tested for COVID-19 - Positive",
          "Patients in Hospital" = "COVID-19 patients in hospital - Confirmed",
          "Patients ICU" = "COVID-19 patients in ICU - Total"
        ),
        selected = 1
      )
    ),


    column(
      4,
      leafletOutput("scot_plot")
    )
  )
)
