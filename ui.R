

library(shiny)
library(shinydashboard)

ui = dashboardPage(
    
    #useshinyjs(),
    
    dashboardHeader(
        title = "Some Cool Name"
    ),
    
    dashboardSidebar(
        div(h4("Inputs"), align = "center"),
        uiOutput("inp_patient"),
        uiOutput("inp_test"),
        checkboxInput("switch", "Threshold?"),
        uiOutput("inp_threshold"),
        checkboxInput("show_others", "Show the other tests (for comparison)")
    ),
    
    dashboardBody(
        fluidRow(
            tabBox(
                id = "tabs",
                width = 12,
                tabPanel(
                    title = "Patient by Patient",
                    fluidRow(
                        column(
                            width = 6,
                            plotOutput("plot1")
                        ),
                        column(
                            width = 6,
                            gt_output("patient_info"),
                            br(),
                            gt_output("patient_data")
                        )
                    ),
                    fluidRow(
                        column(
                            width = 12,
                            plotOutput("plot2")
                        )
                    )
                ),
                tabPanel(
                    title = "Plot2",
                    fluidRow(
                        column(
                            width = 12
                            
                        )
                    )
                    
                    
                )
            )
        )
    )
)
