from sqlalchemy import Column, String, ForeignKey, Enum
from sqlalchemy.orm import relationship
import enum
from .base import BaseModel

class CategoryType(enum.Enum):
    INCOME = "income"
    EXPENSE = "expense"

class Category(BaseModel):
    __tablename__ = "categories"

    name = Column(String, nullable=False)
    color = Column(String, nullable=True)  # Hex color code
    icon = Column(String, nullable=True)  # Icon name or emoji
    type = Column(Enum(CategoryType), nullable=False)
    user_id = Column(ForeignKey("users.id"), nullable=False)

    user = relationship("User", back_populates="categories")
    transactions = relationship("Transaction", back_populates="category")