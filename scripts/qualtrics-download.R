library(here)
library(qualtRics)
library(readr)

qualtrics_survey <- fetch_survey(surveyID = "SV_0vMjmokYyu4nt6m",
                                force_request = TRUE,
                                verbose = TRUE)

write_csv2(qualtrics_survey, file = here(paste0("data/", "ouders_", Sys.Date(), ".csv")))
