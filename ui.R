

library(shiny)
library(shinydashboard)

ui = dashboardPage(
    
    dashboardHeader(
        title = "Some Cool Name"
    ),
    
    dashboardSidebar(
        div(h4("Inputs"), align = "center"),
        uiOutput("inp_patient"),
        uiOutput("inp_test"),
        numericInput("threshold", "Threshold", min = 0, max = 100, value = 50)
    ),
    
    dashboardBody(
        fluidRow(
            tabBox(
                id = "tabs",
                width = 12,
                tabPanel(
                    title = "Plot1",
                    fluidRow(
                        column(
                            width = 7,
                            plotOutput("plot1")
                        ),
                        column(
                            width = 5,
                            gt_output("patient_info")
                        )
                    )
                ),
                tabPanel(
                    title = "Plot2"
                )
            )
        )
    )
)
