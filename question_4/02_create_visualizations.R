#==============================================================================================
# Study:        CDISCPILOT01
# Program:      02_create_visualizations.R        
# Purpose:      1. Create AE severity distribution by treatment bar chart
#               2. Top 10 most frequent AEs (with 95% CI for incidence rates) plot
#
# Input:        pharmaverseadam::adsl, pharmaverseadam::adae
#       
#               
# Outputs:      1. ae_severity_dist_plot.png
#               2. 10_freq_ae_95_ci_plot.png
#
# Author:       Polina Kornilova 
#
# Date:         29/04/2026
#
#==============================================================================================

# Load libraries 
library(pharmaverseadam)
library(dplyr)
library(ggplot2)

# Define output directory to save the outputs
output_dir = "~/Documents/assessment_roche/ads-programmer-assessment/question_4/outputs"

# Read in raw data
adae <- pharmaverseadam::adae 
adsl <- pharmaverseadam::adsl

# Create Plot 1: AE severity distribution by treatment bar chart. 

# Create factors levels to output in the order for severity and treatment arms 
# Calculate number of events per treatment arm and severity
ae_counts <- adae %>%
  mutate(AESEV = factor(AESEV, 
                        levels = c("MILD", "MODERATE", "SEVERE")),
         ACTARM = factor (ACTARM,
                          levels = c("Placebo", "Xanomeline Low Dose", 
                                     "Xanomeline High Dose")))%>%
 count(ACTARM,AESEV,name = "counts")

ae_plot <- ggplot(ae_counts, aes(fill = AESEV, y=counts,x=ACTARM))+
  geom_bar(position="stack", stat="identity")+
  labs(
    title = "AE severity distribution by treatment",
    x = "Treatment Arm",
    y = "Count of AEs",
    fill = "Severity/Intensity"
  )
print(ae_plot)

# Save the plot as png
ggsave(
  filename = file.path(output_dir, "ae_severity_dist_plot.png"),
  plot = ae_plot,
  width = 10,
  height = 6,
  dpi = 300,
  units = "in"
)

# Create Top 10 most frequent AEs (with 95% CI for  incidence rates). 

# Calculate total number of subjects in the study
n_total <- adsl %>%
  distinct(USUBJID) %>%
  nrow()

# Calculate number of AEs for each subjects
ae_num <- adae %>%
  distinct(USUBJID, AETERM) %>% 
  count(AETERM, name = "n_ae")

# Sort by descending freq of adverse event, select top 10 AEs & 
# calculate 95% Clopper-Pearson CIs for each event
ae_ci <- ae_num %>%
  arrange(desc(n_ae)) %>%
  slice_head(n = 10) %>%
  rowwise() %>%
  mutate(
    pct     = n_ae / n_total,
    ci_low  = binom.test(n_ae, n_total)$conf.int[1],
    ci_high = binom.test(n_ae, n_total)$conf.int[2]
  ) %>%
  ungroup() %>%
  mutate(AETERM = reorder(AETERM, pct))

# Create a plot with 95% CIs 
ae_plot_ci <- ggplot(ae_ci, aes(x = pct, y = AETERM)) +
  geom_point(size = 3) +
  geom_errorbarh(
    aes(xmin = ci_low, xmax = ci_high),
    height = 0.25
  ) +
  scale_x_continuous(
    labels = scales::percent_format(),
    limits = c(0.00, 0.30),
    breaks = seq(0.05, 0.30, by = 0.05)) +
  labs(
    title = "Top 10 Most Frequent Adverse Events",
    subtitle = paste0("n = ", n_total, "; 95% Clopper-Pearson CIs"),
    x = "Percentage of Patients (%)",
    y = NULL
  ) +
  theme_gray()
plot(ae_plot_ci)

# Output and save plot to directory 
ggsave(
  filename = file.path(output_dir, "10_freq_ae_95_ci_plot.png"),
  plot = ae_plot_ci,
  width = 10,
  height = 6,
  dpi = 300,
  units = "in"
)



