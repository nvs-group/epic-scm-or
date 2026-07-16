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