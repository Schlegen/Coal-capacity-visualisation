library(shiny)

# Define UI for application
fluidPage(

    # Application title
    titlePanel("Coal Power World Capacity per Country"),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
          textInput("year", "Year of the visualisation?", value="1990")
          ),

        # Show a plot of the generated distribution
        mainPanel(
          tableOutput("dataDisplay")
        )
    )
)
