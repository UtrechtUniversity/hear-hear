# LOAD LIBRARIES

library(here)      # CRAN v1.0.1
library(qualtRics) # CRAN v3.1.7
library(readr)     # CRAN v2.1.4
library(purrr)     # CRAN v1.0.1
library(dplyr)
library(stringr)
library(readr)
library(readxl)
library(tidyr)
library(labelled)
library(sjlabelled)
library(tibble)

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

jongeren <- select(`2025-12-18_jongeren`, -one_of(drop_cols))

# MERGE COLUMNS

variable_merging <- read_csv("config/variable_merging.csv")

jongeren_merged_new <- reduce(
  seq_len(nrow(variable_merging)),
  ~ unite(
    .x,
    !!variable_merging$new[.y],
    !!parse_expr(variable_merging$from[.y]),
    sep = ",",
    remove = TRUE,
    na.rm = FALSE
  ),
  .init = jongeren
)


jongeren_merged <- jongeren %>%
                    unite(A6, A6_1:A6_0, sep = ",", remove = TRUE, na.rm = FALSE) %>%
                    unite(E5, E5_1:E5_888, sep = ",", remove = TRUE, na.rm = FALSE) %>%
                    unite(E6, E6_1:E6_4, sep = ",", remove = TRUE, na.rm = FALSE) %>%
                    unite(E10, E10_1:E10_5, sep = ",", remove = TRUE, na.rm = FALSE) %>%
                    unite(E11, E11_1:E11_7, sep = ",", remove = TRUE, na.rm = FALSE) %>%
                    unite(E28, E28_1:E28_6, sep = ",", remove = TRUE, na.rm = FALSE) %>%
                    unite(E29, E29_1:E29_5, sep = ",", remove = TRUE, na.rm = FALSE) %>%
                    unite(E30, E30_1:E30_7, sep = ",", remove = TRUE, na.rm = FALSE) %>%
                    unite(D6, D6_0:D6_5, sep = ",", remove = TRUE, na.rm = FALSE) %>%
                    unite(D7, D7_1:D7_4, sep = ",", remove = TRUE, na.rm = FALSE) %>%
                    unite(D10, D10_1:D10_5, sep = ",", remove = TRUE, na.rm = FALSE) %>%
                    unite(D18, D18_1:D18_5, sep = ",", remove = TRUE, na.rm = FALSE) %>%
                    unite(D21, D21_1:D21_4, sep = ",", remove = TRUE, na.rm = FALSE) %>%
                    unite(U2, U2_1:U2_7, sep = ",", remove = TRUE, na.rm = FALSE)

# RENAME VARIABLES

mapping_df <- read_excel("config/variable-renaming.xlsx")

# Create a mapping from new_names to old_names

column_mapping <- setNames(mapping_df$old_name, mapping_df$new_name)

jongeren_renamed <- rename(jongeren_merged, !!!column_mapping)

# RELABEL VARIABLES

jongeren_relabelled <- jongeren_renamed

variable_labels <- read_excel("config/variable-labelling.xlsx")

labels <- deframe(variable_labels)

jongeren_relabelled <- set_variable_labels(jongeren_relabelled, !!!labels)

# RECODE VARIABLES 1

# NOTE: do recoding before relabelling!

recoding_mapping <- read_excel("config/variable-recoding.xlsx")

recoding_test_df <- select(jongeren_relabelled, recoding_mapping$new_name)

#1

recoding_test_df <- mutate(
  jongeren_relabelled,
  cpm1yy28 = case_match(
    cpm1yy28,
    "0 tot 5 minuten"   ~ "0",
    "5 tot 10 minuten"  ~ "5",
    "Weet ik niet meer" ~ "888",
    "10 tot 15 minuten" ~ "10",
    "15 tot 30 minuten" ~ "15",
    "30 tot 60 minuten" ~ "30",
    "Langer dan 1 uur" ~ "60"))

#2

recoding_test_df <- mutate(
  recoding_test_df,
  kbh1yy01 = case_match(
    kbh1yy01,
    "Nee" ~ "1",
    "Ja, ik word nu begeleid door een Kindbehartiger" ~ "2",
    "Ja, ik ga bijna starten met begeleiding door een Kindberhartiger" ~ "3",
    "Ja, maar de begeleiding is al klaar" ~ "4"))

#3

