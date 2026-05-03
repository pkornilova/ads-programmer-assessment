# ads-programmer-assessment
This repo contains my code for the ADS Programmer technical assessment. It provides solutions to 6 questions using R and Python. Please refer to the README file below for a detailed description of each question and the repository structure. Each branch was created to address a specific question (1-6), and once completed, all the information was merged into the main branch.

## question_1/descriptive_stats
This folder contains the `descriptiveStats` R package, including all files 
necessary to install and load it. The structure follows the standard R package 
conventions:

- **R/** — contains 3 scripts:
  - `central_tendency_calc.R` — functions for mean, median, and mode
  - `quartiles.R` — functions for Q1, Q3, and IQR
  - `utils.R` — handles input validation (non-numeric values, NAs, NaN, 
    empty vectors)
- **tests/** — contains unit tests:
  - `test-central_tendency_calc.R`
  - `test-quartiles.R`
- **NAMESPACE** and **DESCRIPTION** — standard R package metadata files

For usage examples, input validation behaviour, and edge case handling, 
please refer to the README.md inside this folder.

----

## question_2 - DS Domain Creation

This folder contains the following files:

- **sdtm_ct.csv** — CDISC controlled terminology used as a reference input
- **02_create_ds_domain.R** — main R script that produces the Subject 
  Disposition (DS) SDTM domain

The script takes the following inputs:
- `sdtm_ct.csv` — controlled terminology
- `pharmaverseraw::ds_raw` — raw disposition data
- `pharmaversesdtm::dm` — demographics domain

And produces a standardised DS SDTM domain using the `sdtm.oak` and 
`tidyverse` packages, following the pharmaverse AE domain creation example.

For reference, the associated aCRF can be found here:  
https://github.com/pharmaverse/pharmaverseraw/blob/main/vignettes/articles/aCRFs/Subject_Disposition_aCRF.pdf

----
## queation_3 - ADSL Dataset Creation

This folder contains the following file:

- **create_adsl.R** — creates the ADSL dataset using the `admiral` and 
  `tidyverse` packages

The script takes the following input:
- `pharmaversesdtm::dm` — demographics SDTM domain

And produces the ADSL dataset with the following derivations:
- `AGEGR9` & `AGEGR9N` — age group variables
- `TRTSDTM` — treatment start date-time
- `ITTFL` — intent-to-treat flag
- `ABNSBPFL` — abnormal systolic blood pressure flag
- `LSTALVDT` — last known alive date
- `CARPOPFL` — cardiac disorder adverse event population flag

---

## Question 4 - AE Summaries, Visualisations and Listings

This folder contains 3 scripts:

- **01_create_ae_summary_table.R** — produces a treatment-emergent adverse 
  events summary table organised by organ and system class, output in HTML 
  format using the `gtsummary` package
  - Inputs: `pharmaverseadam::adsl`, `pharmaverseadam::adae`

- **02_create_visualizations.R** — produces 2 plots in PNG format using 
  `ggplot2`:
  - AE counts per treatment arm (Placebo, Xanomeline High, Xanomeline Low) by severity (MILD, MODERATE, SEVERE)
  - Top 10 most frequent adverse events with 95% Clopper-Pearson confidence intervals
  - Inputs: `pharmaverseadam::adsl`, `pharmaverseadam::adae`

- **03_create_listings.R** — produces an adverse event listing per `USUBJID` 
  following the mock shell specified in the brief, using the `gtsummary`, 
  `gt` and `gtreg` packages
---

## question_5 
This folder contains the environment.yml, .env.example, .gitignore, adae.csv, and main.py files.

This allows a user to build REST API with FastAPI that serves an adverse event (AE) clinical trial 
data, supports dynamic cohort filtering, and calculates patient risk scores as per assessment requirements. 

## Dependencies
- Python 3.12
- fastapi
- uvicorn
- pandas
- pydantic
- python-dotenv

## Setup

### 1. Clone the repository
git clone <your-repo-url>
cd question_5

### 2. Activate your conda environment
conda activate your_env_name

### 3. Install dependencies
pip install -r requirements.txt

### 4. Add the data file
Place adae.csv in the same folder as main.py.
This file is exported from the pharmaverse ADAE dataset.

### 5. Configure the environment
Copy the .env.example file to .env:
cp .env.example .env

Open .env and set the path to your adae.csv:
ADAE_CSV=adae.csv

### 6. Run the API
uvicorn main:app --reload

The API will be available at http://127.0.0.1:8000
Interactive docs available at http://127.0.0.1:8000/docs

## Endpoints

### GET /
Returns a welcome message confirming the API is running.

### POST /ae-query
Filters the AE dataset dynamically by severity and/or treatment arm.

Example request body:
{
  "severity": ["MODERATE"],
  "treatment_arm": "Placebo"
}

All fields are optional. Omit or set to null to return all records.

Example response:
{
  "count": 74,
  "subjects": ["01-701-1023","01-701-1047","01-701-1363", .....]
}

### GET /subject-risk/{subject_id}
Calculates a safety risk score for a specific patient based on their AEs.

Scoring logic:
- MILD    = 1 point
- MODERATE = 3 points  
- SEVERE  = 5 points

Risk categories:
- Low    : score < 5
- Medium : 5 <= score < 15
- High   : score >= 15

Example request:
http://127.0.0.1:8000/subject-risk/01-701-1363

Example response:
{
  "usubjid": "01-701-1363",
  "risk_score": 8,
  "risk_category": "Medium"
}
## Input Data
- File: adae.csv
- Source: pharmaversesdtm::adae (exported from R)
- Key columns used: USUBJID, AESEV, ACTARM

## question_6
