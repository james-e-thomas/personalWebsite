library(shiny)
library(shinydashboard)
library(plotly)

data <-  data.frame(x = c(1, 2, 3, 4), y = c(10, 11, 12, 13))

ui <- fluidPage(
  titlePanel(""),
  
  sidebarLayout(position = "left",
                sidebarPanel(sliderInput("sliderA", "a", min = 0, max = 10, step = 0.01, value = 0),
                             sliderInput("sliderB", "b", min = -5, max = 5, step = 0.01, value = 1)),
                mainPanel(fluidRow(column(6, uiOutput('equation'))),
                          fluidRow(column(6, plotlyOutput('waveplot'))))
  )
)

server <- function(input, output, session) { 
  
  output$equation <- renderUI({
    h3(paste0("y = ", input$sliderA, " + ", input$sliderB, "x"))
  })
  
  output$waveplot <- renderPlotly({
    x <- seq(0, 10, 0.1)
    yfxn <- function(x) { input$sliderA + input$sliderB*x }
    y <- yfxn(x)
    df <- data.frame(x,y)
    # ggplot(df,aes_string(x=x,y=y))+geom_point(size=2)+geom_line()+ 
    #   scale_x_continuous()
    plot_ly(df,
            x = ~x,
            y = ~y,
            type = "scatter",
            mode = "line") %>% 
      layout(xaxis = list(range = c(0, 10)),
             yaxis = list(range = c(0, 10)))
  }) 
}

shinyApp(ui, server)