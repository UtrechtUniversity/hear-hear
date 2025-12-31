# LOAD LIBRARIES ----

library(here)
library(haven)
library(dplyr)
library(tidyr)
library(tibble)
library(labelled)
library(sjlabelled)
library(stringr)
library(readr)
library(readxl)
library(purrr)

# READ DATA ----

## extract file metadata (paths & names)

file_list <- tibble(
  file_path = list.files(
    path = here("data/raw"),
    pattern = "\\.csv$",
    full.names = TRUE)) %>%
  mutate(file_name = str_extract(file_path, "(?<=_)[^\\.]+"))

## map() iterates read_csv() and returns a list of data frames
## set_names() assigns names to the data frames within the list

raw_data <- map(file_list$file_path, ~ read_csv(.x)) %>%
  set_names(file_list$file_name)

# UNLIST ----

## unlist jongeren data frame, since we're only processing that now
## unlisting won't be needed if the ouders data frame is processed similarly

jongeren_raw <- raw_data[["jongeren"]]

# DROP VARIABLES ----

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

jongeren_cleaned <- select(jongeren_raw, -any_of(drop_cols))

# MERGE VARIABLES ----

variable_merging <- read_csv("config/variable_merging.csv")

jongeren_merged <- reduce(
  seq_len(nrow(variable_merging)),
  ~ unite(
    .x,
    !!variable_merging$new[.y],
    !!parse_expr(variable_merging$from[.y]),
    sep = ",",
    remove = TRUE,
    na.rm = FALSE
  ),
  .init = jongeren_cleaned
)

# RENAME VARIABLES ----

variable_renaming <- read_excel("config/variable_renaming.xlsx")

jongeren_renamed <- jongeren_merged %>%
  rename(!!!setNames(
    variable_renaming$old_name,
    variable_renaming$new_name
  ))

# RECODE VARIABLES ----

jongeren_recoded <- jongeren_renamed

## recode within the same column

variable_recoding <- read_excel("config/variable_recoding.xlsx")

### cpm1yy28

jongeren_recoded <- mutate(
  jongeren_recoded,
  cpm1yy28 = case_match(
    cpm1yy28,
    "0 tot 5 minuten"   ~ "0",
    "5 tot 10 minuten"  ~ "5",
    "Weet ik niet meer" ~ "888",
    "10 tot 15 minuten" ~ "10",
    "15 tot 30 minuten" ~ "15",
    "30 tot 60 minuten" ~ "30",
    "Langer dan 1 uur" ~ "60"))

### kbh1yy01

jongeren_recoded <- mutate(
  jongeren_recoded,
  kbh1yy01 = case_match(
    kbh1yy01,
    "Nee" ~ "1",
    "Ja, ik word nu begeleid door een Kindbehartiger" ~ "2",
    "Ja, ik ga bijna starten met begeleiding door een Kindberhartiger" ~ "3",
    "Ja, maar de begeleiding is al klaar" ~ "4"))

### kbh1yy02a

jongeren_recoded <- mutate(
  jongeren_recoded,
  kbh1yy02a = case_match(
    kbh1yy02a,
    "Januari"   ~ "1",
    "Februari"  ~ "2",
    "Maart"     ~ "3",
    "April"     ~ "4",
    "Mei"       ~ "5",
    "Juni"      ~ "6",
    "Juli"      ~ "7",
    "Augustus"  ~ "8",
    "September" ~ "9",
    "Oktober"   ~ "10",
    "November"  ~ "11",
    "December"  ~ "12"))

### cpc1yy30

jongeren_recoded <- mutate(
  jongeren_recoded,
  cpc1yy30 = case_match(
    cpc1yy30,
    "0 tot 5 minuten"   ~ "0",
    "5 tot 10 minuten"  ~ "5",
    "weet ik niet meer" ~ "888",
    "10 tot 15 minuten" ~ "10",
    "15 tot 30 minuten" ~ "15",
    "Langer dan 30 minuten" ~ "30"))

### wel1yy02

