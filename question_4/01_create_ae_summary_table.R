#==============================================================================================
# Study:        CDISCPILOT01
# Program:      01_create_ae_summary_table.R        
# Purpose:      Create an adverse event summary table by system organ class
#               and preferred term
#
# Input:        pharmaverseadam::adsl, pharmaverseadam::adae
#       
#               
# Output:       ae_summary_table.html
#
# Description:  This program filters treatment-emergent adverse events
#               (TRTEMFL = "Y") and produces a hierarchical summary table
#               of AEs by System Organ Class (AESOC) and Preferred Term
#               (AETERM), grouped by treatment arm (ACTARM). Percentages
#               are calculated using ADSL as the denominator. Results are
#               sorted by descending frequency and saved as an HTML file.
#
# Author:       Polina Kornilova 
#
# Date:         29/04/2026
#
#==============================================================================================

#Load libraries 
lapply(c("pharmaverseadam", "dplyr", "ggplot2", "gtsummary"), library, character.only = TRUE)

# Read in raw data
adsl <- pharmaverseadam::adsl
adae <- pharmaverseadam::adae 

# Define path where to save the outputs, modify if necessary 
output_dir = "~/Documents/assessment_roche/ads-programmer-assessment/question_4/outputs"

#Filter ADAE for TRTEMFL 

adae <- adae %>%
  filter(TRTEMFL == "Y")

tbl_ae <- 
  adae |>
  # Group by system organ class and report term per AE
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
# Save as HTML file
sort_tbl_ae <- sort_hierarchical(tbl_ae) %>%
  as_gt() %>%
  gt::gtsave(file.path(output_dir, "ae_summary_table.html"))
  





