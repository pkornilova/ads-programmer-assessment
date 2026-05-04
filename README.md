# ads-programmer-assessment
This repo contains my code for the ADS Programmer technical assessment. It provides solutions to 6 questions using R and Python. Please refer to the README file below for a detailed description of each folder's contents and the repository structure. Each branch was created to address a specific question (1-6), and once completed, all the information was merged into the main branch.

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
- `CARPOPFL` — cardiac disorder adverse event flag

---

## question_4 - AE Summary, Visualisations and Listings

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

## question_5 - Clinical Data API 
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
pip install fastapi uvicorn pandas pydantic python-dotenv

### 4. Add the data file
Place adae.csv in the same folder as main.py.
This file is exported from the pharmaverseadam::adae and saved as csv file.

### 5. Configure the environment
Copy the .env.example file to .env:
cp .env.example .env

Open .env and set the path to your adae.csv:
ADAE_CSV=adae.csv

### 6. Run the API
Open the main.py script and run the code.
Open the terminal, set your working directory to the full filepath of the question_5 subfolder.
Then run the command below:

uvicorn main:app --reload

The API will be available at http://127.0.0.1:8000
Interactive docs available at http://127.0.0.1:8000/docs

You can test the endpoints at http://127.0.0.1:8000/docs in a user-friendly way.
Please follow the examples below of the request bodies for POST /ae-query and GET /subject-risk/{subject_id} queries. 
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

## question_6 - Clinical Trial LMM Data Agent

A natural language query agent for clinical trial safety data. Reviewers can ask questions in plain English about the `adae.csv` adverse events dataset and receive filtered lists of subject IDs without needing to know any column names or data structure.

---

### Overview

The agent takes a free-text question (e.g. *"Give me subjects with severe nausea over the age of 60"*), uses an LLM to map it to the correct dataset columns and filter values, validates the result, and returns matching subject IDs and their counts.

---

### File Structure

| File | Description |
|---|---|
| `schema.py` | Builds the LLM system prompt from the dataset; includes column descriptions, real unique values, mapping rules, and JSON output examples |
| `models.py` | Pydantic models (`SingleFilter`, `AEFilter`) for validating structured JSON responses from the LLM |
| `agent.py` | `ClinicalTrialDataAgent` class — defines an agent class with methods for LLM calls, JSON parsing, validation, and dataset filtering |
| `test_agent.py` | Runs three example queries against the agent and prints subject counts and IDs |
| `adae.csv` | Input adverse events dataset (CDISC adae format from pharmaverse) |

---

### How It Works

```
User question (str)
      │
      ▼
build_prompt()       ← Combines system prompt (schema + rules) with the question
      │
      ▼
call_llm()           ← Sends prompt to Gemini via LangChain
      │
      ▼
parse_question()     ← Extracts and validates JSON → AEFilter (list of SingleFilters)
      │
      ▼
validate_filter()    ← Checks age bounds (≥18, ≤100) and date bounds (≥ trial start, ≤ today)
      │
      ▼
execute_filter()     ← Applies each filter to adae DataFrame
      │
      ▼
{"subject_count": N, "subject_ids": [...]}
```

---

### Setup

**Install dependencies:**
```bash
pip install pandas pydantic langchain-google-genai python-dotenv
```
**Get a Google API key:**
You will need a Google Gemini API key to run this example project. You can obtain one for free at [Google AI Studio](https://aistudio.google.com/app/apikey). The free tier includes a generous allowance suitable for running these queries.

**Set your API key** in a `.env` file:
```
GOOGLE_API_KEY=your_key_here
```

**Place `adae.csv`** in the same directory as the scripts.

---

### Usage

```python
from schema import build_system_prompt
from agent import ClinicalTrialDataAgent
from langchain_google_genai import ChatGoogleGenerativeAI
from pandas import read_csv
import os

ae = read_csv("adae.csv")

# You can use any LMM from lang_chain if you have a specific АPI key; the code is not limited to gemini-2.5-flash model
# Please set up your desired LMM and pass it when creating a ClinicaklTrialDataAgent
llm = ChatGoogleGenerativeAI(
    model="gemini-2.5-flash",
    temperature=0,
    max_retries=2,
    api_key=os.getenv("GOOGLE_API_KEY")
)

agent = ClinicalTrialDataAgent(llm=llm, system_prompt=build_system_prompt(ae), input_df=ae)

result = agent.ask("Give me subjects with moderate adverse events aged over 60")
print(result)
# {"subject_count": 128, "subject_ids": [...]}
```

---

### Example Queries & Expected Results

| Query | Expected Subject Count |
|---|---|
| Moderate severity AEs, age > 60 | 128 |
| Severe AEs with nausea | 1 |
| Women under 85, nervous system AEs, last alive on or after 2013-05-05 | 17 |

---

### Supported Filter Columns

| Column | Description | Type |
|---|---|---|
| `AETERM` | Adverse event name | Character |
| `AESEV` | Severity (Mild / Moderate / Severe) | Character |
| `AESOC` | System Organ Class (body system) | Character |
| `AESER` | Serious event flag (Y / N) | Character |
| `AEREL` | Relationship of the advert event to treatment | Character |
| `AEOUT` | Outcome (Recovered, Fatal, etc.) | Character |
| `SEX` | Patient sex (F / M) | Character |
| `RACE` | Patient race | Character |
| `ETHNIC` | Patient ethnicity | Character |
| `AGE` | Age in years | Numeric |
| `ASTDY` | AE duration in days | Numeric |
| `AESTDTC` | AE start date | Date (YYYY-MM-DD) |
| `AEENDTC` | AE end date | Date (YYYY-MM-DD) |
| `LSTALVDT` | Last date known alive | Date (YYYY-MM-DD) |

---

### Validation Rules

- **Age:** must be between 18 and 100 (inclusive)
- **Dates:** must fall on or after the trial start date (`2012-07-09`) and not be in the future
- Multi-condition queries are supported — each condition is applied as a sequential filter

---


