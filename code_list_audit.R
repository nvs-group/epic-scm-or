library(dplyr)
library(readxl)
library(httr)

# ---------------------------------------------------------------------------
# code_list_audit.R
#
# Run this whenever data_raw/ files are refreshed, or periodically
# (SOC/CIP taxonomies revise roughly every 8-10 years) to check whether the
# validated lists in data_prep.R are still complete and accurate.
#
# This script does NOT modify scm_or_cips/scm_or_socs automatically --
# review the printed output manually and update data_prep.R by hand.
#
# Two independent validation methods:
#   1. Keyword search against local reference data (data_raw/)
#   2. Cross-check against NCES's official CIP-SOC crosswalk
# ---------------------------------------------------------------------------

# --- Current validated lists (keep in sync with data_prep.R) ---
current_cips <- c("14.3701", "52.0202", "52.0203", "52.1301")
current_socs <- c("13-1081", "15-2031", "11-3071", "11-3061", "11-3051", "13-1111")

# --- Load local reference data ---
# NOTE: CIP_List.rds has manually corrected headers (Codevalue -> CIPCODE,
# valueLabel -> CIPNAME renamed by hand on 2026-07-16). If this file is ever
# replaced with a fresh download from the NCES source, the header rename
# must be reapplied manually -- it is not automated. Keep this filename
# in sync with data_prep.R.
occupations <- readRDS("data_raw/Occupations.rds")
cips <- readRDS("data_raw/CIP_List.rds")
backbone <- readRDS("data_raw/Backbone.rds")

# =============================================================================
# METHOD 1: keyword search against local reference data
# =============================================================================

candidate_cips <- cips %>%
  filter(grepl("logistic|supply chain|operations research|management science|procurement",
               CIPNAME, ignore.case = TRUE)) %>%
  select(CIPCODE, CIPNAME) %>%
  distinct()

candidate_socs <- occupations %>%
  filter(grepl("logistic|supply chain|purchasing|buyer|procurement|operations research|planning|expediting",
               OCCNAME, ignore.case = TRUE)) %>%
  select(OCCCODE, OCCNAME) %>%
  distinct()

new_cips <- candidate_cips %>% filter(!CIPCODE %in% current_cips)
dropped_cips <- current_cips[!current_cips %in% candidate_cips$CIPCODE]

new_socs <- candidate_socs %>% filter(!OCCCODE %in% current_socs)
dropped_socs <- current_socs[!current_socs %in% candidate_socs$OCCCODE]

cat("=== METHOD 1: keyword search against local data ===\n")
cat("--- New CIP candidates (not currently in list) ---\n")
print(new_cips)
cat("\n--- Current CIP codes no longer matching the keyword search ---\n")
print(dropped_cips)
cat("\n--- New SOC candidates (not currently in list) ---\n")
print(new_socs)
cat("\n--- Current SOC codes no longer matching the keyword search ---\n")
print(dropped_socs)

if (nrow(new_cips) > 0) {
  cat("\n--- Row counts for new CIP candidates ---\n")
  print(table(backbone$CIPCODE[backbone$CIPCODE %in% new_cips$CIPCODE]))
}
if (nrow(new_socs) > 0) {
  cat("\n--- Row counts for new SOC candidates ---\n")
  print(table(backbone$OCCCODE[backbone$OCCCODE %in% new_socs$OCCCODE]))
}

# =============================================================================
# METHOD 2: cross-check against NCES's official CIP2020-SOC2018 crosswalk
# Source: https://nces.ed.gov/ipeds/cipcode/Files/CIP2020_SOC2018_Crosswalk.xlsx
# (sheet: CIP-SOC, last checked 2026-07-16)
# =============================================================================

crosswalk_url <- "https://nces.ed.gov/ipeds/cipcode/Files/CIP2020_SOC2018_Crosswalk.xlsx"
GET(crosswalk_url, write_disk(tf <- tempfile(fileext = ".xlsx")), user_agent("Mozilla/5.0"))
crosswalk <- read_excel(tf, sheet = "CIP-SOC")

official_matches <- crosswalk %>%
  filter(CIP2020Code %in% current_cips) %>%
  distinct()

cat("\n=== METHOD 2: official NCES crosswalk ===\n")
cat("--- SOC codes NCES maps to your current CIP codes ---\n")
print(official_matches %>% select(CIP2020Code, SOC2018Code, SOC2018Title))

missing_from_current <- official_matches %>%
  filter(!SOC2018Code %in% current_socs)

cat("\n--- Official matches not currently in scm_or_socs (review for inclusion) ---\n")
print(missing_from_current %>% select(CIP2020Code, SOC2018Code, SOC2018Title))