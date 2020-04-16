

## installing pacman
if (!require("pacman")) install.packages("pacman")

## required libraries
# req_libs = c("tidyverse", "gt", "janitor", "glue", "patchwork",
#              "ggeasy", "shinyjs", "ggthemes")
pacman::p_load(shiny, shinydashboard, tidyverse, gt, janitor,
               glue, patchwork, ggeasy, shinyjs, ggthemes, ggstatsplot, ggpubr)

## reading the data
data_patient = read_tsv("./Random_PatientLevelInfo_2020.tsv")
data_lab_vals = read_tsv("./Random_LabValuesInfo_2020.tsv")

## fixing column names
data_patient = data_patient %>% clean_names()
data_lab_vals = data_lab_vals %>% clean_names()

## joining them
data_merged = right_join(data_patient, data_lab_vals, by = c("usubjid", "studyid"))

## list of patients
patient_list = unique(data_patient$usubjid)

## list of tests
test_list = unique(data_lab_vals$lbtestcd)

## function to make plot2
make_plot1b = function(df, df2, test) {
  df %>%
    filter(lbtestcd == test) %>% 
    ggplot(aes(x = avisit, y = aval, group = 1)) +
    geom_path(color = "#1F77B4", size = .75) +
    geom_point(size = 4, color = "#1F77B4") +
    scale_x_discrete(limits = df2$avisit) +
    xlab("Visit") +
    ylab(glue("Measurment ({df$avalu[df$lbtestcd == test][1]})")) +
    ylim(0, 80) +
    labs(title = glue("{test} Lab Measurments for the patient across visits")) +
    theme_discrete_chart()
}

## list of variables for analysis
var_list = c("bmrkr1", "bmrkr2", "age", "sex", "race", "actarm", "aval")

## continuous variables
cont_vars = c("age", "bmrkr1")

`%notin%` = Negate(`%in%`)


