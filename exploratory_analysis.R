

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


p1 = data_merged %>% filter(usubjid == "AB12345-CHN-11-id-172") %>% select(avisit, lbtestcd, aval)
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


theme_discrete_chart <- function(...) {
  t <- theme_minimal(...) +
    theme(
      panel.grid.minor.y = element_blank(),
      panel.grid.minor.x = element_blank(),
      panel.grid.major.x = element_blank(),
      panel.grid.major.y = element_line(),
      strip.background = element_rect(fill = "gray", color = "gray"),
      strip.text = element_text(margin = margin(1, 0, 1, 0, "mm"))
    ) +
    easy_legend_at("bottom") +
    labs_pubr()
}


ggstatsplot::ggbetweenstats(data = data_merged %>% filter(lbtestcd == "ALT"),
                            x = race,
                            y = aval,
                            plot.type = "box",
                            bf.message = F,
                            results.subtitle = F,
                            ggtheme = hrbrthemes::theme_ipsum_tw(),
                            ggstatsplot.layer = F)
