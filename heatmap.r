library(shiny)
library(dplyr)
library(ggplot2)
library(reshape2)
library(plotly)
library(DT)
library(httr)
library(jsonlite)
library(RJSONIO)
library(tidyr)

# static checkbox for disease&drugs
datasets <- list(
  'ALS'=read.csv('~/Downloads/ebi_ALS.tsv',sep="\t")%>%
    dplyr::rename("ebi_val"="log_2.fold.change"), 
  'Alzheimer'=read.csv('~/Downloads/ebi_Alzheimer.tsv',sep="\t")%>%
    dplyr::rename("ebi_val"="log_2.fold.change"), 
  'CF'=read.csv('~/Downloads/ebi_CF.tsv',sep="\t")%>%
    dplyr::rename("ebi_val"="log_2.fold.change"),
  'COVID19' = read.csv('~/Downloads/ebi_COVID19.tsv', sep="\t")%>% 
    dplyr::rename("ebi_val"="log_2.fold.change"),
  'COVID19_2' = read.csv('~/Downloads/ebi_COVID192.tsv', sep="\t")%>% 
    dplyr::rename("ebi_val"="log_2.fold.change"),
  'DMD'=read.csv('~/Downloads/ebi_DMD.tsv',sep="\t")%>%
    dplyr::rename("ebi_val"="log_2.fold.change"),
  'HepC'=read.csv('~/Downloads/ebi_HepC.tsv',sep="\t")%>%
    dplyr::rename("ebi_val"="log_2.fold.change"),
  'IPF'=read.csv('~/Downloads/ebi_IPF.tsv',sep="\t")%>%
    dplyr::rename("ebi_val"="log_2.fold.change"),
  'LC'=read.csv('~/Downloads/ebi_LC.tsv',sep="\t")%>%
    dplyr::rename("ebi_val"="log_2.fold.change"), 
  'Lung_Cancer'=read.csv('~/Downloads/ebi_LungCancer.tsv',sep="\t")%>%
    dplyr::rename("ebi_val"="log_2.fold.change"), 
  'Lupus'=read.csv('~/Downloads/ebi_Lupus.tsv',sep="\t")%>%
    dplyr::rename("ebi_val"="log_2.fold.change"), 
  'Lymphoma'=read.csv('~/Downloads/ebi_Lymphoma.tsv',sep="\t")%>%
    dplyr::rename("ebi_val"="log_2.fold.change"),
  'Pneumonia'=read.csv('~/Downloads/ebi_Pneumonia.tsv',sep="\t")%>%
    dplyr::rename("ebi_val"="log_2.fold.change"), 
  'Pso'=read.csv('~/Downloads/ebi_Pso.tsv',sep="\t")%>%
    dplyr::rename("ebi_val"="log_2.fold.change"), 
  'RA'=read.csv('~/Downloads/ebi_RA.tsv',sep="\t")%>%
    dplyr::rename("ebi_val"="log_2.fold.change"), 
  'RSV' = read.csv('~/Downloads/ebi_RSV.tsv', sep="\t")%>% 
    dplyr::rename("ebi_val"="log_2.fold.change"),
  'Sep'=read.csv('~/Downloads/ebi_Sep.tsv',sep="\t")%>%
    dplyr::rename("ebi_val"="log_2.fold.change"), 
  'TB' = read.csv('~/Downloads/ebi_TB.tsv', sep="\t") %>% 
    dplyr::rename("ebi_val"="log_2.fold.change")
)
datasets2 <- list(
  'SB' = read.csv('~/Downloads/TNF-DMSO_vs_TNF-SB203580.csv')%>%
    select(c("ID","log2FoldChange","Gene.name"))%>%
    dplyr::rename("sb_val"="log2FoldChange"), 
  'UM101' = read.csv('~/Downloads/UM101.csv')%>%
    dplyr::rename("um101_val"="log2FoldChange"),
  'SF7044'=read.csv('~/Downloads/TNF-DMSO_vs_TNF-SF7044.csv')%>%
    dplyr::rename("sf7044_val"="log2FoldChange"),
  'SF7009'=read.csv('~/Downloads/TNF-DMSO_vs_TNF-SF7009.csv')%>%
    dplyr::rename("sf7009_val"="log2FoldChange"),
  'SF6222' = read.csv('~/Downloads/TNF-DMSO_vs_TNF-SF6222.csv') %>%
    dplyr::rename('sf6222_val'='log2FoldChange')
)
sb <- datasets2[[1]]
um101 <- datasets2[[2]]
sf7044 <- datasets2[[3]]
sf7009 <- datasets2[[4]]
sf6222 <- datasets2[[5]]

ui <- fluidPage(
  title="GEn1E Heatmap Visualization",
  sidebarLayout(
    sidebarPanel(
      checkboxGroupInput(inputId="disease",label="Pick disease(s) to display",choices=names(datasets),width="50%"),
      checkboxGroupInput(inputId ="drug",label="Pick drug(s) to display",choices=names(datasets2),width="50%"),
      numericInput(inputId="num1",label="Choose amount of genes to display",value=0, width="50%"),
      width=3),
  mainPanel(
    tableOutput("view1"),
    uiOutput("plots"))
))

