

library(shiny)
library(shinydashboard)

ui = dashboardPage(
    
    dashboardHeader(
        title = "Some Cool Name"
    ),
    
    dashboardSidebar(
        uiOutput("inp_patient")
    ),
    
    dashboardBody(
        
    )
)
