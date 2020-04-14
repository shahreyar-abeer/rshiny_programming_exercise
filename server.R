


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
            filter(usubjid == input$patient, lbtestcd == input$test) %>% 
            mutate(type = as.factor(c(1, (ifelse(aval[2:7] >= input$threshold, 2, 3)))))
    })
    
    d2 = reactive({
        data_merged %>%
            filter(usubjid == input$patient)
    })
    
    ## a lollipop chart
    output$plot1 = renderPlot({
        d1() %>% 
            ggplot(aes(x = avisit, y = aval, group = 1)) +
            geom_path(color = "#1F77B4", size = .75) +
            geom_point(aes(color = d1()$type), size = 4, show.legend = T) +
            scale_color_manual(values = c("grey", "red", "#1F77B4"), name = "", labels = c("Screening", "Above threshold", "Below threshold")) +
            xlab("Visit") +
            ylab("Test value") +
            scale_x_discrete(limits = d1()$avisit) +
            ylim(0, max(d1()$aval + 20)) +
            geom_hline(yintercept = input$threshold, color = "red", linetype = "longdash") +
            ggthemes::theme_pander(base_family = "monospace") +
            easy_legend_at("bottom") +
            labs(title = glue("{input$test} test scores for Patient: {input$patient}"),
                 subtitle = "The red line indicates threshold value. Simply put, values above this line are not good.")
    })
    
    ## info of the patient
    output$patient_info = render_gt({
        d1() %>% 
            select(bmrkr1, bmrkr2, age, sex, race, actarm, lbcat) %>%
            slice(1) %>% 
            gt() %>%
            tab_header(title = "Patient Details", subtitle = glue("Patient ID: {input$patient}")) %>% 
            opt_table_lines()
    })
    
    ## patient data
    output$patient_data = render_gt({
        p1 = d1() %>% 
            select(avisit, aval)
        
        data.frame(t(p1)) %>%
            janitor::row_to_names(1) %>%
            gt() %>% 
            tab_header(title = "Test Scores", subtitle = glue("Test: {input$test}")) %>% 
            opt_table_lines()
    })
    
    output$plot2 = renderPlot({
        if (input$show_others) {
            make_plot2(d2(), d1(), input$test)
        }
        
    })
}
