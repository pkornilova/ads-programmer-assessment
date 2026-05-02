from pydantic import BaseModel
class SingleFilter(BaseModel):
    target_column: str
    filter_value: str
    operator: str = "=="

class AEFilter(BaseModel):
    filters: list[SingleFilter]