from schema import build_system_prompt
import os
from langchain_google_genai import ChatGoogleGenerativeAI
from pandas import read_csv
from agent import ClinicalTrialDataAgent

ae = read_csv("adae.csv")

llm = ChatGoogleGenerativeAI(
    model = "gemini-2.5-flash",
    temperature = 0,
    timeout= None,
    max_retries=2,
    api_key= os.getenv("GOOGLE_API_KEY")
)

agent = ClinicalTrialDataAgent(llm=llm, system_prompt=build_system_prompt(ae),input_df=ae)

# Return 128 subjects
test1 = agent.ask("Give me the subjects who had Adverse events of Moderate severity and their age is over 60 years old")
print(test1)

# Return 1 subject
test2 = agent.ask("Give me subjects who had Severe adverse events and nausea")
print(test2)

# Return 17 subjects
test3 = agent.ask("Give me subjects who were women under the age of 85 with adverse events in nervous system and last date known alive on or after 05-05-2013")
print(test3)
