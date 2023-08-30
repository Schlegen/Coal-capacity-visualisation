library(shiny)

# Define server logic required to draw a histogram
function(input, output, session) {

    output$dataDisplay <- renderText({
        input$year
    })
}
