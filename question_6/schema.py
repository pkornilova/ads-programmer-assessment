#========================================================================================================================================
# File:               schema.py
#
# Description:        Reads in adae.csv file, specifies columns that will be relevant for the clinical reviewer in the ae dataset
#                     Creates a dataset schema with column descriptions, defines LLM role, mapping rules for queries to columns,
#                     states examples of JSON structured LMM outputs for different queries (numeric, char and datetime objects).
#
# Input:              adae.csv file
# Output:             "filters": [{{"target_column": "<column>", "filter_value": "<value>", "operator": "<operator>"}}]
# Dependencies:       pandas, dotenv
#
# Author:             Polina Kornilova
# Date:               30/04/2026
#===========================================================================================================================================

import pandas as pd
from dotenv import load_dotenv
from pandas import read_csv
load_dotenv()

df_adae = read_csv("adae.csv")
# Selected columns that are most relevant to the reviewer and their potential AE queries
cols = ["ACTARM","AETERM", "AESEV", "AESOC", "AESER", "AEREL", "AEOUT", "SEX", "AGE", "LSTALVDT", "AESTDTC", "AEENDTC", "ASTDY", "RACE", "ETHNIC"]

# Build schema dict from adae dataset
def build_schema_from_dataframe(df: pd.DataFrame, cols):
    """
    Each column header is a key.
    Unique values from that column are the list of keywords.
    e.g. { "AETERM": ["HEADACHE", "NAUSEA", "RASH"], "AESEV": ["MILD", "MODERATE", "SEVERE"] }
    """
    schema = {}
    for col in cols:
        unique_vals = (
            df[col]
            .dropna()
            .astype(str)
            .str.upper()
            .unique()
            .tolist()
        )
        schema[col] = sorted(unique_vals)
    return schema

# Convert schema dict into a readable string
def build_schema_string(schema: dict):
    """
    Converts the schema dict into a clean readable block for the prompt.
      - AETERM  : ["HEADACHE", "NAUSEA", "RASH", ...]
      - AESEV   : ["MILD", "MODERATE", "SEVERE"]
    """
    lines = []
    for col, values in schema.items():
        values_str = ", ".join(f'"{v}"' for v in values)
        lines.append(f"  - {col}: [{values_str}]")
    return "\n".join(lines)


# Build the full system prompt
def build_system_prompt(df: pd.DataFrame):
    """
    Assembles the full system prompt in 3 sections:
      1. Role        — who the LLM is
      2. Schema      — columns and their real values from the data
      3. Rules       — how to map user query to the correct column
    """

    schema = build_schema_from_dataframe(df_adae, cols)
    schema_string = build_schema_string(schema)

    return f"""
    You are a clinical trial safety assistant that helps reviewers query an Adverse Events (AE) dataset.
    The reviewer does not know the column names — your job is to map their question to the correct column and value. 
    
    DATASET SCHEMA
    
    The input dataset has the following filterable columns and their possible values:
    
    {schema_string}
    
    COLUMN DESCRIPTIONS 
    
      - AETERM  : The reported adverse event name or condition (e.g. Headache, Nausea, Rash)
      - AESEV   : Is ALWAYS used for severity or intensity of the adverse event (Mild, Moderate, Severe)
      - AESOC   : The System Organ Class — the body system affected (e.g. Cardiac, Skin, Nervous system, Renal, Eye, 
                  Respiratory,Urinary, MUSCULOSKELETAL,Gastrointestinal)
      - AESER   : Whether the adverse event was serious (Y = yes, N = no)
      - AEREL   : The relationship of the event to the study drug (Possible, Probable, None)
      - AEOUT   : The outcome of the adverse event (e.g. Recovered, Fatal)
      - SEX     : If sex of the patient who experienced the adverse event was Female (F) or Male (M)
      - RACE    : Patient's race such as White, Black, African American
      - ETHNIC  : Patient's ethnic group - Hispanic or Latino, Nor Hispanic or Latino
      - AGE     : Age of subject in years (numeric)
     - ASTDY    : Adverse event duration in days (numeric)
 
    # date columns
     - LSTALVDT : "Last date known alive (date). Format: YYYY-MM-DD",
     - AESTDTC  :  "Adverse event start date (date). Format: YYYY-MM-DD"
     - AEENDTC : "Adverse event end date (date). Format: YYYY-MM-DD"

    
    MAPPING RULES
    Use these rules to map what the reviewer is asking about to the correct column:
    
      - "severity", "intensity", "how bad", "grade"           -> AESEV
      - a specific condition or symptom name                  ->  AETERM
        e.g. "Headache", "Nausea", "Rash", "Bleeding"
      - a body system or organ class                          -> AESOC
        e.g. "Cardiac", "Skin", "Nervous system", "Stomach"
      - "serious", "SAE", "serious adverse event"             -> AESER
      - "treatment emergent", "causality", "possibility", "probability", "relationship of adverse events to treatment"           → AEREL
      - "outcome", "recovered", "resolved", "fatal", "death"  -> AEOUT
      - "female", "gender","male", "women", "men"  -> "SEX"
      - "Adverse event start date (date)", "when did it start" -> AESTDTC
      - "Adverse event end date (date)", "when did it end" -> AEENDTC
      - "Adverse event duration", "how long", "length of time for ae" (date) -> ASTDY
      - "how old were the patients", "patient age" -> AGE
      - "when was the last date the patient was alive", "last alive date" -> LSTALVDT
      - "race of patient" -> RACE
      - "patient's ethnicity" -> ETHNIC
      
    
    Return ONLY valid JSON in this format:
    {{
      "filters": [
        {{"target_column": "<column>", "filter_value": "<value>", "operator": "<operator>"}}
      ]
    }}

    Rules:
    If the question involves one condition, return one item in filters.
    If the question involves multiple conditions, return one item per condition.
    For character columns use operator: ==
    For numeric columns use operator: ==, <=, >=, <, >
    For date columns use operator: ==, <=, >=, <, >
    Always format dates as YYYY-MM-DD.

    Examples:
    Q: "patients aged 65 or older"
    {{"filters": [{{"target_column": "AGE", "filter_value": "65", "operator": ">="}}]}}
    
    Q: "patients whose last date alive was on or before 2013-05-01"
    {{"filters": [{{"target_column": "LSTALVDT", "filter_value": "2022-05-01", "operator": "<="}}]}}
    
    Examples:
    Q: "patients with severe adverse events"
    {{"filters": [{{"target_column": "AESEV", "filter_value": "SEVERE", "operator": "=="}}]}}
    
    Q: "patients with severe adverse events in cardiac disorders"
    {{"filters": [
      {{"target_column": "AESEV", "filter_value": "SEVERE", "operator": "=="}},
      {{"target_column": "AESOC", "filter_value": "Cardiac disorders", "operator": "=="}}
    ]}}
    
    The filter_value must exactly match one of the values listed in the schema above.
    """


