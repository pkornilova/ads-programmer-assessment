#======================================================================================================================
# File:           models.py
# Description:    Defines classes for two Pydantic models for validating and parsing
#                 structured JSON responses from the LLM before they are
#                 passed to the dataset filtering functions in agent.py
#
# Input:          JSON output from LLM
#
# Output:         Python objects (SingleFilter, AEFilter)
# Used by:        agent.py
#                 - validate_filter()   validates LLM JSON against AEFilter
#                 - execute_filter()    converts AEFilter into dataset filters
#
# Dependencies:   pydantic
# Author:         Polina Kornilova
# Date:           30/04/2026
#========================================================================================================================

from pydantic import BaseModel
class SingleFilter(BaseModel):
    target_column: str
    filter_value: str
    operator: str = "=="

class AEFilter(BaseModel):
    filters: list[SingleFilter]