jongeren_recoded <- mutate(jongeren_recoded, wel1yy02 = if_else(wel1yy02 == 0, 999, wel1yy02))

### wel1yy03

jongeren_recoded <- mutate(jongeren_recoded, wel1yy03 = if_else(wel1yy03 == 0, 999, wel1yy03))

### wel1yy04

jongeren_recoded <- mutate(jongeren_recoded, wel1yy04 = if_else(wel1yy04 == 0, 999, wel1yy04))

### wel1yy05

jongeren_recoded <- mutate(jongeren_recoded, wel1yy05 = if_else(wel1yy05 == 0, 999, wel1yy05))

### kkp1yy01

jongeren_recoded <- mutate(
  jongeren_recoded,
  kkp1yy01 = case_match(
    kkp1yy01,
    "Ja"   ~ "1",
    "Nee"  ~ "0"))

### kkp1yy02

jongeren_recoded <- mutate(
  jongeren_recoded,
  kkp1yy02 = case_match(
    kkp1yy02,
    "Helemaal niet waar" ~ "1",
    "Niet waar" ~ "2",
    "Neutraal" ~ "3",
    "Waar" ~ "4",
    "Helemaal waar" ~ "5"))

## recode into new columns, involves reversing values

variable_reversing <- read_excel("config/variable_reversing.xlsx")

# cpc1yy06

jongeren_recoded <- mutate(
  jongeren_recoded,
  cpc1yy06_r = case_match(
    cpc1yy06,
    "Helemaal niet waar" ~ "5",
    "Niet" ~ "4",
    "Eeen beetje" ~ "3",
    "Wel" ~ "2",
    "Helemaal wel" ~ "1"))

# cpc1yy20

jongeren_recoded <- mutate(
  jongeren_recoded,
  cpc1yy20_r = case_match(
    cpc1yy20,
    "Helemaal niet waar" ~ "5",
    "Niet" ~ "4",
    "Eeen beetje" ~ "3",
    "Wel" ~ "2",
    "Helemaal wel" ~ "1"))

# cpc1yy22

jongeren_recoded <- mutate(
  jongeren_recoded,
  cpc1yy22_r = case_match(
    cpc1yy22,
    "Helemaal niet waar" ~ "5",
    "Niet" ~ "4",
    "Eeen beetje" ~ "3",
    "Wel" ~ "2",
    "Helemaal wel" ~ "1"))

# cpc1yy23

jongeren_recoded <- mutate(
  jongeren_recoded,
  cpc1yy23_r = case_match(
    cpc1yy23,
    "Helemaal niet waar" ~ "5",
    "Niet" ~ "4",
    "Eeen beetje" ~ "3",
    "Wel" ~ "2",
    "Helemaal wel" ~ "1"))

# cpc1yy27

jongeren_recoded <- mutate(
  jongeren_recoded,
  cpc1yy27_r = case_match(
    cpc1yy27,
    "Helemaal niet waar" ~ "5",
    "Niet" ~ "4",
    "Eeen beetje" ~ "3",
    "Wel" ~ "2",
    "Helemaal wel" ~ "1"))

# cpc1yy28

jongeren_recoded <- mutate(
  jongeren_recoded,
  cpc1yy28_r = case_match(
    cpc1yy28,
    "Helemaal niet waar" ~ "5",
    "Niet" ~ "4",
    "Eeen beetje" ~ "3",
    "Wel" ~ "2",
    "Helemaal wel" ~ "1"))

# sbl1yy05

jongeren_recoded <- mutate(
  jongeren_recoded,
  sbl1yy05_r = case_match(
    sbl1yy05,
    "Helemaal niet waar" ~ "5",
    "Niet" ~ "4",
    "Eeen beetje" ~ "3",
    "Wel" ~ "2",
    "Helemaal wel" ~ "1"))

# ipc1yy13

jongeren_recoded <- mutate(
  jongeren_recoded,
  ipc1yy13_r = case_match(
    ipc1yy13,
    "Helemaal niet waar" ~ "5",
    "Niet" ~ "4",
    "Eeen beetje" ~ "3",
    "Wel" ~ "2",
    "Helemaal wel" ~ "1"))

