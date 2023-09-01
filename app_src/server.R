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


# PLANTS DATA
PLANT_DATA_PATH = "data/Global-Coal-Plant-Tracker-July-2023.xlsx"
PLANT_DATA <- read_excel(PLANT_DATA_PATH, sheet="Units")
#setting ISO3 country codes efficiently
unique_plant_data_countries <- unique(PLANT_DATA$Country)
suppressWarnings(#The following warning is about a country name (Kosovo) that was not converted to ISO3, it is treated manually
iso3_lookup <- countrycode(unique_plant_data_countries, origin='country.name', destination='iso3c')
)
PLANT_DATA$ISO3 <- iso3_lookup[match(PLANT_DATA$Country, unique_plant_data_countries)]
PLANT_DATA$ISO3[PLANT_DATA$Country == "Kosovo"] = "XXK"

# WORLD MAP DATA FOR PLOTS
WORLD_DATA = ggplot2::map_data('world')
WORLD_DATA <- fortify(WORLD_DATA)
unique_world_data_countries <- unique(WORLD_DATA$region)
suppressWarnings(#The following warning is about country names (Kosovo and small islands) that was not converted to ISO3, it is treated manually (only Kosovo is needed, since Other countries are not in PLANT_DATA)
iso3_lookup <- countrycode(unique_world_data_countries, origin='country.name', destination='iso3c')
)
WORLD_DATA$ISO3 <- iso3_lookup[match(WORLD_DATA$region, unique_world_data_countries)]
WORLD_DATA$ISO3[WORLD_DATA$region == "Kosovo"] = "XXK"

#QUERY FUNCTION
country_capacities <- function(observed_year) {
  # We first select the plants that operated during the year input$year and then sum them by country
  year_capacity_data <- PLANT_DATA[(PLANT_DATA$Status == 'operating' & PLANT_DATA$'Start year' <= observed_year) 
                                   | (PLANT_DATA$Status == 'retired' & PLANT_DATA$'Start year' <= observed_year & PLANT_DATA$'Retired year' >= observed_year)
                                   | (PLANT_DATA$Status == 'mothballed' & PLANT_DATA$'Start year' <= observed_year),] %>%
    group_by(ISO3)%>% summarise(coal_capacity=sum(`Capacity (MW)`), .groups='drop')
  
  return(year_capacity_data)
}

# THEME FUNCTION
plot_theme <- function () { 
  theme_bw() + theme(axis.text=element_text(size=14),
                     axis.title=element_text(size=14),
                     axis.ticks.y=element_blank(),
                     axis.ticks.x=element_blank(),
                     axis.text.y=element_blank(),
                     axis.text.x=element_blank(),
                     strip.text=element_text(size=14),
                     panel.grid.major=element_blank(), 
                     panel.grid.minor=element_blank(),
                     panel.background=element_blank(), 
                     legend.position="bottom",
                     panel.border=element_blank(), 
                     strip.background=element_rect(fill='white', colour='white'))
}

# PLOT FUNCTION
plot_world_map <- function (observed_year) {
  year_capacity_data <- country_capacities(observed_year)
  
  #Conversion of MW to GW
  year_capacity_data$coal_capacity <- (10 ** (-3)) * year_capacity_data$coal_capacity

  # World map data set for plots
  world_data <- WORLD_DATA
  world_data["coal_capacity"] <- year_capacity_data$coal_capacity[match(WORLD_DATA$ISO3, year_capacity_data$ISO3)]
  
  # Replacing Missing values by 0, assessing the database is comprehensive
  world_data[is.na(world_data$coal_capacity), "coal_capacity"] <- 0
  
  # World map plot
  g <- ggplot() + 
    geom_polygon_interactive(data=world_data, color='gray70', size=0.1,
                             aes(x=long, y=lat, fill=coal_capacity, group=group,
                                 tooltip = sprintf("%s<br/>%s GW", region, coal_capacity))) + 
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
}
