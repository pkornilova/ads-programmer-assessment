library(pharmaverseadam)
library(dplyr)
library(ggplot2)
library(gtsummary)
library(cards)

# Read in raw data
adsl <- pharmaverseadam::adsl
adae <- pharmaverseadam::adae 

# Define path where to save the outputs
output_dir = "~/Documents/assessment_roche/ads-programmer-assessment/question_4/outputs"

#Filter ADAE for TRTEMFL 

adae <- adae %>%
  filter(TRTEMFL == "Y")

tbl_ae <- 
  adae |>
  # Group by system organ class and reporter term per AE
  # Columns as per treatment arm (ACTARM)
  # Use USUBJID from ADSL to calculate percentages
  tbl_hierarchical(
    variables = c(AESOC,AETERM),
    by = ACTARM,
    denominator = adsl,
    id = USUBJID,
    overall_row = TRUE,
    label = list(..ard_hierarchical_overall.. = "Treatment Emergent AEs")
  )

# Sort by the descending frequency of AETERM & AESOC
sort_tbl_ae <- sort_hierarchical(tbl_ae) %>%
  as_gt() %>%
  gt::gtsave(file.path(output_dir, "ae_summary_table.html"))
  