recoding_test_df <- mutate(
  recoding_test_df,
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

#4

recoding_test_df <- mutate(
  recoding_test_df,
  cpc1yy30 = case_match(
    cpc1yy30,
    "0 tot 5 minuten"   ~ "0",
    "5 tot 10 minuten"  ~ "5",
    "weet ik niet meer" ~ "888",
    "10 tot 15 minuten" ~ "10",
    "15 tot 30 minuten" ~ "15",
    "Langer dan 30 minuten" ~ "30"))

#5

recoding_test_df <- mutate(recoding_test_df, wel1yy02 = if_else(wel1yy02 == 0, 999, wel1yy02))

#6

recoding_test_df <- mutate(recoding_test_df, wel1yy03 = if_else(wel1yy03 == 0, 999, wel1yy03))

#7

recoding_test_df <- mutate(recoding_test_df, wel1yy04 = if_else(wel1yy04 == 0, 999, wel1yy04))

#8

recoding_test_df <- mutate(recoding_test_df, wel1yy05 = if_else(wel1yy05 == 0, 999, wel1yy05))

#9

recoding_test_df <- mutate(
  recoding_test_df,
  kkp1yy01 = case_match(
    kkp1yy01,
    "Ja"   ~ "1",
    "Nee"  ~ "0"))

#10

recoding_test_df <- mutate(
  recoding_test_df,
  kkp1yy02 = case_match(
    kkp1yy02,
    "Helemaal niet waar" ~ "1",
    "Niet waar" ~ "2",
    "Neutraal" ~ "3",
    "Waar" ~ "4",
    "Helemaal waar" ~ "5"))

# RECODE VARIABLES 2

reversal_mapping <- read_excel("config/variable_reversing.xlsx")

reversal_test_df <- select(jongeren_relabelled, reversal_mapping$new_name)

# cpc1yy06

reversal_test_df <- mutate(
  recoding_test_df,
  cpc1yy06_r = case_match(
    cpc1yy06,
    "Helemaal niet waar" ~ "5",
    "Niet" ~ "4",
    "Eeen beetje" ~ "3",
    "Wel" ~ "2",
    "Helemaal wel" ~ "1"))

# cpc1yy20

reversal_test_df <- mutate(
  reversal_test_df,
  cpc1yy20_r = case_match(
    cpc1yy20,
    "Helemaal niet waar" ~ "5",
    "Niet" ~ "4",
    "Eeen beetje" ~ "3",
    "Wel" ~ "2",
    "Helemaal wel" ~ "1"))

# cpc1yy22

reversal_test_df <- mutate(
  reversal_test_df,
  cpc1yy22_r = case_match(
    cpc1yy22,
    "Helemaal niet waar" ~ "5",
    "Niet" ~ "4",
    "Eeen beetje" ~ "3",
    "Wel" ~ "2",
    "Helemaal wel" ~ "1"))

# cpc1yy23

reversal_test_df <- mutate(
  reversal_test_df,
  cpc1yy23_r = case_match(
    cpc1yy23,
    "Helemaal niet waar" ~ "5",
    "Niet" ~ "4",
    "Eeen beetje" ~ "3",
    "Wel" ~ "2",
    "Helemaal wel" ~ "1"))

# cpc1yy27

reversal_test_df <- mutate(
  reversal_test_df,
  cpc1yy27_r = case_match(
    cpc1yy27,
    "Helemaal niet waar" ~ "5",
    "Niet" ~ "4",
    "Eeen beetje" ~ "3",
    "Wel" ~ "2",
    "Helemaal wel" ~ "1"))

# cpc1yy28

reversal_test_df <- mutate(
  reversal_test_df,
  cpc1yy28_r = case_match(
    cpc1yy28,
    "Helemaal niet waar" ~ "5",
    "Niet" ~ "4",
    "Eeen beetje" ~ "3",
    "Wel" ~ "2",
    "Helemaal wel" ~ "1"))

# sbl1yy05

reversal_test_df <- mutate(
  reversal_test_df,
  sbl1yy05_r = case_match(
    sbl1yy05,
    "Helemaal niet waar" ~ "5",
    "Niet" ~ "4",
    "Eeen beetje" ~ "3",
    "Wel" ~ "2",
    "Helemaal wel" ~ "1"))

# ipc1yy13

reversal_test_df <- mutate(
  reversal_test_df,
  ipc1yy13_r = case_match(
    ipc1yy13,
    "Helemaal niet waar" ~ "5",
    "Niet" ~ "4",
    "Eeen beetje" ~ "3",
    "Wel" ~ "2",
    "Helemaal wel" ~ "1"))

# ipc1yy14

reversal_test_df <- mutate(
  reversal_test_df,
  ipc1yy14_r = case_match(
    ipc1yy14,
    "Helemaal niet waar" ~ "5",
    "Niet" ~ "4",
    "Eeen beetje" ~ "3",
    "Wel" ~ "2",
    "Helemaal wel" ~ "1"))

# ipc1yy15

reversal_test_df <- mutate(
  reversal_test_df,
  ipc1yy15_r = case_match(
    ipc1yy15,
    "Helemaal niet waar" ~ "5",
    "Niet" ~ "4",
    "Eeen beetje" ~ "3",
    "Wel" ~ "2",
    "Helemaal wel" ~ "1"))

# wel1yy05

reversal_test_df <- mutate(
  reversal_test_df,
  wel1yy05_r = case_match(
    wel1yy05,
    999 ~ 999,
    1 ~ 5,
    2 ~ 4,
    3 ~ 3,
    4 ~ 2,
    5 ~ 1))

# ADD VALUE LABELS

reversal_test_df_label <- reversal_test_df
#reversal_test_df_label <- set_labels(recoding_test_df_label, wel1yy05, labels = c("helemaal niet" = 1, "2" = 2, "3" = 3, "4" = 4, "erg" = 5)) # works
get_labels(reversal_test_df_label$kbh1yy02a) # works

# kbh1yy02a

reversal_test_df_label <- mutate(reversal_test_df_label, kbh1yy02a = as.numeric(kbh1yy02a))

reversal_test_df_label <- set_labels(reversal_test_df_label, kbh1yy02a, 
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
                                                "December" = 12)) # works

