

library(tidyverse)

## reading the data set and getting a feel of the data
data_patient = read_tsv("./Random_PatientLevelInfo_2020.tsv")
str(data_patient)
head(data_patient)

data_lab_vals = read_tsv("./Random_LabValuesInfo_2020.tsv")
str(data_lab_vals)
head(data_lab_vals)

## checking if the 2 datasets have the same number of unique subjects.
length(unique(data_patient$USUBJID))
length(unique(data_lab_vals$USUBJID))

452 * 7 * 3  # no of rows match

## understanding the data by taking a single patient
single_patient = unique(data_lab_vals$USUBJID)[1]
data_lab_vals %>% filter(USUBJID == single_patient) %>% View()

data_lab_vals %>% View()

## joining
data_merged = right_join(data_patient, data_lab_vals, by = c("USUBJID", "STUDYID"))
unique(data_merged$ACTARM)
unique(data_merged$RACE)


##------------------------------------------------------------------------------
## note to self
# analyse patient by patient


data_merged %>%
  filter(USUBJID == input$patient, LBTESTCD == input$test) %>%
  lollipop_chart(x = AVISIT, y = AVAL, horizontal = F, sort = F, point_color = "red") +
  geom_hline(yintercept = input$threshold, color = "red", linetype = "longdash") +
  gghighlight::gghighlight(AVAL > input$threshold,
                           unhighlighted_params = aes(colour = "#1F77B4"),
                           use_direct_label = F) +
  geom_label(aes(label = round(AVAL, 1)), alpha = .1, vjust = -.2, hjust = .2)


p1 = data_merged %>% filter(USUBJID == "AB12345-CHN-11-id-172", LBTESTCD == "CRP") %>% select(AVISIT, AVAL)
t(p1)[2:3,]

p1 %>%
  gather() %>%
  spread(value = value)

d1() %>% 
  lollipop_chart(x = AVISIT, y = AVAL, horizontal = F, sort = F, point_color = "red") +
  geom_hline(yintercept = input$threshold, color = "red", linetype = "longdash") +
  gghighlight::gghighlight(AVAL > input$threshold,
                           unhighlighted_params = aes(colour = "#1F77B4"),
                           use_direct_label = F) +
  scale_x_discrete(limits = d1()$AVISIT) +
  labs(title = glue("{input$test} test scores for the patient"),
       subtitle = "The red line indicates threshold value. Values above this line is deemed 'not-normal' by epidemiologists")
