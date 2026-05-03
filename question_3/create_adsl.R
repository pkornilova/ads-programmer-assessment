#===============================================================================
# Study:        CDISCPILOT01
# Program:      create_adsl.R        
# Purpose:      Create the ADaM ADSL dataset from pharmaversesdtm raw data
#
# Input:        pharmaversesdtm::dm, pharmaversesdtm::ds, pharmaversesdtm::ex
#               pharmaversesdtm::ae, pharmaversesdtm::vs
#               
# Output:       adsl dataframe
#
# Author:       Polina Kornilova 
#
# Date:         29/04/2026
#
#===============================================================================

lapply(c("pharmaversesdtm", "admiral", "dplyr", "tidyr", "lubridate", 
         "stringr"), library, character.only = TRUE)

# Read in input SDTM data
dm <- pharmaversesdtm::dm
ds <- pharmaversesdtm::ds
ex <- pharmaversesdtm::ex
ae <- pharmaversesdtm::ae
vs <- pharmaversesdtm::vs


# Convert blanks to NA values
dm <- convert_blanks_to_na(dm)
ds <- convert_blanks_to_na(ds)
ex <- convert_blanks_to_na(ex)
ae <- convert_blanks_to_na(ae)
vs <- convert_blanks_to_na(vs)

# Create initial adsl
adsl <- dm %>%
  select(-DOMAIN)

# Create a function for deriving AGEGR9 and AGEGR9N
agegr9_lookup <- exprs(
  ~condition,            ~AGEGR9, ~AGEGR9N,
  is.na(AGE),          "Missing",        4,
  AGE < 18,                "<18",        1,
  between(AGE, 18, 50),  "18 - 50",      2,
  !is.na(AGE),             ">50",        3
)


# Derive datetime from character date for TRTSDTM var in ex domain
ex_ext <- ex %>%
  derive_vars_dtm(
    dtc = EXSTDTC,
    highest_imputation = "h",
    time_imputation = "first",
    ignore_seconds_flag = TRUE,
    new_vars_prefix = "EXST"
  ) %>%
  # Derive datetime from character date for TRTEDTM var in ex domain
  derive_vars_dtm(
    dtc = EXENDTC,
    highest_imputation = "h",
    ignore_seconds_flag = TRUE,
    time_imputation = "last",
    new_vars_prefix = "EXEN",
  )

# Derive the TRTSDTM from modified ex
adsl <- adsl %>% 
  derive_vars_merged(
    dataset_add = ex_ext,
    filter_add = (EXDOSE > 0 |
     (EXDOSE == 0 &
      str_detect(EXTRT, "PLACEBO"))) & !is.na(EXSTDTM),
    new_vars = exprs(TRTSDTM = EXSTDTM, TRTSTMF = EXSTTMF),
    order = exprs(EXSTDTM, EXSEQ),
    mode = "first",
    by_vars = exprs(STUDYID, USUBJID)
  ) %>%
  # Derive the TRTEDTM from modified ex for LSTALVDT creation
  derive_vars_merged(
    dataset_add = ex_ext,
    filter_add = (EXDOSE > 0 |
     (EXDOSE == 0 &
      str_detect(EXTRT, "PLACEBO"))) & !is.na(EXENDTM),
    new_vars = exprs(TRTEDTM = EXENDTM),
    order = exprs(EXENDTM, EXSEQ),
    mode = "last",
    by_vars = exprs(STUDYID, USUBJID)
  )
  
# Add AGEGR9 and AGEGR9N to ADSL
adsl_age <-
  derive_vars_cat(
    dataset = adsl,
    definition = agegr9_lookup
)

adsl <- adsl_age %>%
  # Create ITTFL for randomised subjects in valid treatment arms
  derive_var_merged_exist_flag(
    dataset_add = dm,
    by_vars = exprs(STUDYID, USUBJID),
    new_var = ITTFL,
    condition = !is.na(ARM) & ARM != "Screen Failure",
    true_value = "Y",
    false_value = "N",
    missing_value = "N"
  ) %>%
  # Create flag for patients with supine systolic blood pressure <100 or >=140 mmHg
  derive_var_merged_exist_flag(
    dataset_add = vs,
    by_vars = exprs(STUDYID, USUBJID),
    new_var = ABNSBPFL,
    condition = (VSTESTCD == "SYSBP" &
                 VSSTRESU == "mmHg" &
                 (VSSTRESN >= 140 | VSSTRESN < 100)),
    true_value = "Y",
    false_value = "N",
    missing_value = "N"
  ) %>%
  # Create Last Date Known Alive using vs, ae, ds, and adsl 
  derive_vars_extreme_event(
    by_vars = exprs(STUDYID,USUBJID),
    events = list(
      event(
        dataset_name = "vs",
        order = exprs(VSDTC,VSSEQ),
        condition = (!is.na(VSDTC) &
                     !is.na(VSSTRESN) |
                     ! is.na (VSSTRESC)),
        set_values_to = exprs(
          LSTALVDT = convert_dtc_to_dt(VSDTC, highest_imputation = "n"),
          seq = VSSEQ
        ),
      ),
      # Create last date when subject was alive (YYYY-MM-DD) using AESTDTC in the ae 
      event(
        dataset_name = "ae",
        order = exprs(AESTDTC,AESEQ),
        condition = (!is.na(AESTDTC) &
                     grepl("^\\d{4}-\\d{2}-\\d{2}", AESTDTC)),
        set_values_to = exprs(
          LSTALVDT = convert_dtc_to_dt(AESTDTC, highest_imputation = "n"),
          seq = AESEQ
        )
      ),
      # Create last date when subject was alive (YYYY-MM-DD) using DSSTDTC in the ds
      event(
        dataset_name = "ds",
        order = exprs(DSSTDTC,DSSEQ),
        condition = (!is.na(DSSTDTC) &
                      grepl("^\\d{4}-\\d{2}-\\d{2}", DSSTDTC)),
        set_values_to = exprs(
          LSTALVDT = convert_dtc_to_dt(DSSTDTC, highest_imputation = "n"),
          seq = DSSEQ
        )
      ),
      # Create last date when subject was alive (YYYY-MM-DD) using TRTEDTM in the adsl 
      event(
        dataset_name = "adsl",
        condition = (!is.na(TRTEDTM) 
                     & grepl("^\\d{4}-\\d{2}-\\d{2}", TRTEDTM)),
        set_values_to = exprs(LSTALVDT = date(TRTEDTM), seq = 0),
      )
    ),
    # Select the last complete date across above and populate LSTALVDT
    source_datasets = list(vs = vs, ae = ae, ds = ds, adsl = adsl),
    tmp_event_nr_var = event_nr,
    order = exprs(LSTALVDT, seq, event_nr),
    mode = "last",
    new_vars = exprs(LSTALVDT)
  ) %>%
  # Create a flag for adverse event of "CARDIAC DISORDERS" 
  derive_var_merged_exist_flag(
    dataset_add = ae,
    by_vars = exprs(STUDYID, USUBJID),
    new_var = CARPOPFL,
    condition = (toupper(AESOC) == "CARDIAC DISORDERS"),
    true_value = "Y",
    false_value = NA_character_,
    missing_value = NA_character_
  )
