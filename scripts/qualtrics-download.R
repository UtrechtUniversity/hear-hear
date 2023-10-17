library(here)      # CRAN v1.0.1
library(qualtRics) # CRAN v3.1.7
library(readr)     # CRAN v2.1.4
library(purrr)     # CRAN v1.0.1

#qualtrics_survey <- fetch_survey(surveyID = "SV_0vMjmokYyu4nt6m",
#                                force_request = TRUE,
#                                verbose = TRUE)

# write_csv2(qualtrics_survey, file = here(paste0("data/", "ouders_", Sys.Date(), ".csv")))

#--------
  
survey_ids <- read_csv("config/survey-ids.csv") 
              
surveys <- lapply(survey_ids$survey_id, function(x) fetch_survey(x, force_request = TRUE, verbose = TRUE)) %>% 
  
  setNames(., survey_ids$survey_abbreviation)

lapply(1:length(surveys), function(x) write_csv(surveys[[x]], 
                                                file = here(paste0("data/", Sys.Date(), "_", names(surveys[x]), ".csv"))))

