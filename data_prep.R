library(dplyr)

# --- Load raw data ---
backbone <- readRDS("data_raw/Backbone.rds")
occupations <- readRDS("data_raw/Occupations.rds")
cips <- readRDS("data_raw/CIP_List_20260716.rds")
schools <- readRDS("data_raw/Schools.rds")

# --- SCM/OR scope ---
# CIP codes: Operations Research, Purchasing/Procurement, Logistics/SCM, Management Science
# Validated against backbone row counts and name-search cross-check;
# dropped codes with near-zero presence or no linkage to target occupations
# (see project notes for full validation trail)
scm_or_cips <- c("14.3701", "52.0202", "52.0203", "52.1301")

# SOC codes: OR Analysts, Logisticians, Transportation/Distribution Managers,
# Purchasing Managers
scm_or_socs <- c("13-1081", "15-2031", "11-3071", "11-3061")

# --- Filtered dataset ---
filtered_backbone <- backbone %>%
  filter(CIPCODE %in% scm_or_cips, OCCCODE %in% scm_or_socs)
