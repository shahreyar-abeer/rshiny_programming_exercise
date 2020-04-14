


server = function(input, output) {
    
    ## select patient
    output$inp_patient = renderUI({
        selectizeInput(inputId = "patient", label = "Patient ID", choices = patient_list)
    })
    
    ## select test
    output$inp_test = renderUI({
        selectizeInput(inputId = "test", label = "Test", choices = test_list)
    })
    
    ## data for p1
    d1 = reactive({
        data_merged %>%
            filter(usubjid == input$patient, lbtestcd == input$test) %>% 
            mutate(type = as.factor(c(1, (ifelse(aval[2:7] >= input$threshold, 2, 3)))))
    })
    
    ## data for p2
    d2 = reactive({
        data_merged %>%
            filter(usubjid == input$patient)
    })
    
    ## the first plot
    output$plot1 = renderPlot({
        wh = which(d1()$lbtestcd == input$test)
        d1() %>% 
            ggplot(aes(x = avisit, y = aval, group = 1)) +
            geom_path(color = "#1F77B4", size = .75) +
            geom_point(aes(color = d1()$type), size = 4, show.legend = T) +
            scale_color_manual(values = c("1" = "grey", "2" = "red", "3" = "#1F77B4"), name = "",
                               labels = c("1" = "Screening", "2" = "Above threshold", "3" = "Below threshold")) +
            xlab("Visit") +
            ylab(glue("{d1()$avalu[wh][1]}")) +
            scale_x_discrete(limits = d1()$avisit) +
            ylim(0, max(d1()$aval + 20)) +
            geom_hline(yintercept = input$threshold, color = "red", linetype = "longdash") +
            ggthemes::theme_pander() +
            easy_legend_at("bottom") +
            labs(title = glue("{input$test} test scores for Patient: {input$patient}"),
                 subtitle = "The red line indicates threshold value. Simply put, values above this line are not good.")
    })
    
    ## patient info
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
        
        wh = which(d1()$lbtestcd == input$test)
        data.frame(t(p1)) %>%
            janitor::row_to_names(1) %>%
            gt() %>% 
            tab_header(title = "Test Scores", subtitle = glue("Test: {d1()$lbtest[wh][1]}, ({d1()$avalu[wh][1]})")) %>% 
            opt_table_lines()
    })
    
    ## second plot, joins using patchwork's '|'
    output$plot2 = renderPlot({
        if (input$show_others) {
            remaining_tests = test_list[test_list != input$test]
            make_plot2(d2(), d1(), remaining_tests[1]) | make_plot2(d2(), d1(), remaining_tests[2])
        }
    })
}
