library(dplyr)

# --- Load raw data ---
backbone <- readRDS("data_raw/Backbone.rds")
occupations <- readRDS("data_raw/Occupations.rds")

# NOTE: CIP_List.rds has manually corrected headers (Codevalue -> CIPCODE,
# valueLabel -> CIPNAME renamed by hand on 2026-07-16). If this file is ever
# replaced with a fresh download from the NCES source, the header rename
# must be reapplied manually -- it is not automated. Keep this filename
# in sync with code_list_audit.R.
cips <- readRDS("data_raw/CIP_List.rds")

schools <- readRDS("data_raw/Schools.rds")
aw_degree <- readRDS("data_raw/AW_Degree.rds")

# --- SCM/OR scope ---
# CIP codes: Operations Research, Purchasing/Procurement, Logistics/SCM, Management Science
# Validated against backbone row counts and name-search cross-check;
# dropped codes with near-zero presence or no linkage to target occupations
# (see project notes for full validation trail)
scm_or_cips <- c("14.3701", "52.0202", "52.0203", "52.1301")

# SOC codes: OR Analysts, Logisticians, Transportation/Distribution Managers,
# Purchasing Managers, Industrial Production Managers, Management Analysts
# Validated two ways: (1) co-occurrence with target CIP codes in backbone,
# (2) NCES CIP2020-SOC2018 official crosswalk
#   https://nces.ed.gov/ipeds/cipcode/Files/CIP2020_SOC2018_Crosswalk.xlsx
#   (sheet: CIP-SOC, last checked 2026-07-16)
# see code_list_audit.R for periodically re-checking these lists against
# updated government sources
scm_or_socs <- c("13-1081", "15-2031", "11-3071", "11-3061", "11-3051", "13-1111")

# --- Filtered dataset ---
filtered_backbone <- backbone %>%
  filter(CIPCODE %in% scm_or_cips, OCCCODE %in% scm_or_socs)

# --- Join in school, occupation, and degree-level names ---
# Validated 2026-07-16: row count holds at 2,518 (no duplicate-key
# inflation from either lookup table) and zero NAs on all three joined
# name columns (no unmatched UNITID/OCCCODE/AWLEVEL keys). The assertions
# below re-check both conditions on every run so a future data_raw/
# refresh can't silently break this join without being noticed.
scm_or_full <- filtered_backbone %>%
  left_join(schools, by = "UNITID") %>%
  left_join(occupations, by = "OCCCODE") %>%
  left_join(aw_degree, by = "AWLEVEL")

stopifnot(
  "join changed row count -- check for duplicate keys in schools/occupations/aw_degree" =
    nrow(scm_or_full) == nrow(filtered_backbone),
  "unmatched UNITID -- some schools not found in Schools.rds" =
    sum(is.na(scm_or_full$INSTNM)) == 0,
  "unmatched OCCCODE -- some occupations not found in Occupations.rds" =
    sum(is.na(scm_or_full$OCCNAME)) == 0,
  "unmatched AWLEVEL -- some degree levels not found in AW_Degree.rds" =
    sum(is.na(scm_or_full$LEVELName)) == 0
)