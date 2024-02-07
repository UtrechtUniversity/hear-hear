library(haven)
library(dplyr)
library(readr)
library(sjlabelled)

raw_data <- read_sav("playground/Jongerenvragenlijst_-_meetronde_1_October_4_2023_PRE-CLEANING.sav")
processed_data <- read_sav("playground/Jongerenvragenlijst_-_meetronde_1_October_4_2023_POST-CLEANING.sav")

csv_data <- read_csv("playground/2023-10-04_jongeren.csv")

# * Encoding: UTF-8.
# *Data cleaning examples of dropping, renaming, recoding, and computing variables
# *Dataset = Qualtrics export of Jongerenvragenlijst meetronde #1_October 4 2023
# 
# 
# *DROPPING VARIABLES
# 
# DELETE VARIABLES StartDate EndDate Status IPAddress Progress Finished RecipientLastName RecipientFirstName RecipientEmail ExternalReference LocationLatitude LocationLongitude DistributionChannel UserLanguage.
# EXECUTE.

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

# FOR MULTIPLE DATAFRAMES: raw_files <- lapply(raw_files, function(x) select(x, -one_of(drop_cols)))

raw_data <- select(raw_data, !one_of(drop_cols))
csv_data <- select(csv_data, !one_of(drop_cols))

# *RENAMING VARIABLES
# *Background variables
# 
# RENAME VARIABLES (A1 A1_4_TEXT A2a A2b A3 A3_4_TEXT A4a A5a A5a_8_TEXT A4b A5b A4c = Gender Gender_x Geboortemaand Geboortejaar Onderwijstype Onderwijstype_x POgroep VOniveau VOniveau_x VOjaar TOniveau TOjaar).
# EXECUTE.

raw_data <- rename(raw_data, 
                   "Gender" = "A1",
                   "Gender_x" = "A1_4_TEXT",
                   "Geboortemaand" = "A2a",
                   "Geboortejaar" = "A2b",
                   "Onderwijstype" = "A3",
                   "Onderwijstype_x" = "A3_4_TEXT",
                   "POgroep" = "A4a",
                   "VOniveau" = "A5a",
                   "VOniveau_x" = "A5a_8_TEXT",
                   "VOjaar" = "A4b",
                   "TOniveau" = "A5b",
                   "TOjaar" = "A4c")

# *Instrument Veranderingen Na Scheiding = VnS
# 
# RENAME VARIABLES (B2_B4_1 TO B5_B12_8 = VnS_1 TO VnS_11).
# EXECUTE.
# 
# column_mapping <- c(
#   "B2_B4_1" = "VnS_1",
#   "B2_B4_2" = "VnS_2",
#   "B2_B4_3" = "VnS_3",
#   "B5_B12_1" = "VnS_4",
#   "B5_B12_2" = "VnS_5",
#   "B5_B12_3" = "VnS_6",
#   "B5_B12_4" = "VnS_7",
#   "B5_B12_5" = "VnS_8",
#   "B5_B12_6" = "VnS_9",
#   "B5_B12_7" = "VnS_10",
#   "B5_B12_8" = "VnS_11"
# )

# column_mapping <- c(
#   "VnS_1" = "B2_B4_1",
#   "VnS_2" = "B2_B4_2",
#   "VnS_3" = "B2_B4_3",
#   "VnS_4" = "B5_B12_1",
#   "VnS_5" = "B5_B12_2",
#   "VnS_6" = "B5_B12_3",
#   "VnS_7" = "B5_B12_4",
#   "VnS_8" = "B5_B12_5",
#   "VnS_9" = "B5_B12_6",
#   "VnS_10" = "B5_B12_7",
#   "VnS_11" = "B5_B12_8"
# )

# 
# *Instrument Behaviour and Feelings Scale = BFS
# 
# RENAME VARIABLES (R1_R6_1 TO R7_R12_6 = BFS_1 TO BFS_12).
# EXECUTE.
# 
# column_mapping <- c(
#   "R1_R6_1" = "BFS_1",
#   "R1_R6_2" = "BFS_2",
#   "R1_R6_3" = "BFS_3",
#   "R1_R6_4" = "BFS_4",
#   "R1_R6_5" = "BFS_5",
#   "R1_R6_6" = "BFS_6",
#   "R7_R12_1" = "BFS_7",
#   "R7_R12_2" = "BFS_8",
#   "R7_R12_3" = "BFS_9",
#   "R7_R12_4" = "BFS_10",
#   "R7_R12_5" = "BFS_11",
#   "R7_R12_6" = "BFS_12"
# )
# 
# column_mapping <- c(
#   "BFS_1" = "R1_R6_1",
#   "BFS_2" = "R1_R6_2",
#   "BFS_3" = "R1_R6_3",
#   "BFS_4" = "R1_R6_4",
#   "BFS_5" = "R1_R6_5",
#   "BFS_6" = "R1_R6_6",
#   "BFS_7" = "R7_R12_1",
#   "BFS_8" = "R7_R12_2",
#   "BFS_9" = "R7_R12_3",
#   "BFS_10" = "R7_R12_4",
#   "BFS_11" = "R7_R12_5",
#   "BFS_12" = "R7_R12_6"
# )

