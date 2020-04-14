
library(tidyverse)

## reading the data
data_patient = read_tsv("./Random_PatientLevelInfo_2020.tsv")
data_lab_vals = read_tsv("./Random_LabValuesInfo_2020.tsv")

## list of patients
patient_list = unique(data_patient$USUBJID)