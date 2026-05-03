#========================================================================================================================================
# File:               test_agent.py
#
# Description:        Reads in adae.csv file
#                     Creates an agent using ChatGoogleGenerativeAI
#                     agent.ask(question: str) method returns a dict with "subject_count": len(unique_ids), "subject_ids": unique_ids and
#                     takes input as a string for a user's question
#
# Output:             Answer 3 user queries about adverse events dataset and returns the list and counts of unique usubjids
# Dependencies:       pandas, os, build_system_prompt from schema.py (custom script in question_6 folder), ClinicalTrialDataAgent
#                     from agent.py (custom script in question_6 folder)
#
#
# Author:             Polina Kornilova
# Date:               30/04/2026
#===========================================================================================================================================

# Load libraries and functions from other scripts in question_6 task
from schema import build_system_prompt
import os
from langchain_google_genai import ChatGoogleGenerativeAI
from pandas import read_csv
from agent import ClinicalTrialDataAgent

#Read in data from adae
ae = read_csv("adae.csv")

# Define your langchain LLM model here, you can use Gemini-2.5-flash here as GOOGLE_API_KEY has free allowance
# Set temperature = 0 to get reproducible answers for each query
# max_retries of 2: LMM can fail 2 times and retry to generate JSON output per a single user query
llm = ChatGoogleGenerativeAI(
    model = "gemini-2.5-flash",
    temperature = 0,
    timeout= None,
    max_retries=2,
    api_key= os.getenv("GOOGLE_API_KEY")
)

# Create an instance of the class ClinicalTrialDataAgent
# Makes a prompt for LMM using adae.csv and uses adae.csv to fiter for relevant subjects for user query
agent = ClinicalTrialDataAgent(llm=llm, system_prompt=build_system_prompt(ae),input_df=ae)

# Returns 128 subjects
test1 = agent.ask("Give me the subjects who had Adverse events of Moderate severity and their age is over 60 years old")
print(test1)

# Returns 1 subject
test2 = agent.ask("Give me subjects who had Severe adverse events and nausea")
print(test2)

# Returns 17 subjects
test3 = agent.ask("Give me subjects who were women under the age of 85 with adverse events in nervous system and last date known alive on or after 05-05-2013")
print(test3)
