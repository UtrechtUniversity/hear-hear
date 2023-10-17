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

raw_data <- lapply(files, function(x) select(x, -one_of(drop_cols)))

# # RENAME BASED ON CONFIG FILE
# 
# # Read the CSV file into a data frame
# 
# column_mapping <- read_csv("config/column-mapping.csv")
# 
# # Create a mapping from new_names to old_names
# 
# # # column_mapping <- setNames(mapping_df$old_names, mapping_df$new_names)
# #
# # for (i in seq_along(raw_data)) {
# #   if (!is.null(column_mapping)) {
# #     col_names_to_rename <- intersect(names(raw_data[[i]]), column_mapping$old_name)
# #
# #     if (length(col_names_to_rename) > 0) {
# #       raw_data[[i]] <- raw_data[[i]] %>%
# #         rename(!!!setNames(column_mapping$new_name, column_mapping$old_name[col_names_to_rename]))
# #     }
# #   }
# # }


# EXPORT TO CSV

lapply(names(raw_data), function(x) {
  file_path <- here::here("data", paste0(x, "_preprocessed.csv"))
  write_csv(raw_data[[x]], file_path)
})
