from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from sqlalchemy import func, extract
from typing import List, Dict, Any, Optional
from datetime import datetime, date
from decimal import Decimal
from ...models.transaction import Transaction
from ...models.category import Category, CategoryType
from ...models.user import User
from ...utils.database import get_db
from ...utils.auth import get_current_user

router = APIRouter()

@router.get("/summary")
def get_financial_summary(
    start_date: Optional[date] = None,
    end_date: Optional[date] = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> Dict[str, Any]:
    query = db.query(Transaction).join(Category).filter(
        Transaction.user_id == current_user.id
    )

    if start_date:
        query = query.filter(func.date(Transaction.transaction_date) >= start_date)
    if end_date:
        query = query.filter(func.date(Transaction.transaction_date) <= end_date)

    # Calculate total income and expenses
    income = query.filter(Category.type == CategoryType.INCOME).with_entities(
        func.coalesce(func.sum(Transaction.amount), 0)
    ).scalar() or Decimal('0')

    expenses = query.filter(Category.type == CategoryType.EXPENSE).with_entities(
        func.coalesce(func.sum(Transaction.amount), 0)
    ).scalar() or Decimal('0')

    balance = income - expenses

    return {
        "total_income": float(income),
        "total_expenses": float(expenses),
        "balance": float(balance),
        "period": {
            "start_date": start_date,
            "end_date": end_date
        }
    }

@router.get("/spending-by-category")
def get_spending_by_category(
    start_date: Optional[date] = None,
    end_date: Optional[date] = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> List[Dict[str, Any]]:
    query = db.query(
        Category.name,
        Category.color,
        func.sum(Transaction.amount).label('total')
    ).join(Transaction).filter(
        Transaction.user_id == current_user.id,
        Category.type == CategoryType.EXPENSE
    )

    if start_date:
        query = query.filter(func.date(Transaction.transaction_date) >= start_date)
    if end_date:
        query = query.filter(func.date(Transaction.transaction_date) <= end_date)

    results = query.group_by(Category.id, Category.name, Category.color).all()

    return [
        {
            "category": result.name,
            "color": result.color,
            "amount": float(result.total),
            "percentage": 0  # Will be calculated on frontend
        }
        for result in results
    ]

@router.get("/monthly-trends")
def get_monthly_trends(
    year: int = Query(..., description="Year to analyze"),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> Dict[str, List[Dict[str, Any]]]:
    query = db.query(
        extract('month', Transaction.transaction_date).label('month'),
        Category.type,
        func.sum(Transaction.amount).label('total')
    ).join(Category).filter(
        Transaction.user_id == current_user.id,
        extract('year', Transaction.transaction_date) == year
    ).group_by(
        extract('month', Transaction.transaction_date),
        Category.type
    ).order_by('month')

    results = query.all()

    # Initialize monthly data
    monthly_data = {
        "income": [{"month": i, "amount": 0} for i in range(1, 13)],
        "expenses": [{"month": i, "amount": 0} for i in range(1, 13)]
    }

    # Fill in actual data
    for result in results:
        month_idx = int(result.month) - 1
        if result.type == CategoryType.INCOME:
            monthly_data["income"][month_idx]["amount"] = float(result.total)
        else:
            monthly_data["expenses"][month_idx]["amount"] = float(result.total)

    return monthly_data

@router.get("/recent-transactions")
def get_recent_transactions(
    limit: int = Query(10, ge=1, le=50),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> List[Dict[str, Any]]:
    transactions = db.query(Transaction).join(Category).filter(
        Transaction.user_id == current_user.id
    ).order_by(Transaction.transaction_date.desc()).limit(limit).all()

    return [
        {
            "id": t.id,
            "amount": float(t.amount),
            "description": t.description,
            "transaction_date": t.transaction_date.isoformat(),
            "category": {
                "name": t.category.name,
                "type": t.category.type.value,
                "color": t.category.color
            }
        }
        for t in transactions
    ]