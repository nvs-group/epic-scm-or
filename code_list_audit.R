library(dplyr)

# Run this whenever data_raw/ files are refreshed, or periodically
# (SOC/CIP taxonomies revise roughly every 8-10 years) to check
# whether the current validated lists in data_prep.R are still
# complete and accurate. This does NOT modify scm_or_cips/scm_or_socs
# automatically -- review output manually and update data_prep.R by hand.

occupations <- readRDS("data_raw/Occupations.rds")
cips <- readRDS("data_raw/CIP_List.rds") %>%
  rename(CIPCODE = Codevalue, CIPNAME = valueLabel)
backbone <- readRDS("data_raw/Backbone.rds")

# Current validated lists (keep in sync with data_prep.R)
current_cips <- c("14.3701", "52.0202", "52.0203", "52.1301")
current_socs <- c("13-1081", "15-2031", "11-3071", "11-3061")

# --- Re-run the keyword search fresh ---
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

# --- Diff against current lists ---
new_cips <- candidate_cips %>% filter(!CIPCODE %in% current_cips)
dropped_cips <- current_cips[!current_cips %in% candidate_cips$CIPCODE]

new_socs <- candidate_socs %>% filter(!OCCCODE %in% current_socs)
dropped_socs <- current_socs[!current_socs %in% candidate_socs$OCCCODE]

cat("--- New CIP candidates (not currently in list) ---\n")
print(new_cips)
cat("\n--- Current CIP codes no longer matching the keyword search ---\n")
print(dropped_cips)

cat("\n--- New SOC candidates (not currently in list) ---\n")
print(new_socs)
cat("\n--- Current SOC codes no longer matching the keyword search ---\n")
print(dropped_socs)

# --- Row-count sanity check for any new candidates ---
if (nrow(new_cips) > 0) {
  cat("\n--- Row counts for new CIP candidates ---\n")
  print(table(backbone$CIPCODE[backbone$CIPCODE %in% new_cips$CIPCODE]))
}
if (nrow(new_socs) > 0) {
  cat("\n--- Row counts for new SOC candidates ---\n")
  print(table(backbone$OCCCODE[backbone$OCCCODE %in% new_socs$OCCCODE]))
}