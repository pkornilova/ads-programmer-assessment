#==============================================================================
# Study:        CDISCPILOT01
# Program:      02_create_ds_domain.R
# Domain:       DS - Disposition
# Purpose:      Create SDTM DS domain from pharmaverse raw data using controlled 
#               terminology
#
# Input:        pharmaverseraw::ds_raw
#               pharmaversesdtm::dm
#               sdtm_ct.csv
#
# Output:       ds
#
# Author:       Polina Kornilova
# Date:         02-05-2026
#==============================================================================
install.packages(c("sdtm.oak", "pharmaverseraw"))
lapply(c("sdtm.oak", "dplyr", "pharmaverseraw", "pharmaversesdtm"), library, character.only = TRUE)

# Read CT Specification
study_ct <- read.csv("sdtm_ct.csv", stringsAsFactors = FALSE)

# Read in raw data
ds_raw <- pharmaverseraw::ds_raw 
dm <- pharmaversesdtm::dm

# Convert blanks to NAs 
# Uppercase IT.DSDECOD to match controlled terms in the CT file
dm <- admiral::convert_blanks_to_na(dm)
ds_raw <- admiral::convert_blanks_to_na(ds_raw) %>%
  mutate(`IT.DSDECOD` = toupper(`IT.DSDECOD`))


# derive oak_id_vars
ds_raw <- ds_raw %>%
  generate_oak_id_vars(
    pat_var = "PATNUM",
    raw_src = "ds_raw"
  )

#Create a topic variable in the DS Domain
ds <-
  assign_no_ct(
    raw_dat = ds_raw,
    raw_var = "IT.DSTERM",
    tgt_var = "DSTERM"
  )%>%
#Create DSDECOD and keep "Randomized" values
 hardcode_no_ct(
    raw_dat = condition_add(ds_raw,ds_raw$IT.DSDECOD == "RANDOMIZED"),
    raw_var = "IT.DSDECOD",
    tgt_var = "DSDECOD",
    tgt_val = "RANDOMIZED",
    id_vars = oak_id_vars()
  )%>%
#Create DSDECOD using the CT 
  assign_ct(
    raw_dat = condition_add(ds_raw,ds_raw$IT.DSDECOD != "RANDOMIZED"),
    raw_var = "IT.DSDECOD",
    tgt_var = "DSDECOD",
    ct_spec = study_ct,
    ct_clst = "C66727",
    id_vars = oak_id_vars()
)%>%
#Create and derive DSCAT for "Protocol milestone" values
  hardcode_ct(
    raw_dat = condition_add(ds_raw,ds_raw$`IT.DSDECOD` == "RANDOMIZED"),
    raw_var = "IT.DSDECOD",
    tgt_var = "DSCAT",
    ct_spec = study_ct,
    ct_clst = "C74558",
    tgt_val = "PROTOCOL MILESTONE",
    id_vars = oak_id_vars()
  )%>%
#Create and derive DSCAT for "Disposition event" values
  hardcode_ct(
    raw_dat = condition_add(ds_raw,ds_raw$`IT.DSDECOD` != "RANDOMIZED"),
    raw_var = "IT.DSDECOD",
    tgt_var = "DSCAT",
    ct_spec = study_ct,
    ct_clst = "C74558",
    tgt_val = "DISPOSITION EVENT",
    id_vars = oak_id_vars()
  )%>%