# wel1yy01
#
reversal_test_df_label <- set_labels(reversal_test_df_label, wel1yy01, 
                                     labels = c("slecht" = 1, 
                                                "2" = 2, 
                                                "3" = 3, 
                                                "4" = 4, 
                                                "5" = 5,
                                                "6" = 6,
                                                "7" = 7,
                                                "8" = 8,
                                                "9" = 9,
                                                "goed" = 10)) # works

# wel1yy02
reversal_test_df_label <- set_labels(reversal_test_df_label, wel1yy02, 
                                     labels = c("missing" = 999, 
                                                "een niet heel erg gelukkig mens" = 1, 
                                                "2" = 2, 
                                                "3" = 3, 
                                                "4" = 4,
                                                "een heel erg gelukkig mens" = 5)) # works
# wel1yy03
reversal_test_df_label <- set_labels(reversal_test_df_label, wel1yy03, 
                                     labels = c("missing" = 999, 
                                                "minder gelukkig" = 1, 
                                                "2" = 2, 
                                                "3" = 3, 
                                                "4" = 4,
                                                "meer gelukkig" = 5)) # works

# wel1yy04
reversal_test_df_label <- set_labels(reversal_test_df_label, wel1yy04, 
                                     labels = c("missing" = 999, 
                                                "helemaal niet" = 1, 
                                                "2" = 2, 
                                                "3" = 3, 
                                                "4" = 4,
                                                "heel erg" = 5)) # works
# wel1yy05
reversal_test_df_label <- set_labels(reversal_test_df_label, wel1yy05, 
                                     labels = c("missing" = 999, 
                                                "helemaal niet" = 1, 
                                                "2" = 2, 
                                                "3" = 3, 
                                                "4" = 4,
                                                "heel erg" = 5)) # works
# COMPUTATIONS

computation_test_df <- reversal_test_df_label

# computation_test_df <- jongeren_renamed %>% select(wel1yy02:wel1yy05)
#   
# computation_test_df <- computation_test_df %>%
#   rowwise() %>%
#   mutate(HAP1yy = round(mean(c_across(c(wel1yy02:wel1yy05)), na.rm=TRUE), 1))

# LIV1YY1w
# sum(liv1yy1_01 - liv1yy1_14) / 2

# can't work because they're string values?

computation_test_df <- computation_test_df %>%
  rowwise() %>%
  mutate(LIV1YY1w = round(sum(c_across(c(liv1yy1_01:liv1yy1_14)/2), na.rm=TRUE), 1))

compcheck <- select(computation_test_df, liv1yy1_01:liv1yy1_14)

