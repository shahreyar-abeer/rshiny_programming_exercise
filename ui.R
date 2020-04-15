


ui = dashboardPage(
    
    dashboardHeader(
        title = "Some Cool Name"
    ),
    
    dashboardSidebar(
        div(h4("Inputs"), align = "center"),
        div(
            id = "tab1_inputs",
            uiOutput("inp_patient"),
            uiOutput("inp_test"),
            checkboxInput("switch", "Threshold?"),
            uiOutput("inp_threshold"),
            checkboxInput("show_others", "Show the other tests")
        ),
        hidden(div(
            id = "tab2_inputs",
            uiOutput("inp2_var1")
        ))
    ),
    
    dashboardBody(
        useShinyjs(),  # needed to use shinyjs
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
                            plotOutput("plot1b")
                        )
                    )
                ),
                tabPanel(
                    title = "Overall",
                    fluidRow(
                        column(
                            width = 12,
                            plotOutput("plot2")
                        )
                    )
                    
                    
                )
            )
        )
    )
)
