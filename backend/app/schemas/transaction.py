from pydantic import BaseModel
from decimal import Decimal
from datetime import datetime
from typing import Optional
from .category import CategoryResponse

class TransactionBase(BaseModel):
    amount: Decimal
    description: str
    notes: Optional[str] = None
    transaction_date: datetime
    category_id: int

class TransactionCreate(TransactionBase):
    pass

class TransactionUpdate(BaseModel):
    amount: Optional[Decimal] = None
    description: Optional[str] = None
    notes: Optional[str] = None
    transaction_date: Optional[datetime] = None
    category_id: Optional[int] = None

class TransactionResponse(TransactionBase):
    id: int
    user_id: int
    category: CategoryResponse

    class Config:
        from_attributes = True