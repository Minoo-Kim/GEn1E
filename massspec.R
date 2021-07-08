library(shiny)
library(dplyr)
library(ggplot2)
library(forcats)

ui <- fluidPage(
  fileInput(inputId="file1", 
            "Choose CSV File", 
            label="Upload Data", 
            multiple = FALSE, 
            accept = NULL, 
            width = "30%"),
  plotOutput(outputId = "plot1", width="80%")
)

server <- function(input, output) {
  inFile <- reactive({input$file1})
  output$plot1 <- renderPlot({
      ggplot(read.csv(inFile()$datapath), aes(x=Mass, y=Intensity))+
      geom_bar(stat="identity", width=0.1, fill="#0000FF")+ 
      labs(title = "Mass Spec Graph", x="Mass charge (kg/C)", y="Intensity (cps)")+
      geom_text(aes(label=Intensity),hjust=0,vjust=0)
  })
}

shinyApp(ui=ui, server=server)