# FUNCTION: takes in SINGLE disease and MULTIPLE drugs and number to display
make_heatmap <- function(ebi1, drug1, num2) {
  # filter ebi w/ p-value and duplicates & read drug files
  ebi <- data.frame(datasets[[ebi1]]) %>% 
      select(c("Gene","ebi_val","Adjusted.p.value")) %>%
      filter(Adjusted.p.value<1.0E-04) %>%
      group_by(Gene) %>%
      filter(sign(max(ebi_val))==sign(min(ebi_val)) | max(ebi_val)-min(ebi_val)<0.5) %>%
      summarize(ebi_val=median(ebi_val))
  
  # merge ebi and drug data and filter gene count
  sb_filtered <- merge(sb,ebi,by.x="ID",by.y="Gene")
  um101_filtered <- merge(um101,ebi,by.x="ID", by.y="Gene")
  sf7044_filtered <- merge(sf7044,ebi,by.x="ID",by.y="Gene")
  sf7009_filtered <- merge(sf7009,ebi,by.x="ID",by.y="Gene")
  sf6222_filtered <- merge(sf6222,ebi,by.x="ID",by.y="Gene")
  temp <-merge(sb_filtered,um101_filtered,by.x="Gene.name",by.y="Gene.name",all=TRUE) %>%
      mutate(ebi_val.x = coalesce(ebi_val.x,ebi_val.y)) %>%
      dplyr::rename("ebi_val"="ebi_val.x") %>% 
      select(Gene.name, ebi_val, sb_val, um101_val)
  
  temp2<-merge(temp,sf7044_filtered,by.x="Gene.name",by.y="Gene.name",all=TRUE)  %>%
      mutate(ebi_val.x = coalesce(ebi_val.x,ebi_val.y)) %>%
      dplyr::rename("ebi_val"="ebi_val.x") %>%
      select(Gene.name, ebi_val, sb_val, um101_val, sf7044_val) 
  
  temp3<-merge(temp2,sf7009_filtered,by.x="Gene.name",by.y="Gene.name",all=TRUE)  %>%
    mutate(ebi_val.x = coalesce(ebi_val.x,ebi_val.y)) %>%
    dplyr::rename("ebi_val"="ebi_val.x") %>%
    select(Gene.name, ebi_val, sb_val, um101_val, sf7044_val,sf7009_val) 
  
  joint<-merge(temp3,sf6222_filtered,by.x="Gene.name",by.y="Gene.name",all=TRUE)  %>%
    mutate(ebi_val.x = coalesce(ebi_val.x,ebi_val.y)) %>%
    dplyr::rename("ebi_val"="ebi_val.x") %>%
    select(Gene.name, ebi_val, sb_val, um101_val, sf7044_val,sf7009_val,sf6222_val)%>%
    replace(is.na(.), 0) %>%
    arrange(desc(abs(ebi_val))) %>%
    head(num2) 
  
  # create matrix
  m <- matrix(c(joint$ebi_val, joint$sb_val,joint$um101_val,joint$sf7044_val,joint$sf7009_val,joint$sf6222_val),
             ncol=6,
             nrow=num2,
             dimnames=list(joint$Gene.name,append(c('SB','UM101','SF7044','SF7009','SF6222'),ebi1,after=0)))
  if(!('SB' %in% drug1)){
    m<-m[, setdiff(colnames(m),"SB")]
  }
  if(!('UM101' %in% drug1)){
    m<-m[, setdiff(colnames(m),"UM101")]
  }
  if(!('SF7044' %in% drug1)){
    m<-m[, setdiff(colnames(m),"SF7044")]
  }
  if(!('SF7009' %in% drug1)){
    m<-m[, setdiff(colnames(m),"SF7009")]
  }
  if(!('SF6222' %in% drug1)){
    m<-m[, setdiff(colnames(m),"SF6222")]
  }
  
  # create heatmap
  data<- melt(m) %>% dplyr::rename("Condition"="Var2", "Gene"="Var1", "Log2FoldChange"="value")
  plot <- ggplotly(
        ggplot(data, aes(x = Condition, y = Gene)) +
          geom_raster(aes(fill=Log2FoldChange))+
          labs(title = "GEn1E Drugs Visualization Heatmap", x="Condition",y="Gene Name")+
          scale_fill_gradient2(midpoint=0, low="#4252A7", mid="#fff8c2", high="#b81a32")+
          theme(plot.title = element_text(hjust = 0.5)))
  return(plot)
}

server <- function(input,output){
  plotInput <- reactive({
    n_plot <- length(input$disease)
    total_data <- lapply(1:n_plot, function(i){rnorm(500)})
    return (list("n_plot"=n_plot, "total_data"=total_data))
  })
  output$plots <- renderUI({
    plot_output_list <- lapply(1:plotInput()$n_plot, function(i) {
      plotname <- paste("plot", i, sep="")
      plotlyOutput(plotname, height = 400, width = 580)
    })   
    do.call(tagList, plot_output_list)
  })
  observe({
    lapply(1:plotInput()$n_plot, function(i){
      output[[paste("plot", i, sep="") ]] <- renderPlotly({
        make_heatmap(input$disease[[i]],input$drug,input$num1)
      })
    })
  })
}
shinyApp(ui=ui, server=server)