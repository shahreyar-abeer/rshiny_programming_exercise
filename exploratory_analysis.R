

library(tidyverse)

## reading the data set and getting a feel of the data
patient = read_tsv("./Random_PatientLevelInfo_2020.tsv")
str(patient)
head(patient)

lab_values = read_tsv("./Random_LabValuesInfo_2020.tsv")
str(lab_values)
head(lab_values)

## checking if the 2 datasets have the same number of unique subjects.
length(unique(patient$USUBJID))
length(unique(lab_values$USUBJID))

452 * 7 * 3  # no of rows match

## understanding the data by taking a single patient
single_patient = unique(lab_values$USUBJID)[1]
lab_values %>% filter(USUBJID == single_patient) %>% View()


