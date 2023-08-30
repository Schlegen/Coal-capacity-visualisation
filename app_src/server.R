library(shiny)
library(readxl)
library(dplyr)
library(magrittr)
library(rvest)

PLANT_DATA_PATH = "data/Global-Coal-Plant-Tracker-July-2023.xlsx"
PLANT_DATA <- read_excel(PLANT_DATA_PATH, sheet="Units")

ISO_CODES_PATH <- "data/iso_3digit_alpha_country_codes.xls"
ISO_CODES <- read_excel(ISO_CODES_PATH, skip=1)
names(ISO_CODES) <- c("ISO3", "Country")


function(input, output, session) {
    output$dataDisplay <- renderTable({
      
      #We first select the plants that operated during the year input$year and then sum them by country
      year_capacity_data <- PLANT_DATA[(PLANT_DATA$Status == 'operating' & PLANT_DATA$'Start year' <= input$year) 
                                 | (PLANT_DATA$Status == 'retired' & PLANT_DATA$'Start year' <= input$year & PLANT_DATA$'Retired year' >= input$year),] %>% #%>%
                            group_by(Country)%>% summarise(coal_capacity=sum(`Capacity (MW)`), .groups='drop')
      
      #merging with ISO_CODES data frame to get the right format for plots
      year_capacity_data <- merge(x = ISO_CODES, y = year_capacity_data, by = "Country",
                                      all.x = TRUE) %>% select(ISO3, Country, coal_capacity)
    })
}
