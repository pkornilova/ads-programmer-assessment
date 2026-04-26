library(pharmaverseadam)
library(dplyr)
library(gtsummary)
library(gtreg)
library(gt)

# Define path where to save the outputs
output_dir = "~/Documents/assessment_roche/ads-programmer-assessment/question_4/outputs"

# Create a listing of treatment-emergent adverse events by subject and excluding screen failures

ae_listing <- adae %>%
  # Filter for treatment-emergent AEs, convert AESTDTC to date 
  # Specify NA as character for missing values in AEENDTC
  filter(TRTEMFL == "Y") %>%
  mutate(AESTDTC = as.Date(AESTDTC),
         AEENDTC = ifelse(is.na(AEENDTC), "NA", as.character(AEENDTC))) %>%
  arrange(USUBJID, AESTDTC) %>%
  select(
    USUBJID,
    ACTARM,
    AETERM,
    AESEV,
    AEREL,
    AESTDTC,
    AEENDTC
  ) %>%
  # Add a blank row as per sample output 
  group_by(USUBJID) %>%
  group_modify(~ add_row(.x, .after = nrow(.x))) %>%
  ungroup() %>%
  # Show USUBJID and ACTARM only on first row per subject as per sample output
  group_by(USUBJID) %>%
  mutate(
    ACTARM  = ifelse(row_number() == 1, ACTARM, ""),
    USUBJID = ifelse(row_number() == 1, USUBJID, "")
  ) %>%
  tbl_listing() %>%
  modify_header(
    USUBJID = "Unique Subject Identifier",
    ACTARM  = "Description of Actual Arm",
    AETERM  = "Reported Term for the Adverse Event",
    AESEV   = "Severity/Intensity",
    AEREL   = "Causality",
    AESTDTC = "Start Date/Time of Adverse Event",
    AEENDTC = "End Date/Time of Adverse Event"
  ) %>%
  as_gt() %>%
  gt::tab_header(
    title = gt::md("Listing of Treatment-Emergent Adverse Events by Subject<br>Excluding Screen Failure Patients"),
  ) %>%
  gt::opt_align_table_header(align = "left")%>%
  gt::tab_options(
    table.font.names = "Courier New",
    table.font.size  = px(12),
    # Add space between column labels, define table with and hide top line of the header
    column_labels.padding = px(10),
    column_labels.padding.horizontal = px(7),
    table.width = pct(100),
    table.border.top.style = "hidden"
  ) %>%
  gt::cols_align(
    align = "left",
    columns = everything()
  ) %>%
  # Center align AETERM as per sample output in the brief 
  gt::tab_style(
    style = gt::cell_text(align = "center"),
    locations = gt::cells_column_labels(columns = AETERM)
  )%>%
  # Apply nowrap to both column labels and body, this keeps column headers on a single line
  gt::tab_style(
    style = list(
      gt::css("white-space" = "nowrap")
    ),
    locations = list(
      gt::cells_column_labels(),
      gt::cells_body()
    )
  ) %>%
  gt::gtsave(file.path(output_dir, "ae_listings.html"))
