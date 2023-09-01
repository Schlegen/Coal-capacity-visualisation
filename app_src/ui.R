library(shiny)
library(ggiraph)
# Define UI for application
fluidPage(

    # Application title
    titlePanel("Coal Power Capacity per Country"),

    # Text input to select the year
    sidebarLayout(
        sidebarPanel(
          textInput("year", "Enter the year of the visualisation :", value="1990")
          ),
        
        # Map output
        mainPanel(
          girafeOutput("worldPlot")
        )
    )
)
