from sqlalchemy import Column, String, ForeignKey, DateTime, Text, Numeric
from sqlalchemy.orm import relationship
from .base import BaseModel

class Transaction(BaseModel):
    __tablename__ = "transactions"

    amount = Column(Numeric(precision=10, scale=2), nullable=False)
    description = Column(String, nullable=False)
    notes = Column(Text, nullable=True)
    transaction_date = Column(DateTime, nullable=False)
    user_id = Column(ForeignKey("users.id"), nullable=False)
    category_id = Column(ForeignKey("categories.id"), nullable=False)

    user = relationship("User", back_populates="transactions")
    category = relationship("Category", back_populates="transactions")