


ui = dashboardPage(
    
    ##-----------------------------------------------------------------
    ## header
    
    dashboardHeader(
        title = "Some Cool Name"
    ),
    
    ##-----------------------------------------------------------------
    ## sidebar
    
    dashboardSidebar(
        div(h4("Inputs"), align = "center"),
        div(
            id = "tab1_inputs",
            uiOutput("inp_patient"),
            uiOutput("inp_test"),
            checkboxInput("switch", "Threshold?"),
            uiOutput("inp_threshold"),
            checkboxInput("show_others", "Show all tests")
        ),
        hidden(div(
            id = "tab2_inputs",
            uiOutput("inp2_var1"),
            div(
                checkboxInput("box", "Boxplot", value = TRUE),
                checkboxInput("violin", "Violinplot", value = TRUE),
                checkboxInput("show_color", "Show color", value = FALSE)
            )
        ))
    ),
    
    ##-----------------------------------------------------------------
    ## body
    
    dashboardBody(
        useShinyjs(),  # needed to use shinyjs
        fluidRow(
            tabBox(
                id = "tabs",
                width = 12,
                #------------------------------------------------------
                # tab1
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
                #------------------------------------------------------
                #tab2
                tabPanel(
                    title = "Overall",
                    fluidRow(
                        column(
                            width = 12,
                            plotOutput("plot2", height = 570)
                        )
                    )
                )
            )
        )
    )
)
