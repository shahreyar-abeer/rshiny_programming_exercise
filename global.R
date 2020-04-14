

## required libraries
library(tidyverse)
library(ggcharts)
library(gt)
library(glue)

## reading the data
data_patient = read_tsv("./Random_PatientLevelInfo_2020.tsv")
data_lab_vals = read_tsv("./Random_LabValuesInfo_2020.tsv")

## joining them
data_merged = right_join(data_patient, data_lab_vals, by = c("USUBJID", "STUDYID"))

## list of patients
patient_list = unique(data_patient$USUBJID)

## list of tests
test_list = unique(data_lab_vals$LBTESTCD)


