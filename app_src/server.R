library(shiny)
library(readxl)
library(dplyr)
library(magrittr)
library(rvest)
# to import world map data
library(maps)
library(ggplot2)
# for world map plot
library(RColorBrewer)
library(ggiraph)

PLANT_DATA_PATH = "data/Global-Coal-Plant-Tracker-July-2023.xlsx"
PLANT_DATA <- read_excel(PLANT_DATA_PATH, sheet="Units")

ISO_CODES_PATH <- "data/iso_3digit_alpha_country_codes.xls"
ISO_CODES <- read_excel(ISO_CODES_PATH, skip=1)
names(ISO_CODES) <- c("ISO3", "Country")

WORLD_DATA = ggplot2::map_data('world')
WORLD_DATA <- fortify(WORLD_DATA)
WORLD_DATA["ISO3"] <- ISO_CODES$ISO3[match(WORLD_DATA$region, ISO_CODES$Country)]

function(input, output, session) {
    output$worldPlot <- renderPlot({
      
      #We first select the plants that operated during the year input$year and then sum them by country
      year_capacity_data <- PLANT_DATA[(PLANT_DATA$Status == 'operating' & PLANT_DATA$'Start year' <= input$year) 
                                       | (PLANT_DATA$Status == 'retired' & PLANT_DATA$'Start year' <= input$year & PLANT_DATA$'Retired year' >= input$year),] %>%
                            group_by(Country)%>% summarise(coal_capacity=sum(`Capacity (MW)`), .groups='drop')
      
      #merging with ISO_CODES data frame to get the right format for plots
      year_capacity_data <- merge(x=ISO_CODES, y=year_capacity_data, by="Country",
                                  all.x = TRUE) %>% select(ISO3, Country, coal_capacity)

      #year_capacity_data <- year_capacity_data[!is.na(plotdf$ISO3), ]
      
      # World map dataset for plots
      world_data <- WORLD_DATA
      world_data["coal_capacity"] <- year_capacity_data$coal_capacity[match(WORLD_DATA$"ISO3", year_capacity_data$"ISO3")]#rep(1, nrows=)
        
      #world map plot
      g <- ggplot() + 
        geom_polygon_interactive(data=world_data, color='gray70', size=0.1,
                                 aes(x=long, y=lat, fill=coal_capacity, group=group, 
                                 tooltip = sprintf("%s<br/>%s", ISO3, coal_capacity))) + 
        scale_fill_gradientn(colours = brewer.pal(5, "RdBu"), na.value = 'white') + 
        scale_y_continuous(limits = c(-60, 90), breaks = c()) + 
        scale_x_continuous(breaks = c())
      return(g)
    })
    
    output$dataDisplay <- renderTable({
      #We plot the selected plants for debug
      selected_plants <- PLANT_DATA[(PLANT_DATA$Status == 'operating' & PLANT_DATA$'Start year' <= input$year) 
                                       | (PLANT_DATA$Status == 'retired' & PLANT_DATA$'Start year' <= input$year & PLANT_DATA$'Retired year' >= input$year),] %>%
                      select('Country', 'Status', 'Start year', 'Retired year')
      head(selected_plants, 25)
    })
}