compcheck <- compcheck %>%
  rowwise() %>%
  mutate(LIV1YY1w = round(sum(c_across(c(liv1yy1_01:liv1yy1_14)/2), na.rm=TRUE), 1))

# LIV1YY2w
# can't work because they're string values?

compcheck <- select(computation_test_df, liv1yy2_01:liv1yy2_28)

# LIV1YY3w
# can't work because they're string values?


compcheck <- select(computation_test_df, liv1yy3_01:liv1yy3_42)


# LIV1YY4w
# can't work because they're string values?


compcheck <- select(computation_test_df, liv1yy4_01:liv1yy4_56)


# LIV1YY
# can't work because they're string values?

# FEL1YY
# can't work because they're string values?


computation_test_df <- computation_test_df %>%
  rowwise() %>%
  mutate(FEL1YY = round(mean(c_across(c(bfs1yy01:bfs1yy06)), na.rm=TRUE), 1))

compcheck <- select(computation_test_df, bfs1yy01:bfs1yy06)


# BEH1yy
# Column `bfs1yy012` doesn't exist, has to be 12
# can't work because they're string values?


compcheck <- select(computation_test_df, bfs1yy06:bfs1yy12)


# HAP1yy

compcheck <- select(computation_test_df, wel1yy02:wel1yy04, wel1yy05_r)

compcheck <- mutate(compcheck, wel1yy05_r = if_else(wel1yy05_r == 999, NA, wel1yy05_r))

compcheck <- compcheck %>%
  rowwise() %>%
  mutate(HAP1yy = round(mean(c_across(c(wel1yy02:wel1yy04, wel1yy05_r)), na.rm=TRUE), 1))


# ACC1yy
# can't work because they're string values?


compcheck <- select(computation_test_df, acc1yy01:acc1yy04)


# LOY1yy
# can't work because they're string values?

compcheck <- select(computation_test_df, loy1yy01:loy1yy06)


# PAR1yy
# can't work because they're string values?

compcheck <- select(computation_test_df, par1yy01:par1yy07)

# SBL1YY
# can't work because they're string values?

compcheck <- select(computation_test_df, sbl1yy01:sbl1yy08)

# EMP1yy
# can't work because they're string values?

compcheck <- select(computation_test_df, emp1yy01:emp1yy08)

# CVM1YY
# can't work because they're string values?

compcheck <- select(computation_test_df, cvm1yy01:cvm1yy04)

# AUS1YF
# can't work because they're string values?

compcheck <- select(computation_test_df, aus1yf01:aus1yf04)

# AUS1YM
# can't work because they're string values?

compcheck <- select(computation_test_df, aus1ym01:aus1ym04)

# COE1YF
# can't work because they're string values?

compcheck <- select(computation_test_df, coe1yf01:coe1yf04)

# COE1YM
# can't work because they're string values?

compcheck <- select(computation_test_df, coe1ym01:coe1ym04)

# WAR1YF
# can't work because they're string values?

compcheck <- select(computation_test_df, war1yf01:war1yf04)

# WAR1YM
# can't work because they're string values?

compcheck <- select(computation_test_df, war1ym01:war1ym04)

# REJ1YF
# can't work because they're string values?

compcheck <- select(computation_test_df, rej1yf01:rej1yf04)

# REJ1YM
# can't work because they're string values?

compcheck <- select(computation_test_df, rej1ym01:rej1ym04)

# STR1YF
# can't work because they're string values?

compcheck <- select(computation_test_df, str1yf01:str1yf04)

# STR1YM
# can't work because they're string values?

compcheck <- select(computation_test_df, str1ym01:str1ym04)

# CHA1YF
# can't work because they're string values?

compcheck <- select(computation_test_df, cha1yf01:cha1yf04)

# CHA1YM
# can't work because they're string values?

compcheck <- select(computation_test_df, cha1ym01:cha1ym04)

# TRI1YM
# can't work because they're string values?

compcheck <- select(computation_test_df, tri1ym01:tri1ym05)

# TRI1YF
# can't work because they're string values?

compcheck <- select(computation_test_df, tri1yf01:tri1yf05)

# RES1YY
# can't work because they're string values?

compcheck <- select(computation_test_df, coc1yy01:coc1yy08)

# COM1YY
# can't work because they're string values?

compcheck <- select(computation_test_df, coc1yy09:coc1yy15)


# MISSINGS

# EXPORT TO CSV & SAV