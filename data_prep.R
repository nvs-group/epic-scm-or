library(dplyr)

# Load raw data
backbone <- readRDS("data_raw/Backbone.rds")
occupations <- readRDS("data_raw/Occupations.rds")
cips <- readRDS("data_raw/CIP_List.rds")
schools <- readRDS("data_raw/Schools.rds")

# SCM/OR-relevant CIP codes
scm_or_cips <- c("52.0203", "52.1301", "30.1701", "14.3701")

# SCM/OR-relevant SOC codes
scm_or_socs <- c("13-1081", "15-2031", "11-3071", "11-3061", "13-1023", "43-5061")




# confirm occupation and degree codes exist in data
scm_or_cips <- c("52.0203", "52.1301", "30.1701", "14.3701")
scm_or_socs <- c("13-1081", "15-2031", "11-3071", "11-3061", "13-1023", "43-5061")

# Check which CIP codes actually appear, and how many rows each has
table(backbone$CIPCODE[backbone$CIPCODE %in% scm_or_cips])

# Same for SOC codes
table(backbone$OCCCODE[backbone$OCCCODE %in% scm_or_socs])



# Assume we drop both the 13-1023 and the 43-5061 ...
scm_or_cips <- c("52.0203", "52.1301", "30.1701", "14.3701")
scm_or_socs <- c("13-1081", "15-2031", "11-3071", "11-3061")

filtered_backbone <- backbone %>%
  filter(CIPCODE %in% scm_or_cips, OCCCODE %in% scm_or_socs)
nrow(filtered_backbone)




# See every SOC code in the purchasing/buying family present in this data
occupations %>%
  filter(substr(OCCCODE, 1, 5) == "13-10") %>%
  select(OCCCODE, OCCNAME) %>%
  distinct()


# Broader sanity check: any occupation name containing supply chain / logistics / procurement terms
occupations %>%
  filter(grepl("logistic|supply chain|purchasing|buyer|procurement|operations research", OCCNAME, ignore.case = TRUE)) %>%
  select(OCCCODE, OCCNAME) %>%
  distinct()

# replace two weak SOC with new SCM/OR SOC codes
scm_or_socs <- c("13-1081", "15-2031", "11-3071", "11-3061", "13-1020", "43-3061")

# check row counts for the two new additions
table(backbone$OCCCODE[backbone$OCCCODE %in% c("13-1020", "43-3061")])

# what is 43-5061 actually? and should we keep it?
occupations %>% filter(OCCCODE == "43-5061") %>% select(OCCCODE, OCCNAME)

# dropping 13-1020, keep 43-5061 with 43-3061
scm_or_socs <- c("13-1081", "15-2031", "11-3071", "11-3061", "43-3061", "43-5061")


# rename columns in CIPS
cips <- cips %>%
  rename(CIPCODE = Codevalue, CIPNAME = valueLabel)

names(cips)


# confirm CIP checks for SCM and OR occupations
cips %>%
  filter(grepl("logistic|supply chain|operations research|management science|procurement", CIPNAME, ignore.case = TRUE)) %>%
  select(CIPCODE, CIPNAME) %>%
  distinct()


# What is 30.1701 actually called, and does it exist in this table?
cips %>% filter(CIPCODE == "30.1701")

# Row counts for the two new candidates
table(backbone$CIPCODE[backbone$CIPCODE %in% c("52.0202", "52.1399")])



# final validated lists
scm_or_cips <- c("14.3701", "52.0202", "52.0203", "52.1301", "52.1399")
scm_or_socs <- c("13-1081", "15-2031", "11-3071", "11-3061", "43-3061", "43-5061")

# rerun filter with corrected lists
filtered_backbone <- backbone %>%
  filter(CIPCODE %in% scm_or_cips, OCCCODE %in% scm_or_socs)

nrow(filtered_backbone)


# let's try again, previous didn't work
scm_or_cips <- c("14.3701", "52.0202", "52.0203", "52.1301", "52.1399")
scm_or_socs <- c("13-1081", "15-2031", "11-3071", "11-3061", "43-3061", "43-5061")

# confirm they actually took
scm_or_cips
scm_or_socs

filtered_backbone <- backbone %>%
  filter(CIPCODE %in% scm_or_cips, OCCCODE %in% scm_or_socs)

nrow(filtered_backbone)
table(filtered_backbone$CIPCODE, filtered_backbone$OCCCODE)
