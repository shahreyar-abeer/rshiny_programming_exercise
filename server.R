


server = function(input, output, session) {
    
    ##-----------------------------------------------------------------------------------
    ## tab1
    
    ## show inputs based on active tab
    observeEvent(input$tabs, {
        if (input$tabs == "Patient by Patient") {
            hide("tab2_inputs", anim = T, animType = "fade")
            delay(500, show("tab1_inputs", anim = T))
        }
        else {
            hide("tab1_inputs", anim = T, animType = "fade")
            delay(500, show("tab2_inputs", anim = T))
        }
            
    })
    
    ## if threshold is checked
    observeEvent(input$show_threshold, {
        if (isTRUE(input$show_threshold)) show("threshold", anim = TRUE)
        else hide("threshold", anim = TRUE, animType = "fade")
    })
    
    ## select patient
    output$inp_patient = renderUI({
        selectizeInput(inputId = "patient", label = "Patient ID", choices = patient_list)
    })
    
    ## select test
    output$inp_test = renderUI({
        selectizeInput(inputId = "test", label = "Test", choices = test_list)
    })
    
    ## data for plot1
    d1 = reactive({
        req(input$patient)
        data_merged %>%
            filter(usubjid == input$patient, lbtestcd == input$test) %>% 
            mutate(type = as.factor(c(1, (ifelse(aval[2:7] >= input$threshold, 2, 3)))))
    })
    
    ## data for plot2
    d2 = reactive({
        req(input$patient)
        data_merged %>%
            filter(usubjid == input$patient)
    })
    
    ##-----------------------------------------------------------------------------------
    ## plot1
    output$plot1 = renderPlot({
        
        wh = which(d1()$lbtestcd == input$test)
        d1() %>% 
            ggplot(aes(x = avisit, y = aval, group = 1)) +
            geom_path(color = "#1F77B4", size = .75) +
            {
                if (input$show_threshold) geom_point(aes(color = d1()$type), size = 4, show.legend = T)
                else geom_point(size = 4, color = "#1F77B4", show.legend = F)
            } +
            scale_color_manual(values = c("1" = "grey", "2" = "red", "3" = "#1F77B4"), name = "",
                               labels = c("1" = "Screening", "2" = "Above threshold", "3" = "Below threshold")) +
            xlab("Visit") +
            ylab(glue("Lab Measurment value ({d1()$avalu[wh][1]})")) +
            scale_x_discrete(limits = d1()$avisit) +
            ylim(0, max(d1()$aval + 20)) +
            {if (input$show_threshold) geom_hline(yintercept = input$threshold, color = "red", linetype = "longdash")} +
            labs(title = glue("{input$test} Lab Measurments for Patient: {input$patient} across visits.")) +
            {if (input$show_threshold) labs(subtitle = "The red line indicates a threshold value.")} +
            theme1()
                 
    })
    
    ##-----------------------------------------------------------------------------------
    ## patient info
    output$patient_info = render_gt({
        d1() %>% 
            select(studyid, age, sex, race, bmrkr1, bmrkr2, actarm, lbcat) %>%
            slice(1) %>% 
            gt() %>%
            tab_header(title = "Patient Profile", subtitle = glue("Patient ID: {input$patient}")) %>% 
            opt_table_lines()
    })
    
    ##-----------------------------------------------------------------------------------
    ## patient data
    output$patient_data = render_gt({
        if (!input$show_others) {
            p1 = d1() %>% 
                select(avisit, aval)
            
            wh = which(d1()$lbtestcd == input$test)
            data.frame(t(p1)) %>%
                row_to_names(1) %>%
                gt() %>% 
                tab_header(title = "Lab Measurments", subtitle = glue("Test: {d1()$lbtest[wh][1]}, ({d1()$avalu[wh][1]})")) %>% 
                opt_table_lines()
        }
        else {
            data_merged %>% 
                filter(usubjid == input$patient) %>% 
                mutate(lbtestcd = glue("{lbtestcd}({avalu})")) %>% 
                select(avisit, lbtestcd, aval) %>%
                pivot_wider(id_cols = lbtestcd, names_from = avisit, values_from = aval) %>%
                gt(rowname_col = "lbtestcd") %>% 
                tab_stubhead("Test (unit)") %>% 
                tab_header(title = "Lab Measurments") %>%
                opt_table_lines()
        }
        
    })
     ##----------------------------------------------------------------------------------
    ## second plot on first tab, joins using patchwork's '|'
    output$plot1b = renderPlot({
        if (input$show_others) {
            remaining_tests = test_list[test_list != input$test]
            make_plot1b(d2(), d1(), remaining_tests[1]) | make_plot1b(d2(), d1(), remaining_tests[2])
        }
    })
    
    ##------------------------------------------------------------------------------------
    ## tab2
    
    ## variable to select for showing association
    output$inp2_var1 = renderUI({
        selectizeInput("var1", "Choose a variable", choices = var_list, selected = "aval")
    })
    
    ## lab measurment select for tab2
    output$inp_test2 = renderUI({
        hidden(selectizeInput("test2", "Select test", choices = test_list))
    })
    
    ## some inputs show/hide when the user chooses to do the analysis by single vars
    observeEvent(input$single_test_analysis, {
        if(isTRUE(input$single_test_analysis)) {
            show("test2", anim = TRUE)
        }
        else {
            hide("test2", anim = T, animType = FALSE)
        }
    })
    
    ## showing inputs in tab2 based on the variable selected
    observeEvent(input$var1, {
        if (input$var1 == "aval") {
            hide("continuous_vars", anim = TRUE, animType = "fade")
            hide("discrete_vars", anim = TRUE, animType = "fade")
            delay(500, show("show_color", anim = TRUE))
        }
        else if (input$var1 %notin% cont_vars) {
            hide("continuous_vars", anim = TRUE, animType = "fade")
            delay(500, show("discrete_vars", anim = TRUE))
            delay(500, show("show_color", anim = TRUE))
        }
        else {
            hide("discrete_vars", anim = T, animType = "fade")
            hide("show_color", anim = T, animType = "fade")
            delay(500, show("continuous_vars", anim = T))
        }
    })
    
    ## data for plot2
    d3 = reactive({
        if (isTRUE(input$single_test_analysis)) {
            req(input$test2)
            data_merged %>% 
                filter(lbtestcd == input$test2)
        }
        else
            data_merged
    })
    
    ## plot2
    output$plot2 = renderPlot({
        req(input$var1)
        var1 = as.symbol(input$var1)
        var1 = enquo(var1)
        var_name = names(var_list[var_list == input$var1])
        ## histogram
        if (input$var1 == "aval") {
            d3() %>%
                ggplot(aes(x = aval)) + 
                {if (input$show_color) geom_histogram(aes(fill = lbtestcd), bins = 50, color = "black")} +
                {if (!input$show_color) geom_histogram(bins = 50, color = "black", alpha = .5)} +
                scale_fill_viridis_d(alpha = .5, option = "E") +
                xlab("Lab Measurment value") +
                theme2() +
                labs(title = glue("Distribution of the {ifelse(isTRUE(input$single_test_analysis), glue('{input$test2} Lab Measurment'), 'the 3 Lab Measurments')}")) +
                facet_grid(lbtestcd ~ .)
        }
        ## boxplots
        else if (input$var1 %notin% cont_vars) {
            d3() %>%
                ggplot(aes(x = reorder(!!var1, aval, FUN = median), y = aval)) +
                {if (input$violin & input$show_color) geom_violin(aes(fill = lbtestcd), width = .6, position = position_dodge())} +
                {if (input$violin & !input$show_color) geom_violin(width = .6, position = position_dodge())} +
                {if (input$box & input$show_color) geom_boxplot(aes(fill = lbtestcd), width = .4, position = position_dodge(), alpha = .3)} +
                {if (input$box & !input$show_color) geom_boxplot(width = .4, position = position_dodge(), alpha = .3)} +
                stat_summary(fun = mean, geom = "point", size = 2, color = "#f7347a") +
                scale_fill_viridis_d(alpha = .4, option = "E") +
                coord_flip() +
                labs(title = glue("Distribution of the {ifelse(isTRUE(input$single_test_analysis), glue('{input$test2} Lab Measurment'), 'the 3 Lab Measurments')} sorted by {var_name}"),
                     caption = "*The pink dot represents mean") +
                xlab(var_name) +
                ylab("Lab Measurment value") +
                theme2() +
                facet_grid(~lbtestcd, scales = "fixed")
        }
        ## scatter plot
        else {
            d3() %>%
                ggplot(aes(x = !!var1, y = aval)) +
                geom_point() +
                labs(title = glue("Correlation between the {ifelse(isTRUE(input$single_test_analysis), glue('{input$test2} Lab Measurment'), '3 Lab Measurments')} and {var_name}")) +
                xlab(var_name) +
                ylab("Lab Measurment value") +
                theme2() +
                {if (input$regression_line) geom_smooth(method = "lm", color = "red")} +
                facet_grid(~lbtestcd, scales = "fixed")
        }
    }, height = 570)
}
