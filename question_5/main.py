import os
from pathlib import Path
from typing import List, Optional
import pandas as pd
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from dotenv import load_dotenv

load_dotenv()

app = FastAPI(
    title="Clinical Trial Data API",
    description="Serves adverse-event data, cohort analysis, and risk scores.",
    version="1.0.0",
)

DATA_PATH = Path(os.getenv("ADAE_CSV", "adae.csv"))

def load_data():
    """Load adae.csv; raise a clear error if the file is missing."""
    if not DATA_PATH.exists():
        raise FileNotFoundError(
            f"Dataset not found at '{DATA_PATH}'. "
            "Place adae.csv next to main.py or set the ADAE_CSV env var."
        )
    df_adae = pd.read_csv(DATA_PATH)
    # Remove empty spaces in the column headers
    df_adae.columns = [c.strip() for c in df_adae.columns]
    return df_adae

# Load the data; fail if file is missing
try:
    ADEA_DATA: pd.DataFrame = load_data()
    print(f" Loaded {len(ADEA_DATA):,} rows from '{DATA_PATH}'")
    print(f"Columns: {ADEA_DATA.columns.tolist()}")
except FileNotFoundError as exc:
    print(f"{exc}")
    # Return empty ADEA dataset
    ADEA_DATA = pd.DataFrame()


def require_data():
    """Return the dataset or raise HTTP 503 if it was not loaded."""
    if ADEA_DATA.empty:
        raise HTTPException(
            status_code=503,
            detail=(
                "Dataset not available. "
                "Place adae.csv in the folder with question_5.py and restart the server."
            ),
        )
    return ADEA_DATA.copy()


# class AEQueryRequest(BaseModel):
#     """
#     All fields are optional. Missing / null fields are ignored (no filter applied).
#
#     Example JSON payload:
#         {
#           "severity": ["MILD", "MODERATE"],
#           "treatment_arm": "Placebo"
#         }
#     """
#     # filters AESEV
#     severity: Optional[List[str]] = None
#     # filters ACTARM
#     treatment_arm: Optional[str] = None

@app.get("/", summary="Health check / welcome")
def root():
    return {"message": "Clinical Trial Data API is running"}


# Request / response models
class AEQueryRequest(BaseModel):
    """
    Filters are optional. Missing / null fields are ignored (no filter applied).

    Example payload:
        {
          "severity": ["MILD", "MODERATE"],
          "treatment_arm": "Placebo"
        }
    """
    # filters AESEV in adae
    severity: Optional[List[str]] = None
    # filters ACTARM in adae
    treatment_arm: Optional[str] = None


class AEQueryResponse(BaseModel):
    count: int
    subjects: List[str]

class RiskScoreResponse(BaseModel):
    usubjid: str
    risk_score: int
    risk_category: str

@app.post("/ae-query", response_model=AEQueryResponse, summary="Dynamic cohort filter")
def ae_query(body: AEQueryRequest):
    """
    Filter the adverse-event dataset by severity and/or treatment arm.
    Returns the count of matching records and the list of unique subject IDs.
    """
    df = require_data()

    # Raise an exception if column AESEV is missing
    if body.severity and len(body.severity) > 0:
        upper_sev = [s.upper() for s in body.severity]
        if "AESEV" not in df.columns:
            raise HTTPException(status_code=400, detail="Column 'AESEV' not found in dataset.")
        #Convert values in adae AESEV to uppercase
        aesev_upper =df["AESEV"].str.upper()
        #Check adae rows for user's filter in severity
        df_match = aesev_upper.isin(upper_sev)
        # Keep rows in adae that match user's filter
        df = df[df_match]

    # Severity filter (ACTARM) and convert user input to uppercase to match adae
    # Raise an exception if column ACTARM is missing
    if body.treatment_arm and body.treatment_arm.strip() != "":
        if "ACTARM" not in df.columns:
            raise HTTPException(status_code=400, detail="Column 'ACTARM' not found in dataset.")
        actarm_upper = df["ACTARM"].str.upper()

        df_actarm = actarm_upper == body.treatment_arm.upper()
        df = df[df_actarm]

    if "USUBJID" in df.columns:
        unique_ids = df["USUBJID"].unique()
        subjects = sorted([str(s) for s in unique_ids])
    else:
        subjects = []
    print(f"Number of unique subjects: {len(subjects)}")

    return AEQueryResponse(
        count=len(df),
        subjects=subjects,
    )


@app.get("/subject-risk/{subject_id}", summary="Calculate patient risk score")
def subject_risk(subject_id: str):
    df = require_data()

    # Filter for the given subject
    subject_df = df[df["USUBJID"].astype(str) == subject_id]

    # Return 404 if subject not found
    if subject_df.empty:
        raise HTTPException(status_code=404, detail=f"Subject '{subject_id}' not found.")

    # Check if AESEV column has any values for this subject
    if subject_df["AESEV"].isna().all():
        raise HTTPException(status_code=404, detail=" No data in 'AESEV' found in dataset for subject {subject_id}'.")

    # Define severity weights in dict
    severity_weights = {
        "MILD": 1,
        "MODERATE": 3,
        "SEVERE": 5
    }

    # Calculate total risk score
    risk_score = 0
    for severity in subject_df["AESEV"].str.upper():
        risk_score += severity_weights.get(severity, 0)

    # Assign risk category
    if risk_score < 5:
        risk_category = "Low"
    elif risk_score < 15:
        risk_category = "Medium"
    else:
        risk_category = "High"

    return RiskScoreResponse(
        usubjid=subject_id,
        risk_score=risk_score,
        risk_category=risk_category
    )
