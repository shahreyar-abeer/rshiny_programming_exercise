


server = function(input, output) {
    
    ##--------------------------------------------------
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
    output$inp_threshold = renderUI({
        if (input$switch)
            numericInput("threshold", "Threshold (To be determined by experts)", min = 0, max = 100, value = 50)
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
    
    ## the first plot
    output$plot1 = renderPlot({
        
        wh = which(d1()$lbtestcd == input$test)
        d1() %>% 
            ggplot(aes(x = avisit, y = aval, group = 1)) +
            geom_path(color = "#1F77B4", size = .75) +
            {
                if (input$switch) geom_point(aes(color = d1()$type), size = 4, show.legend = T)
                else geom_point(size = 4, color = "#1F77B4", show.legend = F)
            } +
            scale_color_manual(values = c("1" = "grey", "2" = "red", "3" = "#1F77B4"), name = "",
                               labels = c("1" = "Screening", "2" = "Above threshold", "3" = "Below threshold")) +
            xlab("Visit") +
            ylab(glue("Measurment ({d1()$avalu[wh][1]})")) +
            scale_x_discrete(limits = d1()$avisit) +
            ylim(0, max(d1()$aval + 20)) +
            {if (input$switch) geom_hline(yintercept = input$threshold, color = "red", linetype = "longdash")} +
            labs(title = glue("{input$test} Lab Measurments for Patient: {input$patient} across visits.")) +
            {if (input$switch) labs(subtitle = "The red line indicates threshold value. Simply put, values above this line show an element of risk.")} +
            theme_discrete_chart()
                 
    })
    
    ## patient info
    output$patient_info = render_gt({
        d1() %>% 
            select(studyid, age, sex, race, bmrkr1, bmrkr2, actarm, lbcat) %>%
            slice(1) %>% 
            gt() %>%
            tab_header(title = "Patient Profile", subtitle = glue("Patient ID: {input$patient}")) %>% 
            opt_table_lines()
    })
    
    ## patient data
    output$patient_data = render_gt({
        if (!input$show_others) {
            p1 = d1() %>% 
                select(avisit, aval) %>% 
                mutate(aval = round(aval, 1))
            
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
                fmt_number(columns = everything(), decimal = 1) %>% 
                opt_table_lines()
        }
        
    })
    
    ## second plot on first tab, joins using patchwork's '|'
    output$plot1b = renderPlot({
        if (input$show_others) {
            remaining_tests = test_list[test_list != input$test]
            make_plot1b(d2(), d1(), remaining_tests[1]) | make_plot1b(d2(), d1(), remaining_tests[2])
        }
    })
    
    ##----------------------------------------------------------
    ## tab2
    
    ## variable to select for showing association
    output$inp2_var1 = renderUI({
        selectizeInput("var1", "Choose a variable", choices = var_list, selected = "aval")
    })
    
    ## plot2
    output$plot2 = renderPlot({
        req(input$var1)
        
        if (input$var1 == "aval") {
            data_merged %>%
                ggplot(aes(x = aval)) + 
                geom_histogram(bindwidth = 1, color = "black") + 
                theme_pubr() +
                facet_grid(lbtestcd ~ .)
        }
        else if (input$var1 %notin% cont_vars) {
            var1 = as.symbol(input$var1)
            var1 = enquo(var1)
            #print(var1)
            data_merged %>%
                {if (input$show_color) ggplot(aes(x = !!var1, y = aval, fill = lbtestcd))} +
                {if (!input$show_color) ggplot(aes(x = !!var1, y = aval))} +
                {if (input$violin) geom_violin(width = .6, position = position_dodge())} +
                {if (input$box) geom_boxplot(width = .4, position = position_dodge(), alpha = .3)} +
                
                scale_fill_viridis_d(alpha = .3, option = "E") +
                theme_classic() +
                ggpubr::labs_pubr() +
                coord_flip() +
                labs(title = glue("Association of {input$var1} with Lab Measurments")) +
                facet_grid(~lbtestcd, scales = "fixed")
        }
        else {
            var1 = as.symbol(input$var1)
            var1 = enquo(var1)
            #print(var1)
            data_merged %>%
                ggplot(aes(x = aval, y = !!var1)) +
                geom_point() +
                # {if (input$box) geom_boxplot(width = .4, color = "black", position = position_dodge())} +
                # {if (input$violin) geom_violin(width = .6, position = position_dodge(), alpha = .4)} +
                scale_fill_viridis_d(alpha = .3, option = "E") +
                ggpubr::theme_pubr() +
                coord_flip() +
                labs(title = glue("Association of {input$var1} with Lab Measurments")) +
                facet_grid(~lbtestcd, scales = "fixed")
        }
        
        
        
    }, height = 570)
}
