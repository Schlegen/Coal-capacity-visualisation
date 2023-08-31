library(shiny)
library(readxl)
library(dplyr)
# to import world map data
library(maps)
library(ggplot2)
# for world map plot
library(RColorBrewer)
library(ggiraph)
#For ISO3 country name conversion
#Install with install.packages("countrycode") in a R console
library(countrycode)

PLANT_DATA_PATH = "data/Global-Coal-Plant-Tracker-July-2023.xlsx"
PLANT_DATA <- read_excel(PLANT_DATA_PATH, sheet="Units")
PLANT_DATA["ISO3"] <- countrycode(PLANT_DATA$Country, origin = 'country.name', destination = 'iso3c') #read_excel(PLANT_DATA_PATH, sheet="Units")

WORLD_DATA = ggplot2::map_data('world')
WORLD_DATA <- fortify(WORLD_DATA)
WORLD_DATA["ISO3"] <- countrycode(WORLD_DATA$region, origin = 'country.name', destination = 'iso3c') #ISO_CODES$ISO3[match(WORLD_DATA$region, ISO_CODES$Country)]

plot_theme <- function () { 
  theme_bw() + theme(axis.text=element_text(size = 14),
                     axis.title=element_text(size = 14),
                     strip.text=element_text(size = 14),
                     panel.grid.major=element_blank(), 
                     panel.grid.minor=element_blank(),
                     panel.background=element_blank(), 
                     legend.position="bottom",
                     panel.border=element_blank(), 
                     strip.background=element_rect(fill = 'white', colour = 'white'))
}

plot_world_map <- function (observed_year) {
  #We first select the plants that operated during the year input$year and then sum them by country
  year_capacity_data <- PLANT_DATA[(PLANT_DATA$Status == 'operating' & PLANT_DATA$'Start year' <= observed_year) 
                                   | (PLANT_DATA$Status == 'retired' & PLANT_DATA$'Start year' <= observed_year & PLANT_DATA$'Retired year' >= observed_year),] %>%
    group_by(ISO3)%>% summarise(coal_capacity=sum(`Capacity (MW)`), .groups='drop')
  
  #conversion of MW to GW
  year_capacity_data["coal_capacity"] <- (10 ** (-3)) * year_capacity_data["coal_capacity"]
  year_capacity_data <- year_capacity_data[!is.na(year_capacity_data$ISO3), ]
  
  # World map dataset for plots
  world_data <- WORLD_DATA
  world_data["coal_capacity"] <- year_capacity_data$coal_capacity[match(WORLD_DATA$"ISO3", year_capacity_data$"ISO3")]
  
  #world map plot
  g <- ggplot() + 
    geom_polygon_interactive(data=world_data, color='gray70', size=0.1,
                             aes(x=long, y=lat, fill=coal_capacity, group=group,
                                 tooltip = sprintf("%s<br/>%s", region, coal_capacity))) + 
    scale_fill_gradientn(colours = brewer.pal(5, "Reds"), na.value = 'gray80') + 
    scale_x_continuous(breaks = c()) +
    labs(fill="Coal Power Plant Capacity (GW)", color="Coal Power Plant Capacity (GW)", title=NULL, x=NULL, y=NULL, caption=paste("Source: Global Energy Monitor - July 2023")) +
    coord_fixed() +
    plot_theme()
  
  return(g)
}

function(input, output, session) {
    output$worldPlot <- renderGirafe({
      girafe(code = print(plot_world_map(as.numeric(input$year))))
    })
    
    output$dataDisplay <- renderTable({
      observed_year <- as.numeric(input$year)
      #We first select the plants that operated during the year input$year and then sum them by country
      year_capacity_data <- PLANT_DATA[(PLANT_DATA$Status == 'operating' & PLANT_DATA$'Start year' <= observed_year) 
                                       | (PLANT_DATA$Status == 'retired' & PLANT_DATA$'Start year' <= observed_year & PLANT_DATA$'Retired year' >= input$year),] %>%
                    group_by(Country, ISO3)%>% summarise(coal_capacity=sum(`Capacity (MW)`), .groups='drop')
      #conversion of MW to GW
      year_capacity_data["coal_capacity"] <- (10 ** (-3)) * year_capacity_data["coal_capacity"]

      #merging with ISO_CODES data frame to get the right format for plots
      year_capacity_data <- year_capacity_data %>% select(ISO3, Country, coal_capacity)
      
      year_capacity_data <- year_capacity_data[!is.na(year_capacity_data$ISO3), ]
    })
}
