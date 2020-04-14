


server = function(input, output) {
    
    ## list of patients as a select input
    output$inp_patient = renderUI({
        selectizeInput("patient", label = "Patient", choices = patient_list)
    })
}
