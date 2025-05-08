# LOAD LIBRARIES

library(here)      # CRAN v1.0.1
library(qualtRics) # CRAN v3.1.7
library(readr)     # CRAN v2.1.4
library(purrr)     # CRAN v1.0.1
library(dplyr)
library(stringr)
library(readr)
library(readxl)

# DOWNLOAD DATA

survey_ids <- read_csv("config/survey-ids.csv") 

surveys <- lapply(survey_ids$survey_id, function(x) fetch_survey(x, force_request = TRUE, verbose = TRUE)) %>% 
  
  setNames(., survey_ids$survey_abbreviation)

lapply(1:length(surveys), function(x) write_csv(surveys[[x]], 
                                                file = here(paste0("playground/", Sys.Date(), "_", names(surveys[x]), ".csv"))))

# IMPORT DATA

filelist <- data.frame(V1 = list.files(path = here("playground/"), pattern ='*.csv', full.names = TRUE)) %>% 
  
  mutate(., 
         filename = str_extract(V1, '(?<=playground/)[^\\.]+'))

# Import the files specified in the V1 column into a list object called files.
# Set the names of the files based on the filename column.

files <- lapply(filelist$V1, function(x) read_csv(x)) %>% 
  
  setNames(., filelist$filename)

# UNLIST FOR PLAYGROUND

list2env(files, .GlobalEnv)

# DROP VARIABLES

drop_cols <- c("StartDate", 
               "Status",
               "IPAddress", 
               "Progress",
               "Duration (in seconds)",
               "Finished",
               "RecordedDate",
               "ResponseId",
               "RecipientLastName",
               "RecipientFirstName",
               "RecipientEmail", 
               "LocationLatitude",
               "LocationLongitude",
               "DistributionChannel", 
               "UserLanguage",
               "J_gegevens_1",
               "J_gegevens_2",
               "Intro: liever lezen")

jongeren <- select(`2025-05-08_jongeren`, -one_of(drop_cols))

# RENAME VARIABLES

mapping_df <- read_excel("config/variable-renaming.xlsx")

# Create a mapping from new_names to old_names
column_mapping <- setNames(mapping_df$old_name, mapping_df$new_name)

jongeren_renamed <- rename(jongeren, !!!column_mapping)

# Rename per dataset 
# raw_data <- rename(raw_data, !!!column_mapping)
# csv_data <- rename(csv_data, !!!column_mapping) #works

# Rename within list
# preprocessed_data <- lapply(preprocessed_data, function(x) rename(x, !!!column_mapping))

# RELABEL VARIABLES

# RECODE VARIABLES

# MISSINGS



# COMPUTATIONS
