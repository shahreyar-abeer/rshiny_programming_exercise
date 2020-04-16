

## installing pacman if not already there
if (!require("pacman")) install.packages("pacman")

## required libraries, pacman takes care of the installation
pacman::p_load(shiny, shinydashboard, tidyverse, gt, janitor,
               glue, patchwork, ggeasy, shinyjs, ggpubr, shinycssloaders)

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

## theme for plots, tab1
theme1 <- function(...) {
  t <- theme_minimal(...) +
    theme(
      panel.grid.minor.y = element_blank(),
      panel.grid.minor.x = element_blank(),
      strip.background = element_rect(fill = "gray", color = "gray"),
      strip.text = element_text(margin = margin(1, 0, 1, 0, "mm"))
    ) +
    easy_legend_at("bottom") +
    labs_pubr()
}

## theme for plot, tab2
theme2 <- function(...) {
  t <- theme_bw(...) +
    theme(
      panel.grid.minor.y = element_blank(),
      panel.grid.minor.x = element_blank(),
      strip.background = element_rect(fill = "gray", color = "gray"),
      strip.text = element_text(margin = margin(1, 0, 1, 0, "mm"))
    ) +
    labs_pubr() +
    easy_legend_at("bottom")
}

## function to make plot2
make_plot1b = function(df, df2, test) {
  df %>%
    filter(lbtestcd == test) %>% 
    ggplot(aes(x = avisit, y = aval, group = 1)) +
    geom_path(color = "#1F77B4", size = .75) +
    geom_point(size = 4, color = "#1F77B4") +
    scale_x_discrete(limits = df2$avisit) +
    xlab("Visit") +
    ylab(glue("Value ({df$avalu[df$lbtestcd == test][1]})")) +
    ylim(0, 80) +
    labs(title = glue("{test} Lab Measurments for the patient across visits")) +
    theme1()
}

## list of variables for analysis
var_list = c("Biomarker 1 (cont.)" = "bmrkr1", "Biomarker 2 (disc.)" = "bmrkr2",
             "Age (cont.)" = "age", "Sex (disc.)" = "sex", "Race (disc.)" = "race",
             "Actarm (disc.)" = "actarm", "Test Values (var of interest)" = "aval")

## continuous variables
cont_vars = c("age", "bmrkr1")

## Function to work as not in
`%notin%` = Negate(`%in%`)


