


server = function(input, output) {
    
    ## select patient
    output$inp_patient = renderUI({
        selectizeInput(inputId = "patient", label = "Patient ID", choices = patient_list)
    })
    
    ## select test
    output$inp_test = renderUI({
        selectizeInput(inputId = "test", label = "Test", choices = test_list)
    })
    
    ## a lollipop chart
    output$plot1 = renderPlot({
        d1 = data_merged %>%
            filter(USUBJID == input$patient, LBTESTCD == input$test)
        p1 = d1 %>% 
            lollipop_chart(x = AVISIT, y = AVAL, horizontal = F, sort = F, point_color = "red") +
            geom_hline(yintercept = input$threshold, color = "red", linetype = "longdash") +
            gghighlight::gghighlight(AVAL > input$threshold,
                                     unhighlighted_params = aes(colour = "#1F77B4"),
                                     use_direct_label = F) +
            scale_x_discrete(limits = d1$AVISIT)
        p1
    })
    
    ## info of the patient
    output$patient_info = render_gt({
        data_merged %>%
            filter(USUBJID == input$patient, LBTESTCD == input$test) %>%
            select(BMRKR1, BMRKR2, AGE, SEX, RACE, ACTARM, LBCAT) %>%
            slice(1) %>% 
            gt() %>%
            tab_header(title = "Patient Details", subtitle = glue("Patient ID: {input$patient}")) %>% 
            opt_table_lines()
            
    })
}
