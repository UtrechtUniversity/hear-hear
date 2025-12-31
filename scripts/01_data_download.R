# LOAD PACKAGES ----

library(here)
library(readr)
library(purrr)
library(qualtRics)
library(haven)

# FETCH DATA ----

## import survey metadata (ids & abbreviations)

survey_metadata <- read_csv("config/survey_metadata.csv", col_names = TRUE)

## fetch data from qualtrics

### map() iterates fetch_survey() and returns a list of data frames
### set_names() assigns names to the data frames within the list

surveys <- map(survey_metadata$survey_id, 
               ~ fetch_survey(.x,
                              label = TRUE,
                              convert = TRUE, 
                              add_var_labels = TRUE,
                              verbose = TRUE,
                              force_request = TRUE)) %>% 
  set_names(survey_metadata$survey_abbreviation)

# WRITE DATA ----

## csv

walk(names(surveys), ~ {
  write_csv(
    surveys[[.x]],
    here("data/raw", paste0(Sys.Date(), "_", .x, ".csv"))
  )
})

# END SCRIPT ----