#If OTHERSP var not null, populate DSDECOD with OTHERSP values
assign_no_ct(
  raw_dat = condition_add(ds_raw, !is.na(ds_raw$OTHERSP)),
  raw_var = "OTHERSP",
  tgt_var = "DSDECOD",
  id_vars = oak_id_vars()
) %>%
 #If OTHERSP var not null, populate DSTERM with OTHERSP values
  assign_no_ct(
    raw_dat = condition_add(ds_raw, !is.na(ds_raw$OTHERSP)),
    raw_var = "OTHERSP",
    tgt_var = "DSTERM",
    id_vars = oak_id_vars()
  )%>%
 #If OTHERSP is null, populate IT.DSTERM to DSTERM
  assign_no_ct(
    raw_dat = condition_add(ds_raw, is.na(ds_raw$OTHERSP)),
    raw_var = "IT.DSTERM",
    tgt_var = "DSTERM",
    id_vars = oak_id_vars()
  )%>%
 #If OTHERSP is null, populate IT.DSDECOD to DSDECOD
  assign_no_ct(
    raw_dat = condition_add(ds_raw, is.na(ds_raw$OTHERSP)),
    raw_var = "IT.DSDECOD",
    tgt_var = "DSDECOD",
    id_vars = oak_id_vars()
  )%>%
 #If OTHERSP is not null, populate DSCAT as "OTHER EVENT" per CT codelist
  hardcode_ct(
    raw_dat = condition_add(ds_raw, !is.na(ds_raw$OTHERSP)),
    raw_var = "OTHERSP",
    tgt_var = "DSCAT",
    ct_spec = study_ct,
    ct_clst = "C74558",
    tgt_val = "OTHER EVENT",
    id_vars = oak_id_vars()
  )%>%
  # Create VISIT 
  assign_ct(
    raw_dat = ds_raw,
    raw_var = "INSTANCE",
    tgt_var = "VISIT",
    ct_spec = study_ct,
    ct_clst = "VISIT",
    id_vars = oak_id_vars()
  )%>%
  # Create VISITNUM
  assign_ct(
    raw_dat = ds_raw,
    raw_var = "INSTANCE",
    tgt_var = "VISITNUM",
    ct_spec = study_ct,
    ct_clst = "VISITNUM",
    id_vars = oak_id_vars()
  )%>%
  # Create DSSTDTC in ISO8601 format
  assign_datetime(
    raw_dat = ds_raw,
    raw_var = "IT.DSSTDAT",
    tgt_var = "DSSTDTC",
    raw_fmt = "mm-dd-yyyy",
    id_vars = oak_id_vars()
  )%>%
  # Create DSDTC with combining DSDTCOL and DSTMCOL
  assign_datetime(
    raw_dat = ds_raw,
    raw_var = c("DSDTCOL", "DSTMCOL"),
    tgt_var = "DSDTC",
    raw_fmt = c("mm-dd-yyyy", "HH:MM"),
    id_vars = oak_id_vars()
  )

# Change VISITNUM values that did not match CT as per CT logic 
# Derive USUBJID, DOMAIN and STUDYID
ds <- ds %>%
  mutate(
  STUDYID = ds_raw$STUDY,
  DOMAIN = "DS",
  USUBJID = paste0("01-", ds_raw$PATNUM),
  DSTERM = toupper(DSTERM),      
  DSDECOD = toupper(DSDECOD),
  VISITNUM = case_when(
    VISIT == "AMBUL ECG REMOVAL" ~ "3.5",
    VISIT == "UNSCHEDULED 6.1" ~ "6.1",
    VISIT == "UNSCHEDULED 1.1" ~ "1.1",
    VISIT == "UNSCHEDULED 5.1" ~ "5.1",
    VISIT == "UNSCHEDULED 8.2" ~ "8.2",
    VISIT == "UNSCHEDULED 4.1" ~ "4.1",
    TRUE ~ VISITNUM              
  )) %>%
  # Derive DSSEQ using DTERM 
  # Derive DSSTDY using Date/Time of First Study Treatment from DM domain
  derive_seq(tgt_var = "DSSEQ",
             rec_vars = c("USUBJID","DSTERM"))%>%
  derive_study_day(
  sdtm_in = .,
  dm_domain = dm,
  tgdt = "DSSTDTC",
  refdt = "RFXSTDTC",
  study_day_var = "DSSTDY"  
  ) %>%
  select("STUDYID", "DOMAIN", "USUBJID", "DSSEQ", "DSTERM", "DSDECOD",
         "DSCAT", "VISITNUM", "VISIT", "DSDTC", "DSSTDTC", "DSSTDY")
  
  


  


