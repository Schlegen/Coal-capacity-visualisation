library(shiny)
library(readxl)
library(dplyr)


PLANT_DATA_PATH = "data/Global-Coal-Plant-Tracker-July-2023.xlsx"
PLANT_DATA <- read_excel(PLANT_DATA_PATH, sheet="Units")

function(input, output, session) {
    output$dataDisplay <- renderTable({
      #We first select the plants that operated during the year input$year 
      year_capacity_data <- PLANT_DATA[(PLANT_DATA$Status == 'operating' & PLANT_DATA$'Start year' <= input$year) 
                                 | (PLANT_DATA$Status == 'retired' & PLANT_DATA$'Start year' <= input$year & PLANT_DATA$'Retired year' >= input$year),] %>% #%>%
        group_by(Country)%>% summarise(coal_capacity=sum(`Capacity (MW)`), .groups='drop')
      year_capacity_data
    })
}
