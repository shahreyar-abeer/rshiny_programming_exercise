


server = function(input, output) {
    
    ## select patient
    output$inp_patient = renderUI({
        selectizeInput(inputId = "patient", label = "Patient ID", choices = patient_list)
    })
    
    ## select test
    output$inp_test = renderUI({
        selectizeInput(inputId = "test", label = "Test", choices = test_list)
    })
    
    d1 = reactive({
        data_merged %>%
            filter(USUBJID == input$patient, LBTESTCD == input$test) %>% 
            mutate(type = as.factor(ifelse(AVAL >= input$threshold, 1, 2)))
    })
    
    ## a lollipop chart
    output$plot1 = renderPlot({
        d1() %>% 
            ggplot(aes(x = AVISIT, y = AVAL, group = 1)) +
            geom_path(color = "#1F77B4", size = .75) +
            geom_point(aes(color = d1()$type), size = 4, show.legend = F) +
            scale_color_manual(values = c("red", "#1F77B4")) +
            xlab("Visit") +
            ylab("Test value") +
            scale_x_discrete(limits = d1()$AVISIT) +
            ylim(0, max(d1()$AVAL + 20)) +
            geom_hline(yintercept = input$threshold, color = "red", linetype = "longdash") +
            ggthemes::theme_hc() +
            labs(title = glue("{input$test} test scores for Patient: {input$patient}"),
                 subtitle = "The red line indicates threshold value. Values above this line is deemed 'not-normal' by epidemiologists")
    })
    
    ## info of the patient
    output$patient_info = render_gt({
        d1() %>% 
            select(BMRKR1, BMRKR2, AGE, SEX, RACE, ACTARM, LBCAT) %>%
            slice(1) %>% 
            gt() %>%
            tab_header(title = "Patient Details", subtitle = glue("Patient ID: {input$patient}")) %>% 
            opt_table_lines()
    })
    
    ## patient data
    output$patient_data = render_gt({
        p1 = d1() %>% 
            select(AVISIT, AVAL)
        data.frame(t(p1)) %>%
            janitor::row_to_names(1) %>%
            gt() %>% 
            tab_header(title = "Data") %>% 
            opt_table_lines()
    })
}
