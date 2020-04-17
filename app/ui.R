

ui = dashboardPage(
    
    ##-----------------------------------------------------------------
    ## header
    dashboardHeader(
        title = "Some Cool Name"
    ),
    
    ##-----------------------------------------------------------------
    ## sidebar
    dashboardSidebar(
        div(
            id = "tab1_inputs",
            div(
                div(h4("Narrative"), align = "center"),
                p("An app built for exploratory analysis.
                  This page lets you explore the data for each patient, thoroughly,
                  for each lab measurments."),
                p("Choosing a patient and a test shows the lab measurments of the patient across visits
                  in a plot along with the data.")
            ),
            uiOutput("inp_patient"),
            uiOutput("inp_test"),
            checkboxInput("show_threshold", "Threshold?"),
            hidden(numericInput("threshold", "Threshold (To be determined by experts)",
                         min = 0, max = 100, value = 50)),
            checkboxInput("show_others", "Show the other tests")
        ),
        hidden(div(
            id = "tab2_inputs",
            div(
                div(h4("Narrative"), align = "center"),
                p("This page helps in finding patterns among variables."),
                p("Plots are created automatically based on variable types.
                  Choosing a variable shows its relation with the lab measurments, default is all 3 tests.")
            ),
            div(actionButton("data_overview", "Data Overview", icon = icon("database")), align = "center"),
            uiOutput("inp2_var1"),
            div(
                id = "discrete_vars",
                checkboxInput("box", "Boxplot", value = TRUE),
                checkboxInput("violin", "Violinplot", value = FALSE)
            ),
            div(
                id = "continuous_vars",
                checkboxInput("regression_line", "Regression line")
            ),
            checkboxInput("show_color", "Dude it's shiny, show some colors!", value = FALSE),
            checkboxInput("single_test_analysis",
                          "I'd like to do the analysis by single Lab Measurments"),
            uiOutput("inp_test2")
        ))
    ),
    
    ##-----------------------------------------------------------------
    ## body
    dashboardBody(
        useShinyjs(),  # needed for shinyjs
        
        ## some html/css
        tags$head(tags$style(HTML(
            "section.sidebar .shiny-input-container {
            padding: 2px 15px 0px 15px;
            }
            form-group {
            margin-bottom:10px;
            }"
        ))),
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
                    title = "Finding Overall Patterns",
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