# ipc1yy14

jongeren_recoded <- mutate(
  jongeren_recoded,
  ipc1yy14_r = case_match(
    ipc1yy14,
    "Helemaal niet waar" ~ "5",
    "Niet" ~ "4",
    "Eeen beetje" ~ "3",
    "Wel" ~ "2",
    "Helemaal wel" ~ "1"))

# ipc1yy15

jongeren_recoded <- mutate(
  jongeren_recoded,
  ipc1yy15_r = case_match(
    ipc1yy15,
    "Helemaal niet waar" ~ "5",
    "Niet" ~ "4",
    "Eeen beetje" ~ "3",
    "Wel" ~ "2",
    "Helemaal wel" ~ "1"))

# wel1yy05

jongeren_recoded <- mutate(
  jongeren_recoded,
  wel1yy05_r = case_match(
    wel1yy05,
    999 ~ 999,
    1 ~ 5,
    2 ~ 4,
    3 ~ 3,
    4 ~ 2,
    5 ~ 1))

# COMPUTE VARIABLES ----

## to be incorporated, see playground-v2.R for test code

# LABEL VARIABLES ----

jongeren_labelled <- jongeren_recoded

## set variable labels

variable_labelling <- read_excel("config/variable_labelling.xlsx")

labels <- deframe(variable_labelling)

jongeren_labelled <- set_variable_labels(jongeren_labelled, !!!labels)

## set value labels

### kbh1yy02a

jongeren_labelled <- mutate(jongeren_labelled, kbh1yy02a = as.numeric(kbh1yy02a))

jongeren_labelled <- set_labels(jongeren_labelled, kbh1yy02a, 
                                     labels = c("Januari" = 1, 
                                                "Februari" = 2, 
                                                "Maart" = 3, 
                                                "April" = 4, 
                                                "Mei" = 5,
                                                "Juni" = 6,
                                                "Juli" = 7,
                                                "Augustus" = 8,
                                                "September" = 9,
                                                "Oktober" = 10,
                                                "November" = 11,
                                                "December" = 12)) 

### wel1yy01

jongeren_labelled <- set_labels(jongeren_labelled, wel1yy01, 
                                     labels = c("slecht" = 1, 
                                                "2" = 2, 
                                                "3" = 3, 
                                                "4" = 4, 
                                                "5" = 5,
                                                "6" = 6,
                                                "7" = 7,
                                                "8" = 8,
                                                "9" = 9,
                                                "goed" = 10)) 

### wel1yy02

jongeren_labelled <- set_labels(jongeren_labelled, wel1yy02, 
                                     labels = c("missing" = 999, 
                                                "een niet heel erg gelukkig mens" = 1, 
                                                "2" = 2, 
                                                "3" = 3, 
                                                "4" = 4,
                                                "een heel erg gelukkig mens" = 5)) # works
### wel1yy03

jongeren_labelled <- set_labels(jongeren_labelled, wel1yy03, 
                                     labels = c("missing" = 999, 
                                                "minder gelukkig" = 1, 
                                                "2" = 2, 
                                                "3" = 3, 
                                                "4" = 4,
                                                "meer gelukkig" = 5)) 

### wel1yy04

jongeren_labelled <- set_labels(jongeren_labelled, wel1yy04, 
                                     labels = c("missing" = 999, 
                                                "helemaal niet" = 1, 
                                                "2" = 2, 
                                                "3" = 3, 
                                                "4" = 4,
                                                "heel erg" = 5)) 
### wel1yy05

jongeren_labelled <- set_labels(jongeren_labelled, wel1yy05, 
                                     labels = c("missing" = 999, 
                                                "helemaal niet" = 1, 
                                                "2" = 2, 
                                                "3" = 3, 
                                                "4" = 4,
                                                "heel erg" = 5)) 

# WRITE DATA ----

## sav

write_sav(jongeren_labelled, "data/processed/jongeren.sav")

## csv

write_csv(jongeren_labelled, "data/processed/jongeren.csv")

# END SCRIPT ----