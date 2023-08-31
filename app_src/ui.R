library(shiny)
library(ggiraph)
# Define UI for application
fluidPage(

    # Application title
    titlePanel("Coal Power Capacity per Country"),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
          textInput("year", "Enter the year of the visualisation :", value="1990")
          ),

        # Show a plot of the generated distribution
        mainPanel(
          girafeOutput("worldPlot"),
          tableOutput("dataDisplay")
        )
    )
)
