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