# RENAME BASED ON CONFIG FILE 

# Read the CSV file into a data frame
mapping_df <- read_csv("config/column-mapping.csv")

# mapping_df <- mapping_df[-c(13:4), ]

# Create a mapping from new_names to old_names
column_mapping <- setNames(mapping_df$old_name, mapping_df$new_name)

raw_data <- rename(raw_data, !!!column_mapping)

csv_data <- rename(csv_data, !!!column_mapping) #works

# files_baseline <- lapply(files_baseline, function(x) rename(x, newnames = oldnames)

# VARIABLE LABELS Gender (Hoe identificeer jij je?).
# EXECUTE.

sjlabelled::set_label(csv_data$Gender) <- "Hoe identificeer jij je?"
# haven::attr(csv_data$Gender, "label") <- "Hoe identificeer jij je?"

# *RECODING VARIABLES
# 
# RECODE Geboortejaar (4=2004) (5=2005) (6=2006) (7=2007) (8=2008) (9=2009) (10=2010) (11=2011) 
# (12=2012) (13=2013) (14=2014) (15=2015) (16=2016).
# EXECUTE.

# raw_data <- mutate(raw_data, Geboortejaar = recode(Geboortejaar, `4` = 2004, `5` = 2005, `6` = 2006, `7` = 2007, `8` = 2008))
csv_data <- mutate(csv_data, Geboortejaar = recode(Geboortejaar, `4` = 2004, `5` = 2005, `6` = 2006, `7` = 2007, `8` = 2008))

# VALUE LABELS Geboortejaar (null).
# ADD VALUE LABELS Geboortejaar 2004'2004'  2005'2005' 2006'2006' 2007'2007' 2008'2008' 2009'2009' 2010'2010' 2011'2011' 2012'2012' 2013'2013' 2014'2014' 2015'2015' 2016'2016'.



# RECODE BFS_1 TO BFS_12 (0=1) (1=2) (2=3) (3=4) (4=5).
# EXECUTE.

csv_data <- mutate(csv_data, Geboortejaar = recode(Geboortejaar, `4` = 2004, `5` = 2005, `6` = 2006, `7` = 2007, `8` = 2008))

# VALUE LABELS BFS_1 to BFS_12 (null).
# EXECUTE.
# ADD VALUE LABELS BFS_1 to BFS_12  1'Niet' 2'Zelden' 3'Soms' 4'Vaak' 5'Altijd'.
# EXECUTE.
# 
# *COMPUTING VARIABLES
# *AGE IN TWO STEPS
# *STEP 1. COMPUTE GEBOORTEDATUM
# 
# COMPUTE Geboortedatum=DATE.MOYR(Geboortemaand,Geboortejaar).
# EXECUTE.
# 
# *STEP 2. COMPUTE AGE BASED ON GEBOORTEDATUM & RECORDED DATE
# 
# COMPUTE  Leeftijd=(RecordedDate - Geboortedatum) / (365.25 * time.days(1)).
# VARIABLE LABELS  Leeftijd "Retain fractional parts".
# VARIABLE LEVEL  Leeftijd (SCALE).
# FORMATS  Leeftijd (F8.2).
# VARIABLE WIDTH  Leeftijd(8).
# EXECUTE.
# 
# *SIMPLE SUMSCORE NUMBER OF CHANGES FOLLOWING PARENTAL DIVORCE
# 
# COMPUTE VnS_Sum=SUM(VnS_1,VnS_2,VnS_3,VnS_4,VnS_5,VnS_6,VnS_7,VnS_8,VnS_9,VnS_10,VnS_11).
# EXECUTE.
# 
# *SIMPLE MEAN SCORE BASED ON BFS ITEMS
# 
# COMPUTE BFS_Mean=MEAN(BFS_1,BFS_2,BFS_3,BFS_4,BFS_5,BFS_6,BFS_7,BFS_8,BFS_9,BFS_10,BFS_11,BFS_12).
# EXECUTE.
