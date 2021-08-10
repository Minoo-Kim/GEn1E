library(shiny)
library(ggplot2)
library(dplyr)
library(tidyverse)
library(cluster)

ui <- fluidPage(
  title="GEn1E Cluster Visualization",
  sidebarLayout(
    sidebarPanel(
      fileInput(inputId="file1", 
                "Choose CSV File", 
                label="Upload Data", 
                multiple = FALSE, 
                accept = NULL, 
                width = "80%"),
      sliderInput(inputId="num1",
                  label="Choose amount of clusters to display",
                  value=0, 
                  min=2,
                  max=15,
                  width="80%")),
    mainPanel(
      plotlyOutput(outputId = "graph",width="auto",height="auto"), 
      plotOutput(outputId = "curve"),
      tableOutput("test"))
))

server <- function(input, output) {
  data <- reactive({
    read.csv(input$file1$datapath)[1:100, ] 
  })
  
  # remove na values from data
  data2 <- reactive({
    data()[complete.cases(data()), ]
  })
  
  # scale data for non-biased clustering (otherwise clustering would be biased by variables which are higher)
  data3 <- reactive({
    data2()[, -c(1)]
  })
  data4 <- reactive({
    scale(data3()[, -c(1)])
  })
  
  set.seed(123)
  
  # function to compute total within-cluster sum of square 
  wss <- reactive({
    function(k) {
      kmeans(data4()[,-1], algorithm="Lloyd", centers=k, iter.max = 10, nstart = 10 )$tot.withinss
    }
  })
  
  # Compute and plot wss for k = 1 to k = 15
  k.values <- 1:15
  gc()
  
  # extract wss for 2-15 clusters - this step takes a loooottt of time
  wss_values <- reactive({
    map_dbl(k.values, wss())
  })
  
  #plot wss vs cluster no. to obtain optimum no. of clusters indicated by elbow in curve
  output$curve <- renderPlot({
    plot(k.values, wss_values(),
       type="b", pch = 19, frame = FALSE, 
       xlab="Number of clusters K",
       ylab="Total within-clusters sum of squares")
  })
  
  # K-Means Cluster Analysis
  fit <- reactive({
    kmeans(data4()[,-1], input$num1) # 4 cluster solution
  })
  o <- reactive({
    order(fit()$cluster)
  })
  data5 <- reactive({
    data.frame(data4(),fit()$cluster)
  })

  #plot the clusters in a 2D respresentation
  # output$graph <- renderPlot({
  #   clusplot(data4()[,-1], fit()$cluster, main='2D representation of the Cluster solution', color=TRUE, shade=TRUE, labels=2, lines=0)
  # })
  # output$test <- renderTable({
  #   data5()
  # })
  output$graph  <- renderPlotly({
    plot_ly(data5(), 
            x=data5()$hbonddonor, 
            y=data5()$hbondacc,
            z=data5()$rotbonds,
            color=data5()$fit...cluster,
            size=2,
            text = ~paste("Compound : ", data2()$cmpdname,
                  "<br> H bond acceptors :", data2()$hbondacc,
                  "<br> H bond acceptors :", data2()$hbonddonor,
                  "<br> Rotational Bonds :", data2()$rotbonds),
            textposition = "auto", 
            hoverinfo = "text") %>% 
      add_markers() %>%
      layout(scene = list(xaxis = list(title = 'Hbonddonor'),
                          yaxis = list(title = 'Hbondacc'),
                          zaxis = list(title = 'Rotbonds'))) 
  })
}
shinyApp(ui=ui, server=server)