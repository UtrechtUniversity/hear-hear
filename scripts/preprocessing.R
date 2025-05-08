# LOAD LIBRARIES

library(here)   
library(dplyr)
library(stringr)
library(readr)

# IMPORT DATA

filelist <- data.frame(V1 = list.files(path = here("data"), pattern ='*.csv', full.names = TRUE)) %>% 
  
  mutate(., 
         filename = str_extract(V1, '(?<=data/)[^\\.]+'))

# Import the files specified in the V1 column into a list object called files.
# Set the names of the files based on the filename column.

files <- lapply(filelist$V1, function(x) read_csv(x)) %>% 
  
  setNames(., filelist$filename)

# DROP COLUMNS

drop_cols <- c("StartDate", 
               "EndDate", 
               "Status",
               "IPAddress", 
               "Progress",
               "Finished",
               "RecipientLastName",
               "RecipientFirstName",
               "RecipientEmail", 
               "ExternalReference",
               "LocationLatitude",
               "LocationLongitude",
               "DistributionChannel", 
               "UserLanguage")

preprocessed_data <- lapply(files, function(x) select(x, -one_of(drop_cols)))


dummy_ic <- select(csv_data, c(`Duration (in seconds)`, `RecordedDate`, `ResponseId`))

# RENAME BASED ON CONFIG FILE

# Read the CSV file into a data frame
# mapping_df <- read_csv("config/column-mapping.csv")
 
# Create a mapping from new_names to old_names
# column_mapping <- setNames(mapping_df$old_name, mapping_df$new_name)

# Rename per dataset 
# raw_data <- rename(raw_data, !!!column_mapping)
# csv_data <- rename(csv_data, !!!column_mapping) #works

# Rename within list
# preprocessed_data <- lapply(preprocessed_data, function(x) rename(x, !!!column_mapping))

# EXPORT TO CSV

lapply(names(raw_data), function(x) {
  file_path <- here::here("data", paste0(x, "_preprocessed.csv"))
  write_csv(raw_data[[x]], file_path)
})
