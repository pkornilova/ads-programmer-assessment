from schema import build_system_prompt
import os
import pandas as pd
import datetime
from langchain_google_genai import ChatGoogleGenerativeAI
import re
from models import AEFilter,SingleFilter

class ClinicalTrialDataAgent:
    def __init__(self, llm, system_prompt, input_df):
        self.llm = llm
        self.system_prompt = system_prompt
        self.input_df = input_df

    # Build prompt
    def build_prompt(self, question: str):
        return f"""
{self.system_prompt}

Question:
{question}
"""

    #  Call LLM
    def call_llm(self, prompt: str):
        return self.llm.invoke(prompt).content.strip()

    #  Extract JSON
    def extract_json(self, text: str):
        match = re.search(r"\{.*\}", text, re.DOTALL)
        if not match:
            raise ValueError(f"No JSON found: {text}")
        return match.group(0)

    # Check the user's query after LLM parse for JSON structured output
    def parse_question(self, question: str):
        prompt = self.build_prompt(question)
        raw = self.call_llm(prompt)
        json_str = self.extract_json(raw)

        return AEFilter.model_validate_json(json_str)

    def validate_filter(self, ae_filter: SingleFilter):
        col = ae_filter.target_column
        val = ae_filter.filter_value

        # validate age
        if col == "AGE":
            age = int(val)
            if age < 18:
                raise ValueError(f"Invalid age: {age}. Clinical trial subjects must be 18 or older.")
            if age > 100:
                raise ValueError(f"Invalid age: {age}. Please check the age value.")

        # validate date
        if re.match(r"^\d{4}-\d{2}-\d{2}$", val):
            date = pd.Timestamp(val)
            treatment_start = pd.Timestamp("2012-07-09")
            today = pd.Timestamp(datetime.date.today())

            if date < treatment_start:
                raise ValueError(f"Date {val} is before the treatment start date {treatment_start.date()}.")
            if date > today:
                raise ValueError(f"Date {val} is in the future. Invalid query.")

    def execute_filter(self, ae_filter: AEFilter):

        filtered_df = self.input_df.copy()

        # apply each filter one at a time
        for f in ae_filter.filters:
            # validate before filtering
            self.validate_filter(f)
            col = f.target_column
            val = f.filter_value
            op = f.operator
            # apply the operator
            if op == "==":
                # always treat as string/character for equality
                filtered_df = filtered_df[
                    filtered_df[col].astype(str).str.upper() == str(val).upper()
                    ]
            elif op in (">=", "<=", ">", "<"):
                # always treat as numeric or date for comparisons
                if re.match(r"^\d{4}-\d{2}-\d{2}$", val):
                    # date comparison
                    filtered_df[col] = pd.to_datetime(filtered_df[col], errors="coerce")
                    val = pd.Timestamp(val)
                else:
                    # numeric comparison
                    filtered_df[col] = pd.to_numeric(filtered_df[col], errors="coerce")
                    val = float(val)

                if op == ">=":
                    filtered_df = filtered_df[filtered_df[col] >= val]
                elif op == "<=":
                    filtered_df = filtered_df[filtered_df[col] <= val]
                elif op == ">":
                    filtered_df = filtered_df[filtered_df[col] > val]
                elif op == "<":
                    filtered_df = filtered_df[filtered_df[col] < val]


        # get unique patient IDs from the filtered result
        unique_ids = filtered_df["USUBJID"].unique().tolist()

        return {
            "subject_count": len(unique_ids),
            "subject_ids": unique_ids,
        }

    def ask(self, question: str):
        parsed = self.parse_question(question)
        return self.execute_filter(parsed)



