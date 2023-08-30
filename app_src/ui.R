library(shiny)

# Define UI for application
fluidPage(

    # Application title
    titlePanel("Coal World capacity visualisation"),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
          textInput("year", "Year of the visualisation?")
          ),

        # Show a plot of the generated distribution
        mainPanel(
          textOutput("dataDisplay")
        )
    )
)
